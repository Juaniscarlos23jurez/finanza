import 'package:firebase_auth/firebase_auth.dart';
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
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final String? savedLocale = prefs.getString('user_locale');
  if (savedLocale != null) {
    LocaleSettings.instance.setLocale(Locale(savedLocale));
    await initializeDateFormatting(savedLocale, null);
    Intl.defaultLocale = savedLocale;
  } else {
    await initializeDateFormatting('es', null);
    Intl.defaultLocale = 'es';
  }
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


  final String? token = prefs.getString('auth_token');
  final bool onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
  
  // Ensure Firebase is authenticated if we have a token (social users are already handled, 
  // but email users or app restarts need this for Realtime Database access).
  if (token != null && FirebaseAuth.instance.currentUser == null) {
    try {
      debugPrint('Startup: Authenticating anonymously with Firebase for Database access...');
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      debugPrint('Startup: Error in anonymous auth: $e');
    }
  }

  debugPrint('Startup Check - Token: ${token != null}, Onboarding: $onboardingCompleted');
  if (FirebaseAuth.instance.currentUser != null) {
    debugPrint('Startup Check - Firebase UID: ${FirebaseAuth.instance.currentUser?.uid}');
  }

  Widget initialScreen;
  if (token != null) {
    initialScreen = onboardingCompleted ? const MainScreen() : const OnboardingScreen();
  } else {
    initialScreen = const LoginScreen();
  }

  runApp(MyApp(initialScreen: initialScreen));
}

class LocaleSettings {
  LocaleSettings._();
  static final LocaleSettings instance = LocaleSettings._();
  
  final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('es'));

  Future<void> setLocale(Locale locale) async {
    localeNotifier.value = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_locale', locale.languageCode);
    Intl.defaultLocale = locale.languageCode;
    await initializeDateFormatting(locale.languageCode, null);
  }
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleSettings.instance.localeNotifier,
      builder: (context, locale, _) {
        return MaterialApp(
          title: 'NutriGPT AI',
          theme: AppTheme.theme,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('es', ''),
            Locale('en', ''),
            Locale('de', ''),
            Locale('fr', ''),
            Locale('ja', ''),
            Locale('it', ''),
            Locale('pt', ''),
          ],
          locale: locale,
          home: initialScreen,
        );
      },
    );
  }
}
