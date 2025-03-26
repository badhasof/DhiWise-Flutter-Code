import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../theme/custom_button_style.dart';
import '../../widgets/app_bar/appbar_leading_image.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/custom_outlined_button.dart';
import '../../widgets/custom_elevated_button.dart';
import 'bloc/quiz_bloc.dart';
import 'models/quiz_model.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({Key? key})
      : super(
          key: key,
        );

  static Widget builder(BuildContext context) {
    return BlocProvider<QuizBloc>(
      create: (context) => QuizBloc(QuizState(
        quizModelObj: QuizModel(),
      ))
        ..add(QuizInitialEvent()),
      child: QuizScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizBloc, QuizState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: appTheme.gray50,
          body: SafeArea(
            child: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Container(
                  height: 636.h,
                  width: double.maxFinite,
                  padding: EdgeInsets.only(top: 16.h),
                  decoration: AppDecoration.fillGray,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        width: double.maxFinite,
                        child: _buildAppBar(context),
                      ),
                      SizedBox(height: 40.h),
                      CustomImageView(
                        imagePath: ImageConstant.imgIllustrationWelcome,
                        height: 270.h,
                        width: 270.h,
                      ),
                      SizedBox(height: 18.h),
                      Container(
                        width: double.maxFinite,
                        margin: EdgeInsets.symmetric(horizontal: 56.h),
                        child: Column(
                          spacing: 6,
                          children: [
                            Text(
                              "msg_welcome_to_linguax".tr,
                              style: theme.textTheme.titleLarge,
                            ),
                            Text(
                              "msg_answer_4_quick_questions".tr,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleSmall!.copyWith(
                                height: 1.43,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: _buildContinueButtonSection(context),
        );
      },
    );
  }

  /// Section Widget
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return CustomAppBar(
      leadingWidth: 40.h,
      leading: AppbarLeadingImage(
        imagePath: ImageConstant.imgArrowDown,
        margin: EdgeInsets.only(left: 16.h),
      ),
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
                  Navigator.pushNamed(context, AppRoutes.quizOneScreen);
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
                  "lbl_continue".tr,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 16.fSize,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
