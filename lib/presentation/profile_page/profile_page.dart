import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../theme/custom_button_style.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_floating_text_field.dart';
import '../../widgets/custom_text_form_field.dart';
import 'bloc/profile_bloc.dart';
import 'models/profile_model.dart'; // ignore_for_file: must_be_immutable

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key})
      : super(
          key: key,
        );

  static Widget builder(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (context) => ProfileBloc(ProfileState(
        profileModelObj: ProfileModel(),
      ))
        ..add(ProfileInitialEvent()),
      child: ProfilePage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.gray50,
      body: SafeArea(
        child: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SizedBox(
              height: 688.h,
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  _buildTrailTimeColumn(context),
                  _buildProfileTitleColumn(context),
                  SizedBox(height: 16.h),
                  Container(
                    height: 108.h,
                    width: 110.h,
                    decoration: AppDecoration.outlineDeeporangeA100.copyWith(
                      borderRadius: BorderRadiusStyle.circleBorder54,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "lbl_jp".tr,
                          style: theme.textTheme.displayMedium,
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "lbl_change_avatar".tr,
                          style: CustomTextStyles.titleMediumDeeporangeA200,
                        ),
                      ),
                      CustomImageView(
                        imagePath: ImageConstant.imgUserDeepOrangeA200,
                        height: 16.h,
                        width: 16.h,
                      )
                    ],
                  ),
                  SizedBox(height: 22.h),
                  _buildNameFieldColumn(context),
                  SizedBox(height: 14.h),
                  _buildUsernameFieldColumn(context),
                  SizedBox(height: 16.h),
                  _buildPasswordField(context),
                  SizedBox(height: 14.h),
                  _buildEmailFieldColumn(context),
                  SizedBox(height: 24.h),
                  _buildDeleteAccountButton(context)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildTrailButton(BuildContext context) {
    return CustomElevatedButton(
      height: 22.h,
      width: 122.h,
      text: "msg_trail_time_12_00".tr,
      leftIcon: Container(
        margin: EdgeInsets.only(right: 4.h),
        child: CustomImageView(
          imagePath: ImageConstant.imgClock,
          height: 16.h,
          width: 16.h,
          fit: BoxFit.contain,
        ),
      ),
      buttonStyle: CustomButtonStyles.fillDeepOrangeA,
      buttonTextStyle: CustomTextStyles.labelLargeDeeporangeA200_1,
    );
  }

  /// Section Widget
  Widget _buildTrailTimeColumn(BuildContext context) {
    return Container(
      width: double.maxFinite,
      decoration: AppDecoration.fillGray,
      child: Column(
        children: [_buildTrailButton(context)],
      ),
    );
  }

  /// Section Widget
  Widget _buildProfileTitleColumn(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      decoration: AppDecoration.outlinePrimary12,
      child: Column(
        children: [
          Text(
            "lbl_profile".tr,
            style: CustomTextStyles.titleMediumOnPrimaryExtraBold,
          ),
          SizedBox(height: 6.h)
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildNameField(BuildContext context) {
    return BlocSelector<ProfileBloc, ProfileState, TextEditingController?>(
      selector: (state) => state.nameFieldController,
      builder: (context, nameFieldController) {
        return CustomFloatingTextField(
          width: 86.h,
          controller: nameFieldController,
          labelText: "lbl_name".tr,
          labelStyle: CustomTextStyles.titleMediumOnPrimary,
          hintText: "lbl_name".tr,
          contentPadding: EdgeInsets.all(12.h),
          borderDecoration: FloatingTextFormFieldStyleHelper.custom,
          filled: false,
        );
      },
    );
  }

  /// Section Widget
  Widget _buildNameFieldColumn(BuildContext context) {
    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.symmetric(horizontal: 14.h),
      padding: EdgeInsets.only(
        left: 14.h,
        top: 6.h,
        bottom: 6.h,
      ),
      decoration: AppDecoration.outlinePrimary14.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildNameField(context), SizedBox(height: 22.h)],
      ),
    );
  }

  /// Section Widget
  Widget _buildUsernameField(BuildContext context) {
    return BlocSelector<ProfileBloc, ProfileState, TextEditingController?>(
      selector: (state) => state.usernameFieldController,
      builder: (context, usernameFieldController) {
        return CustomFloatingTextField(
          width: 108.h,
          controller: usernameFieldController,
          labelText: "lbl_user_name".tr,
          labelStyle: CustomTextStyles.titleMediumOnPrimary,
          hintText: "lbl_user_name".tr,
          contentPadding: EdgeInsets.all(12.h),
          borderDecoration: FloatingTextFormFieldStyleHelper.custom,
          filled: false,
        );
      },
    );
  }

  /// Section Widget
  Widget _buildUsernameFieldColumn(BuildContext context) {
    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.symmetric(horizontal: 14.h),
      padding: EdgeInsets.only(
        left: 14.h,
        top: 6.h,
        bottom: 6.h,
      ),
      decoration: AppDecoration.outlinePrimary14.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildUsernameField(context), SizedBox(height: 22.h)],
      ),
    );
  }

  /// Section Widget
  Widget _buildPasswordField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.h),
      child: BlocSelector<ProfileBloc, ProfileState, TextEditingController?>(
        selector: (state) => state.passwordFieldController,
        builder: (context, passwordFieldController) {
          return CustomTextFormField(
            controller: passwordFieldController,
            hintText: "lbl_password".tr,
            hintStyle: CustomTextStyles.titleMediumGray500Medium,
            textInputType: TextInputType.visiblePassword,
            obscureText: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.h,
              vertical: 20.h,
            ),
          );
        },
      ),
    );
  }

  /// Section Widget
  Widget _buildEmailField(BuildContext context) {
    return BlocSelector<ProfileBloc, ProfileState, TextEditingController?>(
      selector: (state) => state.emailFieldController,
      builder: (context, emailFieldController) {
        return CustomFloatingTextField(
          width: 192.h,
          controller: emailFieldController,
          labelText: "lbl_email".tr,
          labelStyle: CustomTextStyles.titleMediumOnPrimary,
          hintText: "lbl_email".tr,
          textInputAction: TextInputAction.done,
          textInputType: TextInputType.emailAddress,
          contentPadding: EdgeInsets.all(12.h),
          borderDecoration: FloatingTextFormFieldStyleHelper.custom,
          filled: false,
        );
      },
    );
  }

  /// Section Widget
  Widget _buildEmailFieldColumn(BuildContext context) {
    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.symmetric(horizontal: 14.h),
      padding: EdgeInsets.only(
        left: 14.h,
        top: 6.h,
        bottom: 6.h,
      ),
      decoration: AppDecoration.outlinePrimary14.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildEmailField(context), SizedBox(height: 24.h)],
      ),
    );
  }

  /// Section Widget
  Widget _buildDeleteAccountButton(BuildContext context) {
    return CustomElevatedButton(
      height: 48.h,
      text: "lbl_delete_account".tr,
      margin: EdgeInsets.symmetric(horizontal: 14.h),
      buttonTextStyle: CustomTextStyles.titleMediumRedA200,
    );
  }
}
