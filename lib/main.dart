import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'core/app_export.dart';
import 'package:get/get.dart' as GetX;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'services/subscription_status_manager.dart';
import 'services/user_service.dart';
import 'services/user_stats_manager.dart';
import 'services/revenuecat_service.dart';
import 'services/revenuecat_offering_manager.dart';
import 'services/demo_timer_service.dart';
import 'services/user_feedback_service.dart';
import 'presentation/app_navigation_screen/app_navigation_screen.dart';
import 'presentation/feedback_screen/feedback_screen.dart';
import 'presentation/subscription_screen/subscription_screen.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

var globalMessengerKey = GlobalKey<ScaffoldMessengerState>();
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((value) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize services
    await initDependencies();
    
    await PrefUtils().init();
    GetX.Get.put(PrefUtils());
    PrefUtils prefUtils = GetX.Get.find<PrefUtils>();
    UserStatsManager statsManager = UserStatsManager();
    
    // Log current configuration
    debugPrint('🔄 Starting app with configuration:');
    debugPrint('   Dark mode: ${prefUtils.getThemeData() == 'dark'}');
    debugPrint('   Stats tracking: ${statsManager.isDataLoaded}');
    debugPrint('   Demo timer started: ${prefUtils.getTimerStartTime() > 0}');
    
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
    
    // Initialize RevenueCat and subscription manager - don't await this
    _initializeBackgroundServices();
    
    // Trigger background preloading of subscription data without awaiting
    Future.microtask(() => _preloadSubscriptionData());
    
    runApp(MyApp());
  });
}

/// Initialize services in the background to not block app launch
void _initializeBackgroundServices() {
  Future.microtask(() async {
    try {
      // Pre-warm RevenueCat service
      final revenueCatService = RevenueCatService();
      revenueCatService.initialize().timeout(
        Duration(seconds: 20),
        onTimeout: () {
          print('⚠️ RevenueCat initialization timed out - will retry when needed');
          return;
        }
      ).then((_) {
        // Once initialized, pre-fetch offerings in the background
        _fetchRevenueCatOfferings();
      }).catchError((e) {
        print('⚠️ RevenueCat initialization failed: $e');
      });
    } catch (e) {
      print('⚠️ Background services initialization failed: $e');
    }
  });
}

