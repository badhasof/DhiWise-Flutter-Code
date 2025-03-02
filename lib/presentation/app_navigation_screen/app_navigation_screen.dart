import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import 'bloc/app_navigation_bloc.dart';
import 'models/app_navigation_model.dart';

class AppNavigationScreen extends StatelessWidget {
  const AppNavigationScreen({Key? key})
      : super(
          key: key,
        );

  static Widget builder(BuildContext context) {
    return BlocProvider<AppNavigationBloc>(
      create: (context) => AppNavigationBloc(AppNavigationState(
        appNavigationModelObj: AppNavigationModel(),
      ))
        ..add(AppNavigationInitialEvent()),
      child: AppNavigationScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppNavigationBloc, AppNavigationState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Color(0XFFFFFFFF),
          body: SafeArea(
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0XFFFFFFFF),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 10.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.h),
                          child: Text(
                            "App Navigation",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0XFF000000),
                              fontSize: 20.fSize,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Padding(
                          padding: EdgeInsets.only(left: 20.h),
                          child: Text(
                            "Check your app's UI from the below demo screens of your app.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0XFF888888),
                              fontSize: 16.fSize,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Divider(
                          height: 1.h,
                          thickness: 1.h,
                          color: Color(0XFF000000),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0XFFFFFFFF),
                        ),
                        child: Column(
                          children: [
                            _buildScreenTitle(
                              context,
                              screenTitle: "Sign In",
                              onTapScreenTitle: () =>
                                  onTapScreenTitle(AppRoutes.signInScreen),
                            ),
                            _buildScreenTitle(
                              context,
                              screenTitle: "Onboardimg",
                              onTapScreenTitle: () =>
                                  onTapScreenTitle(AppRoutes.onboardimgScreen),
                            ),
                            _buildScreenTitle(
                              context,
                              screenTitle: "Quiz",
                              onTapScreenTitle: () =>
                                  onTapScreenTitle(AppRoutes.quizScreen),
                            ),
                            _buildScreenTitle(
                              context,
                              screenTitle: "Quiz/One",
                              onTapScreenTitle: () =>
                                  onTapScreenTitle(AppRoutes.quizOneScreen),
                            ),
                            _buildScreenTitle(
                              context,
                              screenTitle: "Quiz/Two",
                              onTapScreenTitle: () =>
                                  onTapScreenTitle(AppRoutes.quizTwoScreen),
                            ),
                            _buildScreenTitle(
                              context,
                              screenTitle: "Quiz/Three",
                              onTapScreenTitle: () =>
                                  onTapScreenTitle(AppRoutes.quizThreeScreen),
                            ),
                            _buildScreenTitle(
                              context,
                              screenTitle: "Quiz/Four",
                              onTapScreenTitle: () =>
                                  onTapScreenTitle(AppRoutes.quizFourScreen),
                            ),
                            _buildScreenTitle(
                              context,
                              screenTitle: "create profile",
                              onTapScreenTitle: () => onTapScreenTitle(
                                  AppRoutes.createProfileScreen),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Common widget
  Widget _buildScreenTitle(
    BuildContext context, {
    required String screenTitle,
    Function? onTapScreenTitle,
  }) {
    return GestureDetector(
      onTap: () {
        onTapScreenTitle?.call();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color(0XFFFFFFFF),
        ),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.h),
              child: Text(
                screenTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0XFF000000),
                  fontSize: 20.fSize,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            SizedBox(height: 5.h),
            Divider(
              height: 1.h,
              thickness: 1.h,
              color: Color(0XFF000000),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigates to the specified route.
  onTapScreenTitle(String routeName) {
    NavigatorService.pushNamed(routeName);
  }
}
