import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:untitled2/screens/After%20feedback/thank_you_screen.dart';
import 'package:untitled2/screens/After_registration/after_register_screen.dart';
import 'package:untitled2/screens/dashboard/dashboard_screen.dart';
import 'package:untitled2/screens/feedback/feedback_screen.dart';
import 'package:untitled2/screens/login/login_screen.dart';
import 'package:untitled2/screens/register/register_screen.dart';
import 'package:untitled2/screens/splash_screen.dart';
import 'package:untitled2/screens/welcome_screen/welcome_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_stripe/flutter_stripe.dart';



class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

void main() async {
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firebase messaging initialization
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Get the device token for sending push notifications
  String? token = await messaging.getToken();
  print("Device Token: $token");

  // Request permission to send notifications on iOS
  NotificationSettings settings = await messaging.requestPermission();
  print('User granted permission: ${settings.authorizationStatus}');

  Stripe.publishableKey = 'pk_test_51QozdgE4AvnS7JdujCdMrR5GYRnT9wWs0h2EshJWLYRD4ZTMFKW5vt9PXfsaX3fjR6glVxnn2NpOX5Sa0Ia05E4m00QCJsaMt5';
  Stripe.instance.applySettings(); // Apply default settings

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Smart Citizen',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
            useMaterial3: true,
          ),
          darkTheme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.lightBlue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => SplashScreen(),
            '/login': (context) => LoginScreen(),
            '/dashboard': (context) => DashboardScreen(),
          },
        );
      },
    );
  }
}
