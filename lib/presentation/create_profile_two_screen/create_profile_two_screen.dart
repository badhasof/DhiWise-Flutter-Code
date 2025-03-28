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
  final ValueNotifier<String> _nameNotifier = ValueNotifier<String>('');
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
      extendBody: true,
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
                    _buildGenderField(context),
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
                    textStyle: CustomTextStyles.titleMediumGray500Medium.copyWith(
                      color: age.isEmpty ? appTheme.gray500 : Colors.black,
                    ),
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
                    textStyle: CustomTextStyles.titleMediumGray500Medium.copyWith(
                      color: name.isEmpty ? appTheme.gray500 : Colors.black,
                    ),
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
  Widget _buildGenderField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: BlocBuilder<CreateProfileTwoBloc, CreateProfileTwoState>(
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimaryContainer,
              borderRadius: BorderRadius.circular(8.h),
            ),
            child: DropdownButtonFormField<String>(
              value: state.genderValue,
              isExpanded: true,
              icon: Padding(
                padding: EdgeInsets.only(right: 12.h),
                child: Icon(
                  Icons.arrow_drop_down,
                  color: appTheme.gray500,
                ),
              ),
              decoration: InputDecoration(
                isDense: false,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.h),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.h,
                  vertical: 20.h,
                ),
                hintText: "Gender",
                hintStyle: CustomTextStyles.titleMediumGray500Medium,
                filled: true,
                fillColor: theme.colorScheme.onPrimaryContainer,
              ),
              style: CustomTextStyles.titleMediumGray500Medium.copyWith(
                color: state.genderValue == null ? appTheme.gray500 : Colors.black,
              ),
              dropdownColor: theme.colorScheme.onPrimaryContainer,
              menuMaxHeight: 300.h,
              borderRadius: BorderRadius.circular(8.h),
              alignment: AlignmentDirectional.centerStart,
              itemHeight: 64.h,
              items: [
                DropdownMenuItem<String>(
                  value: "male",
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Male",
                      style: CustomTextStyles.titleMediumGray500Medium.copyWith(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                DropdownMenuItem<String>(
                  value: "female",
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Female", 
                      style: CustomTextStyles.titleMediumGray500Medium.copyWith(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                
              ],
              onChanged: (value) {
                if (value != null) {
                  context.read<CreateProfileTwoBloc>().add(
                    ChangeGenderEvent(value: value),
                  );
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please select your gender";
                }
                return null;
              },
            ),
          );
        },
      ),
    );
  }

  /// Section Widget
  Widget _buildCreateProfileButton(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.only(bottom: 4.h),
      decoration: BoxDecoration(
        color: Color(0xFFD84918),
        borderRadius: BorderRadius.circular(12.h),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFF6F3E),
          borderRadius: BorderRadius.circular(12.h),
        ),
        child: TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final bloc = context.read<CreateProfileTwoBloc>();
              final state = bloc.state;
              final userName = state.nameFieldController?.text ?? '';
              final age = state.ageFieldController?.text ?? '';
              final gender = state.genderValue ?? '';

              Navigator.pushNamed(
                context,
                AppRoutes.createProfileOneScreen,
                arguments: {
                  'userName': userName,
                  'age': age,
                  'gender': gender,
                },
              );
            }
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
    );
  }

  /// Section Widget
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.only(
        left: 16.h,
        right: 16.h,
        top: 14.h,
        bottom: 30.h,
      ),
      color: appTheme.gray50,
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
                  text: "By signing up to LinguaX, you agree to our ",
                  style: CustomTextStyles.bodyMediumGray700.copyWith(
                    fontSize: 10.fSize,
                  ),
                ),
                TextSpan(
                  text: "Terms",
                  style: CustomTextStyles.titleSmallBold.copyWith(
                    fontSize: 10.fSize,
                  ),
                ),
                TextSpan(
                  text: " and ",
                  style: CustomTextStyles.bodyMediumGray700.copyWith(
                    fontSize: 10.fSize,
                  ),
                ),
                TextSpan(
                  text: "Privacy Policy",
                  style: CustomTextStyles.titleSmallBold.copyWith(
                    fontSize: 10.fSize,
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
