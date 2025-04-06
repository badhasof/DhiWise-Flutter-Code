import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/app_export.dart';
import '../../theme/custom_button_style.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/countdown_timer_widget.dart';
import '../../widgets/custom_image_view.dart';
import 'bloc/vocabulary_bloc.dart';
import 'models/vocabulary_model.dart'; // ignore_for_file: must_be_immutable
import '../../core/utils/pref_utils.dart';
import '../../services/user_service.dart';
import '../../services/demo_timer_service.dart';

class VocabularyPage extends StatefulWidget {
  const VocabularyPage({Key? key})
      : super(
          key: key,
        );

  static Widget builder(BuildContext context) {
    return BlocProvider<VocabularyBloc>(
      create: (context) => VocabularyBloc(VocabularyState(
        vocabularyModelObj: VocabularyModel(),
      ))
        ..add(VocabularyInitialEvent()),
      child: VocabularyPage(),
    );
  }

  @override
  State<VocabularyPage> createState() => _VocabularyPageState();
}

class _VocabularyPageState extends State<VocabularyPage> {
  late PrefUtils _prefUtils;
  bool _isPremium = false;
  bool _isCheckingPremium = true;
  late UserService _userService;
  
  @override
  void initState() {
    super.initState();
    _prefUtils = PrefUtils();
    _userService = UserService();
    _checkPremiumStatus();
  }
  
  Future<void> _checkPremiumStatus() async {
    setState(() {
      _isCheckingPremium = true;
    });
    
    try {
      // Check if user has premium access
      bool isPremium = await _userService.hasPremiumAccess();
      
      setState(() {
        _isPremium = isPremium;
        _isCheckingPremium = false;
      });
      
    } catch (e) {
      print('Error checking premium status: $e');
      setState(() {
        _isCheckingPremium = false;
        _isPremium = false;
      });
    }
  }
  
  @override
  void dispose() {
    super.dispose();
  }
  
  // Format seconds to mm:ss
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VocabularyBloc, VocabularyState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: appTheme.gray50,
          body: SafeArea(
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                children: [
                  _buildTopBar(context),
                  Spacer(
                    flex: 56,
                  ),
                  CustomImageView(
                    imagePath: ImageConstant.imgIsolationModeGray10002,
                    height: 200.h,
                    width: 182.h,
                  ),
                  SizedBox(height: 52.h),
                  _buildHeader(context),
                  Spacer(
                    flex: 43,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Section Widget
  Widget _buildTopBar(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        children: [
          if (!_isPremium && !_isCheckingPremium) // Only show timer for non-premium users
            Container(
              width: double.maxFinite,
              decoration: AppDecoration.fillGray,
              child: Column(
                children: [
                  CountdownTimerWidget()
                ],
              ),
            ),
          Container(
            width: double.maxFinite,
            padding: EdgeInsets.symmetric(vertical: 6.h),
            decoration: AppDecoration.outlinePrimary12,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Vocabulary",
                  style: CustomTextStyles.titleMediumOnPrimaryExtraBold,
                ),
                SizedBox(height: 4.h)
              ],
            ),
          )
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.symmetric(horizontal: 22.h),
      child: Column(
        spacing: 6,
        children: [
          Text(
            "Exciting features coming soon",
            style: theme.textTheme.titleLarge,
          ),
          Text(
            "Stay tuned! New features are on their way to help you master the language",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall!.copyWith(
              height: 1.43,
            ),
          )
        ],
      ),
    );
  }
}

