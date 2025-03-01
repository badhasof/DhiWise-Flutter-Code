import 'package:flutter/material.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import '../../core/app_export.dart';
import '../../theme/custom_button_style.dart';
import '../../widgets/app_bar/appbar_leading_image.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/custom_outlined_button.dart';
import 'bloc/quiz_four_eight_bloc.dart';
import 'models/dialectoptionsgrid_item_model.dart';
import 'models/quiz_four_eight_model.dart';
import 'widgets/dialectoptionsgrid_item_widget.dart';

class QuizFourEightScreen extends StatelessWidget {
  const QuizFourEightScreen({Key? key})
      : super(
          key: key,
        );

  static Widget builder(BuildContext context) {
    return BlocProvider<QuizFourEightBloc>(
      create: (context) => QuizFourEightBloc(QuizFourEightState(
        quizFourEightModelObj: QuizFourEightModel(),
      ))
        ..add(QuizFourEightInitialEvent()),
      child: QuizFourEightScreen(),
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
            children: [
              Expanded(
                child: Container(
                  width: double.maxFinite,
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
                      _buildDialectOptionsGrid(context)
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
  Widget _buildDialectOptionsGrid(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.h),
        child: BlocSelector<QuizFourEightBloc, QuizFourEightState,
            QuizFourEightModel?>(
          selector: (state) => state.quizFourEightModelObj,
          builder: (context, quizFourEightModelObj) {
            return ResponsiveGridListBuilder(
              minItemWidth: 1,
              minItemsPerRow: 2,
              maxItemsPerRow: 2,
              horizontalGridSpacing: 12.h,
              verticalGridSpacing: 12.h,
              builder: (context, items) => ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: BouncingScrollPhysics(),
                children: items,
              ),
              gridItems: List.generate(
                quizFourEightModelObj?.dialectoptionsgridItemList.length ?? 0,
                (index) {
                  DialectoptionsgridItemModel model = quizFourEightModelObj
                          ?.dialectoptionsgridItemList[index] ??
                      DialectoptionsgridItemModel();
                  return DialectoptionsgridItemWidget(
                    model,
                  );
                },
              ),
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
              Navigator.pushNamed(context, AppRoutes.quizFourNineScreen);
            },
          )
        ],
      ),
    );
  }
}
