import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

const String OPENAI_API_KEY = ''; // Replace with your actual API key
const String AUDIO_DIR = 'assets/data/audio';
const String TIMESTAMPS_DIR = 'assets/data/timestamps';

void main() async {
  // Create the timestamps directory if it doesn't exist
  final Directory timestampsDir = Directory(TIMESTAMPS_DIR);
  if (!await timestampsDir.exists()) {
    await timestampsDir.create(recursive: true);
  }

  // Process the Tiny Dragon audio files for testing
  await processAudio('the-tiny-dragon_ar_male.mp3');
  await processAudio('the-tiny-dragon_ar_female.mp3');
  
  print('Timestamp generation completed!');
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
    // Check if the file already exists to avoid unnecessary API calls
    if (await outputFile.exists()) {
      print('Timestamps already exist: ${outputFile.path}');
      return;
    }
    
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