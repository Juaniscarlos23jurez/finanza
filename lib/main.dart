import 'package:firebase_core/firebase_core.dart';
import 'package:geminifinanzas/screens/login_screen.dart';
import 'package:geminifinanzas/screens/main_screen.dart';
import 'package:geminifinanzas/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:provider/provider.dart';
import 'package:geminifinanzas/l10n/app_localizations.dart';
import 'package:geminifinanzas/providers/locale_provider.dart';

import 'package:geminifinanzas/widgets/connectivity_wrapper.dart';

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

  // Initialize AdMob
  try {
    await MobileAds.instance.initialize();
    debugPrint('AdMob initialized successfully');
  } catch (e) {
    debugPrint('Error initializing AdMob: $e');
  }

  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('auth_token');
  debugPrint('Startup Token Check: ${token != null ? "Token Found" : "No Token"}');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: MyApp(initialScreen: token != null ? const MainScreen() : const LoginScreen()),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          title: 'Digital Minimalist Finance',
          theme: AppTheme.theme,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: localeProvider.locale,
          home: initialScreen,
          builder: (context, child) {
            return ConnectivityWrapper(child: child!);
          },
        );
      },
    );
  }
}
