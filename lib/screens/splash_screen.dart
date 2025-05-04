import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:untitled2/screens/Complaint%20Screen/complaint_screen.dart';
import 'package:untitled2/screens/NewsScreen.dart';
import 'package:untitled2/screens/dashboard/dashboard_screen.dart';
import 'package:untitled2/screens/login/login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Stack(
        children: [
          // Background animation (Lottie file)
          Positioned.fill(
            child: LottieBuilder.asset(
              "assets/lottie/anm2.json", // Your background animation
              repeat: true, // Ensure the background animation loops
              fit: BoxFit.cover, // Ensure it fills the entire screen
            ),
          ),
          // Foreground content (Your main Lottie animation)
          Center(
            child: LottieBuilder.asset(
              "assets/lottie/anm3.json", // Foreground animation
              repeat: true, // Ensure it loops
              fit: BoxFit.contain, // Adjust as needed for proper sizing
            ),
          ),
        ],
      ),
      nextScreen: LoginScreen(),
      splashIconSize: double.infinity, // Full screen
      backgroundColor: Colors.transparent, // Transparent background to show animations
    );
  }
}
