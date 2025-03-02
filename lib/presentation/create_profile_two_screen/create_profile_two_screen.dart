import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../core/utils/validation_functions.dart';
import '../../theme/custom_button_style.dart';
import '../../widgets/app_bar/appbar_leading_image.dart';
import '../../widgets/app_bar/appbar_title.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_text_form_field.dart';
import 'bloc/create_profile_two_bloc.dart';
import 'models/create_profile_two_model.dart';

// ignore_for_file: must_be_immutable
class CreateProfileTwoScreen extends StatelessWidget {
  CreateProfileTwoScreen({Key? key})
      : super(
          key: key,
        );

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  static Widget builder(BuildContext context) {
    return BlocProvider<CreateProfileTwoBloc>(
      create: (context) => CreateProfileTwoBloc(CreateProfileTwoState(
        createProfileTwoModelObj: CreateProfileTwoModel(),
      ))
        ..add(CreateProfileTwoInitialEvent()),
      child: CreateProfileTwoScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.gray50,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Container(
                height: 586.h,
                width: double.maxFinite,
                padding: EdgeInsets.only(top: 18.h),
                decoration: AppDecoration.fillGray,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      width: double.maxFinite,
                      child: _buildAppbar(context),
                    ),
                    SizedBox(height: 22.h),
                    _buildAgeField(context),
                    SizedBox(height: 16.h),
                    _buildNameField(context),
                    SizedBox(height: 16.h),
                    _buildEmailField(context),
                    SizedBox(height: 16.h),
                    _buildPasswordField(context)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  /// Section Widget
  PreferredSizeWidget _buildAppbar(BuildContext context) {
    return CustomAppBar(
      height: 26.h,
      leadingWidth: 38.h,
      leading: AppbarLeadingImage(
        imagePath: ImageConstant.imgClose,
        margin: EdgeInsets.only(left: 14.h),
        onTap: () {
          onTapCloseone(context);
        },
      ),
      centerTitle: true,
      title: AppbarTitle(
        text: "msg_create_your_profile".tr,
      ),
    );
  }

  /// Section Widget
  Widget _buildAgeField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: BlocSelector<CreateProfileTwoBloc, CreateProfileTwoState,
          TextEditingController?>(
        selector: (state) => state.ageFieldController,
        builder: (context, ageFieldController) {
          return CustomTextFormField(
            controller: ageFieldController,
            hintText: "lbl_age".tr,
            hintStyle: CustomTextStyles.titleMediumGray500Medium,
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
  Widget _buildNameField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: BlocSelector<CreateProfileTwoBloc, CreateProfileTwoState,
          TextEditingController?>(
        selector: (state) => state.nameFieldController,
        builder: (context, nameFieldController) {
          return CustomTextFormField(
            controller: nameFieldController,
            hintText: "lbl_name".tr,
            hintStyle: CustomTextStyles.titleMediumGray500Medium,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.h,
              vertical: 20.h,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "err_msg_please_enter_valid_text".tr;
              }
              return null;
            },
          );
        },
      ),
    );
  }

  /// Section Widget
  Widget _buildEmailField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: BlocSelector<CreateProfileTwoBloc, CreateProfileTwoState,
          TextEditingController?>(
        selector: (state) => state.emailFieldController,
        builder: (context, emailFieldController) {
          return CustomTextFormField(
            controller: emailFieldController,
            hintText: "lbl_email_address".tr,
            hintStyle: CustomTextStyles.titleMediumGray500Medium,
            textInputType: TextInputType.emailAddress,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.h,
              vertical: 20.h,
            ),
            validator: (value) {
              if (value == null || (!isValidEmail(value, isRequired: true))) {
                return "err_msg_please_enter_valid_email".tr;
              }
              return null;
            },
          );
        },
      ),
    );
  }

  /// Section Widget
  Widget _buildPasswordField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: BlocBuilder<CreateProfileTwoBloc, CreateProfileTwoState>(
        builder: (context, state) {
          return CustomTextFormField(
            controller: state.passwordFieldController,
            hintText: "lbl_password".tr,
            hintStyle: CustomTextStyles.titleMediumGray500Medium,
            textInputAction: TextInputAction.done,
            textInputType: TextInputType.visiblePassword,
            suffix: InkWell(
              onTap: () {
                context.read<CreateProfileTwoBloc>().add(
                    ChangePasswordVisibilityEvent(
                        value: !state.isShowPassword));
              },
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 16.h,
                  vertical: 20.h,
                ),
                child: CustomImageView(
                  imagePath: ImageConstant.imgSettingsGray500,
                  height: 24.h,
                  width: 24.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            suffixConstraints: BoxConstraints(
              maxHeight: 64.h,
            ),
            obscureText: state.isShowPassword,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.h,
              vertical: 20.h,
            ),
            validator: (value) {
              if (value == null ||
                  (!isValidPassword(value, isRequired: true))) {
                return "err_msg_please_enter_valid_password".tr;
              }
              return null;
            },
          );
        },
      ),
    );
  }

  /// Section Widget
  Widget _buildCreateProfileButton(BuildContext context) {
    return CustomElevatedButton(
      height: 48.h,
      text: "lbl_create_profile".tr,
      buttonStyle: CustomButtonStyles.fillDeepOrange,
    );
  }

  /// Section Widget
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.symmetric(
        horizontal: 16.h,
        vertical: 14.h,
      ),
      decoration: AppDecoration.outlinePrimary,
      child: Column(
        spacing: 10,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCreateProfileButton(context),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "msg_by_signing_in_to".tr,
                  style: CustomTextStyles.bodyMediumGray700,
                ),
                TextSpan(
                  text: "lbl_terms".tr,
                  style: CustomTextStyles.titleSmallBold,
                ),
                TextSpan(
                  text: "lbl_and".tr,
                  style: CustomTextStyles.bodyMediumGray700,
                ),
                TextSpan(
                  text: "lbl_privacy_policy".tr,
                  style: CustomTextStyles.titleSmallBold,
                )
              ],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }

  /// Navigates to the previous screen.
  onTapCloseone(BuildContext context) {
    NavigatorService.goBack();
  }
}
