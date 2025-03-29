import 'package:flutter/material.dart';
import '../presentation/app_navigation_screen/app_navigation_screen.dart';
import '../presentation/create_profile_screen/create_profile_screen.dart';
import '../presentation/create_profile_one_screen/create_profile_one_screen.dart';
import '../presentation/create_profile_two_screen/create_profile_two_screen.dart';
import '../presentation/onboardimg_screen/onboardimg_screen.dart';
import '../presentation/quiz_four_screen/quiz_four_screen.dart';
import '../presentation/quiz_one_screen/quiz_one_screen.dart';
import '../presentation/quiz_screen/quiz_screen.dart';
import '../presentation/quiz_three_screen/quiz_three_screen.dart';
import '../presentation/quiz_two_screen/quiz_two_screen.dart';
import '../presentation/sign_in_screen/sign_in_screen.dart';
import '../presentation/home_screen/home_initial_page.dart';
import '../presentation/home_screen/home_screen.dart';
import '../presentation/profile_page/profile_page.dart';
import '../presentation/vocabulary_page/vocabulary_page.dart';
import '../presentation/sign_up_screen/sign_up_screen.dart';
import '../presentation/learning_page/learning_page.dart';
import '../presentation/progress_page/progress_page.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/notification_settings_screen/notification_settings_screen.dart';
import '../presentation/reminders_settings_screen/reminders_settings_screen.dart';
import '../presentation/friends_settings_screen/friends_settings_screen.dart';
import '../presentation/leaderboards_settings_screen/leaderboards_settings_screen.dart';
import '../presentation/announcements_settings_screen/announcements_settings_screen.dart';
import '../presentation/new_stories_completion_screen/new_stories_completion_screen.dart';
import '../presentation/demo_time_screen/demo_time_screen.dart';
import '../presentation/feedback_screen/feedback_screen.dart';
import '../presentation/subscription_screen/subscription_screen.dart';
import '../presentation/product_test_screen/product_test_screen.dart';
import '../presentation/firebase_test_screen.dart';

class AppRoutes {
  static const String onboardimgScreen = '/onboardimg_screen';

  static const String quizScreen = '/quiz_screen';

  static const String quizOneScreen = '/quiz_one_screen';

  static const String quizTwoScreen = '/quiz_two_screen';

  static const String quizThreeScreen = '/quiz_three_screen';

  static const String quizFourScreen = '/quiz_four_screen';

  static const String createProfileScreen = '/create_profile_screen';
  
  static const String createProfileOneScreen = '/create_profile_one_screen';
  
  static const String createProfileTwoScreen = '/create_profile_two_screen';

  static const String signInScreen = '/sign_in_screen';

  static const String signUpScreen = '/sign_up_screen';

  static const String appNavigationScreen = '/app_navigation_screen';

  static const String initialRoute = '/initialRoute';
  
  static const String homeInitialPage = '/home_initial_page';
  
  static const String vocabularyPage = '/vocabulary_page';
  
  static const String learningPage = '/learning_page';
  
  static const String progressPage = '/progress_page';
  
  static const String profilePage = '/profile_page';
  
  static const String homeScreen = '/home_screen';
  
  static const String settingsScreen = '/settings_screen';
  
  static const String notificationSettingsScreen = '/notification_settings_screen';
  
  static const String remindersSettingsScreen = '/reminders_settings_screen';
  
  static const String friendsSettingsScreen = '/friends_settings_screen';
  
  static const String leaderboardsSettingsScreen = '/leaderboards_settings_screen';
  
  static const String announcementsSettingsScreen = '/announcements_settings_screen';
  
  static const String newStoriesCompletionScreen = '/new_stories_completion_screen';
  
  static const String demoTimeScreen = '/demo_time_screen';

  static const String feedbackScreen = '/feedback_screen';

  static const String subscriptionScreen = '/subscription_screen';
  
  static const String productTestScreen = '/product_test_screen';

  static const String firebaseTestScreen = '/firebase_test_screen';

  static Map<String, WidgetBuilder> get routes => {
        onboardimgScreen: OnboardimgScreen.builder,
        quizScreen: QuizScreen.builder,
        quizOneScreen: QuizOneScreen.builder,
        quizTwoScreen: QuizTwoScreen.builder,
        quizThreeScreen: QuizThreeScreen.builder,
        quizFourScreen: QuizFourScreen.builder,
        createProfileScreen: CreateProfileScreen.builder,
        createProfileOneScreen: CreateProfileOneScreen.builder,
        createProfileTwoScreen: CreateProfileTwoScreen.builder,
        signInScreen: SignInScreen.builder,
        signUpScreen: SignUpScreen.builder,
        appNavigationScreen: AppNavigationScreen.builder,
        initialRoute: AppNavigationScreen.builder,
        homeInitialPage: HomeInitialPage.builder,
        vocabularyPage: VocabularyPage.builder,
        learningPage: LearningPage.builder,
        progressPage: ProgressPage.builder,
        profilePage: ProfilePage.builder,
        homeScreen: HomeScreen.builder,
        settingsScreen: SettingsScreen.builder,
        notificationSettingsScreen: NotificationSettingsScreen.builder,
        remindersSettingsScreen: RemindersSettingsScreen.builder,
        friendsSettingsScreen: FriendsSettingsScreen.builder,
        leaderboardsSettingsScreen: LeaderboardsSettingsScreen.builder,
        announcementsSettingsScreen: AnnouncementsSettingsScreen.builder,
        newStoriesCompletionScreen: NewStoriesCompletionScreen.builder,
        demoTimeScreen: DemoTimeScreen.builder,
        feedbackScreen: FeedbackScreen.builder,
        subscriptionScreen: SubscriptionScreen.builder,
        productTestScreen: ProductTestScreen.builder,
        firebaseTestScreen: FirebaseTestScreen.builder
      };
}
