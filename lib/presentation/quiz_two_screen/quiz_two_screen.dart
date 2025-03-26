import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../theme/custom_button_style.dart';
import '../../widgets/app_bar/appbar_leading_image.dart';
import '../../widgets/app_bar/custom_app_bar.dart';
import '../../widgets/custom_elevated_button.dart';
import 'bloc/quiz_two_bloc.dart';
import 'models/optionslist_item_model.dart';
import 'models/quiz_two_model.dart';
import 'widgets/optionslist_item_widget.dart';

class QuizTwoScreen extends StatelessWidget {
  const QuizTwoScreen({Key? key})
      : super(
          key: key,
        );

  static Widget builder(BuildContext context) {
    return BlocProvider<QuizTwoBloc>(
      create: (context) => QuizTwoBloc(QuizTwoState(
        quizTwoModelObj: QuizTwoModel(),
      ))
        ..add(QuizTwoInitialEvent()),
      child: QuizTwoScreen(),
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
              value: 0.25,
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
            "msg_i_want_to_use_linguax".tr,
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
        child: BlocBuilder<QuizTwoBloc, QuizTwoState>(
          buildWhen: (previous, current) {
            return previous.quizTwoModelObj?.optionslistItemList != 
                   current.quizTwoModelObj?.optionslistItemList;
          },
          builder: (context, state) {
            return ListView.separated(
              padding: EdgeInsets.zero,
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              separatorBuilder: (context, index) {
                return SizedBox(
                  height: 12.h,
                );
              },
              itemCount: state.quizTwoModelObj?.optionslistItemList.length ?? 0,
              itemBuilder: (context, index) {
                OptionslistItemModel model =
                    state.quizTwoModelObj?.optionslistItemList[index] ??
                        OptionslistItemModel();
                return OptionslistItemWidget(
                  model,
                  onTapOption: (option) {
                    context.read<QuizTwoBloc>().add(SelectOptionEvent(option));
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
          BlocBuilder<QuizTwoBloc, QuizTwoState>(
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
                            Navigator.pushNamed(context, AppRoutes.quizThreeScreen);
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
