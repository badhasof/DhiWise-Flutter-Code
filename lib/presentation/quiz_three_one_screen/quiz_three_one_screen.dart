import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../theme/custom_button_style.dart';
import '../../widgets/app_bar/appbar_leading_image.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/custom_outlined_button.dart';
import 'bloc/quiz_three_one_bloc.dart';
import 'models/optionslist_item_model.dart';
import 'models/quiz_three_one_model.dart';
import 'widgets/optionslist_item_widget.dart';

class QuizThreeOneScreen extends StatelessWidget {
  const QuizThreeOneScreen({Key? key})
      : super(
          key: key,
        );

  static Widget builder(BuildContext context) {
    return BlocProvider<QuizThreeOneBloc>(
      create: (context) => QuizThreeOneBloc(QuizThreeOneState(
        quizThreeOneModelObj: QuizThreeOneModel(),
      ))
        ..add(QuizThreeOneInitialEvent()),
      child: QuizThreeOneScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      _buildOptionsList(context)
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
              value: 0.51,
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
      margin: EdgeInsets.symmetric(horizontal: 14.h),
      child: Column(
        spacing: 6,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "msg_i_plan_to_practice".tr,
            style: theme.textTheme.titleLarge,
          ),
          Text(
            "msg_your_selections".tr,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall!.copyWith(
              height: 1.43,
            ),
          )
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildOptionsList(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.h),
        child: BlocSelector<QuizThreeOneBloc, QuizThreeOneState,
            QuizThreeOneModel?>(
          selector: (state) => state.quizThreeOneModelObj,
          builder: (context, quizThreeOneModelObj) {
            return ListView.separated(
              padding: EdgeInsets.zero,
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              separatorBuilder: (context, index) {
                return SizedBox(
                  height: 12.h,
                );
              },
              itemCount: quizThreeOneModelObj?.optionslistItemList.length ?? 0,
              itemBuilder: (context, index) {
                OptionslistItemModel model =
                    quizThreeOneModelObj?.optionslistItemList[index] ??
                        OptionslistItemModel();
                return OptionslistItemWidget(
                  model,
                );
              },
            );
          },
        ),
      ),
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
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.quizFourScreen);
            },
          )
        ],
      ),
    );
  }
}
