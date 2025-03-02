import 'package:flutter/material.dart';
import '../core/app_export.dart';

enum BottomBarEnum { Home, Vocabulary, Learning, Progress, Profile }

// ignore_for_file: must_be_immutable
class CustomBottomBar extends StatefulWidget {
  CustomBottomBar({this.onChanged});

  Function(BottomBarEnum)? onChanged;

  @override
  CustomBottomBarState createState() => CustomBottomBarState();
}

// ignore_for_file: must_be_immutable
class CustomBottomBarState extends State<CustomBottomBar> {
  int selectedIndex = 0;

  List<BottomMenuModel> bottomMenuList = [
    BottomMenuModel(
      icon: ImageConstant.imgNavHomeDeepOrangeA200,
      activeIcon: ImageConstant.imgNavHomeDeepOrangeA200,
      title: "lbl_home".tr,
      type: BottomBarEnum.Home,
    ),
    BottomMenuModel(
      icon: ImageConstant.imgNavVocabularyGray600,
      activeIcon: ImageConstant.imgNavVocabularyGray600,
      title: "lbl_vocabulary".tr,
      type: BottomBarEnum.Vocabulary,
    ),
    BottomMenuModel(
      icon: ImageConstant.imgNavLearning,
      activeIcon: ImageConstant.imgNavLearning,
      title: "lbl_learning".tr,
      type: BottomBarEnum.Learning,
    ),
    BottomMenuModel(
      icon: ImageConstant.imgNavProgress,
      activeIcon: ImageConstant.imgNavProgress,
      title: "lbl_progress".tr,
      type: BottomBarEnum.Progress,
    ),
    BottomMenuModel(
      icon: ImageConstant.imgNavProfile,
      activeIcon: ImageConstant.imgNavProfile,
      title: "lbl_profile".tr,
      type: BottomBarEnum.Profile,
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appTheme.gray5001,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.primary,
            width: 2.h,
          ),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedFontSize: 0,
        elevation: 0,
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        items: List.generate(bottomMenuList.length, (index) {
          return BottomNavigationBarItem(
            icon: SizedBox(
              width: double.maxFinite,
              child: Column(
                spacing: 4,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomImageView(
                    imagePath: bottomMenuList[index].icon,
                    height: 20.h,
                    width: 22.h,
                    color: appTheme.gray600,
                  ),
                  Text(
                    bottomMenuList[index].title ?? "",
                    style: CustomTextStyles.labelLargeGray600.copyWith(
                      color: appTheme.gray600,
                    ),
                  )
                ],
              ),
            ),
            activeIcon: Column(
              spacing: 4,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomImageView(
                  imagePath: bottomMenuList[index].activeIcon,
                  height: 4.h,
                  width: 10.h,
                  color: appTheme.deepOrangeA200,
                ),
                CustomImageView(
                  imagePath: bottomMenuList[index].activeIcon,
                  height: 20.h,
                  width: 20.h,
                  color: appTheme.deepOrangeA200,
                ),
                Text(
                  bottomMenuList[index].title ?? "",
                  style: CustomTextStyles.labelLargeDeeporangeA200Bold.copyWith(
                    color: appTheme.deepOrangeA200,
                  ),
                )
              ],
            ),
            label: '',
          );
        }),
        onTap: (index) {
          selectedIndex = index;
          widget.onChanged?.call(bottomMenuList[index].type);
          setState(() {});
        },
      ),
    );
  }
}

// ignore_for_file: must_be_immutable
class BottomMenuModel {
  BottomMenuModel(
      {required this.icon,
      required this.activeIcon,
      this.title,
      required this.type});

  String icon;

  String activeIcon;

  String? title;

  BottomBarEnum type;
}

class DefaultWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xffffffff),
      padding: EdgeInsets.all(10),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Please replace the respective Widget here',
              style: TextStyle(
                fontSize: 18,
              ),
            )
          ],
        ),
      ),
    );
  }
}
