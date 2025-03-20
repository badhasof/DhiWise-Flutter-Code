import 'package:flutter/material.dart';

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
  // Whether we're using a preset or custom speed
  bool _usingCustomSpeed = false;

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
    if (!_speedOptions.contains(widget.playbackSpeed)) {
      _usingCustomSpeed = true;
      _customSliderValue = widget.playbackSpeed.clamp(0.25, 4.0);
    } else {
      _customSliderValue = widget.playbackSpeed;
    }
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
                  color: Colors.white,
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
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: _closeOverlay,
                            iconSize: 24,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const Text(
                            "Select voice",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 24), // For alignment
                        ],
                      ),
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
                          // Male voice option
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: () => widget.onVoiceChange(true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: widget.isMaleVoice 
                                        ? Theme.of(context).primaryColor 
                                        : const Color(0xFFEFECEB),
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.grey.shade700,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "Male",
                                      style: TextStyle(
                                        color: widget.isMaleVoice 
                                            ? Theme.of(context).primaryColor 
                                            : Colors.grey.shade800,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Female voice option
                          Container(
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: () => widget.onVoiceChange(false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: !widget.isMaleVoice 
                                        ? Theme.of(context).primaryColor 
                                        : const Color(0xFFEFECEB),
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Icon(
                                        Icons.person_outline,
                                        color: Colors.grey.shade700,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "Female",
                                      style: TextStyle(
                                        color: !widget.isMaleVoice 
                                            ? Theme.of(context).primaryColor 
                                            : Colors.grey.shade800,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Playback speed section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
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
                          const SizedBox(height: 4),
                          // Grid of speed options
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 3.5,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: _speedOptions.length,
                            itemBuilder: (context, index) {
                              final speed = _speedOptions[index];
                              final isSelected = !_usingCustomSpeed && speed == widget.playbackSpeed;
                              final bool isNormal = speed == 1.0;
                              
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _usingCustomSpeed = false;
                                  });
                                  widget.onSpeedChange(speed);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected 
                                          ? const Color(0xFFFF7F57) 
                                          : const Color(0xFFEFECEB),
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      isNormal ? "1x (Normal)" : "${speed}x",
                                      style: TextStyle(
                                        color: isSelected 
                                            ? const Color(0xFFFF7F57) 
                                            : const Color(0xFF26211D),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          // Custom speed section
                          const SizedBox(height: 8),
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF26211D),
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
                        ],
                      ),
                    ),
                    
                    // Confirm button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                      child: ElevatedButton(
                        onPressed: _closeOverlay,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          "Confirm",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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