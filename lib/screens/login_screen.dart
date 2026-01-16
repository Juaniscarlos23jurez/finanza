import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'main_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Text(
                'Welcome\nBack.',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 48),
              const CustomTextField(
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              const CustomTextField(
                label: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: 'Sign In',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Divider(color: AppTheme.secondary.withValues(alpha: 0.3))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Expanded(child: Divider(color: AppTheme.secondary.withValues(alpha: 0.3))),
                ],
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Continue with Google',
                onPressed: () {},
                isOutlined: true,
                icon: FontAwesomeIcons.google,
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Continue with Apple',
                onPressed: () {},
                isOutlined: true,
                icon: FontAwesomeIcons.apple,
              ),
              const SizedBox(height: 40),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: 'Sign up',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
