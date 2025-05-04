import 'package:flutter/material.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: Colors.white)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Or login with',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6C7278),
                ),
              ),
            ),
            const Expanded(child: Divider(color: Colors.white)),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _SocialButton(
              onPressed: () {},
              icon: 'assets/images/google_icon.png',
              label: 'Google',
            ),
            const SizedBox(width: 15),
            _SocialButton(
              onPressed: () {},
              icon: 'assets/images/apple_icon.png',
              label: 'Apple',
            ),
            const SizedBox(width: 15),
            _SocialButton(
              onPressed: () {},
              icon: 'assets/images/facebook.png',
              label: 'Facebook',
            ),
            const SizedBox(width: 15),
            _SocialButton(
              onPressed: () {},
              icon: 'assets/images/twitter.png',
              label: 'Twitter',
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String icon;
  final String label;

  const _SocialButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MaterialButton(
        onPressed: onPressed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFFEFF0F6)),
        ),
        color: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Image.asset(
          icon,
          width: 18,
          height: 18,
          semanticLabel: '$label login button',
        ),
      ),
    );
  }
}