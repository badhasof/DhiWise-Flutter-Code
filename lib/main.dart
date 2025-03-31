import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'core/app_export.dart';
import 'services/subscription_service.dart';
import 'services/user_service.dart';
import 'services/user_stats_manager.dart';

var globalMessengerKey = GlobalKey<ScaffoldMessengerState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await _initializeFirebase();
  
  // Initialize services
  await _initializeServices();
  
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
  ]).then((value) {
    PrefUtils().init();
    runApp(MyApp());
  });
}

/// Initialize all services needed at app startup
Future<void> _initializeServices() async {
  // Initialize subscription service
  final subscriptionService = SubscriptionService();
  await subscriptionService.initialize();
  
  // Initialize user service and check for existing user data
  await _initUserData();
  
  // Pre-fetch user stats and profile data
  await UserStatsManager().initialize();
}

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    
    final user = FirebaseAuth.instance.currentUser;
    
  } catch (e) {
    // Silently handle Firebase initialization error
  }
}

Future<void> _initUserData() async {
  try {
    final userService = UserService();
    if (userService.isLoggedIn) {
      await userService.initializeUserDataIfNeeded();
    }
  } catch (e) {
    // Silently handle user data initialization error
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return BlocProvider(
          create: (context) => ThemeBloc(
            ThemeState(
              themeType: PrefUtils().getThemeData(),
            ),
          ),
          child: BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return MaterialApp(
                theme: theme,
                title: 'LinguaX',
                builder: (context, child) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.linear(1.0),
                    ),
                    child: child!,
                  );
                },
                navigatorKey: NavigatorService.navigatorKey,
                debugShowCheckedModeBanner: false,
                localizationsDelegates: [
                  AppLocalizationDelegate(),
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate
                ],
                locale: Locale('en', ''),
                supportedLocales: [Locale('en', '')],
                initialRoute: AppRoutes.initialRoute,
                routes: AppRoutes.routes,
              );
            },
          ),
        );
      },
    );
  }
}
