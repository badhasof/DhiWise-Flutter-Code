import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../theme/custom_button_style.dart';
import '../../widgets/custom_elevated_button.dart';
import 'bloc/create_profile_bloc.dart';
import 'models/create_profile_model.dart';

class CreateProfileScreen extends StatelessWidget {
  const CreateProfileScreen({Key? key})
      : super(
          key: key,
        );

  static Widget builder(BuildContext context) {
    return BlocProvider<CreateProfileBloc>(
      create: (context) => CreateProfileBloc(CreateProfileState(
        createProfileModelObj: CreateProfileModel(),
      ))
        ..add(CreateProfileInitialEvent()),
      child: CreateProfileScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateProfileBloc, CreateProfileState>(
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
                        left: 26.h,
                        top: 48.h,
                        right: 26.h,
                      ),
                      decoration: AppDecoration.fillGray,
                      child: Column(
                        spacing: 50,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          CustomImageView(
                            imagePath:
                                ImageConstant.imgIllustrationCreateProfile,
                            height: 204.h,
                            width: 206.h,
                            radius: BorderRadius.circular(
                              102.h,
                            ),
                          ),
                          _buildHeaderSection(context)
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomBarSection(context),
        );
      },
    );
  }

  /// Section Widget
  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      width: double.maxFinite,
      child: Column(
        children: [
          Text(
            "Awesome!",
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 20.fSize,
              fontWeight: FontWeight.w900,
              color: Color(0xFF37251F),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            "Let's study together! Create your profile to save your\nprogress and keep learning seamlessly",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 13.fSize,
              fontWeight: FontWeight.w500,
              color: Color(0xFF63514B),
              height: 1.43,
            ),
          )
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildBottomBarSection(BuildContext context) {
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
                  Navigator.pushNamed(context, AppRoutes.signUpScreen);
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
                  "Create Profile",
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
