import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import '../../core/app_export.dart';
import '../../domain/story/story_model.dart';
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
    _audioPlayer = AudioPlayer();
    
    // Set up audio player
    _setupAudioPlayer();
    
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

  void _setupAudioPlayer() {
    // Setup audio player listeners
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      if (mounted) {
      setState(() {
        _duration = duration;
        // Calculate ms per word for text adherence
        if (_currentLanguage == 'ar') {
          _msPerWord = duration.inMilliseconds / _arabicWords.length;
        } else {
          _msPerWord = duration.inMilliseconds / _englishWords.length;
        }
      });
      }
    });
    
    _audioPlayer.onPositionChanged.listen((Duration position) {
      if (mounted) { // Add safety check
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
      }
    });
    
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) { // Add safety check
      setState(() {
        _isPlaying = state == PlayerState.playing;
        if (state == PlayerState.completed) {
          _currentPosition = 0.0;
          _position = Duration.zero;
          _currentWordIndex = 0;
          _resetHighlightedWords();
            
            // Show story completion screen
            _showCompletionScreen();
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
      }
    });
    
    // Additional direct completion listener for reliability
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        _showCompletionScreen();
      }
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
    // Cancel all timers
    _highlightTimer?.cancel();
    
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
            children: _buildHighlightedText(
              widget.story.contentAr,
              TextDirection.rtl,
              isArabic: true,
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
            children: _buildHighlightedText(
              widget.story.contentEn,
              TextDirection.ltr,
              isArabic: false,
            ),
          ),
        ),
        ),
        // Add extra padding at the bottom to ensure content is not cut off by audio player
        SizedBox(height: 120.h),
      ],
    );
  }

  List<Widget> _buildHighlightedText(String content, TextDirection direction, {required bool isArabic}) {
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
                fontFamily: isArabic ? 'Lato' : 'Lato', // Use appropriate font for Arabic
                fontSize: 16.fSize,
                fontWeight: FontWeight.w500,
                height: 1.5,
                color: Color(0xFF37251F),
              ),
              children: words.map((word) {
                final highlightedWord = isArabic ? _highlightedArabicWord : _highlightedEnglishWord;
                // Only highlight if the highlighted word is not empty and is contained in the current word
                final isHighlighted = highlightedWord != null && 
                                     highlightedWord.isNotEmpty && 
                                     word.contains(highlightedWord);
                
                // Special handling for "took" word in the English text to show the figma highlight
                final isFigmaHighlight = !isArabic && word.toLowerCase().contains("took");
                
                return TextSpan(
                  text: '$word ',
                  style: TextStyle(
                    color: isHighlighted || isFigmaHighlight
                        ? Color(0xFFFF6F3E)
                        : Color(0xFF37251F),
                    backgroundColor: isHighlighted || isFigmaHighlight
                        ? Color(0xFFFFEBE5)
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