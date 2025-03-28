import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../theme/custom_button_style.dart';
import '../../widgets/custom_outlined_button.dart';
import '../../widgets/custom_elevated_button.dart';
import 'bloc/create_profile_one_bloc.dart';
import 'models/create_profile_one_model.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;
import 'dart:ui';

class CreateProfileOneScreen extends StatefulWidget {
  final String? userName;

  const CreateProfileOneScreen({Key? key, this.userName})
      : super(
          key: key,
        );

  static Widget builder(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final userName = args?['userName'] as String?;
    
    return BlocProvider<CreateProfileOneBloc>(
      create: (context) => CreateProfileOneBloc(CreateProfileOneState(
        createProfileOneModelObj: CreateProfileOneModel(userName: userName),
      ))
        ..add(CreateProfileOneInitialEvent()),
      child: CreateProfileOneScreen(userName: userName),
    );
  }

  @override
  State<CreateProfileOneScreen> createState() => _CreateProfileOneScreenState();
}

class _CreateProfileOneScreenState extends State<CreateProfileOneScreen> with TickerProviderStateMixin {
  late final AnimationController _lottieController;
  
  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // Duration for HDFC Success animation
    );
    
    // Add a small delay before playing the animation
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _lottieController.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateProfileOneBloc, CreateProfileOneState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: appTheme.gray50,
          body: SafeArea(
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Container(
                      width: double.maxFinite,
                      padding: EdgeInsets.only(
                        left: 52.h,
                        top: 16.h,
                        right: 52.h,
                      ),
                      decoration: AppDecoration.fillGray,
                      child: Column(
                        spacing: 16,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          _buildSuccessAnimation(),
                          Container(
                            width: double.maxFinite,
                            margin: EdgeInsets.symmetric(horizontal: 0),
                            child: Column(
                              spacing: 8,
                              children: [
                                Text(
                                  "Welcome ${state.createProfileOneModelObj?.userName ?? 'User'}",
                                  style: theme.textTheme.titleLarge!.copyWith(
                                    fontSize: 28.fSize,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text(
                                      "Your profile has been successfully created.",
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.titleSmall!.copyWith(
                                        height: 1.43,
                                        color: appTheme.gray700,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      "Let's start your learning journey",
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.titleSmall!.copyWith(
                                        height: 1.43,
                                        color: appTheme.gray700,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildContinueButtonSection(context),
        );
      },
    );
  }

  /// Section Widget
  Widget _buildContinueButtonSection(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.only(
        left: 16.h,
        right: 16.h,
        top: 14.h,
        bottom: 51.5.h,
      ),
      decoration: AppDecoration.outlinePrimary,
      child: Column(
        spacing: 10,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.maxFinite,
            padding: EdgeInsets.only(bottom: 4.h),
            decoration: BoxDecoration(
              color: Color(0xFFD84918), // Deep orange outer frame
              borderRadius: BorderRadius.circular(12.h),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFFF6F3E), // Inner orange content wrapper
                borderRadius: BorderRadius.circular(12.h),
              ),
              child: TextButton(
                onPressed: () {
                  // Navigate to the demo time screen
                  Navigator.pushNamed(context, AppRoutes.demoTimeScreen);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.h),
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.h),
                  ),
                  minimumSize: Size(double.infinity, 0),
                ),
                child: Text(
                  "Continue",
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 16.fSize,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Method for success animation with proper centering
  Widget _buildSuccessAnimation() {
    return Container(
      width: 300.h,
      height: 300.h,
      decoration: BoxDecoration(
        color: appTheme.gray50, // Match app background
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Transform.scale(
          scale: 1.42, // Fine-tuned scale factor
          alignment: Alignment.center,
          child: Transform.translate(
            offset: Offset(0, -6.h), // Slight vertical adjustment to center the checkmark
            child: Lottie.asset(
              'assets/lottie/success_animation.json',
              controller: _lottieController,
              fit: BoxFit.contain,
              onLoaded: (composition) {
                _lottieController.duration = Duration(milliseconds: (composition.duration.inMilliseconds * 0.8).round());
              },
            ),
          ),
        ),
      ),
    );
  }
}

// Custom blend mask widget to apply blend modes
class BlendMask extends StatelessWidget {
  final BlendMode blendMode;
  final Widget child;
  final double opacity;

  const BlendMask({
    Key? key,
    required this.blendMode,
    required this.child,
    this.opacity = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: blendMode,
      shaderCallback: (bounds) => LinearGradient(
        colors: [Colors.transparent, Colors.transparent],
        stops: [0.0, 1.0],
      ).createShader(bounds),
      child: child,
    );
  }
}
