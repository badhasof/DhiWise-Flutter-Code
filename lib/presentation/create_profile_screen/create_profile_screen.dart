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
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        spacing: 8,
        children: [
          Text(
            "lbl_awesome".tr,
            style: theme.textTheme.titleLarge,
          ),
          Text(
            "msg_let_s_study_together".tr,
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

  /// Section Widget
  Widget _buildBottomBarSection(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.all(16.h),
      decoration: AppDecoration.outlinePrimary,
      child: Column(
        spacing: 22,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomElevatedButton(
            height: 48.h,
            text: "lbl_create_profile".tr,
            buttonStyle: CustomButtonStyles.fillDeepOrange,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.signUpScreen);
            },
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.signInScreen);
            },
            child: Text(
              "msg_i_ll_do_it_later".tr,
              style: CustomTextStyles.titleMediumDeeporangeA200,
            ),
          )
        ],
      ),
    );
  }
}
