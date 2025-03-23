import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../domain/story/word_timestamp.dart';
import '../core/app_export.dart';
import 'dart:math' as Math;

class TextHighlightingService {
  // Singleton instance
  static final TextHighlightingService _instance = TextHighlightingService._internal();
  
  // Factory constructor to return the singleton instance
  factory TextHighlightingService() => _instance;
  
  // Private constructor
  TextHighlightingService._internal();
  
  // Current highlighted word index
  int _currentHighlightIndex = 0;
  
  // Current word index map
  List<Map<String, dynamic>> _wordIndexMap = [];
  
  // Getter for word index map
  List<Map<String, dynamic>> get wordIndexMap => _wordIndexMap;
  
  // Set word index map
  void setWordIndexMap(List<Map<String, dynamic>> indexMap) {
    _wordIndexMap = indexMap;
  }
  
  // Get current index
  int getCurrentIndex() => _currentHighlightIndex;
  
  // Set current index
  void setCurrentIndex(int index) {
    _currentHighlightIndex = index;
  }
  
  // Reset current index
  void resetCurrentIndex() {
    _currentHighlightIndex = 0;
  }
  
  /// Build highlighted text paragraphs with rich text formatting
  List<Widget> buildHighlightedTextParagraphs(
    String content, 
    TextDirection direction, 
    String? highlightedWord,
    bool isArabic, 
    Function(String) onWordTap
  ) {
    // Split content into paragraphs
    final paragraphs = content.split('\n');
    
    return paragraphs.map((paragraph) {
      if (paragraph.trim().isEmpty) {
        return SizedBox(height: 16.h);
      }
      
      // Split paragraph into words
      final words = paragraph.split(' ');
      
      return Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Directionality(
          textDirection: direction,
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 16.fSize,
                fontWeight: FontWeight.w500,
                height: 1.5,
                color: Color(0xFF37251F),
              ),
              children: words.map((word) {
                // Check if this word should be highlighted by exact matching
                final isHighlighted = word == highlightedWord;
                
                return TextSpan(
                  text: '$word ',
                  style: TextStyle(
                    color: isHighlighted
                        ? Color(0xFFFF6F3E)
                        : Color(0xFF37251F),
                    backgroundColor: isHighlighted
                        ? Color(0xFFFFEBE5)
                        : null,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => onWordTap(word),
                );
              }).toList(),
            ),
          ),
        ),
      );
    }).toList();
  }
  
  /// Extract ordered array of words from content
  List<String> extractWordsArray(String content) {
    return content
        .replaceAll('\n', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .toList();
  }
  
  /// Get word at specific index in the array
  String? getWordAtIndex(List<String> words, int index) {
    if (index >= 0 && index < words.length) {
      return words[index];
    }
    return null;
  }
  
  /// Map timestamps to word indices to ensure all words are highlighted
  List<Map<String, dynamic>> createWordIndexMap(
    WordTimestampCollection? wordTimestamps,
    List<String> contentWords
  ) {
    List<Map<String, dynamic>> indexMap = [];
    
    if (wordTimestamps == null || wordTimestamps.words.isEmpty) {
      // If no timestamps, create simple evenly spaced timestamps
      double startTime = 0.0;
      double increment = 0.5; // Half a second per word as default
      
      for (int i = 0; i < contentWords.length; i++) {
        final endTime = startTime + increment;
        indexMap.add({
          'index': i,
          'word': contentWords[i],
          'start': startTime,
          'end': endTime,
          'visualStart': i == 0 ? 0.0 : startTime - 0.1,
        });
        startTime = endTime;
      }
      return indexMap;
    }
    
    // Direct word-by-word matching using normalized comparison
    
    // Extract raw words from timestamps for matching
    List<String> timestampWords = wordTimestamps.words.map((tw) => tw.word).toList();
    
    // Initialize index for tracking our position in both arrays
    int contentIndex = 0;
    
    // First pass: Try to match timestamp words to content words directly
    for (int i = 0; i < wordTimestamps.words.length && contentIndex < contentWords.length; i++) {
      final timestampWord = wordTimestamps.words[i];
      
      // Try to find a match for this timestamp word in upcoming content words
      // Allow looking ahead up to 3 words to handle small variations
      int matchIndex = _findBestWordMatch(
        timestampWord.word, 
        contentWords, 
        contentIndex, 
        5  // Look ahead up to 5 words
      );
      
      if (matchIndex >= 0) {
        // Found a direct match - first fill in any skipped words
        if (matchIndex > contentIndex) {
          // Calculate how to distribute time for skipped words
          double timeToDistribute = timestampWord.start - 
              (indexMap.isEmpty ? 0.0 : (indexMap.last['end'] as num).toDouble());
          
          // If this is valid time to distribute
          if (timeToDistribute > 0) {
            double timePerWord = timeToDistribute / (matchIndex - contentIndex);
            double currentTime = indexMap.isEmpty ? 
                0.0 : (indexMap.last['end'] as num).toDouble();
            
            // Add entries for skipped words with estimated timing
            for (int j = contentIndex; j < matchIndex; j++) {
              double wordStart = currentTime;
              double wordEnd = wordStart + timePerWord;
              
              indexMap.add({
                'index': j,
                'word': contentWords[j],
                'start': wordStart,
                'end': wordEnd,
                'matched': false,  // Mark as estimated
              });
              
              currentTime = wordEnd;
            }
          } else {
            // If we have invalid time (negative), just use tiny increments
            double currentTime = indexMap.isEmpty ? 
                0.0 : (indexMap.last['end'] as num).toDouble();
            
            for (int j = contentIndex; j < matchIndex; j++) {
              double wordStart = currentTime;
              double wordEnd = wordStart + 0.1;  // Small increment
              
              indexMap.add({
                'index': j,
                'word': contentWords[j],
                'start': wordStart,
                'end': wordEnd,
                'matched': false,
              });
              
              currentTime = wordEnd;
            }
          }
        }
        
        // Now add the matched word with its exact timestamp
        indexMap.add({
          'index': matchIndex,
          'word': contentWords[matchIndex],
          'start': timestampWord.start,
          'end': timestampWord.end,
          'matched': true,
        });
        
        // Update content index to continue after this match
        contentIndex = matchIndex + 1;
      } else {
        // No match found - try simple sequential assignment
        if (contentIndex < contentWords.length) {
          indexMap.add({
            'index': contentIndex,
            'word': contentWords[contentIndex],
            'start': timestampWord.start,
            'end': timestampWord.end,
            'matched': false,
          });
          
          contentIndex++;
        }
      }
    }
    
    // Handle any remaining content words
    if (contentIndex < contentWords.length) {
      // Calculate average duration for remaining words
      double avgDuration = 0.25;  // Default fallback
      if (indexMap.isNotEmpty) {
        double totalDuration = 0;
        for (var item in indexMap.where((item) => item['matched'] == true)) {
          totalDuration += (item['end'] as num).toDouble() - (item['start'] as num).toDouble();
        }
        
        // Use matched words for better average, or all words if needed
        int matchedCount = indexMap.where((item) => item['matched'] == true).length;
        avgDuration = matchedCount > 0
            ? totalDuration / matchedCount
            : totalDuration / indexMap.length;
      }
      
      // If average is too small, use reasonable minimum
      avgDuration = Math.max(avgDuration, 0.2);
      
      // Start time for remaining words
      double startTime = indexMap.isNotEmpty
          ? (indexMap.last['end'] as num).toDouble()
          : 0.0;
      
      // Add remaining words with estimated timestamps
      for (int i = contentIndex; i < contentWords.length; i++) {
        double wordEnd = startTime + avgDuration;
        
        indexMap.add({
          'index': i,
          'word': contentWords[i],
          'start': startTime,
          'end': wordEnd,
          'matched': false,
        });
        
        startTime = wordEnd;
      }
    }
    
    // Ensure timing is continuous and valid
    for (int i = 0; i < indexMap.length - 1; i++) {
      final currentWord = indexMap[i];
      final nextWord = indexMap[i + 1];
      
      // Ensure values are doubles
      final currentStart = (currentWord['start'] as num).toDouble();
      final currentEnd = (currentWord['end'] as num).toDouble();
      final nextStart = (nextWord['start'] as num).toDouble();
      
      // Fix any invalid timing
      if (currentStart >= currentEnd) {
        currentWord['end'] = currentStart + 0.1;
      }
      
      // Fix overlaps
      if (currentEnd > nextStart) {
        currentWord['end'] = nextStart;
      }
      
      // Fix gaps for continuous highlighting
      if (currentEnd < nextStart) {
        nextWord['start'] = currentEnd;
      }
      
      // Add visual start time for pre-highlighting
      nextWord['visualStart'] = Math.max(0.0, (nextWord['start'] as num).toDouble() - 0.1);
    }
    
    // Make sure first word is always highlighted from the beginning
    if (indexMap.isNotEmpty) {
      indexMap.first['visualStart'] = 0.0;
    }
    
    return indexMap;
  }
  
  /// Find highlighted word at current position using sequential approach
  String? findHighlightedWordAtSequentialPosition(
    WordTimestampCollection? wordTimestamps,
    Duration position,
    String currentLanguage,
    List<String> arabicWords,
    List<String> englishWords,
    int currentWordIndex,
    double msPerWord
  ) {
    // Convert position to seconds for precise time comparison
    // Add a much larger look-ahead offset to match our extremely aggressive main method
    final lookAheadOffset = 0.6; // 600ms for very aggressive precision
    final positionInSeconds = position.inMilliseconds / 1000.0 + lookAheadOffset;
    
    // Get the current word list based on language
    final List<String> currentWords = currentLanguage == 'ar' ? arabicWords : englishWords;
    
    // If no words, return null
    if (currentWords.isEmpty) {
      return null;
    }
    
    // At beginning of playback, always highlight first word
    if (position.inMilliseconds < 100) {
      _currentHighlightIndex = 0;
      final firstWord = getWordAtIndex(currentWords, 0);
      if (firstWord != null) {
        return firstWord;
      }
    }
    
    // Use timestamp data to determine which word to highlight
    if (wordTimestamps != null && wordTimestamps.words.isNotEmpty) {
      // Create a map between indices and timestamps - this only needs to be done once
      final indexMap = createWordIndexMap(wordTimestamps, currentWords);
      
      // Store the index map for direct position lookup
      setWordIndexMap(indexMap);
      
      // DIRECT APPROACH: Find exactly which word should be highlighted at this specific time
      // This ensures we always highlight the correct word regardless of our current index
      for (int i = 0; i < indexMap.length; i++) {
        final wordData = indexMap[i];
        final start = wordData['start'] as double;
        final end = wordData['end'] as double;
        
        // If position is exactly within this word's time range
        if (positionInSeconds >= start && positionInSeconds < end) {
          // Only update index if changed
          if (_currentHighlightIndex != i) {
            _currentHighlightIndex = i;
          }
          
          final word = wordData['word'] as String;
          return word;
        }
      }
      
      // If we didn't find a match, check if we should anticipate the next word
      if (_currentHighlightIndex < indexMap.length - 1) {
        final currentWordData = indexMap[_currentHighlightIndex];
        final nextWordData = indexMap[_currentHighlightIndex + 1];
        
        // Use safer conversion for timestamp values
        final currentEnd = currentWordData['end'] is int ? 
            (currentWordData['end'] as int).toDouble() : currentWordData['end'] as double;
        final nextStart = nextWordData['start'] is int ? 
            (nextWordData['start'] as int).toDouble() : nextWordData['start'] as double;
        
        // Very aggressively anticipate the next word - 250ms ahead of the end
        // This ensures extremely smooth transitions between words
        if (positionInSeconds >= currentEnd - 0.25) {
          _currentHighlightIndex++;
          final word = indexMap[_currentHighlightIndex]['word'] as String;
          return word;
        }
      }
      
      // If we're past the last word's end time, use the last word
      if (indexMap.isNotEmpty) {
        final lastEndRaw = indexMap.last['end'];
        final lastEnd = lastEndRaw is int ? (lastEndRaw as int).toDouble() : lastEndRaw as double;
        
        if (positionInSeconds >= lastEnd) {
          _currentHighlightIndex = indexMap.length - 1;
          final lastWord = indexMap.last['word'] as String;
          return lastWord;
        }
      }
      
      // If we're before the first word's start time, use the first word
      if (indexMap.isNotEmpty) {
        final firstStartRaw = indexMap.first['start'];
        final firstStart = firstStartRaw is int ? (firstStartRaw as int).toDouble() : firstStartRaw as double;
        
        if (positionInSeconds < firstStart) {
          _currentHighlightIndex = 0;
          final firstWord = indexMap.first['word'] as String;
          return firstWord;
        }
      }
      
      // If nothing else matched, return the word at current index
      if (_currentHighlightIndex >= 0 && _currentHighlightIndex < indexMap.length) {
        final wordData = indexMap[_currentHighlightIndex];
        final word = wordData['word'] as String;
        return word;
      }
      
      // If the current index is somehow invalid but we have words,
      // return the first word to ensure something is highlighted
      if (indexMap.isNotEmpty) {
        _currentHighlightIndex = 0;
        return indexMap.first['word'] as String;
      }
    } else {
      // Fallback to the time-based estimation method if no timestamps
      if (msPerWord <= 0) {
        return null;
      }
      
      // Calculate which word should be highlighted based on elapsed time
      int wordIndex = (position.inMilliseconds / msPerWord).floor();
      
      // Ensure index is valid
      if (wordIndex < 0) wordIndex = 0;
      if (wordIndex >= currentWords.length) wordIndex = currentWords.length - 1;
      
      _currentHighlightIndex = wordIndex;
      final word = currentWords[wordIndex];
      return word;
    }
    
    // If all else fails (should never happen), return the word at the current index if valid
    if (_currentHighlightIndex >= 0 && _currentHighlightIndex < currentWords.length) {
      return currentWords[_currentHighlightIndex];
    }
    
    return null;
  }

  int findHighlightedWordAtPosition(Duration position) {
    if (wordIndexMap.isEmpty) {
      return -1;
    }

    // For very early positions, always return the first word
    if (position.inMilliseconds < 100) {
      _currentHighlightIndex = 0;
      return 0;  // Return first word index
    }

    // Convert position to seconds for precise comparison
    final positionInSeconds = position.inMilliseconds / 1000.0;
    
    // Increase look-ahead timing to compensate for audio processing and rendering delays
    final adjustedPosition = positionInSeconds + 0.75; // 750ms look-ahead
    
    // Step 1: First check if we're still within the current word's time range
    // This prevents unnecessary jumping between words and provides stability
    if (_currentHighlightIndex >= 0 && _currentHighlightIndex < wordIndexMap.length) {
      final currentWord = wordIndexMap[_currentHighlightIndex];
      final wordStart = (currentWord['visualStart'] ?? currentWord['start'] as num).toDouble();
      final wordEnd = (currentWord['end'] as num).toDouble();
      
      // If we're still within the current word's time range, keep highlighting it
      if (wordStart <= adjustedPosition && adjustedPosition < wordEnd) {
        return _currentHighlightIndex;
      }
      
      // Check if we should move to the next word
      if (_currentHighlightIndex < wordIndexMap.length - 1 && adjustedPosition >= wordEnd) {
        final nextWord = wordIndexMap[_currentHighlightIndex + 1];
        final nextStart = (nextWord['visualStart'] ?? nextWord['start'] as num).toDouble();
        
        // If we're within the early transition window, move to the next word
        if (adjustedPosition >= wordEnd && adjustedPosition < nextStart &&
            (nextStart - adjustedPosition) <= 0.3) { // 300ms early transition
          _currentHighlightIndex += 1;
          return _currentHighlightIndex;
        }
      }
    }
    
    // Step 2: If we're not within the current word or we need to move,
    // find the word that should be highlighted at this exact time
    for (int i = 0; i < wordIndexMap.length; i++) {
      final word = wordIndexMap[i];
      final wordStart = (word['visualStart'] ?? word['start'] as num).toDouble();
      final wordEnd = (word['end'] as num).toDouble();
      
      // If this position is within this word's time range, this is our word
      if (wordStart <= adjustedPosition && adjustedPosition < wordEnd) {
        _currentHighlightIndex = i;
        return i;
      }
    }

    // Step 3: Handle special cases like being before the first word or after the last word
    
    // Case: Position is before the first word
    if (wordIndexMap.isNotEmpty) {
      final firstStart = (wordIndexMap.first['visualStart'] ?? 
          wordIndexMap.first['start'] as num).toDouble();
      
      if (adjustedPosition < firstStart) {
        _currentHighlightIndex = 0;
        return 0; // Always highlight the first word even before its start
      }
    }
    
    // Case: Position is past the last word
    if (wordIndexMap.isNotEmpty) {
      final lastEnd = (wordIndexMap.last['end'] as num).toDouble();
      
      if (adjustedPosition >= lastEnd) {
        _currentHighlightIndex = wordIndexMap.length - 1;
        return wordIndexMap.length - 1; // Keep highlighting the last word
      }
    }
    
    // Step 4: Find the word in a gap between two words
    for (int i = 0; i < wordIndexMap.length - 1; i++) {
      final currentEnd = (wordIndexMap[i]['end'] as num).toDouble();
      final nextStart = (wordIndexMap[i + 1]['visualStart'] ?? 
          wordIndexMap[i + 1]['start'] as num).toDouble();
      
      if (adjustedPosition >= currentEnd && adjustedPosition < nextStart) {
        // When in a gap, ALWAYS move to the next word to prevent skipping
        _currentHighlightIndex = i + 1;
        return i + 1;
      }
    }

    // Step 5: Fallback to binary search if no direct match was found
    int result = _findWordIndexBinarySearch(adjustedPosition);
    _currentHighlightIndex = result;
    return result;
  }

  // Binary search fallback for finding the appropriate word index
  int _findWordIndexBinarySearch(double positionInSeconds) {
    int low = 0;
    int high = wordIndexMap.length - 1;
    
    while (low <= high) {
      int mid = (low + high) ~/ 2;
      final word = wordIndexMap[mid];
      
      final wordStartRaw = word['visualStart'] ?? word['start'];
      final wordStart = wordStartRaw is int ? (wordStartRaw as int).toDouble() : wordStartRaw as double;
      
      final wordEndRaw = word['end'];
      final wordEnd = wordEndRaw is int ? (wordEndRaw as int).toDouble() : wordEndRaw as double;
      
      if (positionInSeconds < wordStart) {
        high = mid - 1;
      } else if (positionInSeconds >= wordEnd) {
        low = mid + 1;
      } else {
        // Found the word that contains this position
        return mid;
      }
    }
    
    // If not found within a word's range, return the closest upcoming word
    // or the last word if we're past the end
    if (low >= wordIndexMap.length) {
      return wordIndexMap.length - 1;
    }
    return low;
  }

  /// Utility method to normalize words for better matching
  String _normalizeWord(String word) {
    // Convert to lowercase, trim whitespace, remove punctuation, normalize spaces
    return word
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[.،!?,;:"()،]'), '') // Include Arabic comma
        .replaceAll(RegExp(r'\s+'), ' ');  // Normalize spaces
  }
  
  /// Check if two words match after normalization
  bool _wordsMatch(String word1, String word2) {
    final normalized1 = _normalizeWord(word1);
    final normalized2 = _normalizeWord(word2);
    return normalized1 == normalized2;
  }
  
  /// Find the best match for a word in a list of candidate words
  int _findBestWordMatch(String word, List<String> candidates, int startIndex, int maxLookAhead) {
    // First try exact match
    for (int i = startIndex; i < Math.min(startIndex + maxLookAhead, candidates.length); i++) {
      if (_wordsMatch(word, candidates[i])) {
        return i;  // Found exact match
      }
    }
    
    // If no exact match, try to find the closest match
    // This helps with slight variations in spelling or punctuation
    return -1;  // No match found
  }
} 