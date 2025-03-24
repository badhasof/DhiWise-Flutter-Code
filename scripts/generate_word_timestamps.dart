import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

const String OPENAI_API_KEY = '';
const String AUDIO_DIR = 'assets/data/audio';
const String TIMESTAMPS_DIR = 'assets/data/timestamps';
const String STORIES_JSON_PATH = 'assets/msa_stories.json';

void main() async {
  // Create the timestamps directory if it doesn't exist
  final Directory timestampsDir = Directory(TIMESTAMPS_DIR);
  if (!await timestampsDir.exists()) {
    await timestampsDir.create(recursive: true);
  }

  // Read the stories JSON file
  final File storiesFile = File(STORIES_JSON_PATH);
  if (!await storiesFile.exists()) {
    print('Stories JSON file not found: ${storiesFile.path}');
    return;
  }

  final String storiesJson = await storiesFile.readAsString();
  final Map<String, dynamic> storiesData = jsonDecode(storiesJson);
  
  if (!storiesData.containsKey('stories') || storiesData['stories'].isEmpty) {
    print('No stories found in the JSON file');
    return;
  }
  
  final List<dynamic> stories = storiesData['stories'];
  print('Found ${stories.length} stories in the JSON file');
  
  // Process each story
  int processed = 0;
  for (int i = 0; i < stories.length; i++) {
    final story = stories[i];
    final String storyId = story['id'];
    
    // Skip if story has no audio
    if (!story.containsKey('audio_ar_male') || !story.containsKey('audio_ar_female')) {
      print('Skipping story $storyId: No audio files');
      continue;
    }
    
    // Skip if story already has timestamps
    if (story.containsKey('timestamps_ar_male') && story.containsKey('timestamps_ar_female')) {
      print('Skipping story $storyId: Already has timestamps');
      continue;
    }
    
    print('\nProcessing story [${i + 1}/${stories.length}]: ${story['title_en']} (${storyId})');
    
    // Process male audio if needed
    if (story.containsKey('audio_ar_male') && !story.containsKey('timestamps_ar_male')) {
      final String audioPath = story['audio_ar_male'];
      final String audioFilename = path.basename(audioPath);
      
      final String timestampFilename = '${path.basenameWithoutExtension(audioFilename)}_timestamps.json';
      final String timestampPath = 'data/timestamps/$timestampFilename';
      
      if (!await File(path.join('assets', timestampPath)).exists()) {
        print('Generating male timestamps for $storyId');
        await processAudio(audioFilename);
        processed++;
        
        // Add a delay to avoid rate limiting
        print('Waiting 5 seconds...');
        await Future.delayed(Duration(seconds: 5));
      }
      
      // Update the story with the timestamp path
      story['timestamps_ar_male'] = timestampPath;
      print('Updated story with male timestamp path: $timestampPath');
    }
    
    // Process female audio if needed
    if (story.containsKey('audio_ar_female') && !story.containsKey('timestamps_ar_female')) {
      final String audioPath = story['audio_ar_female'];
      final String audioFilename = path.basename(audioPath);
      
      final String timestampFilename = '${path.basenameWithoutExtension(audioFilename)}_timestamps.json';
      final String timestampPath = 'data/timestamps/$timestampFilename';
      
      if (!await File(path.join('assets', timestampPath)).exists()) {
        print('Generating female timestamps for $storyId');
        await processAudio(audioFilename);
        processed++;
        
        // Add a delay to avoid rate limiting
        if (i < stories.length - 1) {
          print('Waiting 10 seconds before next file...');
          await Future.delayed(Duration(seconds: 10));
        }
      }
      
      // Update the story with the timestamp path
      story['timestamps_ar_female'] = timestampPath;
      print('Updated story with female timestamp path: $timestampPath');
    }
    
    // Update the story in the stories array
    stories[i] = story;
    
    // Save the updated JSON after each story to avoid losing progress
    await storiesFile.writeAsString(jsonEncode(storiesData));
    print('Updated and saved stories JSON file');
  }
  
  print('\nTimestamp generation completed! Processed $processed new audio files.');
}

Future<void> processAudio(String audioFilename) async {
  final File audioFile = File(path.join(AUDIO_DIR, audioFilename));
  if (!await audioFile.exists()) {
    print('Audio file not found: ${audioFile.path}');
    return;
  }

  print('Processing audio file: ${audioFile.path}');
  
  // Create the output JSON filename
  final String outputFilename = '${path.basenameWithoutExtension(audioFilename)}_timestamps.json';
  final File outputFile = File(path.join(TIMESTAMPS_DIR, outputFilename));
  
  try {
    // Read the audio file as bytes
    final List<int> audioBytes = await audioFile.readAsBytes();
    
    // Call the OpenAI API to get timestamped transcription
    final Map<String, dynamic> timestamps = await getWordTimestamps(audioBytes, audioFilename);
    
    // Save the timestamps to a JSON file
    await outputFile.writeAsString(jsonEncode(timestamps));
    print('Timestamps saved to: ${outputFile.path}');
  } catch (e) {
    print('Error processing audio file: $e');
  }
}

Future<Map<String, dynamic>> getWordTimestamps(List<int> audioBytes, String filename) async {
  final Uri url = Uri.parse('https://api.openai.com/v1/audio/transcriptions');
  
  // Create a multipart request
  final request = http.MultipartRequest('POST', url);
  
  // Add the authorization header
  request.headers.addAll({
    'Authorization': 'Bearer $OPENAI_API_KEY',
  });
  
  // Add form fields
  request.fields.addAll({
    'model': 'whisper-1',
    'response_format': 'verbose_json',
    'timestamp_granularities[]': 'word',
    'language': 'ar', // Specify Arabic language for better results
  });
  
  // Add the audio file
  request.files.add(
    http.MultipartFile.fromBytes(
      'file',
      audioBytes,
      filename: filename,
    ),
  );
  
  print('Sending request to OpenAI API...');
  final http.StreamedResponse response = await request.send();
  
  if (response.statusCode == 200) {
    final String responseBody = await response.stream.bytesToString();
    final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
    
    // Extract what we need for the timestamp integration
    return {
      'text': jsonResponse['text'],
      'words': jsonResponse['words'],
      'language': jsonResponse['language'],
    };
  } else {
    final String errorBody = await response.stream.bytesToString();
    throw Exception('API Error: ${response.statusCode} - ${response.reasonPhrase}\n$errorBody');
  }
} 