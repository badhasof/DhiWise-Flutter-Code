import 'package:flutter/material.dart';
import '../presentation/app_navigation_screen/app_navigation_screen.dart';
import '../presentation/create_profile_screen/create_profile_screen.dart';
import '../presentation/onboardimg_screen/onboardimg_screen.dart';
import '../presentation/quiz_four_eight_screen/quiz_four_eight_screen.dart';
import '../presentation/quiz_four_five_screen/quiz_four_five_screen.dart';
import '../presentation/quiz_four_four_screen/quiz_four_four_screen.dart';
import '../presentation/quiz_four_nine_screen/quiz_four_nine_screen.dart';
import '../presentation/quiz_four_one_screen/quiz_four_one_screen.dart';
import '../presentation/quiz_four_screen/quiz_four_screen.dart';
import '../presentation/quiz_four_seven_screen/quiz_four_seven_screen.dart';
import '../presentation/quiz_four_six_screen/quiz_four_six_screen.dart';
import '../presentation/quiz_four_ten_screen/quiz_four_ten_screen.dart';
import '../presentation/quiz_four_three_screen/quiz_four_three_screen.dart';
import '../presentation/quiz_four_two_screen/quiz_four_two_screen.dart';
import '../presentation/quiz_one_one_screen/quiz_one_one_screen.dart';
import '../presentation/quiz_one_screen/quiz_one_screen.dart';
import '../presentation/quiz_screen/quiz_screen.dart';
import '../presentation/quiz_three_one_screen/quiz_three_one_screen.dart';
import '../presentation/quiz_three_screen/quiz_three_screen.dart';
import '../presentation/quiz_two_one_screen/quiz_two_one_screen.dart';
import '../presentation/quiz_two_screen/quiz_two_screen.dart';
import '../presentation/sign_in_screen/sign_in_screen.dart';

class AppRoutes {
  static const String onboardimgScreen = '/onboardimg_screen';

  static const String quizScreen = '/quiz_screen';

  static const String quizOneScreen = '/quiz_one_screen';

  static const String quizOneOneScreen = '/quiz_one_one_screen';

  static const String quizTwoScreen = '/quiz_two_screen';

  static const String quizTwoOneScreen = '/quiz_two_one_screen';

  static const String quizThreeScreen = '/quiz_three_screen';

  static const String quizThreeOneScreen = '/quiz_three_one_screen';

  static const String quizFourScreen = '/quiz_four_screen';

  static const String quizFourOneScreen = '/quiz_four_one_screen';

  static const String createProfileScreen = '/create_profile_screen';

  static const String quizFourTwoScreen = '/quiz_four_two_screen';

  static const String quizFourThreeScreen = '/quiz_four_three_screen';

  static const String quizFourFourScreen = '/quiz_four_four_screen';

  static const String quizFourFiveScreen = '/quiz_four_five_screen';

  static const String quizFourSixScreen = '/quiz_four_six_screen';

  static const String quizFourSevenScreen = '/quiz_four_seven_screen';

  static const String quizFourEightScreen = '/quiz_four_eight_screen';

  static const String quizFourNineScreen = '/quiz_four_nine_screen';

  static const String quizFourTenScreen = '/quiz_four_ten_screen';

  static const String signInScreen = '/sign_in_screen';

  static const String appNavigationScreen = '/app_navigation_screen';

  static const String initialRoute = '/initialRoute';

  static Map<String, WidgetBuilder> get routes => {
        onboardimgScreen: OnboardimgScreen.builder,
        quizScreen: QuizScreen.builder,
        quizOneScreen: QuizOneScreen.builder,
        quizOneOneScreen: QuizOneOneScreen.builder,
        quizTwoScreen: QuizTwoScreen.builder,
        quizTwoOneScreen: QuizTwoOneScreen.builder,
        quizThreeScreen: QuizThreeScreen.builder,
        quizThreeOneScreen: QuizThreeOneScreen.builder,
        quizFourScreen: QuizFourScreen.builder,
        quizFourOneScreen: QuizFourOneScreen.builder,
        createProfileScreen: CreateProfileScreen.builder,
        quizFourTwoScreen: QuizFourTwoScreen.builder,
        quizFourThreeScreen: QuizFourThreeScreen.builder,
        quizFourFourScreen: QuizFourFourScreen.builder,
        quizFourFiveScreen: QuizFourFiveScreen.builder,
        quizFourSixScreen: QuizFourSixScreen.builder,
        quizFourSevenScreen: QuizFourSevenScreen.builder,
        quizFourEightScreen: QuizFourEightScreen.builder,
        quizFourNineScreen: QuizFourNineScreen.builder,
        quizFourTenScreen: QuizFourTenScreen.builder,
        signInScreen: SignInScreen.builder,
        appNavigationScreen: AppNavigationScreen.builder,
        initialRoute: OnboardimgScreen.builder
      };
}
