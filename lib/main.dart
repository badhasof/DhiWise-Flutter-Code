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
import 'services/revenuecat_service.dart';
import 'services/revenuecat_offering_manager.dart';
import 'services/subscription_status_manager.dart';
import 'services/demo_timer_service.dart';
import 'presentation/app_navigation_screen/app_navigation_screen.dart';

var globalMessengerKey = GlobalKey<ScaffoldMessengerState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase successfully initialized');
    
    // Test Firestore connection
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    print('📊 Got Firestore instance');
    
    // Verify if a user is logged in
    final user = FirebaseAuth.instance.currentUser;
    print('👤 Current user: ${user?.uid ?? 'No user logged in'}');
    
  } catch (e) {
    print('❌ Error initializing Firebase: $e');
  }
  
  // Initialize services in the background
  _initializeServices();
  
  // Continue with app launch immediately
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await PrefUtils().init();
  await DemoTimerService.instance.initialize();
  runApp(MyApp());
}

/// Initialize all services needed at app startup
Future<void> _initializeServices() async {
  // Initialize subscription services
  try {
    final revenueCatService = RevenueCatService();
    await revenueCatService.initialize();
    print('✅ RevenueCat service initialized');
  } catch (e) {
    print('⚠️ RevenueCat service initialization failed: $e');
  }
  
  try {
    final offeringManager = RevenueCatOfferingManager();
    await offeringManager.fetchAndDisplayOfferings();
    print('✅ RevenueCat offerings fetched');
  } catch (e) {
    print('⚠️ RevenueCat offerings fetch failed: $e');
  }
  
  try {
    final subscriptionStatusManager = SubscriptionStatusManager();
    await subscriptionStatusManager.initialize();
    print('✅ Subscription status manager initialized');
  } catch (e) {
    print('⚠️ Subscription status manager initialization failed: $e');
  }
  
  try {
    await DemoTimerService.instance.initialize();
    print('✅ Demo timer service initialized');
  } catch (e) {
    print('⚠️ Demo timer service initialization failed: $e');
  }
  
  try {
    final subscriptionService = SubscriptionService();
    await subscriptionService.initialize();
    print('✅ Legacy subscription service initialized');
  } catch (e) {
    print('⚠️ Legacy subscription service initialization failed: $e');
  }
  
  // Initialize user service and check for existing user data
  final userService = UserService();
  if (userService.isLoggedIn) {
    try {
      await userService.initializeUserDataIfNeeded();
      
      // Pre-fetch user stats and profile data
      print('🔄 Pre-fetching user data...');
      await UserStatsManager().initialize();
      print('✅ User data pre-fetched successfully');
    } catch (e) {
      print('⚠️ User data initialization failed: $e');
    }
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
                home: AppNavigationScreen.builder(context), // Use AppNavigationScreen as home
                routes: AppRoutes.routes, // Add routes for navigation between screens
                onGenerateRoute: (settings) {
                  // Handle any routes that aren't explicitly defined
                  print('⚠️ Attempting to navigate to undefined route: ${settings.name}');
                  return MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(title: Text('Navigation Error')),
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Could not navigate to: ${settings.name}'),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('Go Back'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
