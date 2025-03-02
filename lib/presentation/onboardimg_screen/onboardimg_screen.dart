import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../theme/custom_button_style.dart';
import '../../widgets/custom_elevated_button.dart';
import 'bloc/onboardimg_bloc.dart';
import 'models/onboardimg_model.dart';

class OnboardimgScreen extends StatelessWidget {
  const OnboardimgScreen({Key? key})
      : super(
          key: key,
        );

  static Widget builder(BuildContext context) {
    return BlocProvider<OnboardimgBloc>(
      create: (context) => OnboardimgBloc(OnboardimgState(
        onboardimgModelObj: OnboardimgModel(),
      ))
        ..add(OnboardimgInitialEvent()),
      child: OnboardimgScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardimgBloc, OnboardimgState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: appTheme.gray50,
          body: SafeArea(
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      width: double.maxFinite,
                      decoration: AppDecoration.fillGray,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomImageView(
                            imagePath: ImageConstant.imgLogo,
                            height: 108.h,
                            width: 102.h,
                          ),
                          SizedBox(height: 20.h),
                          CustomImageView(
                            imagePath: ImageConstant.imgText,
                            height: 38.h,
                            width: 142.h,
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomBar(context),
        );
      },
    );
  }

  /// Section Widget
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.all(16.h),
      decoration: AppDecoration.outlinePrimary,
      child: Column(
        spacing: 12,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomElevatedButton(
            height: 48.h,
            text: "lbl_get_started".tr,
            buttonStyle: CustomButtonStyles.fillDeepOrange,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.quizScreen);
            },
          ),
          CustomElevatedButton(
            height: 48.h,
            text: "msg_i_already_have_an".tr,
            buttonTextStyle: CustomTextStyles.titleMediumDeeporangeA200,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.signInScreen);
            },
          )
        ],
      ),
    );
  }
}
