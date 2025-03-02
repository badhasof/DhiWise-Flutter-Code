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
  final ValueNotifier<String> _passwordNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> _nameNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> _emailNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> _ageNotifier = ValueNotifier<String>('');

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
        text: "Create Your Profile",
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
          // Add listener to update the ValueNotifier
          if (ageFieldController != null) {
            ageFieldController.addListener(() {
              _ageNotifier.value = ageFieldController.text;
            });
          }
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueListenableBuilder<String>(
                valueListenable: _ageNotifier,
                builder: (context, age, child) {
                  int? ageValue = int.tryParse(age);
                  bool isValid = age.isNotEmpty && ageValue != null && ageValue > 0 && ageValue <= 120;
                  
                  return CustomTextFormField(
                    controller: ageFieldController,
                    hintText: "Age",
                    hintStyle: CustomTextStyles.titleMediumGray500Medium,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.h,
                      vertical: 20.h,
                    ),
                    fillColor: theme.colorScheme.onPrimaryContainer,
                    filled: true,
                    borderDecoration: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.h),
                      borderSide: BorderSide.none,
                    ),
                    textInputType: TextInputType.number,
                    suffix: age.isNotEmpty && isValid ? Container(
                      margin: EdgeInsets.only(
                        right: 16.h,
                        left: 8.h,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16.h,
                      ),
                    ) : null,
                    suffixConstraints: BoxConstraints(
                      maxHeight: 64.h,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your age";
                      }
                      int? age = int.tryParse(value);
                      if (age == null || age <= 0 || age > 120) {
                        return "Please enter a valid age";
                      }
                      return null;
                    },
                  );
                },
              ),
              ValueListenableBuilder<String>(
                valueListenable: _ageNotifier,
                builder: (context, age, child) {
                  if (age.isEmpty) {
                    return SizedBox.shrink();
                  }
                  
                  int? ageValue = int.tryParse(age);
                  bool isValid = ageValue != null && ageValue > 0 && ageValue <= 120;
                  
                  if (!isValid) {
                    return Padding(
                      padding: EdgeInsets.only(top: 8.h, left: 8.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.cancel,
                            color: appTheme.deepOrangeA200,
                            size: 16.h,
                          ),
                          SizedBox(width: 8.h),
                          Text(
                            "Please enter a valid age (1-120)",
                            style: CustomTextStyles.bodyMediumGray700.copyWith(
                              fontSize: 12.fSize,
                              color: appTheme.gray700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return SizedBox.shrink();
                },
              ),
            ],
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
          // Add listener to update the ValueNotifier
          if (nameFieldController != null) {
            nameFieldController.addListener(() {
              _nameNotifier.value = nameFieldController.text;
            });
          }
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueListenableBuilder<String>(
                valueListenable: _nameNotifier,
                builder: (context, name, child) {
                  bool isValid = name.isNotEmpty;
                  
                  return CustomTextFormField(
                    controller: nameFieldController,
                    hintText: "Name",
                    hintStyle: CustomTextStyles.titleMediumGray500Medium,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.h,
                      vertical: 20.h,
                    ),
                    fillColor: theme.colorScheme.onPrimaryContainer,
                    filled: true,
                    borderDecoration: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.h),
                      borderSide: BorderSide.none,
                    ),
                    suffix: name.isNotEmpty && isValid ? Container(
                      margin: EdgeInsets.only(
                        right: 16.h,
                        left: 8.h,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16.h,
                      ),
                    ) : null,
                    suffixConstraints: BoxConstraints(
                      maxHeight: 64.h,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a valid name";
                      }
                      return null;
                    },
                  );
                },
              ),
              ValueListenableBuilder<String>(
                valueListenable: _nameNotifier,
                builder: (context, name, child) {
                  if (name.isEmpty) {
                    return SizedBox.shrink();
                  }
                  
                  bool isValid = name.isNotEmpty;
                  
                  if (!isValid) {
                    return Padding(
                      padding: EdgeInsets.only(top: 8.h, left: 8.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.cancel,
                            color: appTheme.deepOrangeA200,
                            size: 16.h,
                          ),
                          SizedBox(width: 8.h),
                          Text(
                            "Name cannot be empty",
                            style: CustomTextStyles.bodyMediumGray700.copyWith(
                              fontSize: 12.fSize,
                              color: appTheme.gray700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return SizedBox.shrink();
                },
              ),
            ],
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
          // Add listener to update the ValueNotifier
          if (emailFieldController != null) {
            emailFieldController.addListener(() {
              _emailNotifier.value = emailFieldController.text;
            });
          }
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueListenableBuilder<String>(
                valueListenable: _emailNotifier,
                builder: (context, email, child) {
                  bool isValid = isValidEmail(email, isRequired: true);
                  
                  return CustomTextFormField(
                    controller: emailFieldController,
                    hintText: "Email Address",
                    hintStyle: CustomTextStyles.titleMediumGray500Medium,
                    textInputType: TextInputType.emailAddress,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.h,
                      vertical: 20.h,
                    ),
                    fillColor: theme.colorScheme.onPrimaryContainer,
                    filled: true,
                    borderDecoration: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.h),
                      borderSide: BorderSide.none,
                    ),
                    suffix: email.isNotEmpty && isValid ? Container(
                      margin: EdgeInsets.only(
                        right: 16.h,
                        left: 8.h,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16.h,
                      ),
                    ) : null,
                    suffixConstraints: BoxConstraints(
                      maxHeight: 64.h,
                    ),
                    validator: (value) {
                      if (value == null || (!isValidEmail(value, isRequired: true))) {
                        return "Please enter a valid email";
                      }
                      return null;
                    },
                  );
                },
              ),
              ValueListenableBuilder<String>(
                valueListenable: _emailNotifier,
                builder: (context, email, child) {
                  if (email.isEmpty) {
                    return SizedBox.shrink();
                  }
                  
                  bool isValid = isValidEmail(email, isRequired: true);
                  
                  if (!isValid) {
                    return Padding(
                      padding: EdgeInsets.only(top: 8.h, left: 8.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.cancel,
                            color: appTheme.deepOrangeA200,
                            size: 16.h,
                          ),
                          SizedBox(width: 8.h),
                          Expanded(
                            child: Text(
                              "Please enter a valid email address (e.g., example@domain.com)",
                              style: CustomTextStyles.bodyMediumGray700.copyWith(
                                fontSize: 12.fSize,
                                color: appTheme.gray700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return SizedBox.shrink();
                },
              ),
            ],
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
          // Update the ValueNotifier when the state is built
          if (state.passwordFieldController != null) {
            state.passwordFieldController!.addListener(() {
              _passwordNotifier.value = state.passwordFieldController!.text;
            });
          }
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextFormField(
                controller: state.passwordFieldController,
                hintText: "Password",
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_passwordNotifier.value.isNotEmpty && isValidPassword(_passwordNotifier.value, isRequired: true))
                          Padding(
                            padding: EdgeInsets.only(right: 8.h),
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16.h,
                            ),
                          ),
                        CustomImageView(
                          imagePath: ImageConstant.imgSettingsGray500,
                          height: 24.h,
                          width: 24.h,
                          fit: BoxFit.contain,
                        ),
                      ],
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
                fillColor: theme.colorScheme.onPrimaryContainer,
                filled: true,
                borderDecoration: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.h),
                  borderSide: BorderSide.none,
                ),
                validator: (value) {
                  if (value == null ||
                      (!isValidPassword(value, isRequired: true))) {
                    return "Please enter a valid password";
                  }
                  return null;
                },
              ),
              ValueListenableBuilder<String>(
                valueListenable: _passwordNotifier,
                builder: (context, password, child) {
                  if (password.isEmpty) {
                    return SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: 8.h, left: 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPasswordRequirement(
                          "At least 8 characters",
                          password.length >= 8,
                        ),
                        _buildPasswordRequirement(
                          "At least one uppercase letter",
                          RegExp(r'[A-Z]').hasMatch(password),
                        ),
                        _buildPasswordRequirement(
                          "At least one lowercase letter",
                          RegExp(r'[a-z]').hasMatch(password),
                        ),
                        _buildPasswordRequirement(
                          "At least one number",
                          RegExp(r'[0-9]').hasMatch(password),
                        ),
                        _buildPasswordRequirement(
                          "At least one special character",
                          RegExp(r'[\W]').hasMatch(password),
                        ),
                        _buildPasswordRequirement(
                          "No whitespace",
                          !RegExp(r'\s').hasMatch(password),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPasswordRequirement(String requirement, bool isMet) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            color: isMet ? Colors.green : appTheme.deepOrangeA200,
            size: 16.h,
          ),
          SizedBox(width: 8.h),
          Expanded(
            child: Text(
              requirement,
              style: CustomTextStyles.bodyMediumGray700.copyWith(
                fontSize: 12.fSize,
                color: isMet ? Colors.green : appTheme.gray700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildCreateProfileButton(BuildContext context) {
    return CustomElevatedButton(
      height: 48.h,
      text: "Create Profile",
      buttonStyle: CustomButtonStyles.fillDeepOrange,
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          // Get the user's name from the controller
          final nameController = context.read<CreateProfileTwoBloc>().state.nameFieldController;
          final userName = nameController?.text ?? '';
          
          // Navigate to the profile one screen with the user's name
          Navigator.pushNamed(
            context, 
            AppRoutes.createProfileOneScreen,
            arguments: {'userName': userName}
          );
        } else {
          // Form validation failed, errors will be shown automatically
        }
      },
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
                  text: "By signing in to LinguaX, you agree to our ",
                  style: CustomTextStyles.bodyMediumGray700.copyWith(
                    fontSize: 12.fSize,
                  ),
                ),
                TextSpan(
                  text: "Terms",
                  style: CustomTextStyles.titleSmallBold.copyWith(
                    fontSize: 12.fSize,
                  ),
                ),
                TextSpan(
                  text: " and ",
                  style: CustomTextStyles.bodyMediumGray700.copyWith(
                    fontSize: 12.fSize,
                  ),
                ),
                TextSpan(
                  text: "Privacy Policy",
                  style: CustomTextStyles.titleSmallBold.copyWith(
                    fontSize: 12.fSize,
                  ),
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
