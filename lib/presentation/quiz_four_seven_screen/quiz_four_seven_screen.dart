import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../core/app_export.dart';
import '../../theme/custom_button_style.dart';
import '../../widgets/app_bar/appbar_leading_image.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_text_form_field.dart';
import 'bloc/quiz_four_seven_bloc.dart';
import 'models/options_item_model.dart';
import 'models/quiz_four_seven_model.dart';
import 'widgets/options_item_widget.dart';

class QuizFourSevenScreen extends StatelessWidget {
  const QuizFourSevenScreen({Key? key})
      : super(
          key: key,
        );

  static Widget builder(BuildContext context) {
    return BlocProvider<QuizFourSevenBloc>(
      create: (context) => QuizFourSevenBloc(QuizFourSevenState(
        quizFourSevenModelObj: QuizFourSevenModel(),
      ))
        ..add(QuizFourSevenInitialEvent()),
      child: QuizFourSevenScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.gray50,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Container(
                  width: double.maxFinite,
                  padding: EdgeInsets.only(top: 16.h),
                  decoration: AppDecoration.fillGray,
                  child: Column(
                    spacing: 40,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        width: double.maxFinite,
                        child: _buildAppBar(context),
                      ),
                      _buildHeaderSection(context),
                      _buildDialectOptionsStack(context)
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
  Widget _buildPalestinianOption(BuildContext context) {
    return BlocSelector<QuizFourSevenBloc, QuizFourSevenState,
        TextEditingController?>(
      selector: (state) => state.palestinianOptionController,
      builder: (context, palestinianOptionController) {
        return CustomTextFormField(
          controller: palestinianOptionController,
          hintText: "lbl_palestinian".tr,
          contentPadding: EdgeInsets.all(12.h),
          borderDecoration: TextFormFieldStyleHelper.outlinePrimary,
          filled: true,
          fillColor: theme.colorScheme.onPrimaryContainer,
        );
      },
    );
  }

  /// Section Widget
  Widget _buildSyrianOption(BuildContext context) {
    return BlocSelector<QuizFourSevenBloc, QuizFourSevenState,
        TextEditingController?>(
      selector: (state) => state.syrianOptionController,
      builder: (context, syrianOptionController) {
        return CustomTextFormField(
          controller: syrianOptionController,
          hintText: "lbl_syrian".tr,
          contentPadding: EdgeInsets.all(12.h),
          borderDecoration: TextFormFieldStyleHelper.outlinePrimary,
          filled: true,
          fillColor: theme.colorScheme.onPrimaryContainer,
        );
      },
    );
  }

  /// Section Widget
  Widget _buildLebaneseOption(BuildContext context) {
    return BlocSelector<QuizFourSevenBloc, QuizFourSevenState,
        TextEditingController?>(
      selector: (state) => state.lebaneseOptionController,
      builder: (context, lebaneseOptionController) {
        return CustomTextFormField(
          controller: lebaneseOptionController,
          hintText: "lbl_lebanese".tr,
          contentPadding: EdgeInsets.all(12.h),
          borderDecoration: TextFormFieldStyleHelper.outlinePrimary,
          filled: true,
          fillColor: theme.colorScheme.onPrimaryContainer,
        );
      },
    );
  }

  /// Section Widget
  Widget _buildJordanianOption(BuildContext context) {
    return BlocSelector<QuizFourSevenBloc, QuizFourSevenState,
        TextEditingController?>(
      selector: (state) => state.jordanianOptionController,
      builder: (context, jordanianOptionController) {
        return CustomTextFormField(
          controller: jordanianOptionController,
          hintText: "lbl_jordanian".tr,
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
  Widget _buildDialectOptionsStack(BuildContext context) {
    return Expanded(
      child: Container(
        height: 352.h,
        width: double.maxFinite,
        margin: EdgeInsets.symmetric(horizontal: 16.h),
        child: Stack(
          alignment: Alignment.center,
          children: [
            BlocSelector<QuizFourSevenBloc, QuizFourSevenState,
                QuizFourSevenModel?>(
              selector: (state) => state.quizFourSevenModelObj,
              builder: (context, quizFourSevenModelObj) {
                return MasonryGridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.h,
                  mainAxisSpacing: 12.h,
                  itemCount: quizFourSevenModelObj?.optionsItemList.length ?? 0,
                  itemBuilder: (context, index) {
                    OptionsItemModel model =
                        quizFourSevenModelObj?.optionsItemList[index] ??
                            OptionsItemModel();
                    return OptionsItemWidget(
                      model,
                    );
                  },
                );
              },
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                width: 166.h,
                decoration: AppDecoration.outlinePrimary11.copyWith(
                  borderRadius: BorderRadiusStyle.roundedBorder12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPalestinianOption(context),
                    _buildSyrianOption(context),
                    _buildLebaneseOption(context),
                    _buildJordanianOption(context)
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildContinueButton(BuildContext context) {
    return CustomElevatedButton(
      height: 44.h,
      text: "lbl_continue".tr,
      buttonTextStyle: CustomTextStyles.titleMediumGray500,
      onPressed: () {
        Navigator.pushNamed(context, AppRoutes.quizFourEightScreen);
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
