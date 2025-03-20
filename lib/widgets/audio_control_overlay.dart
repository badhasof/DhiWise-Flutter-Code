import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AudioControlOverlay extends StatefulWidget {
  final bool isMaleVoice;
  final double playbackSpeed;
  final Function(bool) onVoiceChange;
  final Function(double) onSpeedChange;
  final Function() onClose;

  const AudioControlOverlay({
    Key? key,
    required this.isMaleVoice,
    required this.playbackSpeed,
    required this.onVoiceChange,
    required this.onSpeedChange,
    required this.onClose,
  }) : super(key: key);

  @override
  State<AudioControlOverlay> createState() => _AudioControlOverlayState();
}

class _AudioControlOverlayState extends State<AudioControlOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  // Playback speed options
  final List<double> _speedOptions = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
  // Custom slider value
  double _customSliderValue = 2.0;
  // Selected speed index
  int _selectedSpeedIndex = 0;
  // Whether we're using a preset or custom speed
  bool _usingCustomSpeed = false;
  bool _isMaleSelected = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
    
    // Initialize custom slider with current value if not a preset
    _customSliderValue = widget.playbackSpeed.clamp(0.25, 4.0);
    _isMaleSelected = widget.isMaleVoice;
    
    // Set the selected speed index or custom mode based on current speed
    _setInitialSpeedSelection();
  }

  void _setInitialSpeedSelection() {
    final speed = widget.playbackSpeed;
    // Find if the current speed matches any preset speed
    for (int i = 0; i < _speedOptions.length; i++) {
      if (_speedOptions[i] == speed) {
        _selectedSpeedIndex = i;
        _usingCustomSpeed = false;
        return;
      }
    }
    // If no match, set to custom speed
    _usingCustomSpeed = true;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _closeOverlay() {
    _animationController.reverse().then((_) {
      widget.onClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _closeOverlay,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        width: double.infinity,
        height: double.infinity,
        child: SlideTransition(
          position: _animation,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {}, // Prevent taps from closing the overlay
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF9F4),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with close button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        children: [
                          // Left-aligned close button (X)
                          GestureDetector(
                            onTap: _closeOverlay,
                            child: const Icon(
                              Icons.close,
                              size: 24,
                              color: Color(0xFF9E9E9E),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                "Audio Settings",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF26211D),
                                  fontFamily: "Lato",
                                ),
                              ),
                            ),
                          ),
                          // Empty space to balance the layout
                          SizedBox(width: 24),
                        ],
                      ),
                    ),
                    // Divider line
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFEFECEB),
                    ),
                    
                    // Voice selection section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Voice",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF26211D),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  widget.onVoiceChange(true);
                                  setState(() {
                                    _isMaleSelected = true;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  decoration: BoxDecoration(
                                    color: _isMaleSelected ? const Color(0xFFFF6F3E) : const Color(0xFFEFECEB),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: _isMaleSelected ? const Color(0xFFFF6F3E) : const Color(0xFFEFECEB),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/male_icon.svg',
                                          height: 16,
                                          width: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Male',
                                          style: TextStyle(
                                            fontFamily: 'Lato',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            height: 1.4,
                                            color: _isMaleSelected ? const Color(0xFFFF6F3E) : const Color(0xFF37251F),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  widget.onVoiceChange(false);
                                  setState(() {
                                    _isMaleSelected = false;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  decoration: BoxDecoration(
                                    color: !_isMaleSelected ? const Color(0xFFFF6F3E) : const Color(0xFFEFECEB),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: !_isMaleSelected ? const Color(0xFFFF6F3E) : const Color(0xFFEFECEB),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/female_icon.svg',
                                          height: 16,
                                          width: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Female',
                                          style: TextStyle(
                                            fontFamily: 'Lato',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            height: 1.4,
                                            color: !_isMaleSelected ? const Color(0xFFFF6F3E) : const Color(0xFF37251F),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Playback speed section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Playback Speed",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF26211D),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Grid of speed options
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 3.5,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: _speedOptions.length,
                            itemBuilder: (context, index) {
                              final speed = _speedOptions[index];
                              final isSelected = !_usingCustomSpeed && index == _selectedSpeedIndex;
                              final bool isNormal = speed == 1.0;
                              
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _usingCustomSpeed = false;
                                    _selectedSpeedIndex = index;
                                  });
                                  widget.onSpeedChange(speed);
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFFFF7F57) : const Color(0xFFEFECEB),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected ? const Color(0xFFFF7F57) : const Color(0xFFEFECEB),
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        isNormal ? "1x (Normal)" : "${speed}x",
                                        style: TextStyle(
                                          fontFamily: "Lato",
                                          color: isSelected 
                                              ? const Color(0xFFFF7F57) 
                                              : const Color(0xFF37251F),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          // Custom speed section
                          const SizedBox(height: 16),
                          const Text(
                            "Custom",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF26211D),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.only(bottom: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFECEB),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFEFECEB),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Current value display
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFFEFECEB),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      "${_customSliderValue.toStringAsFixed(2)}x",
                                      style: const TextStyle(
                                        fontFamily: "Lato",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF37251F),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // Slider with min/max labels
                                  Row(
                                    children: [
                                      const Text(
                                        "0.25x",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF80706B),
                                        ),
                                      ),
                                      Expanded(
                                        child: SliderTheme(
                                          data: SliderThemeData(
                                            trackHeight: 6,
                                            activeTrackColor: const Color(0xFF47B1FE),
                                            inactiveTrackColor: Colors.grey.shade200,
                                            thumbColor: Colors.white,
                                            thumbShape: const RoundSliderThumbShape(
                                              enabledThumbRadius: 10,
                                              elevation: 2,
                                            ),
                                            overlayColor: const Color(0xFF47B1FE).withOpacity(0.2),
                                          ),
                                          child: Slider(
                                            min: 0.25,
                                            max: 4.0,
                                            value: _customSliderValue,
                                            onChanged: (value) {
                                              setState(() {
                                                _customSliderValue = double.parse(value.toStringAsFixed(2));
                                                _usingCustomSpeed = true;
                                              });
                                              widget.onSpeedChange(_customSliderValue);
                                            },
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        "4x",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF80706B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Confirm button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 26, 24, 40),
                      child: GestureDetector(
                        onTap: _closeOverlay,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFD84918),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6F3E),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            child: const Center(
                              child: Text(
                                "Confirm",
                                style: TextStyle(
                                  fontFamily: "Lato",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 