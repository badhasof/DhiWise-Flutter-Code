import 'package:flutter/foundation.dart';
import '../domain/story/word_timestamp.dart';

class TimestampService {
  // Singleton instance
  static final TimestampService _instance = TimestampService._internal();
  
  // Factory constructor to return the singleton instance
  factory TimestampService() => _instance;
  
  // Private constructor
  TimestampService._internal();
  
  // Cache for loaded timestamp collections
  final Map<String, WordTimestampCollection> _timestampCache = {};
  
  /// Get the asset path for a timestamp file based on the audio path
  String getTimestampPath(String audioPath) {
    if (audioPath.isEmpty) return '';
    
    // Extract file name without extension
    String fileName = audioPath.split('/').last.split('.').first;
    
    // Handle paths that might already include 'assets/'
    if (audioPath.startsWith('assets/')) {
      audioPath = audioPath.substring(7); // Remove 'assets/' prefix
    }
    
    // Check if this is a dialect-specific audio file
    bool isDialectSpecific = false;
    String dialectCode = '';
    
    // Check for Egyptian dialect
    if (audioPath.contains('egyptian')) {
      isDialectSpecific = true;
      dialectCode = 'egyptian';
    } 
    // Check for Jordanian dialect
    else if (audioPath.contains('jordanian')) {
      isDialectSpecific = true;
      dialectCode = 'jordanian';
    } 
    // Check for Moroccan dialect
    else if (audioPath.contains('moroccan')) {
      isDialectSpecific = true;
      dialectCode = 'moroccan';
    }
    
    // Build the timestamp path
    String path;
    if (isDialectSpecific) {
      // For dialect-specific files, ensure we use the correct filename pattern
      path = 'assets/data/timestamps/${dialectCode}/${fileName}_timestamps.json';
    } else {
      // Standard MSA path
      path = 'assets/data/timestamps/${fileName}_timestamps.json';
    }
    
    debugPrint('Timestamp path for $audioPath: $path');
    return path;
  }
  
  /// Load word timestamps for an audio file
  Future<WordTimestampCollection?> loadTimestamps(String audioPath) async {
    if (audioPath.isEmpty) return null;
    
    debugPrint('Loading timestamps for audio: $audioPath');
    final timestampPath = getTimestampPath(audioPath);
    
    // Check if timestamps are already cached
    if (_timestampCache.containsKey(timestampPath)) {
      debugPrint('Returning cached timestamps for $audioPath');
      return _timestampCache[timestampPath];
    }
    
    // For dialect-specific files, if we don't find timestamps in the dialect-specific directory,
    // try to use the standard naming convention as a fallback
    String fallbackPath = '';
    if (timestampPath.contains('/egyptian/') || 
        timestampPath.contains('/jordanian/') || 
        timestampPath.contains('/moroccan/')) {
      
      // Extract the filename
      String fileName = audioPath.split('/').last.split('.').first;
      
      // If it's a dialect-specific audio file (like "something_egyptian_male.mp3")
      // Convert to standard format (like "something_ar_male_timestamps.json")
      String standardFileName = fileName;
      
      // Replace dialect markers with "ar"
      standardFileName = standardFileName.replaceAll('_egyptian_', '_ar_')
                                         .replaceAll('_jordanian_', '_ar_')
                                         .replaceAll('_moroccan_', '_ar_')
                                         .replaceAll('_nonfiction_', '_');
      
      // Create the fallback path
      fallbackPath = 'assets/data/timestamps/${standardFileName}_timestamps.json';
      debugPrint('Created fallback timestamp path: $fallbackPath');
    }
    
    try {
      // First try to load from the primary path
      debugPrint('Attempting to load timestamps from: $timestampPath');
      var timestamps = await WordTimestampCollection.loadFromAsset(timestampPath);
      
      // If primary path doesn't work and we have a fallback, try that
      if (timestamps == null && fallbackPath.isNotEmpty) {
        debugPrint('Primary path failed, trying fallback path: $fallbackPath');
        timestamps = await WordTimestampCollection.loadFromAsset(fallbackPath);
      }
      
      // Cache the timestamps if we found them
      if (timestamps != null) {
        debugPrint('Successfully loaded timestamps for $audioPath with ${timestamps.words.length} words');
        _timestampCache[timestampPath] = timestamps;
        
        // Validate timestamps for completeness and order
        _validateTimestamps(timestamps);
        
        // Add missing timestamps if needed to ensure all words have timing
        _ensureCompleteTimestamps(timestamps);
      } else {
        debugPrint('Failed to load timestamps for $audioPath - file may not exist');
      }
      
      return timestamps;
    } catch (e) {
      debugPrint('Error loading timestamps for $audioPath: $e');
      return null;
    }
  }
  
