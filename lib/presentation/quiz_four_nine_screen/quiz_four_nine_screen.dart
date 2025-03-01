import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../theme/custom_button_style.dart';
import '../../widgets/app_bar/appbar_leading_image.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_text_form_field.dart';
import 'bloc/quiz_four_nine_bloc.dart';
import 'models/quiz_four_nine_model.dart';

class QuizFourNineScreen extends StatelessWidget {
  const QuizFourNineScreen({Key? key})
      : super(
          key: key,
        );

  static Widget builder(BuildContext context) {
    return BlocProvider<QuizFourNineBloc>(
      create: (context) => QuizFourNineBloc(QuizFourNineState(
        quizFourNineModelObj: QuizFourNineModel(),
      ))
        ..add(QuizFourNineInitialEvent()),
      child: QuizFourNineScreen(),
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
            child: Container(
              width: double.maxFinite,
              padding: EdgeInsets.only(top: 16.h),
              decoration: AppDecoration.fillGray,
              child: Column(
                spacing: 40,
                children: [
                  SizedBox(
                    width: double.maxFinite,
                    child: _buildAppBar(context),
                  ),
                  _buildHeaderSection(context),
                  Container(
                    height: 400.h,
                    width: double.maxFinite,
                    margin: EdgeInsets.symmetric(horizontal: 16.h),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        _buildOptionsSection(context),
                        Container(
                          width: 166.h,
                          decoration: AppDecoration.outlinePrimary11.copyWith(
                            borderRadius: BorderRadiusStyle.roundedBorder12,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildSaudiOption(context),
                              _buildEmiratiOption(context),
                              _buildKuwaitiOption(context),
                              _buildBahrainiOption(context),
                              _buildQatariOption(context)
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 44.h)
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  /// Section Widget
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return CustomAppBar(
      leadingWidth: 40.h,
      leading: AppbarLeadingImage(
        imagePath: ImageConstant.imgArrowDown,
        margin: EdgeInsets.only(left: 16.h),
      ),
      title: Container(
        width: double.maxFinite,
        margin: EdgeInsets.symmetric(horizontal: 16.h),
        child: Container(
          height: 16.h,
          width: 302.h,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(
              8.h,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              8.h,
            ),
            child: LinearProgressIndicator(
              value: 0.76,
              backgroundColor: theme.colorScheme.primary,
              valueColor: AlwaysStoppedAnimation<Color>(
                appTheme.lightGreenA700,
              ),
            ),
          ),
        ),
      ),
      styleType: Style.bgFillPrimary,
    );
  }

  /// Section Widget
  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.only(
        left: 16.h,
        right: 26.h,
      ),
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "msg_choose_your_dialect".tr,
            style: theme.textTheme.titleLarge,
          ),
          Text(
            "msg_arabic_dialects".tr,
            style: theme.textTheme.titleSmall,
          )
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildOptionsSection(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: double.maxFinite,
        child: Column(
          spacing: 12,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.maxFinite,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      width: double.maxFinite,
                      decoration: AppDecoration.fillPrimary.copyWith(
                        borderRadius: BorderRadiusStyle.roundedBorder12,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: double.maxFinite,
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            decoration: AppDecoration.outlinePrimary10.copyWith(
                              borderRadius: BorderRadiusStyle.roundedBorder12,
                            ),
                            child: Column(
                              spacing: 6,
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "lbl_msa".tr,
                                  style: theme.textTheme.titleMedium,
                                ),
                                Text(
                                  "lbl".tr,
                                  style: theme.textTheme.bodyMedium,
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 4.h)
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.maxFinite,
                      decoration: AppDecoration.fillPrimary.copyWith(
                        borderRadius: BorderRadiusStyle.roundedBorder12,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: double.maxFinite,
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            decoration: AppDecoration.outlinePrimary2.copyWith(
                              borderRadius: BorderRadiusStyle.roundedBorder12,
                            ),
                            child: Column(
                              spacing: 4,
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 2.h),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.h),
                                  child: Text(
                                    "lbl_eygptian".tr,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ),
                                Text(
                                  "lbl2".tr,
                                  style: theme.textTheme.bodyMedium,
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 4.h)
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              width: double.maxFinite,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      width: double.maxFinite,
                      decoration: AppDecoration.fillPrimary.copyWith(
                        borderRadius: BorderRadiusStyle.roundedBorder12,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.h,
                              vertical: 8.h,
                            ),
                            decoration: AppDecoration.outlinePrimary3.copyWith(
                              borderRadius: BorderRadiusStyle.roundedBorder12,
                            ),
                            width: double.maxFinite,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    spacing: 6,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 4.h),
                                        child: Text(
                                          "lbl_levantine".tr,
                                          style: theme.textTheme.titleMedium,
                                        ),
                                      ),
                                      Text(
                                        "lbl3".tr,
                                        style: theme.textTheme.bodyMedium,
                                      )
                                    ],
                                  ),
                                ),
                                CustomImageView(
                                  imagePath: ImageConstant
                                      .imgArrowDownOnprimarycontainer,
                                  height: 20.h,
                                  width: 20.h,
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 4.h)
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.maxFinite,
                      decoration: AppDecoration.fillPrimary.copyWith(
                        borderRadius: BorderRadiusStyle.roundedBorder12,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 22.h,
                              vertical: 8.h,
                            ),
                            decoration: AppDecoration.outlinePrimary9.copyWith(
                              borderRadius: BorderRadiusStyle.roundedBorder12,
                            ),
                            width: double.maxFinite,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    spacing: 6,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 26.h),
                                        child: Text(
                                          "lbl_gulf".tr,
                                          style: theme.textTheme.titleMedium,
                                        ),
                                      ),
                                      Text(
                                        "lbl4".tr,
                                        style: theme.textTheme.bodyMedium,
                                      )
                                    ],
                                  ),
                                ),
                                CustomImageView(
                                  imagePath: ImageConstant
                                      .imgArrowDownOnprimarycontainer,
                                  height: 20.h,
                                  width: 20.h,
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 4.h)
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              width: double.maxFinite,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      width: double.maxFinite,
                      decoration: AppDecoration.fillPrimary.copyWith(
                        borderRadius: BorderRadiusStyle.roundedBorder12,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: double.maxFinite,
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            decoration: AppDecoration.outlinePrimary5.copyWith(
                              borderRadius: BorderRadiusStyle.roundedBorder12,
                            ),
                            child: Column(
                              spacing: 4,
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 2.h),
                                Text(
                                  "lbl_iraqi".tr,
                                  style: theme.textTheme.titleMedium,
                                ),
                                Text(
                                  "lbl5".tr,
                                  style: theme.textTheme.bodyMedium,
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 4.h)
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.maxFinite,
                      decoration: AppDecoration.fillPrimary.copyWith(
                        borderRadius: BorderRadiusStyle.roundedBorder12,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: double.maxFinite,
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            decoration: AppDecoration.outlinePrimary2.copyWith(
                              borderRadius: BorderRadiusStyle.roundedBorder12,
                            ),
                            child: Column(
                              spacing: 6,
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.h),
                                  child: Text(
                                    "lbl_sudanese".tr,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ),
                                Text(
                                  "msg".tr,
                                  style: theme.textTheme.bodyMedium,
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 4.h)
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              width: double.maxFinite,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      width: double.maxFinite,
                      decoration: AppDecoration.fillPrimary.copyWith(
                        borderRadius: BorderRadiusStyle.roundedBorder12,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: double.maxFinite,
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            decoration: AppDecoration.outlinePrimary7.copyWith(
                              borderRadius: BorderRadiusStyle.roundedBorder12,
                            ),
                            child: Column(
                              spacing: 6,
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.h),
                                  child: Text(
                                    "lbl_yemeni".tr,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ),
                                Text(
                                  "lbl6".tr,
                                  style: theme.textTheme.bodyMedium,
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 4.h)
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.maxFinite,
                      decoration: AppDecoration.fillPrimary.copyWith(
                        borderRadius: BorderRadiusStyle.roundedBorder12,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: double.maxFinite,
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            decoration: AppDecoration.outlinePrimary7.copyWith(
                              borderRadius: BorderRadiusStyle.roundedBorder12,
                            ),
                            child: Column(
                              spacing: 4,
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 2.h),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.h),
                                  child: Text(
                                    "lbl_maghrebi".tr,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ),
                                Text(
                                  "msg2".tr,
                                  style: theme.textTheme.bodyMedium,
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 4.h)
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildSaudiOption(BuildContext context) {
    return BlocSelector<QuizFourNineBloc, QuizFourNineState,
        TextEditingController?>(
      selector: (state) => state.saudiOptionController,
      builder: (context, saudiOptionController) {
        return CustomTextFormField(
          controller: saudiOptionController,
          hintText: "lbl_saudi".tr,
          contentPadding: EdgeInsets.all(12.h),
          borderDecoration: TextFormFieldStyleHelper.outlinePrimary,
          filled: true,
          fillColor: theme.colorScheme.onPrimaryContainer,
        );
      },
    );
  }

  /// Section Widget
  Widget _buildEmiratiOption(BuildContext context) {
    return BlocSelector<QuizFourNineBloc, QuizFourNineState,
        TextEditingController?>(
      selector: (state) => state.emiratiOptionController,
      builder: (context, emiratiOptionController) {
        return CustomTextFormField(
          controller: emiratiOptionController,
          hintText: "lbl_emirati".tr,
          contentPadding: EdgeInsets.all(12.h),
          borderDecoration: TextFormFieldStyleHelper.outlinePrimary,
          filled: true,
          fillColor: theme.colorScheme.onPrimaryContainer,
        );
      },
    );
  }

  /// Section Widget
  Widget _buildKuwaitiOption(BuildContext context) {
    return BlocSelector<QuizFourNineBloc, QuizFourNineState,
        TextEditingController?>(
      selector: (state) => state.kuwaitiOptionController,
      builder: (context, kuwaitiOptionController) {
        return CustomTextFormField(
          controller: kuwaitiOptionController,
          hintText: "lbl_kuwaiti".tr,
          contentPadding: EdgeInsets.all(12.h),
          borderDecoration: TextFormFieldStyleHelper.outlinePrimary,
          filled: true,
          fillColor: theme.colorScheme.onPrimaryContainer,
        );
      },
    );
  }

  /// Section Widget
  Widget _buildBahrainiOption(BuildContext context) {
    return BlocSelector<QuizFourNineBloc, QuizFourNineState,
        TextEditingController?>(
      selector: (state) => state.bahrainiOptionController,
      builder: (context, bahrainiOptionController) {
        return CustomTextFormField(
          controller: bahrainiOptionController,
          hintText: "lbl_bahraini".tr,
          contentPadding: EdgeInsets.all(12.h),
          borderDecoration: TextFormFieldStyleHelper.outlinePrimary,
          filled: true,
          fillColor: theme.colorScheme.onPrimaryContainer,
        );
      },
    );
  }

  /// Section Widget
  Widget _buildQatariOption(BuildContext context) {
    return BlocSelector<QuizFourNineBloc, QuizFourNineState,
        TextEditingController?>(
      selector: (state) => state.qatariOptionController,
      builder: (context, qatariOptionController) {
        return CustomTextFormField(
          controller: qatariOptionController,
          hintText: "lbl_qatari".tr,
          textInputAction: TextInputAction.done,
          contentPadding: EdgeInsets.all(12.h),
          borderDecoration: TextFormFieldStyleHelper.outlinePrimary,
          filled: true,
          fillColor: theme.colorScheme.onPrimaryContainer,
        );
      },
    );
  }

  /// Section Widget
  Widget _buildContinueButton(BuildContext context) {
    return CustomElevatedButton(
      height: 44.h,
      text: "lbl_continue".tr,
      buttonTextStyle: CustomTextStyles.titleMediumGray500,
      onPressed: () {
        Navigator.pushNamed(context, AppRoutes.quizFourTenScreen);
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
        mainAxisSize: MainAxisSize.min,
        children: [_buildContinueButton(context)],
      ),
    );
  }
}
