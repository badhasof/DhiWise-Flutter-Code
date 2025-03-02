import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../theme/custom_button_style.dart';
import '../../widgets/custom_outlined_button.dart';
import '../../widgets/custom_elevated_button.dart';
import 'bloc/create_profile_one_bloc.dart';
import 'models/create_profile_one_model.dart';

class CreateProfileOneScreen extends StatelessWidget {
  final String? userName;

  const CreateProfileOneScreen({Key? key, this.userName})
      : super(
          key: key,
        );

  static Widget builder(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final userName = args?['userName'] as String?;
    
    return BlocProvider<CreateProfileOneBloc>(
      create: (context) => CreateProfileOneBloc(CreateProfileOneState(
        createProfileOneModelObj: CreateProfileOneModel(userName: userName),
      ))
        ..add(CreateProfileOneInitialEvent()),
      child: CreateProfileOneScreen(userName: userName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateProfileOneBloc, CreateProfileOneState>(
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
                        left: 52.h,
                        top: 16.h,
                        right: 52.h,
                      ),
                      decoration: AppDecoration.fillGray,
                      child: Column(
                        spacing: 16,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          CustomImageView(
                            imagePath: ImageConstant.imgIllustrationWellDone,
                            height: 270.h,
                            width: 270.h,
                          ),
                          Container(
                            width: double.maxFinite,
                            margin: EdgeInsets.symmetric(horizontal: 4.h),
                            child: Column(
                              spacing: 8,
                              children: [
                                Text(
                                  "Welcome ${state.createProfileOneModelObj?.userName ?? 'User'}",
                                  style: theme.textTheme.titleLarge,
                                ),
                                Text(
                                  "Your profile has been successfully created.\nLet's start your learning journey",
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
                  )
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildContinueButtonSection(context),
        );
      },
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
          CustomElevatedButton(
            height: 48.h,
            text: "Continue",
            buttonStyle: CustomButtonStyles.fillDeepOrange,
            onPressed: () {
              // Navigate to the next screen
              Navigator.pushNamed(context, AppRoutes.homeScreen);
            },
          )
        ],
      ),
    );
  }
}
