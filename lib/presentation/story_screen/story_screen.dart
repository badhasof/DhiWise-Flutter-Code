import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import '../../core/app_export.dart';
import '../../domain/story/story_model.dart';
import '../../domain/story/word_timestamp.dart';
import '../../services/timestamp_service.dart';
import '../../services/text_highlighting_service.dart';
import '../../widgets/audio_control_overlay.dart';
import '../story_completion_screen/story_completion_screen.dart';

class StoryScreen extends StatefulWidget {
  final Story story;

  const StoryScreen({
    Key? key,
    required this.story,
  }) : super(key: key);

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> with TickerProviderStateMixin {
  // Instance variables
  AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isAudioLoaded = false;
  double _currentPosition = 0.0;
  String _currentLanguage = 'ar';
  bool _isMaleVoice = true;
  bool _textAdherenceEnabled = true;
  int _currentWordIndex = 0;
  double _lastUpdateTime = 0.0;
  
  // Word lists for current content
  late List<String> _arabicWords;
  late List<String> _englishWords;
  
  // Word highlighting frequency timer for more precise updates
  Timer? _precisionHighlightTimer;
  
  // Handling milliseconds per word (used as fallback)
  double _msPerWord = 500.0;
  
  // Timer for text adherence highlighting
  Timer? _highlightTimer;
  
  // Text highlighting service
  final TextHighlightingService _textHighlightingService = TextHighlightingService();
  
  // Word timestamps
  WordTimestampCollection? _wordTimestamps;
  
  // Audio settings overlay visible
  bool _showAudioSettings = false;
  // Highlighted word in Arabic
  String? _highlightedArabicWord = '';
  // Highlighted word in English
  String? _highlightedEnglishWord = '';
  // Playback speed
  double _playbackSpeed = 1.0;
  // Animation controller for smooth transitions
  late AnimationController _animationController;
  
  // Timestamp service
  final TimestampService _timestampService = TimestampService();
  
  // Current highlighted word with precise timestamp
  WordTimestamp? _currentHighlightedWord;
  
  @override
  void initState() {
    super.initState();
    // Initialize word lists using the service method
    _arabicWords = _textHighlightingService.extractWordsArray(widget.story.contentAr);
    _englishWords = _textHighlightingService.extractWordsArray(widget.story.contentEn);
    
    // Make sure highlighting index is reset at start
    _textHighlightingService.resetCurrentIndex();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    // Initialize audio player
    _audioPlayer = AudioPlayer();
    
    // Set up audio player
    _setupAudioPlayer();
    
    // Load audio data
    _loadAudio();
    // Hide the bottom navigation bar when this screen is shown
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
  }

  void _setupAudioPlayer() {
    // Setup audio player listeners
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
          // Calculate ms per word for text adherence (fallback method)
          if (_currentLanguage == 'ar') {
            _msPerWord = duration.inMilliseconds / _arabicWords.length;
          } else {
            _msPerWord = duration.inMilliseconds / _englishWords.length;
          }
        });
      }
    });
    
    // Configure audio player for maximum precision in position updates
    _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
    
    // Start a high-precision timer for more frequent word highlighting updates
    _startPrecisionHighlightTimer();
    
    // Set up position update listener for state tracking
    _audioPlayer.onPositionChanged.listen((Duration position) {
      if (mounted) { // Add safety check
        // Update position in state
        setState(() {
          _position = position;
          if (_duration.inMilliseconds > 0) {
            _currentPosition = _position.inMilliseconds / _duration.inMilliseconds;
          }
        });
      }
    });
    
    // Player state change listener (playing, paused, stopped, completed)
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) { // Add safety check
        setState(() {
          _isPlaying = state == PlayerState.playing;
          
          // If playback starts, make sure text adherence is working
          if (_isPlaying && _textAdherenceEnabled) {
            _startTextAdherence();
          }
          
          // If playback stops or pauses, stop text adherence
          if (!_isPlaying && _textAdherenceEnabled) {
            _stopTextAdherence();
          }
          
          // Check if playback is completed
          if (state == PlayerState.completed) {
            // Reset position
            _position = Duration.zero;
            _currentPosition = 0.0;
            
            // Reset highlighted words
            _resetHighlightedWords();
            
            // Show completion screen
            _showCompletionScreen();
          }
        });
      }
    });
    
    // Additional listener for player completion
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
          _currentPosition = 0.0;
          
          // Reset highlighted words
          _resetHighlightedWords();
        });
        
        // Show completion screen
        _showCompletionScreen();
      }
    });
  }
  
  Future<void> _loadAudio() async {
    String? audioPath;
    
    // Determine which audio file to play based on language and voice preference
    if (_currentLanguage == 'ar') {
      // Check for gender-specific audio files
      if (_isMaleVoice && widget.story.audioArMale != null && widget.story.audioArMale!.isNotEmpty) {
        audioPath = widget.story.audioArMale;
      } else if (!_isMaleVoice && widget.story.audioArFemale != null && widget.story.audioArFemale!.isNotEmpty) {
        audioPath = widget.story.audioArFemale;
      } else if (widget.story.audioAr != null && widget.story.audioAr!.isNotEmpty) {
        // Fallback to generic Arabic audio
        audioPath = widget.story.audioAr;
      }
      
      // Load timestamps for Arabic audio
      if (audioPath != null && audioPath.isNotEmpty) {
        _wordTimestamps = await _timestampService.loadTimestamps(audioPath);
      }
      
      // Load audio source
      try {
        if (audioPath != null && audioPath.isNotEmpty) {
          // Make sure the path doesn't start with 'assets/' to avoid duplication
          if (audioPath.startsWith('assets/')) {
            audioPath = audioPath.substring(7); // Remove 'assets/' prefix
          }
          
          await _audioPlayer.setSource(AssetSource(audioPath));
          await _audioPlayer.setPlaybackRate(_playbackSpeed);
          
          // Immediately update highlighted word at position zero
          // This needs to happen before setting _isAudioLoaded to ensure the UI updates
          setState(() {
            if (_currentLanguage == 'ar' && _arabicWords.isNotEmpty) {
              _highlightedArabicWord = _arabicWords.first;
              _highlightedEnglishWord = '';
            } else if (_currentLanguage == 'en' && _englishWords.isNotEmpty) {
              _highlightedEnglishWord = _englishWords.first;
              _highlightedArabicWord = '';
            }
          });
          
          setState(() {
            _isAudioLoaded = true;
          });
          
          _updateHighlightedWord(Duration.zero);
        } else {
          setState(() {
            _isAudioLoaded = false;
          });
        }
      } catch (e) {
        // Handle error
        print("Error loading audio: $e");
        setState(() {
          _isAudioLoaded = false;
        });
      }
    } else if (_currentLanguage == 'en' && widget.story.audioEn != null && widget.story.audioEn!.isNotEmpty) {
      audioPath = widget.story.audioEn;
      
      // Load timestamps for English audio
      if (audioPath != null && audioPath.isNotEmpty) {
        _wordTimestamps = await _timestampService.loadTimestamps(audioPath);
      }
      
      try {
        // Make sure the path doesn't start with 'assets/' to avoid duplication
        if (audioPath != null && audioPath.startsWith('assets/')) {
          audioPath = audioPath.substring(7); // Remove 'assets/' prefix
        }
        
        if (audioPath != null) {
          await _audioPlayer.setSource(AssetSource(audioPath));
          await _audioPlayer.setPlaybackRate(_playbackSpeed);
          setState(() {
            _isAudioLoaded = true;
          });
        } else {
          setState(() {
            _isAudioLoaded = false;
          });
        }
      } catch (e) {
        // Handle error
        print("Error loading English audio: $e");
        setState(() {
          _isAudioLoaded = false;
        });
      }
    } else {
      setState(() {
        _isAudioLoaded = false;
      });
    }
  }

  // Update highlighted word based on current position with exact timing
  void _updateHighlightedWord(Duration position) {
    if (!_textAdherenceEnabled) return;
    
    // Special case for start of playback to ensure first word is highlighted
    if (position.inMilliseconds < 100) {
      final currentWords = _currentLanguage == 'ar' ? _arabicWords : _englishWords;
      if (currentWords.isNotEmpty) {
        setState(() {
          if (_currentLanguage == 'ar') {
            _highlightedArabicWord = currentWords.first;
            _highlightedEnglishWord = '';
          } else {
            _highlightedEnglishWord = currentWords.first;
            _highlightedArabicWord = '';
          }
          _currentWordIndex = 0;
        });
        return;
      }
    }
    
    // First approach: Setup the index map if we have timestamps
    if (_wordTimestamps != null && _wordTimestamps!.words.isNotEmpty) {
      // Initialize the index map if empty (first time)
      if (_textHighlightingService.wordIndexMap.isEmpty) {
        final currentWords = _currentLanguage == 'ar' ? _arabicWords : _englishWords;
        
        // Print debug info about timestamp collection and content words
        print("Timestamp words: ${_wordTimestamps!.words.length}, Content words: ${currentWords.length}");
        
        // Create the index map with direct timestamp matching
        final indexMap = _textHighlightingService.createWordIndexMap(_wordTimestamps, currentWords);
        _textHighlightingService.setWordIndexMap(indexMap);
        
        // Verify all content words are represented in the index map
        print("Index map created with ${indexMap.length} words");
      }
      
      // Get the index of the word to highlight at current position using timestamp-based lookup
      int wordIndex = _textHighlightingService.findHighlightedWordAtPosition(position);
      
      // Check if the index is valid
      if (wordIndex >= 0) {
        final currentWords = _currentLanguage == 'ar' ? _arabicWords : _englishWords;
        
        // Get the actual word at this index if it's valid
        if (wordIndex < currentWords.length) {
          final wordToHighlight = currentWords[wordIndex];
          
          // Check if the word is actually new to avoid unnecessary UI updates
          final currentHighlighted = _currentLanguage == 'ar' ? _highlightedArabicWord : _highlightedEnglishWord;
          
          if (wordToHighlight != currentHighlighted) {
            // Update the UI with the new highlighted word immediately
            setState(() {
              if (_currentLanguage == 'ar') {
                _highlightedArabicWord = wordToHighlight;
                _highlightedEnglishWord = '';
              } else {
                _highlightedEnglishWord = wordToHighlight;
                _highlightedArabicWord = '';
              }
              _currentWordIndex = wordIndex;
            });
          }
        }
      } else if (wordIndex == -1 && _currentWordIndex > 0) {
        // We have a -1 index but we've already started highlighting words
        // This is likely an edge case, so maintain the current word
        // Don't reset highlighting to avoid skipping words
      } else if (wordIndex == -1) {
        // Initial case: No word to highlight yet (before first word)
        // But let's highlight the first word anyway for better UX
        final currentWords = _currentLanguage == 'ar' ? _arabicWords : _englishWords;
        if (currentWords.isNotEmpty) {
          setState(() {
            if (_currentLanguage == 'ar') {
              _highlightedArabicWord = currentWords.first;
              _highlightedEnglishWord = '';
            } else {
              _highlightedEnglishWord = currentWords.first;
              _highlightedArabicWord = '';
            }
            _currentWordIndex = 0;
          });
        }
      }
    } else {
      // Fallback to the sequential approach if we don't have timestamps
      _updateHighlightedWordSequential(position);
    }
  }
  
  // Separate method for the sequential approach to keep the main method clean
  void _updateHighlightedWordSequential(Duration position) {
    // Use the sequential approach to find the highlighted word
    final wordToHighlight = _textHighlightingService.findHighlightedWordAtSequentialPosition(
      _wordTimestamps,
      position,
      _currentLanguage,
      _arabicWords,
      _englishWords,
      _currentWordIndex,
      _msPerWord
    );
    
    if (wordToHighlight != null) {
      // Check if the word is actually new to avoid unnecessary UI updates
      final currentHighlighted = _currentLanguage == 'ar' ? _highlightedArabicWord : _highlightedEnglishWord;
      
      if (wordToHighlight != currentHighlighted) {
        // Update the UI with the new highlighted word immediately
        setState(() {
          if (_currentLanguage == 'ar') {
            _highlightedArabicWord = wordToHighlight;
            _highlightedEnglishWord = '';
          } else {
            _highlightedEnglishWord = wordToHighlight;
            _highlightedArabicWord = '';
          }
          // Update current word index to match the service's tracking
          _currentWordIndex = _textHighlightingService.getCurrentIndex();
        });
        
        // Print some debug info for tracking
        if (_textHighlightingService.wordIndexMap.isNotEmpty && 
            _currentWordIndex < _textHighlightingService.wordIndexMap.length) {
          final wordData = _textHighlightingService.wordIndexMap[_currentWordIndex];
          debugPrint('Highlighted word: $wordToHighlight at index: $_currentWordIndex');
        }
      }
    }
  }
  
  // Reset highlighted words
  void _resetHighlightedWords() {
    setState(() {
      _highlightedArabicWord = '';
      _highlightedEnglishWord = '';
      _textHighlightingService.resetCurrentIndex();
    });
  }
  
  // Start text adherence highlighting
  void _startTextAdherence() {
    _stopTextAdherence(); // Stop any existing timer
    
    // Update the highlighted word immediately
    _updateHighlightedWord(_position);
  }
  
  // Stop text adherence highlighting
  void _stopTextAdherence() {
    if (_highlightTimer != null) {
      _highlightTimer!.cancel();
      _highlightTimer = null;
    }
  }
  
  // Toggle text adherence mode
  void _toggleTextAdherence() {
    setState(() {
      _textAdherenceEnabled = !_textAdherenceEnabled;
      
      if (_textAdherenceEnabled && _isPlaying) {
        _startTextAdherence();
      } else {
        _stopTextAdherence();
        _resetHighlightedWords();
      }
    });
  }

  // Toggle between playing and pausing audio
  void _togglePlayback() async {
    if (!_isAudioLoaded) {
      return;
    }
    
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      // When starting playback, make sure first word is highlighted immediately
      if (_position.inMilliseconds < 100) {
        // If we're at the start, force highlight the first word and reset index
        _textHighlightingService.resetCurrentIndex();
        setState(() {
          if (_currentLanguage == 'ar' && _arabicWords.isNotEmpty) {
            _highlightedArabicWord = _arabicWords.first;
            _highlightedEnglishWord = '';
          } else if (_currentLanguage == 'en' && _englishWords.isNotEmpty) {
            _highlightedEnglishWord = _englishWords.first;
            _highlightedArabicWord = '';
          }
        });
      } else {
        // Otherwise update based on current position
        _updateHighlightedWord(_position);
      }
      
      await _audioPlayer.resume();
    }
  }
  
  // Toggle between Arabic and English audio
  void _toggleLanguage() async {
    if (_currentLanguage == 'ar' && widget.story.audioEn != null && widget.story.audioEn!.isNotEmpty) {
      await _audioPlayer.stop();
      String audioPath = widget.story.audioEn!;
      
      // Make sure the path doesn't start with 'assets/' to avoid duplication
      if (audioPath.startsWith('assets/')) {
        audioPath = audioPath.substring(7); // Remove 'assets/' prefix
      }
      
      await _audioPlayer.setSource(AssetSource(audioPath));
      setState(() {
        _currentLanguage = 'en';
        _position = Duration.zero;
        _currentPosition = 0.0;
        _currentWordIndex = 0;
        _resetHighlightedWords();
        _textHighlightingService.resetCurrentIndex();
        // Reset word index map for new language
        _textHighlightingService.setWordIndexMap([]);
      });
    } else if (_currentLanguage == 'en' && widget.story.audioAr != null && widget.story.audioAr!.isNotEmpty) {
      await _audioPlayer.stop();
      
      String audioPath = widget.story.audioAr!;
      
      // Make sure the path doesn't start with 'assets/' to avoid duplication
      if (audioPath.startsWith('assets/')) {
        audioPath = audioPath.substring(7); // Remove 'assets/' prefix
      }
      
      await _audioPlayer.setSource(AssetSource(audioPath));
      setState(() {
        _currentLanguage = 'ar';
        _position = Duration.zero;
        _currentPosition = 0.0;
        _currentWordIndex = 0;
        _resetHighlightedWords();
        _textHighlightingService.resetCurrentIndex();
        // Reset word index map for new language
        _textHighlightingService.setWordIndexMap([]);
      });
    }
  }
  
  // Set playback position
  void _seekTo(double value) async {
    if (!_isAudioLoaded) {
      return;
    }
    
    final position = Duration(milliseconds: (value * _duration.inMilliseconds).round());
    await _audioPlayer.seek(position);
    
    // Reset highlight index if seeking to beginning
    if (position.inMilliseconds < 100) {
      _textHighlightingService.resetCurrentIndex();
    }
    
    // Update highlighted word if text adherence is enabled
    if (_textAdherenceEnabled) {
      _updateHighlightedWord(position);
    }
  }
  
  // Set playback speed
  void _setPlaybackSpeed(double speed) async {
    if (!_isAudioLoaded) {
      return;
    }
    
    await _audioPlayer.setPlaybackRate(speed);
    setState(() {
      _playbackSpeed = speed;
      
      // Recalculate ms per word with new playback speed
      if (_currentLanguage == 'ar') {
        _msPerWord = (_duration.inMilliseconds / _arabicWords.length) / speed;
      } else {
        _msPerWord = (_duration.inMilliseconds / _englishWords.length) / speed;
      }
    });
  }

  // Toggle between male and female voices
  void _toggleVoice(bool isMale) async {
    if (_isMaleVoice == isMale) return;
    
    bool wasPlaying = _isPlaying;
    
    // Stop any currently playing audio
    if (_isPlaying) {
      await _audioPlayer.pause();
    }
    
    setState(() {
      _isMaleVoice = isMale;
      _isAudioLoaded = false;
    });
    
    // Reload the audio with the new voice
    await _loadAudio();
    
    // Resume playback if it was playing before
    if (wasPlaying && _isAudioLoaded) {
      await _audioPlayer.resume();
    }
  }
  
  // Change playback speed
  void _changePlaybackSpeed(double speed) async {
    if (_playbackSpeed == speed) return;
    
    setState(() {
      _playbackSpeed = speed;
    });
    
    if (_isAudioLoaded) {
      await _audioPlayer.setPlaybackRate(_playbackSpeed);
    }
  }
  
  // Toggle audio settings overlay
  void _toggleAudioSettings() {
    setState(() {
      _showAudioSettings = !_showAudioSettings;
    });
  }

  @override
  void dispose() {
    // Cancel all timers
    _highlightTimer?.cancel();
    _precisionHighlightTimer?.cancel();
    
    // Remove all listeners before disposing
    _audioPlayer.onPositionChanged.drain();
    _audioPlayer.onPlayerStateChanged.drain();
    _audioPlayer.onPlayerComplete.drain();
    
    // Make sure to release the audio player resources
    _audioPlayer.stop();
    _audioPlayer.dispose();
    
    // Restore the bottom navigation bar when this screen is closed
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  // Format duration as MM:SS
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF9F4),
      body: Stack(
        children: [
          SafeArea(
        child: Column(
          children: [
            _buildHeader(),
                _buildDashedDivider(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                          _buildStoryHeader(),
                          SizedBox(height: 16.h),
                      _buildStoryContent(),
                    ],
                  ),
                ),
              ),
            ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Audio player container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9F4),
                    border: Border(
                      top: BorderSide(
                        color: const Color(0xFFEFECEB),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progress bar and time
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Custom progress bar
                          Container(
                            height: 8,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFECEB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final width = constraints.maxWidth;
                                final progressWidth = width * _currentPosition.clamp(0.0, 1.0);
                                
                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Progress fill
                                    Container(
                                      width: progressWidth,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1CAFFB),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    // Thumb/handle
                                    Positioned(
                                      left: progressWidth - 8,
                                      top: -5.5,
                                      child: GestureDetector(
                                        onHorizontalDragUpdate: (details) {
                                          final RenderBox box = context.findRenderObject() as RenderBox;
                                          final Offset localPosition = box.globalToLocal(details.globalPosition);
                                          final double newPosition = (localPosition.dx / width).clamp(0.0, 1.0);
                                          _seekTo(newPosition);
                                        },
                                        child: Container(
                                          width: 16,
                                          height: 19,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.1),
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                            border: Border.all(
                                              color: const Color(0xFF1CAFFB),
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Time display
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(_position),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF80706B),
                                ),
                              ),
                              Text(
                                _formatDuration(_duration),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF80706B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Controls row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Empty space or hidden time (as per design)
                          const SizedBox(width: 80, height: 32),
                          
                          // Play/Pause button
                          GestureDetector(
                            onTap: _togglePlayback,
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4AA9FB),
                                borderRadius: BorderRadius.circular(16),
                                border: const Border(
                                  bottom: BorderSide(
                                    color: Color(0xFF0A8FD4),
                                    width: 4,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4AA9FB).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _isPlaying 
                                  ? Icon(Icons.pause, color: Colors.white, size: 32)
                                  : SvgPicture.asset(
                                      'assets/svg/play_button/play_button.svg',
                                      width: 25,
                                      height: 24,
                                    ),
                              ),
                            ),
                          ),
                          
                          // Speed control
                          GestureDetector(
                            onTap: _toggleAudioSettings,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              height: 32,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "${_playbackSpeed}x",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF80706B),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    color: Color(0xFFAB9C97),
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Audio settings overlay
          if (_showAudioSettings)
            AudioControlOverlay(
              isMaleVoice: _isMaleVoice,
              playbackSpeed: _playbackSpeed,
              onVoiceChange: _toggleVoice,
              onSpeedChange: _changePlaybackSpeed,
              onClose: _toggleAudioSettings,
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: Color(0xFFFFF9F4),
      ),
      child: Column(
        children: [
          // Trial time indicator
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: Container(
              margin: EdgeInsets.only(top: 4.h),
              padding: EdgeInsets.symmetric(horizontal: 8.h, vertical: 3.h),
            decoration: BoxDecoration(
                color: Color(0xFFFF6F3E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.h),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time,
                  size: 16.h,
                    color: Color(0xFFFF6F3E),
                  ),
                  SizedBox(width: 4.h),
                  Text(
                    "Trail time: 30:00",
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 12.fSize,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFFF6F3E),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Header with back button and title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button (X)
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    color: Colors.grey,
                    size: 24.h,
                  ),
                ),
                
                // Title
                Text(
                  "Story details",
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 18.fSize,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF37251F),
                  ),
                ),
                
                // Menu dots
                GestureDetector(
                  onTap: () {
                    // Show options menu
                  },
                  child: Icon(
                    Icons.more_horiz,
                    color: Colors.grey,
                    size: 24.h,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Story title
        Text(
          widget.story.titleEn,
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 18.fSize,
            fontWeight: FontWeight.w800,
            color: Color(0xFF37251F),
            height: 1.5,
          ),
        ),
        SizedBox(height: 8.h),
        
        // Level and duration tags
        Row(
          children: [
            // Beginner level tag
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.h, vertical: 3.h),
              decoration: BoxDecoration(
                color: Color(0xFF1CAFFB),
                borderRadius: BorderRadius.circular(8.h),
              ),
              child: Text(
                widget.story.level,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 12.fSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 8.h),
            
            // Duration tag
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.h, vertical: 3.h),
              decoration: BoxDecoration(
                color: Color(0xFFFFEBE5),
                borderRadius: BorderRadius.circular(8.h),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14.h,
                    color: Color(0xFFFF6F3E),
                  ),
                  SizedBox(width: 4.h),
                  Text(
                    "3 min",
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 12.fSize,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFFF6F3E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDashedDivider() {
    return Container(
      width: double.infinity,
      height: 1,
      child: CustomPaint(
        painter: DashedLinePainter(color: Color(0xFFEFECEB)),
      ),
    );
  }

  Widget _buildStoryContent() {
    return Column(
      children: [
        // Arabic content
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFFFEBE5),
            borderRadius: BorderRadius.circular(12.h),
          ),
          child: Container(
            padding: EdgeInsets.all(16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.h),
              border: Border.all(
                  color: Color(0xFFFFEBE5),
                  width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end, // Right-to-left for Arabic
              children: _textHighlightingService.buildHighlightedTextParagraphs(
                widget.story.contentAr,
                TextDirection.rtl,
                _highlightedArabicWord,
                true,
                (word) {
                  setState(() {
                    _highlightedArabicWord = word;
                    _highlightedEnglishWord = '';
                  });
                }
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        
        // Language toggle indicator
        Center(
          child: Container(
            width: 24.h,
            height: 24.h,
            decoration: BoxDecoration(
              color: Color(0xFFFF9E71),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.swap_vert,
                color: Colors.white,
                size: 16.h,
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        
        // English content
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFEFECEB),
            borderRadius: BorderRadius.circular(12.h),
          ),
          child: Container(
            padding: EdgeInsets.all(16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.h),
              border: Border.all(
                  color: Color(0xFFEFECEB),
                  width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _textHighlightingService.buildHighlightedTextParagraphs(
                widget.story.contentEn,
                TextDirection.ltr,
                _highlightedEnglishWord,
                false,
                (word) {
                  setState(() {
                    _highlightedEnglishWord = word;
                    _highlightedArabicWord = '';
                  });
                }
              ),
            ),
          ),
        ),
        // Add extra padding at the bottom to ensure content is not cut off by audio player
        SizedBox(height: 120.h),
      ],
    );
  }

  // Show story completion screen
  void _showCompletionScreen() {
    // Stop any ongoing audio
    _audioPlayer.stop();
    
    // Wait a moment before showing completion screen
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {  // Add safety check
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const StoryCompletionScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.easeOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(position: offsetAnimation, child: child);
            },
          ),
        );
      }
    });
  }

  // Start high-precision timer for text highlighting
  void _startPrecisionHighlightTimer() {
    // Cancel any existing timer
    _precisionHighlightTimer?.cancel();
    
    // Create a new timer that updates more frequently than the audio position updates
    // 10ms = 100 updates per second for ultra-smooth highlighting
    _precisionHighlightTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (_isPlaying && _textAdherenceEnabled) {
        // Only update highlighted word if we're playing and text adherence is enabled
        _updateHighlightedWord(_position);
      }
    });
  }
}

// Custom painter for dashed line
class DashedLinePainter extends CustomPainter {
  final Color color;
  
  DashedLinePainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1;
      
    double dashWidth = 2;
    double dashSpace = 2;
    double startX = 0;
    
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 