  /// Validate timestamps for completeness and proper ordering
  void _validateTimestamps(WordTimestampCollection timestamps) {
    if (timestamps.words.isEmpty) {
      debugPrint('⚠️ Warning: Timestamp collection has no words');
      return;
    }
    
    // Check for proper time ordering
    for (int i = 0; i < timestamps.words.length - 1; i++) {
      final currentWord = timestamps.words[i];
      final nextWord = timestamps.words[i + 1];
      
      // Check that end time is not after start time
      if (currentWord.end < currentWord.start) {
        debugPrint('⚠️ Warning: Word "${currentWord.word}" has end time before start time');
      }
      
      // Check that words don't overlap
      if (currentWord.end > nextWord.start) {
        debugPrint('⚠️ Warning: Word "${currentWord.word}" overlaps with next word "${nextWord.word}"');
      }
      
      // Check for gaps between words
      if (nextWord.start - currentWord.end > 1.0) { // Gap larger than 1 second
        debugPrint('⚠️ Warning: Large gap (${(nextWord.start - currentWord.end).toStringAsFixed(2)}s) between words "${currentWord.word}" and "${nextWord.word}"');
      }
    }
    
    debugPrint('✅ Timestamp validation complete for ${timestamps.words.length} words');
  }
  
  /// Ensure all words have timestamps by adding estimated ones if needed
  void _ensureCompleteTimestamps(WordTimestampCollection timestamps) {
    if (timestamps.words.isEmpty) return;
    
    // Extract all words from the text to compare with timestamp words
    final String fullText = timestamps.text;
    final List<String> allWords = fullText
        .replaceAll('\n', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .toList();
    
    debugPrint('Text has ${allWords.length} words, timestamps has ${timestamps.words.length} words');
    
    // If we have fewer timestamp words than actual words, it means some words are missing timestamps
    if (allWords.length > timestamps.words.length) {
      debugPrint('⚠️ Warning: ${allWords.length - timestamps.words.length} words are missing timestamps');
      
      // Calculate average word duration from existing timestamps
      double totalDuration = 0;
      for (var word in timestamps.words) {
        totalDuration += (word.end - word.start);
      }
      final double avgWordDuration = totalDuration / timestamps.words.length;
      
      debugPrint('Average word duration: ${avgWordDuration.toStringAsFixed(3)}s');
      
      // Create a list of words that don't have timestamps yet
      List<String> wordsWithoutTimestamps = List.from(allWords);
      
      // Remove words that already have timestamps
      for (var timestampWord in timestamps.words) {
        wordsWithoutTimestamps.removeWhere((word) => 
          word == timestampWord.word || 
          word.trim() == timestampWord.word.trim()
        );
      }
      
      // If we still have words without timestamps, add them with estimated times
      if (wordsWithoutTimestamps.isNotEmpty) {
        debugPrint('Adding estimated timestamps for ${wordsWithoutTimestamps.length} words');
        
        // Start after the last known timestamp
        double currentTime = timestamps.words.isNotEmpty 
            ? timestamps.words.last.end 
            : 0.0;
        
        // Add missing words with estimated timestamps
        for (var word in wordsWithoutTimestamps) {
          final newTimestamp = WordTimestamp(
            word: word,
            start: currentTime,
            end: currentTime + avgWordDuration
          );
          
          timestamps.words.add(newTimestamp);
          currentTime += avgWordDuration;
        }
        
        // Sort to ensure all words are in time order
        timestamps.words.sort((a, b) => a.start.compareTo(b.start));
        
        debugPrint('Updated timestamp collection now has ${timestamps.words.length} words');
      }
    }
  }
  
  /// Find the word that should be highlighted at the current position
  WordTimestamp? findWordAtPosition(String audioPath, Duration position) {
    if (audioPath.isEmpty) return null;
    
    final timestampPath = getTimestampPath(audioPath);
    
    // Check if timestamps are cached
    if (_timestampCache.containsKey(timestampPath)) {
      final word = _timestampCache[timestampPath]?.findWordAtPosition(position);
      if (word != null) {
        debugPrint('Found word at ${position.inMilliseconds}ms: ${word.word}');
      }
      return word;
    }
    
    return null;
  }
  
  /// Get all words with their timestamps in order
  List<WordTimestamp> getOrderedWords(String audioPath) {
    if (audioPath.isEmpty) return [];
    
    final timestampPath = getTimestampPath(audioPath);
    
    // Check if timestamps are cached
    if (_timestampCache.containsKey(timestampPath)) {
      return _timestampCache[timestampPath]?.words ?? [];
    }
    
    return [];
  }
  
  /// Clear the timestamp cache
  void clearCache() {
    _timestampCache.clear();
  }
} 