/// Initialize all services needed at app startup
Future<void> _initializeServices() async {
  // This function is kept for backward compatibility
  // All initialization is now done in _initializeBackgroundServices
  print('⚙️ Initializing other services...');
  
  try {
    final subscriptionStatusManager = SubscriptionStatusManager();
    await subscriptionStatusManager.initialize();
    print('✅ Subscription status manager initialized');
  } catch (e) {
    print('⚠️ Subscription status manager initialization failed: $e');
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

/// Fetch RevenueCat offerings in the background after initialization.
Future<void> _fetchRevenueCatOfferings() async {
  print('🔄 Initiating background pre-fetch of RevenueCat offerings...');
  final offeringManager = RevenueCatOfferingManager();

  try {
    // Fetch all offerings. This also populates the internal cache in RevenueCatOfferingManager.
    final Offerings? offerings = await offeringManager.fetchAndDisplayOfferings();

    if (offerings == null) {
      print('⚠️ Failed to fetch offerings in background. Result was null.');
      return; // Exit if fetching failed
    }

    print('✅ RevenueCat offerings fetched successfully in background.');

    // Check the current offering specifically (e.g., the one marked "default")
    final Offering? currentOffering = offerings.current;
    if (currentOffering == null) {
      print('   ⚠️ No "Current" offering found in fetched data.');
    } else {
      print('   📦 Current Offering ID: ${currentOffering.identifier}');
      print('   📦 Packages available in Current Offering: ${currentOffering.availablePackages.length}');
      if (currentOffering.availablePackages.isEmpty) {
        print('      ⚠️ The Current offering has no packages attached.');
      } else {
         for (var package in currentOffering.availablePackages) {
          print('      - Package: ${package.identifier}');
          print('        Product: ${package.storeProduct.identifier} (${package.storeProduct.title})');
          print('        Price: ${package.storeProduct.priceString}');
        }
      }
    }

    // Attempt to retrieve specific packages using the manager's logic
    // This tests if the expected packages can be found within the current offering
    print('   ℹ️ Attempting to locate specific packages using RevenueCatOfferingManager...');
    final Package? monthlyPackage = offeringManager.getMonthlyPackage();
    final Package? lifetimePackage = offeringManager.getLifetimePackage();

    print('   📦 Result of getMonthlyPackage(): ${monthlyPackage != null ? 'Found (${monthlyPackage.identifier})' : 'Not Found'}');
    print('   📦 Result of getLifetimePackage(): ${lifetimePackage != null ? 'Found (${lifetimePackage.identifier})' : 'Not Found'}');

  } on PlatformException catch (e) {
    print('❌ PlatformException during background offerings pre-fetch: ${e.message} (Code: ${e.code})');
  } catch (e) {
    print('❌ Unexpected error during background offerings pre-fetch: $e');
  }
}

Future<void> initDependencies() async {
  // Initialize payment services
  await RevenueCatService().initialize();
  
  // Initialize subscription status manager
  await SubscriptionStatusManager.instance.initialize();
  
  // Initialize demo timer
  await DemoTimerService().initialize();
  
  // Initialize user stats
  await UserStatsManager().initialize();
  
  // Initialize services for logged in users
  if (FirebaseAuth.instance.currentUser != null) {
    debugPrint('📊 Initializing services for logged in user');
    
    // Initialize user feedback service
    await UserFeedbackService().initializeFeedbackDataIfNeeded();
    
    // Debug: Check current feedback status
    try {
      final feedbackStatus = await UserFeedbackService().getFeedbackStatus();
      debugPrint('📊 Current feedback status during app init: ${feedbackStatus.value}');
    } catch (e) {
      debugPrint('❌ Error checking status during init: $e');
    }
  } else {
    debugPrint('📊 No user logged in, skipping user services initialization');
  }
  
  // Log dependencies initialized
  debugPrint('♻️ Dependencies initialized');
}

// Preload subscription data as early as possible if user is logged in
Future<void> _preloadSubscriptionData() async {
  try {
    await SubscriptionStatusManager.instance.prefetchSubscriptionStatus();
  } catch (e) {
    debugPrint('Error preloading subscription data: $e');
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Flags to determine which screen to show initially
  bool _shouldShowFeedback = false;
  bool _shouldShowSubscription = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _checkInitialScreen();
  }

  Future<void> _checkInitialScreen() async {
    // Only proceed with checks if a user is logged in
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        // First, check if feedback screen should be shown
        bool shouldShowFeedback = await UserFeedbackService().shouldShowFeedback();
        debugPrint('👉 Initial screen check: Should show feedback = $shouldShowFeedback');
        
        // Only check for subscription if feedback is not needed
        bool shouldShowSubscription = false;
        if (!shouldShowFeedback) {
          // Simple check - if user doesn't have premium, show subscription
          final isPremium = await SubscriptionStatusManager.instance.checkSubscriptionStatus();
          debugPrint('👉 User premium status: $isPremium');
          
          // If not premium and feedback is completed, show subscription
          shouldShowSubscription = !isPremium;
          debugPrint('👉 Should show subscription = $shouldShowSubscription');
        }
        
        if (mounted) {
          setState(() {
            _shouldShowFeedback = shouldShowFeedback;
            _shouldShowSubscription = shouldShowSubscription;
            _isInitializing = false;
          });
          
          debugPrint('🔄 Final screen decision:');
          debugPrint('   Show feedback: $_shouldShowFeedback');
          debugPrint('   Show subscription: $_shouldShowSubscription');
        }
      } catch (e) {
        debugPrint('❌ Error during initial screen check: $e');
        if (mounted) {
          setState(() {
            _isInitializing = false;
          });
        }
      }
    } else {
      // No user logged in, no need to show special screens
      debugPrint('👉 No user logged in, skipping special screens');
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      // Show loading screen while checking what initial screen to display
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Color(0xFFFFF9F4),
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFF6F3E),
            ),
          ),
        ),
      );
    }

    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
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
                // Determine which screen to show as the initial screen
                home: _determineHomeScreen(),
                routes: AppRoutes.routes,
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
  
  // Helper method to determine which screen to show
  Widget _determineHomeScreen() {
    // Priority order:
    // 1. Feedback screen (if needed)
    // 2. Subscription screen (if feedback completed and subscription needed)
    // 3. Normal app navigation screen
    
    if (_shouldShowFeedback) {
      return FeedbackScreen();
    } else if (_shouldShowSubscription) {
      return SubscriptionScreen();
    } else {
      return AppNavigationScreen.builder(context);
    }
  }
}
