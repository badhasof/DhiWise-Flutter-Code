import 'package:flutter/material.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import '../../core/app_export.dart';
import '../../theme/custom_button_style.dart';
import '../../widgets/app_bar/appbar_leading_image.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/custom_elevated_button.dart';
import 'bloc/quiz_four_bloc.dart';
import 'models/optionsgrid_item_model.dart';
import 'models/quiz_four_model.dart';
import 'widgets/optionsgrid_item_widget.dart';

class QuizFourScreen extends StatelessWidget {
  const QuizFourScreen({Key? key})
      : super(
          key: key,
        );

  static Widget builder(BuildContext context) {
    return BlocProvider<QuizFourBloc>(
      create: (context) => QuizFourBloc(QuizFourState(
        quizFourModelObj: QuizFourModel(),
      ))
        ..add(QuizFourInitialEvent()),
      child: QuizFourScreen(),
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
                      _buildOptionsGrid(context)
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
        onTap: () {
          Navigator.pop(context);
        },
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
  Widget _buildOptionsGrid(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.h),
        child: BlocBuilder<QuizFourBloc, QuizFourState>(
          buildWhen: (previous, current) {
            return previous.quizFourModelObj?.optionsgridItemList != 
                   current.quizFourModelObj?.optionsgridItemList;
          },
          builder: (context, state) {
            // Calculate item height - double height + gap size
            final double itemHeight = 160.h; // Double the original height plus spacing
            final double horizontalSpacing = 12.h;
            final double verticalSpacing = 12.h;
            
            // Only take the first 4 options
            final displayItems = state.quizFourModelObj?.optionsgridItemList.take(4).toList() ?? [];
            
            return ResponsiveGridListBuilder(
              minItemWidth: 1,
              minItemsPerRow: 2,
              maxItemsPerRow: 2,
              horizontalGridSpacing: horizontalSpacing,
              verticalGridSpacing: verticalSpacing,
              builder: (context, items) => ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: BouncingScrollPhysics(),
                children: items,
              ),
              gridItems: List.generate(
                displayItems.length,
                (index) {
                  OptionsgridItemModel model = displayItems[index];
                  return SizedBox(
                    height: itemHeight,
                    child: OptionsgridItemWidget(
                      model,
                      onTapOption: (option) {
                        context.read<QuizFourBloc>().add(SelectOptionEvent(option));
                      },
                    ),
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
  Widget _buildBottomBar(BuildContext context) {
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
          BlocBuilder<QuizFourBloc, QuizFourState>(
            buildWhen: (previous, current) {
              return previous.hasSelection != current.hasSelection;
            },
            builder: (context, state) {
              return Container(
                width: double.maxFinite,
                padding: EdgeInsets.only(bottom: 4.h),
                decoration: BoxDecoration(
                  color: state.hasSelection ? Color(0xFFD84918) : Color(0xFFEFECEB),
                  borderRadius: BorderRadius.circular(12.h),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: state.hasSelection ? Color(0xFFFF6F3E) : Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12.h),
                  ),
                  child: TextButton(
                    onPressed: state.hasSelection 
                        ? () {
                            Navigator.pushNamed(context, AppRoutes.createProfileScreen);
                          } 
                        : null,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.h),
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.h),
                      ),
                      minimumSize: Size(double.infinity, 0),
                    ),
                    child: Text(
                      "lbl_continue".tr,
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        fontSize: 16.fSize,
                        color: state.hasSelection ? Colors.white : appTheme.gray500,
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
