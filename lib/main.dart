import 'package:firebase_core/firebase_core.dart';
import 'package:nutrigpt/screens/login_screen.dart';
import 'package:nutrigpt/screens/main_screen.dart';
import 'package:nutrigpt/screens/onboarding_screen.dart';
import 'package:nutrigpt/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  Intl.defaultLocale = 'es';
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
  final bool onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
  
  debugPrint('Startup Check - Token: ${token != null}, Onboarding: $onboardingCompleted');

  Widget initialScreen;
  if (token != null) {
    initialScreen = onboardingCompleted ? const MainScreen() : const OnboardingScreen();
  } else {
    initialScreen = const LoginScreen();
  }

  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriGPT AI',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', ''), // Spanish
        Locale('en', ''), // English
      ],
      locale: const Locale('es', ''),
      home: initialScreen,
    );
  }
}
