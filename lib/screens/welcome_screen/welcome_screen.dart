import 'package:flutter/material.dart';
import 'auth_button.dart';
import 'social_login_button.dart';


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 18),
          child: Column(
            children: [

              const SizedBox(height: 80),
              Image.asset(
                'assets/images/welcome_image.png',
                width: double.infinity,
                fit: BoxFit.contain,
                semanticLabel: 'Welcome illustration',
              ),
              const SizedBox(height: 30),
              Text(
                'Hello, welcome!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Manrope',
                ),
                semanticsLabel: 'Welcome heading',
              ),
              const SizedBox(height: 10),
              Text(
                'Log in or create an account!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF585858),
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Manrope',
                ),
              ),
              const SizedBox(height: 47),
              AuthButton(
                label: 'Register',
                onPressed: () {},
                isPrimary: true,
              ),
              const SizedBox(height: 10),
              AuthButton(
                label: 'Login',
                onPressed: () {},
                isPrimary: false,
              ),
              const SizedBox(height: 20),
              const Divider(
                color: Color(0xFF585858),
                thickness: 0.5,
              ),
              const SizedBox(height: 20),
              SocialLoginButton(
                icon: 'assets/images/google_icon.png',
                label: 'Continue with Google',
                onPressed: () {},
              ),
              const SizedBox(height: 20),
              SocialLoginButton(
                icon: 'assets/images/apple_icon.png',
                label: 'Continue with Apple',
                onPressed: () {},
              ),
              const Spacer(),
              Container(
                width: 139,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}