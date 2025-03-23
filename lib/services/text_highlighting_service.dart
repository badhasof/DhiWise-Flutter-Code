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
      
      // Split paragraph into normalized words for better matching
      final String normalizedParagraph = _normalizeFullText(paragraph);
      final words = normalizedParagraph.split(' ');
      
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
                // Check if this word should be highlighted using improved word matching logic
                final isHighlighted = highlightedWord != null && 
                                     _wordsMatch(word, highlightedWord);
                
                // Add debug logging for near-misses that might be helpful
                if (highlightedWord != null && 
                    word.length > 2 && 
                    !isHighlighted && 
                    _calculateWordSimilarity(_normalizeWord(word), _normalizeWord(highlightedWord)) > 0.6) {
                  debugPrint('Near miss highlighting: "$word" vs "$highlightedWord", '
                      'similarity: ${_calculateWordSimilarity(_normalizeWord(word), _normalizeWord(highlightedWord))}');
                }
                
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
    // First, normalize the content to ensure consistent processing
    String normalizedContent = _normalizeFullText(content);
    
    // Split the normalized content into words and filter out empty strings
    return normalizedContent
        .split(' ')
        .where((word) => word.isNotEmpty)
        .toList();
  }

  /// Normalize full text for consistent processing
  String _normalizeFullText(String text) {
    // Handle newlines, periods, and other punctuation consistently
    String normalized = text
        .replaceAll('\n', ' ')  // Replace newlines with spaces
        .replaceAll('.', ' . ') // Add spaces around periods
        .replaceAll('،', ' ، ') // Add spaces around Arabic commas
        .replaceAll('!', ' ! ') // Add spaces around exclamation marks
        .replaceAll('?', ' ? ') // Add spaces around question marks
        .replaceAll(':', ' : ') // Add spaces around colons
        .replaceAll('؛', ' ؛ ') // Add spaces around Arabic semicolons
        .replaceAll('"', ' " ') // Add spaces around quotes
        .replaceAll('(', ' ( ') // Add spaces around parentheses
        .replaceAll(')', ' ) ') // Add spaces around parentheses
        .replaceAll('-', ' - '); // Add spaces around hyphens
    
    // Replace multiple spaces with a single space
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    // Normalize Arabic characters
    normalized = _normalizeArabicChars(normalized);
    
    return normalized;
  }

  /// Normalize Arabic characters for consistent matching
  String _normalizeArabicChars(String text) {
    return text
        // Normalize Ya variations
        .replaceAll('ی', 'ي')  // Farsi Ya to Arabic Ya
        .replaceAll('ى', 'ي')  // Alif Maqsura to Ya
        
        // Normalize Alif variations
        .replaceAll('إ', 'ا')  // Alif with Hamza below to simple Alif
        .replaceAll('أ', 'ا')  // Alif with Hamza above to simple Alif
        .replaceAll('آ', 'ا')  // Alif with Madda above to simple Alif
        .replaceAll('ٱ', 'ا')  // Alif Wasla to simple Alif
        
        // Normalize other characters
        .replaceAll('ة', 'ه')  // Ta Marbuta to Ha
        .replaceAll('ؤ', 'و')  // Waw with Hamza above to Waw
        .replaceAll('ئ', 'ي')  // Ya with Hamza above to Ya
        
        // Normalize Ha variations
        .replaceAll('ھ', 'ه')  // Alternative Ha form to standard Ha
        
        // Normalize other potentially problematic characters
        .replaceAll('ـ', '')   // Tatweel (kashida) to nothing
        .replaceAll('٫', '.')  // Arabic decimal separator to period
        .replaceAll('،', ','); // Arabic comma to Latin comma
  }

  /// Utility method to normalize words for better matching
  String _normalizeWord(String word) {
    // First apply general Arabic character normalization
    String normalized = _normalizeArabicChars(word);
    
    // Then apply more aggressive normalization for word matching
    normalized = normalized
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[.،!?,;:"()،\-]'), '') // Remove punctuation
        .replaceAll(RegExp(r'\s+'), ' ');           // Normalize spaces
    
    return normalized;
  }
  
  /// Check if two words match after normalization
  bool _wordsMatch(String word1, String word2) {
    final normalized1 = _normalizeWord(word1);
    final normalized2 = _normalizeWord(word2);
    
    // Add debug logging for problematic words
    if (word1.length > 2 && word2.length > 2 && 
        normalized1 != normalized2 && 
        (_calculateWordSimilarity(normalized1, normalized2) > 0.7)) {
      debugPrint('Near miss match: "$word1" -> "$normalized1" vs "$word2" -> "$normalized2"');
    }
    
    // Check for exact match or very high similarity
    if (normalized1 == normalized2) {
      return true;
    }
    
    // If words are longer than 3 characters, also accept high similarity matches
    if (normalized1.length > 3 && normalized2.length > 3) {
      double similarity = _calculateWordSimilarity(normalized1, normalized2);
      if (similarity >= 0.8) { // 80% similarity threshold for longer words
        return true;
      }
    }
    
    return false;
  }

  /// Find the best match for a word in a list of candidate words
  int _findBestWordMatch(String word, List<String> candidates, int startIndex, int maxLookAhead) {
    final normalizedWord = _normalizeWord(word);
    
    // If the word is very short (like a, an, in, etc.), be more strict with matching
    bool isShortWord = normalizedWord.length <= 2;
    
    // First try exact normalized match - highest priority
    for (int i = startIndex; i < Math.min(startIndex + maxLookAhead, candidates.length); i++) {
      final normalizedCandidate = _normalizeWord(candidates[i]);
      
      if (normalizedWord == normalizedCandidate) {
        return i;  // Found exact normalized match
      }
    }
    
    // For short words (1-2 chars), we don't use fuzzy matching to avoid false positives
    if (isShortWord) {
      return -1;
    }
    
    // If no exact match, try for high similarity partial matches
    int bestMatchIndex = -1;
    double highestSimilarity = 0.75; // Higher threshold for more precision
    
    for (int i = startIndex; i < Math.min(startIndex + maxLookAhead, candidates.length); i++) {
      final normalizedCandidate = _normalizeWord(candidates[i]);
      
      // Only consider candidates with similar length to avoid matching
      // short words to parts of longer words
      if (normalizedCandidate.length < normalizedWord.length * 0.5 ||
          normalizedCandidate.length > normalizedWord.length * 1.5) {
        continue;
      }
      
      // Calculate similarity score
      final similarity = _calculateWordSimilarity(normalizedWord, normalizedCandidate);
      
      // If this is the best match so far, remember it
      if (similarity > highestSimilarity) {
        highestSimilarity = similarity;
        bestMatchIndex = i;
      }
    }
    
    return bestMatchIndex;  // Returns -1 if no good match found
  }
  
  /// Calculate similarity between two words (0.0-1.0)
  double _calculateWordSimilarity(String word1, String word2) {
    // If either string is empty, return 0
    if (word1.isEmpty || word2.isEmpty) return 0.0;
    
    // If strings are identical, return 1
    if (word1 == word2) return 1.0;
    
    // First check if one is a substring of the other
    if (word1.contains(word2)) {
      return word2.length / word1.length;
    }
    if (word2.contains(word1)) {
      return word1.length / word2.length;
    }
    
    // Calculate Levenshtein distance (edit distance)
    final int distance = _levenshteinDistance(word1, word2);
    final int maxLength = Math.max(word1.length, word2.length);
    
    // Convert distance to similarity (1.0 means identical, 0.0 means completely different)
    return 1.0 - (distance / maxLength);
  }
  
  /// Calculate Levenshtein distance between two strings
  int _levenshteinDistance(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;
    
    List<int> v0 = List<int>.filled(t.length + 1, 0);
    List<int> v1 = List<int>.filled(t.length + 1, 0);
    
    for (int i = 0; i <= t.length; i++) {
      v0[i] = i;
    }
    
    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      
      for (int j = 0; j < t.length; j++) {
        int cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = Math.min(Math.min(v1[j] + 1, v0[j + 1] + 1), v0[j] + cost);
      }
      
      for (int j = 0; j <= t.length; j++) {
        v0[j] = v1[j];
      }
    }
    
    return v1[t.length];
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
    
    // First pass: Try to match timestamp words to content words directly using improved normalized comparison
    for (int i = 0; i < wordTimestamps.words.length && contentIndex < contentWords.length; i++) {
      final timestampWord = wordTimestamps.words[i];
      
      // Skip very short words or punctuation in timestamps (usually noise or artifacts)
      if (timestampWord.word.trim().length < 2) {
        continue;
      }
      
      // Try to find a match for this timestamp word in upcoming content words
      // Allow looking ahead up to 10 words to handle variations in text
      int matchIndex = _findBestWordMatch(
        timestampWord.word, 
        contentWords, 
        contentIndex, 
        10  // Increased look-ahead to handle more variations
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
                'visualization': 'skipped',  // Mark why it was included
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
                'visualization': 'skipped-small',
              });
              
              currentTime = wordEnd;
            }
          }
        }
        
        // Add extra debug info to understand matching quality
        String normalizedTimestampWord = _normalizeWord(timestampWord.word);
        String normalizedContentWord = _normalizeWord(contentWords[matchIndex]);
        double similarity = _calculateWordSimilarity(normalizedTimestampWord, normalizedContentWord);
        
        // Now add the matched word with its exact timestamp
        indexMap.add({
          'index': matchIndex,
          'word': contentWords[matchIndex],
          'start': timestampWord.start,
          'end': timestampWord.end,
          'matched': true,
          'originalTimestampWord': timestampWord.word, // Store original for debugging
          'similarity': similarity,  // Store similarity score for debugging
        });
        
        // Log matching details for debugging
        if (similarity < 1.0 && timestampWord.word.length > 2) {
          debugPrint('Word match: "${timestampWord.word}" -> "${contentWords[matchIndex]}", '
              'similarity: $similarity');
        }
        
        // Update content index to continue after this match
        contentIndex = matchIndex + 1;
      } else {
        // No match found - try simple sequential assignment
        if (contentIndex < contentWords.length) {
          // Try to find any available word with at least some similarity
          bool foundAnyMatch = false;
          for (int j = contentIndex; j < Math.min(contentIndex + 15, contentWords.length); j++) {
            if (_normalizeWord(timestampWord.word).length > 2 && 
                _calculateWordSimilarity(_normalizeWord(timestampWord.word), _normalizeWord(contentWords[j])) > 0.6) {
              
              // Found a reasonable match - use it
              double similarity = _calculateWordSimilarity(
                  _normalizeWord(timestampWord.word), _normalizeWord(contentWords[j]));
              
              // Fill in skipped words with estimated timings
              if (j > contentIndex) {
                double timePerWord = timestampWord.start / (j - contentIndex + 1);
                double currentTime = indexMap.isEmpty ? 
                    0.0 : (indexMap.last['end'] as num).toDouble();
                
                for (int k = contentIndex; k < j; k++) {
                  indexMap.add({
                    'index': k,
                    'word': contentWords[k],
                    'start': currentTime,
                    'end': currentTime + timePerWord,
                    'matched': false,
                    'visualization': 'low-match-skip',
                  });
                  currentTime += timePerWord;
                }
              }
              
              indexMap.add({
                'index': j,
                'word': contentWords[j],
                'start': timestampWord.start,
                'end': timestampWord.end,
                'matched': true,
                'originalTimestampWord': timestampWord.word,
                'similarity': similarity,
                'visualization': 'fuzzy-match',
              });
              
              debugPrint('Fuzzy match: "${timestampWord.word}" -> "${contentWords[j]}", '
                  'similarity: $similarity');
              
              contentIndex = j + 1;
              foundAnyMatch = true;
              break;
            }
          }
          
          // If no match was found, just use sequential assignment
          if (!foundAnyMatch) {
            indexMap.add({
              'index': contentIndex,
              'word': contentWords[contentIndex],
              'start': timestampWord.start,
              'end': timestampWord.end,
              'matched': false,
              'originalTimestampWord': timestampWord.word,
              'visualization': 'sequential-fallback',
            });
            
            contentIndex++;
          }
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
          'visualization': 'remaining-words',
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
      
      // Add visual start time for pre-highlighting - reduce to slow down transitions
      nextWord['visualStart'] = Math.max(0.0, (nextWord['start'] as num).toDouble() - 0.05);
    }
    
    // Make sure first word is always highlighted from the beginning
    if (indexMap.isNotEmpty) {
      indexMap.first['visualStart'] = 0.0;
      
      // Give the first word a bit longer duration to ensure it's visible
      // Extend the first word's end time if it's too short (less than 400ms)
      final firstWordEnd = (indexMap.first['end'] as num).toDouble();
      final firstWordStart = (indexMap.first['start'] as num).toDouble();
      final firstWordDuration = firstWordEnd - firstWordStart;
      
      if (firstWordDuration < 0.4) {  // If duration is less than 400ms
        // Make sure the first word gets at least 400ms of visibility
        indexMap.first['end'] = firstWordStart + 0.4;
        
        // Adjust subsequent words if needed
        if (indexMap.length > 1) {
          // Get the next word's start time
          final nextWordStart = (indexMap[1]['start'] as num).toDouble();
          
          // If our extension creates an overlap, adjust the next word's start time
          if (firstWordStart + 0.4 > nextWordStart) {
            indexMap[1]['start'] = firstWordStart + 0.4;
          }
          
          // Ensure the second word gets enough visibility time too
          if (indexMap.length > 1) {
            // Make sure second word has sufficient duration (at least 500ms - increased from 300ms)
            final secondWordStart = (indexMap[1]['start'] as num).toDouble();
            final secondWordEnd = (indexMap[1]['end'] as num).toDouble();
            final secondWordDuration = secondWordEnd - secondWordStart;
            
            if (secondWordDuration < 0.5) {
              indexMap[1]['end'] = secondWordStart + 0.5;
              
              // Adjust subsequent words if needed
              if (indexMap.length > 2) {
                final thirdWordStart = (indexMap[2]['start'] as num).toDouble();
                if (secondWordStart + 0.5 > thirdWordStart) {
                  indexMap[2]['start'] = secondWordStart + 0.5;
                }
              }
            }
            
            // Set visualStart for second word earlier to prepare for highlighting
            indexMap[1]['visualStart'] = Math.max(0.0, secondWordStart - 0.15);
          }
        }
      }
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
    // Use gender-aware timing - faster transitions for female voices
    // Check if any timestamp words have female-specific metadata or timing
    final bool isFemaleVoice = currentLanguage == 'en' && msPerWord < 300; // Female typically has shorter words
    final lookAheadOffset = isFemaleVoice ? 0.45 : 0.3; // Increased offset for female audio
    final positionInSeconds = position.inMilliseconds / 1000.0 + lookAheadOffset;
    
    // Get the current word list based on language
    final List<String> currentWords = currentLanguage == 'ar' ? arabicWords : englishWords;
    
    // If no words, return null
    if (currentWords.isEmpty) {
      return null;
    }
    
    // At beginning of playback, always highlight first word
    // Increase this threshold to ensure the first word is highlighted for longer
    if (position.inMilliseconds < 200) {
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
        
        // Special case for the second word transition - ensure it's visible
        if (i == 1 && _currentHighlightIndex == 0) {
          // If we're near the end of the first word, prepare to transition to second
          // Check if likely female voice based on word duration
          final bool likelyFemaleVoice = indexMap.length > 3 && 
              ((indexMap[0]['end'] as double) - (indexMap[0]['start'] as double)) < 0.25;
          
          // Use more aggressive timing for female voice
          final transitionOffset = likelyFemaleVoice ? 0.25 : 0.2;
          if (positionInSeconds >= (indexMap[0]['end'] as double) - transitionOffset) {
            _currentHighlightIndex = 1;
            return wordData['word'] as String;
          }
        }
        
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
        
        // Very aggressively anticipate the next word - reduce look-ahead to slow down transitions
        // Use voice-specific timing
        final bool likelyFemaleVoice = indexMap.length > 3 && 
            ((currentEnd - (currentWordData['start'] as double)) < 0.25);
        
        // More aggressive timing for female voice
        final transitionOffset = likelyFemaleVoice ? 0.2 : 0.15;
        
        if (positionInSeconds >= currentEnd - transitionOffset) {
          // Special case for second word - extend its display time
          if (_currentHighlightIndex == 1) {
            // For second word, wait until we're much closer to the end
            if (positionInSeconds >= currentEnd - 0.1) {
              _currentHighlightIndex++;
              final word = indexMap[_currentHighlightIndex]['word'] as String;
              return word;
            } else {
              // Keep showing the second word
              final word = indexMap[_currentHighlightIndex]['word'] as String;
              return word;
            }
          } else {
            // Normal transition for other words
            _currentHighlightIndex++;
            final word = indexMap[_currentHighlightIndex]['word'] as String;
            return word;
          }
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
    // Increase this threshold to ensure the first word is highlighted longer
    if (position.inMilliseconds < 200) {
      _currentHighlightIndex = 0;
      return 0;  // Return first word index
    }

    // Convert position to seconds for precise comparison
    final positionInSeconds = position.inMilliseconds / 1000.0;
    
    // Check if this is likely female voice audio (use timing analysis)
    final bool likelyFemaleVoice = wordIndexMap.length > 3 && 
        wordIndexMap.where((w) => 
            ((w['end'] as num).toDouble() - (w['start'] as num).toDouble()) < 0.25
        ).length > wordIndexMap.length / 2;
    
    // Adjust look-ahead timing based on voice type
    final lookAheadTiming = likelyFemaleVoice ? 0.55 : 0.4; // More aggressive for female voice
    final adjustedPosition = positionInSeconds + lookAheadTiming;
    
    // Special case for the first word - ensure it's highlighted for its full duration
    if (wordIndexMap.isNotEmpty && _currentHighlightIndex == 0) {
      final firstWord = wordIndexMap.first;
      final firstWordEnd = (firstWord['end'] as num).toDouble();
      
      // Give the first word a slightly longer display time
      if (adjustedPosition < firstWordEnd + 0.1) {
        return 0;  // Keep showing the first word
      }
      
      // Special case for transition to second word
      if (wordIndexMap.length > 1 && adjustedPosition >= firstWordEnd) {
        // Transition to second word immediately after first word ends
        _currentHighlightIndex = 1;
        return 1;  // Move to second word
      }
    }
    
    // Special case for second word - ensure it stays visible longer
    if (wordIndexMap.length > 1 && _currentHighlightIndex == 1) {
      final secondWord = wordIndexMap[1];
      final secondWordEnd = (secondWord['end'] as num).toDouble();
      
      // Add extra time to the second word
      if (adjustedPosition < secondWordEnd + 0.3) {  // Extra 300ms buffer
        return 1;  // Keep showing the second word
      }
    }
    
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
            (nextStart - adjustedPosition) <= 0.15) { // Reduced from 300ms to 150ms early transition
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

  /// Get word at specific index in the array
  String? getWordAtIndex(List<String> words, int index) {
    if (index >= 0 && index < words.length) {
      return words[index];
    }
    return null;
  }
} 