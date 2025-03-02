import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../theme/custom_button_style.dart';
import '../../widgets/custom_outlined_button.dart';
import 'bloc/create_profile_one_bloc.dart';
import 'models/create_profile_one_model.dart';

class CreateProfileOneScreen extends StatelessWidget {
  const CreateProfileOneScreen({Key? key})
      : super(
          key: key,
        );

  static Widget builder(BuildContext context) {
    return BlocProvider<CreateProfileOneBloc>(
      create: (context) => CreateProfileOneBloc(CreateProfileOneState(
        createProfileOneModelObj: CreateProfileOneModel(),
      ))
        ..add(CreateProfileOneInitialEvent()),
      child: CreateProfileOneScreen(),
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
                                  "lbl_welcome_amber".tr,
                                  style: theme.textTheme.titleLarge,
                                ),
                                Text(
                                  "msg_your_profile_has".tr,
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
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomOutlinedButton(
            text: "lbl_continue".tr,
          )
        ],
      ),
    );
  }
}
