import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

const String AUDIO_DIR = 'assets/data/audio';
const String TIMESTAMPS_DIR = 'assets/data/timestamps';

void main() async {
  // Create the timestamps directory if it doesn't exist
  final Directory timestampsDir = Directory(TIMESTAMPS_DIR);
  if (!await timestampsDir.exists()) {
    await timestampsDir.create(recursive: true);
  }

  // Generate sample timestamps for The Tiny Dragon audio files
  await generateSampleTimestamps('the-tiny-dragon_ar_male.mp3');
  await generateSampleTimestamps('the-tiny-dragon_ar_female.mp3');
  
  print('Sample timestamp generation completed!');
}

Future<void> generateSampleTimestamps(String audioFilename) async {
  final File audioFile = File(path.join(AUDIO_DIR, audioFilename));
  if (!await audioFile.exists()) {
    print('Audio file not found: ${audioFile.path}');
    return;
  }

  print('Generating sample timestamps for: ${audioFile.path}');
  
  // Create the output JSON filename
  final String outputFilename = '${path.basenameWithoutExtension(audioFilename)}_timestamps.json';
  final File outputFile = File(path.join(TIMESTAMPS_DIR, outputFilename));
  
  try {
    // Generate sample word timestamps
    final Map<String, dynamic> sampleTimestamps = generateSampleData(audioFilename);
    
    // Save the timestamps to a JSON file
    await outputFile.writeAsString(jsonEncode(sampleTimestamps));
    print('Sample timestamps saved to: ${outputFile.path}');
  } catch (e) {
    print('Error generating sample timestamps: $e');
  }
}

Map<String, dynamic> generateSampleData(String audioFilename) {
  // Arabic sample text for The Tiny Dragon
  final String arText = "هناك تنينٌ صغير يعيش مع عائلته في كهف عالٍ بين الجبال. حاول مراراً ان ينفث النار مثل والديه. لكنه لم ينجح سوى في اخراج الدخان رماديهٍ خفيف. شعر بالحزن والاحباط. لكنه لم يستسلم. في كل صباح. كان يقف امام البحيرة ويتدرم. يوماً بعد يوم اصبح الدخان اكثف واتفأ. وفي صباحٍ مشرق. وبينما كان يحاول للمرة الاولى خرج من فمه لهب ذهب صغير. فرحت تنين الصغير وطار حول الكهف فخوراً بنفسه. وعلم ان الشجاعة الحقيقية تكمن في المثابرة.";
  
  // Split into words
  final List<String> words = arText
      .replaceAll('\n', ' ')
      .split(' ')
      .where((word) => word.isNotEmpty)
      .toList();
  
  // Use fixed timestamps based on audio duration
  // For male voice recording, total duration is about 38.5 seconds
  final double totalDuration = audioFilename.contains('male') ? 38.5 : 38.2; // seconds
  
  // Give a bit more precision to the first 10 words to ensure they highlight properly
  final List<Map<String, dynamic>> wordTimestamps = [];
  double currentTime = 0.0;
  
  // Calculate times with more precision for beginning words
  for (int i = 0; i < words.length; i++) {
    final word = words[i];
    double wordDuration;
    
    if (i < 10) {
      // Give shorter, more precise durations to the first 10 words
      wordDuration = 0.3; // 300ms per word at the beginning
    } else {
      // Distribute the remaining time evenly among the rest of the words
      final remainingWords = words.length - 10;
      final remainingTime = totalDuration - (10 * 0.3);
      wordDuration = remainingTime / remainingWords;
    }
    
    wordTimestamps.add({
      'word': word,
      'start': currentTime,
      'end': currentTime + wordDuration,
    });
    
    currentTime += wordDuration;
  }
  
  return {
    'text': arText,
    'words': wordTimestamps,
    'language': 'arabic',
  };
} 