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
      padding: EdgeInsets.only(left: 16.h, right: 16.h, top: 16.h, bottom: 36.h),
      decoration: AppDecoration.outlinePrimary,
      child: Column(
        spacing: 12,
        mainAxisSize: MainAxisSize.min,
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
                  Navigator.pushNamed(context, AppRoutes.quizScreen);
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
                  "lbl_get_started".tr,
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
          Container(
            width: double.maxFinite,
            padding: EdgeInsets.only(bottom: 4.h),
            decoration: BoxDecoration(
              color: Color(0xFFF0F0F0), // Light gray outer frame
              borderRadius: BorderRadius.circular(12.h),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.h),
                border: Border.all(
                  color: Color(0xFFEFECEB),
                  width: 1.5,
                ),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.signInScreen);
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
                  "msg_i_already_have_an".tr,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 16.fSize,
                    color: Color(0xFFFF6F3E),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
