import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class WordTimestamp {
  final String word;
  final double start;
  final double end;

  WordTimestamp({
    required this.word,
    required this.start,
    required this.end,
  });

  factory WordTimestamp.fromJson(Map<String, dynamic> json) {
    return WordTimestamp(
      word: json['word'] as String,
      start: (json['start'] as num).toDouble(),
      end: (json['end'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'start': start,
      'end': end,
    };
  }
}

class WordTimestampCollection {
  final String text;
  final List<WordTimestamp> words;
  final String language;

  WordTimestampCollection({
    required this.text,
    required this.words,
    required this.language,
  });

  factory WordTimestampCollection.fromJson(Map<String, dynamic> json) {
    debugPrint('Creating WordTimestampCollection from JSON: ${json.keys}');
    return WordTimestampCollection(
      text: json['text'] as String,
      words: (json['words'] as List<dynamic>)
          .map((wordJson) => WordTimestamp.fromJson(wordJson as Map<String, dynamic>))
          .toList(),
      language: json['language'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'words': words.map((word) => word.toJson()).toList(),
      'language': language,
    };
  }

  /// Find the word that should be highlighted at the current position
  /// This is kept for backward compatibility but our new service handles this directly
  WordTimestamp? findWordAtPosition(Duration position) {
    final positionInSeconds = position.inMilliseconds / 1000.0;
    
    // Special case for position zero or near zero - return the first word
    if (positionInSeconds < 0.1 && words.isNotEmpty) {
      debugPrint('📍 Position near zero (${positionInSeconds.toStringAsFixed(3)}s), highlighting first word: "${words[0].word}"');
      return words[0];
    }
    
    // Try to find the exact word at this position with strict boundaries
    for (final word in words) {
      if (positionInSeconds >= word.start && positionInSeconds < word.end) {
        debugPrint('📍 Found exact word at ${positionInSeconds.toStringAsFixed(3)}s: "${word.word}" (${word.start.toStringAsFixed(3)}-${word.end.toStringAsFixed(3)})');
        return word;
      }
    }
    
    // If position is before the first word's start time, return the first word
    if (words.isNotEmpty && positionInSeconds < words.first.start) {
      debugPrint('📍 Position (${positionInSeconds.toStringAsFixed(3)}s) before first word start time (${words.first.start.toStringAsFixed(3)}s), returning first word: "${words.first.word}"');
      return words.first;
    }
    
    // If we've passed the last word, return null
    if (words.isNotEmpty && positionInSeconds > words.last.end) {
      debugPrint('📍 Position (${positionInSeconds.toStringAsFixed(3)}s) after last word end time (${words.last.end.toStringAsFixed(3)}s)');
      return null;
    }
    
    // Find the closest word if we couldn't find an exact match
    if (words.isNotEmpty) {
      var closestWord = words.first;
      var minDistance = double.infinity;
      
      for (final word in words) {
        // Calculate distance to word center
        final wordCenter = (word.start + word.end) / 2;
        final distance = (positionInSeconds - wordCenter).abs();
        
        if (distance < minDistance) {
          minDistance = distance;
          closestWord = word;
        }
      }
      
      debugPrint('📍 No exact match found at ${positionInSeconds.toStringAsFixed(3)}s, using closest word: "${closestWord.word}"');
      return closestWord;
    }
    
    return null;
  }

  /// Load timestamps from assets
  static Future<WordTimestampCollection?> loadFromAsset(String assetPath) async {
    try {
      debugPrint('Attempting to load asset: $assetPath');
      final jsonString = await rootBundle.loadString(assetPath);
      debugPrint('Asset loaded, length: ${jsonString.length}');
      
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      debugPrint('JSON decoded, keys: ${jsonData.keys.join(', ')}');
      
      return WordTimestampCollection.fromJson(jsonData);
    } catch (e) {
      debugPrint('Error loading timestamps from asset: $e');
      return null;
    }
  }
} 