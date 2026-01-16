import 'package:firebase_core/firebase_core.dart';
import 'package:finanzas/screens/login_screen.dart';
import 'package:finanzas/screens/main_screen.dart';
import 'package:finanzas/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('--- APP STARTING ---');
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('Dotenv loaded successfully');
  } catch (e) {
    debugPrint('Error loading .env: $e');
  }
  
  try {
    await Firebase.initializeApp();
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }

  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('auth_token');
  debugPrint('Startup Token Check: ${token != null ? "Token Found" : "No Token"}');

  runApp(MyApp(initialScreen: token != null ? const MainScreen() : const LoginScreen()));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Minimalist Finance',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: initialScreen,
    );
  }
}
