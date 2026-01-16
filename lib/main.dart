import 'package:finanzas/screens/login_screen.dart';
import 'package:finanzas/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Minimalist Finance',
      theme: AppTheme.theme, // Use the custom theme
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(), // Start with LoginScreen
    );
  }
}
