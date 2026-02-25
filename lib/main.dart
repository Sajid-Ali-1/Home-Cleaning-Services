import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/services/fcm_service_account_helper.dart';
import 'package:home_cleaning_app/services/notification_service.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/views/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _loadEnv();
  await Firebase.initializeApp();
  // Initialize FCM service account (for HTTP v1 API)
  try {
    await FcmServiceAccountHelper.initialize();
  } catch (e) {
    debugPrint('Warning: FCM Service Account initialization failed: $e');
    debugPrint('Push notifications may not work. Check your .env file.');
  }
  try {
    await _configureStripe();
  } catch (e) {
    debugPrint('Warning: Stripe initialization failed: $e');
    debugPrint(
      'Payments will be disabled. Please check your Android MainActivity configuration.',
    );
  }
  await NotificationService.initialize();
  await AppTheme.initialize();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

Future<void> _loadEnv() async {
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('Successfully loaded .env from root directory');
  } catch (e) {
    // warn if attempt failed
    debugPrint('Warning: Could not load .env file from root: $e');
    debugPrint('FCM Service Account will not be initialized.');
    debugPrint('Stripe will not be initialized.');
    // Load empty env to prevent crashes
    dotenv.env;
  }
}

Future<void> _configureStripe() async {
  final publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'];
  if (publishableKey == null || publishableKey.isEmpty) {
    debugPrint('Stripe publishable key missing. Payments disabled.');
    return;
  }
  Stripe.publishableKey = publishableKey;
  Stripe.merchantIdentifier =
      dotenv.env['STRIPE_MERCHANT_IDENTIFIER'] ?? 'merchant.com.home.cleaning';
  await Stripe.instance.applySettings();
}

class _MyAppState extends State<MyApp> {
  // ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode _themeMode = AppTheme.themeMode;

  void setThemeMode(ThemeMode mode) => setState(() {
    _themeMode = mode;
    AppTheme.saveThemeMode(mode);
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,

      builder: (context, child) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Home Cleaning Services',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        home: SplashScreen(),
      ),
    );
  }
}
