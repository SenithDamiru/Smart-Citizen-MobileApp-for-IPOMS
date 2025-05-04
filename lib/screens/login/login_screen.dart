import 'dart:ui';

import 'package:flutter/material.dart';
import '../register/register_screen.dart';
import 'login_form.dart';
import 'social_login_buttons.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Blurred gradient background
          Container(
            height: MediaQuery.of(context).size.height, // Full screen height
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB4CDED), Color(0xFF2E76EA)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Positioned(
            top: 75,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.8), // Adjust opacity
                border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  'assets/images/img5.png',
                  fit: BoxFit.contain,
                  semanticLabel: 'App Logo',
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 180),
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8), // Adjust opacity
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(0.8)),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          Text(
                            'Login',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.64,
                            ),
                            semanticsLabel: 'Login Screen Title',
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Enter your email and password to log in',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF6C7278),
                              letterSpacing: -0.12,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const LoginForm(),
                          const SizedBox(height: 24),
                          const SocialLoginButtons(),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF6C7278),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => RegistrationScreen()));
                                },
                                child: Text(
                                  'Sign Up',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF4D81E7),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
