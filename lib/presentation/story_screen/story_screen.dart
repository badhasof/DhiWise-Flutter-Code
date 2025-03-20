import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import '../../core/app_export.dart';
import '../../domain/story/story_model.dart';
import '../../widgets/audio_control_overlay.dart';

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
  // Audio player
  late AudioPlayer _audioPlayer;
  // Audio duration
  Duration _duration = Duration.zero;
  // Current position
  Duration _position = Duration.zero;
  // Current playback position
  double _currentPosition = 0.0;
  // Playback speed
  double _playbackSpeed = 1.0;
  // Is playing
  bool _isPlaying = false;
  // Is audio loaded
  bool _isAudioLoaded = false;
  // Current language being played
  String _currentLanguage = 'ar'; // Default to Arabic
  // Male voice is selected (default is true for backward compatibility)
  bool _isMaleVoice = true;
  // Audio settings overlay visible
  bool _showAudioSettings = false;
  // Highlighted word in Arabic
  String? _highlightedArabicWord = '';
  // Highlighted word in English
  String? _highlightedEnglishWord = '';
  // Text adherence mode enabled
  bool _textAdherenceEnabled = false;
  // Timer for text highlighting in adherence mode
  Timer? _highlightTimer;
  // Word lists for current content
  late List<String> _arabicWords;
  late List<String> _englishWords;
  // Current word index for highlighting
  int _currentWordIndex = 0;
  // Estimated time per word (calculated based on audio duration)
  double _msPerWord = 0.0;
  // Animation controller for smooth transitions
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // Initialize word lists
    _arabicWords = _getWords(widget.story.contentAr);
    _englishWords = _getWords(widget.story.contentEn);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    // Initialize audio player
    _initializeAudioPlayer();
    
    // Load audio data
    _loadAudio();
    // Hide the bottom navigation bar when this screen is shown
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
  }

  List<String> _getWords(String content) {
    // Split content into words and remove empty strings
    return content
        .replaceAll('\n', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .toList();
  }

  void _initializeAudioPlayer() {
    _audioPlayer = AudioPlayer();
    
    // Set up audio player listeners
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        _duration = duration;
        // Calculate ms per word for text adherence
        if (_currentLanguage == 'ar') {
          _msPerWord = duration.inMilliseconds / _arabicWords.length;
        } else {
          _msPerWord = duration.inMilliseconds / _englishWords.length;
        }
      });
    });
    
    _audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        _position = position;
        if (_duration.inMilliseconds > 0) {
          _currentPosition = _position.inMilliseconds / _duration.inMilliseconds;
          
          // Update highlighted word if text adherence is enabled
          if (_textAdherenceEnabled && _isPlaying) {
            _updateHighlightedWord(position);
          }
        }
      });
    });
    
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
        if (state == PlayerState.completed) {
          _currentPosition = 0.0;
          _position = Duration.zero;
          _currentWordIndex = 0;
          _resetHighlightedWords();
        }
        
        // Handle text adherence timer
        if (_textAdherenceEnabled) {
          if (state == PlayerState.playing) {
            _startTextAdherence();
          } else {
            _stopTextAdherence();
          }
        }
      });
    });
  }
  
  Future<void> _loadAudio() async {
    // Check if Arabic audio exists
    if (_currentLanguage == 'ar') {
      String? audioPath = _isMaleVoice ? widget.story.audioArMale : widget.story.audioArFemale;
      
      // Fallback to regular audio_ar if gendered paths don't exist
      if (audioPath == null || audioPath.isEmpty) {
        audioPath = widget.story.audioAr;
      }
      
      if (audioPath != null && audioPath.isNotEmpty) {
        try {
          await _audioPlayer.setSource(AssetSource(audioPath));
          await _audioPlayer.setPlaybackRate(_playbackSpeed);
          setState(() {
            _isAudioLoaded = true;
          });
        } catch (e) {
          print('Error loading Arabic audio: $e');
        }
      }
    } else if (_currentLanguage == 'en' && widget.story.audioEn != null && widget.story.audioEn!.isNotEmpty) {
      try {
        await _audioPlayer.setSource(AssetSource(widget.story.audioEn!));
        await _audioPlayer.setPlaybackRate(_playbackSpeed);
        setState(() {
          _isAudioLoaded = true;
        });
      } catch (e) {
        print('Error loading English audio: $e');
      }
    } else {
      setState(() {
        _isAudioLoaded = false;
      });
    }
  }

  // Update highlighted word based on current position
  void _updateHighlightedWord(Duration position) {
    if (_msPerWord <= 0) return;
    
    int wordIndex = (position.inMilliseconds / _msPerWord).floor();
    List<String> currentWords = _currentLanguage == 'ar' ? _arabicWords : _englishWords;
    
    if (wordIndex < currentWords.length && wordIndex != _currentWordIndex) {
      setState(() {
        _currentWordIndex = wordIndex;
        if (_currentLanguage == 'ar') {
          _highlightedArabicWord = currentWords[wordIndex];
          _highlightedEnglishWord = '';
        } else {
          _highlightedEnglishWord = currentWords[wordIndex];
          _highlightedArabicWord = '';
        }
      });
    }
  }
  
  // Reset highlighted words
  void _resetHighlightedWords() {
    setState(() {
      _highlightedArabicWord = '';
      _highlightedEnglishWord = '';
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
      await _audioPlayer.resume();
    }
  }
  
  // Toggle between Arabic and English audio
  void _toggleLanguage() async {
    if (_currentLanguage == 'ar' && widget.story.audioEn != null && widget.story.audioEn!.isNotEmpty) {
      await _audioPlayer.stop();
      await _audioPlayer.setSource(AssetSource(widget.story.audioEn!));
      setState(() {
        _currentLanguage = 'en';
        _position = Duration.zero;
        _currentPosition = 0.0;
        _currentWordIndex = 0;
        _resetHighlightedWords();
      });
    } else if (_currentLanguage == 'en' && widget.story.audioAr != null && widget.story.audioAr!.isNotEmpty) {
      await _audioPlayer.stop();
      await _audioPlayer.setSource(AssetSource(widget.story.audioAr!));
      setState(() {
        _currentLanguage = 'ar';
        _position = Duration.zero;
        _currentPosition = 0.0;
        _currentWordIndex = 0;
        _resetHighlightedWords();
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
    // Stop text adherence timer
    _stopTextAdherence();
    // Release the audio player resources
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
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(16.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitleAndLevel(),
                          SizedBox(height: 24.h),
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
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
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
                                      top: -6,
                                      child: GestureDetector(
                                        onHorizontalDragUpdate: (details) {
                                          final RenderBox box = context.findRenderObject() as RenderBox;
                                          final Offset localPosition = box.globalToLocal(details.globalPosition);
                                          final double newPosition = (localPosition.dx / width).clamp(0.0, 1.0);
                                          _seekTo(newPosition);
                                        },
                                        child: Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
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
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1CAFFB),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 24,
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
      padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 8.h),
      decoration: BoxDecoration(
        color: Color(0xFFFFF9F4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                "Story details",
                style: theme.textTheme.titleLarge,
              ),
              IconButton(
                icon: Icon(Icons.more_horiz),
                onPressed: () {
                  // Show options menu
                },
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.h),
            padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 6.h),
            decoration: BoxDecoration(
              color: appTheme.deepOrangeA200.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.h),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time,
                  size: 16.h,
                  color: appTheme.deepOrangeA200,
                ),
                SizedBox(width: 4.h),
                Text(
                  "Trial time: 30:00",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: appTheme.deepOrangeA200,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleAndLevel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.story.titleEn,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20.h),
              ),
              child: Text(
                widget.story.level,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 6.h),
              decoration: BoxDecoration(
                color: appTheme.deepOrangeA200.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.h),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16.h,
                    color: appTheme.deepOrangeA200,
                  ),
                  SizedBox(width: 4.h),
                  Text(
                    "3 min",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: appTheme.deepOrangeA200,
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

  Widget _buildStoryContent() {
    return Column(
      children: [
        // Arabic content
        Container(
          padding: EdgeInsets.all(16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.h),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end, // Right-to-left for Arabic
            children: _buildHighlightedText(
              widget.story.contentAr,
              TextDirection.rtl,
              isArabic: true,
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
              color: appTheme.deepOrangeA200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.translate,
              color: Colors.white,
              size: 16.h,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        // English content
        Container(
          padding: EdgeInsets.all(16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.h),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildHighlightedText(
              widget.story.contentEn,
              TextDirection.ltr,
              isArabic: false,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildHighlightedText(String content, TextDirection direction, {required bool isArabic}) {
    // Split content into paragraphs
    final paragraphs = content.split('\n');
    
    return paragraphs.map((paragraph) {
      // Split paragraph into words
      final words = paragraph.split(' ');
      
      return Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Directionality(
          textDirection: direction,
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
                fontFamily: isArabic ? 'Arabic' : null,
              ),
              children: words.map((word) {
                final highlightedWord = isArabic ? _highlightedArabicWord : _highlightedEnglishWord;
                // Only highlight if the highlighted word is not empty and is contained in the current word
                final isHighlighted = highlightedWord != null && 
                                     highlightedWord.isNotEmpty && 
                                     word.contains(highlightedWord);
                
                return TextSpan(
                  text: '$word ',
                  style: TextStyle(
                    color: isHighlighted 
                        ? appTheme.deepOrangeA200 
                        : Colors.black,
                    backgroundColor: isHighlighted 
                        ? appTheme.deepOrangeA200.withOpacity(0.1)
                        : null,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      setState(() {
                        if (isArabic) {
                          _highlightedArabicWord = word;
                          // TODO: Find corresponding English word
                        } else {
                          _highlightedEnglishWord = word;
                          // TODO: Find corresponding Arabic word
                        }
                      });
                    },
                );
              }).toList(),
            ),
          ),
        ),
      );
    }).toList();
  }
} 