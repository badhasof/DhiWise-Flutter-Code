import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../theme/custom_button_style.dart';
import '../../widgets/app_bar/appbar_leading_image.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/custom_elevated_button.dart';
import 'bloc/quiz_one_bloc.dart';
import 'models/optionslist_item_model.dart';
import 'models/quiz_one_model.dart';
import 'widgets/optionslist_item_widget.dart';

class QuizOneScreen extends StatelessWidget {
  const QuizOneScreen({Key? key})
      : super(
          key: key,
        );

  static Widget builder(BuildContext context) {
    return BlocProvider<QuizOneBloc>(
      create: (context) => QuizOneBloc(QuizOneState(
        quizOneModelObj: QuizOneModel(),
      ))
        ..add(QuizOneInitialEvent()),
      child: QuizOneScreen(),
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
                    spacing: 38,
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
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  /// Section Widget
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return CustomAppBar(
      leadingWidth: 40.h,
      leading: AppbarLeadingImage(
        onTap: () {
          Navigator.pop(context);
        },
        imagePath: ImageConstant.imgArrowDown,
        margin: EdgeInsets.only(left: 16.h),
      ),
      title: Container(
        width: double.maxFinite,
        margin: EdgeInsets.symmetric(horizontal: 16.h),
        decoration: AppDecoration.fillPrimary.copyWith(
          borderRadius: BorderRadiusStyle.circleBorder8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(right: 282.h),
              decoration: AppDecoration.fillLightGreenA,
              child: Column(
                children: [
                  SizedBox(height: 6.h),
                  Container(
                    height: 4.h,
                    width: 4.h,
                    margin: EdgeInsets.symmetric(horizontal: 8.h),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onPrimaryContainer.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(
                        2.h,
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h)
                ],
              ),
            )
          ],
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
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "msg_i_want_to_learn".tr,
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
        padding: EdgeInsets.symmetric(horizontal: 16.h),
        child: BlocBuilder<QuizOneBloc, QuizOneState>(
          buildWhen: (previous, current) {
            // Only rebuild if the options list has changed
            return previous.quizOneModelObj?.optionslistItemList != 
                   current.quizOneModelObj?.optionslistItemList;
          },
          builder: (context, state) {
            print("Building options list"); // Debug print
            return ListView.separated(
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              separatorBuilder: (context, index) {
                return SizedBox(height: 12.h);
              },
              itemCount: state.quizOneModelObj?.optionslistItemList.length ?? 0,
              itemBuilder: (context, index) {
                OptionslistItemModel model =
                    state.quizOneModelObj?.optionslistItemList[index] ??
                        OptionslistItemModel();
                return OptionslistItemWidget(
                  model,
                  onTapOption: (option) {
                    print("Option tapped: ${option.id}"); // Debug print
                    context.read<QuizOneBloc>().add(SelectOptionEvent(option));
                  },
                );
              },
            );
          },
        ),
      ),
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
        children: [
          BlocBuilder<QuizOneBloc, QuizOneState>(
            buildWhen: (previous, current) {
              return previous.hasSelection != current.hasSelection;
            },
            builder: (context, state) {
              return CustomElevatedButton(
                height: 44.h,
                text: "lbl_continue".tr,
                buttonStyle: state.hasSelection 
                    ? CustomButtonStyles.fillDeepOrange 
                    : null,
                buttonTextStyle: state.hasSelection 
                    ? CustomTextStyles.titleMediumOnPrimaryContainer 
                    : CustomTextStyles.titleMediumGray500,
                onPressed: state.hasSelection 
                    ? () {
                        Navigator.pushNamed(context, AppRoutes.quizTwoScreen);
                      } 
                    : null,
              );
            },
          )
        ],
      ),
    );
  }
}
