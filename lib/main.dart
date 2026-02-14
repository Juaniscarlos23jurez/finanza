import 'package:firebase_core/firebase_core.dart';
import 'package:geminifinanzas/screens/login_screen.dart';
import 'package:geminifinanzas/screens/main_screen.dart';
import 'package:geminifinanzas/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:provider/provider.dart';
import 'package:geminifinanzas/l10n/app_localizations.dart';
import 'package:geminifinanzas/providers/locale_provider.dart';

import 'package:geminifinanzas/widgets/connectivity_wrapper.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:geminifinanzas/services/ad_service.dart';
import 'dart:io';

import 'package:geminifinanzas/screens/onboarding_screen.dart';
import 'package:geminifinanzas/services/auth_service.dart';
import 'package:geminifinanzas/services/app_version_service.dart';
import 'package:url_launcher/url_launcher.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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

  // Request Tracking Permission for iOS (ATT)
  if (Platform.isIOS) {
    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        // Wait a bit to ensure the app is in the foreground
        await Future.delayed(const Duration(milliseconds: 1000));
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } catch (e) {
      debugPrint('Error requesting tracking authorization: $e');
    }
  }

  // Initialize AdMob and Remote Config
  try {
    await AdService().initialize();
    debugPrint('AdService initialized successfully');
  } catch (e) {
    debugPrint('Error initializing AdService: $e');
  }

  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('auth_token');
  debugPrint('Startup Token Check: ${token != null ? "Token Found" : "No Token"}');

  Widget initialScreen = const LoginScreen();
  
  if (token != null) {
    debugPrint('Main: Token detected, checking onboarding...');
    final authService = AuthService();
    try {
      final bool onboardingComplete = await authService.isOnboardingComplete();
      debugPrint('Main: Onboarding status: $onboardingComplete');
      if (onboardingComplete) {
        debugPrint('Main: Navigating to MainScreen');
        initialScreen = const MainScreen();
      } else {
        debugPrint('Main: Navigating to OnboardingScreen (incomplete)');
        initialScreen = const OnboardingScreen();
      }
    } catch (e) {
      debugPrint('Main: CRITICAL ERROR during startup onboarding check: $e');
      initialScreen = const LoginScreen();
    }
  } else {
    debugPrint('Main: No token found, showing LoginScreen');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: MyApp(
        initialScreen: initialScreen,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUpdate();
    });
  }

  Future<void> _checkUpdate() async {
    final service = AppVersionService();
    final status = await service.checkAppVersion();

    if (status.state != UpdateState.noUpdate) {
      final context = navigatorKey.currentContext; // Use navigatorKey context
      if (context != null && mounted) {
        _showUpdateDialog(context, status);
      }
    }
  }

  void _showUpdateDialog(BuildContext context, AppUpdateStatus status) {
    final bool isForce = status.state == UpdateState.forceUpdate;
    final l10n = AppLocalizations.of(context)!;
    String storeUrl = status.storeUrl ?? '';

    // Override iOS URL as requested
    if (Platform.isIOS) {
      storeUrl = 'https://apps.apple.com/us/app/fingenius/id6757898883';
    }

    showDialog(
      context: context,
      barrierDismissible: !isForce,
      builder: (context) => PopScope(
        canPop: !isForce,
        child: AlertDialog(
          title: Text(isForce ? l10n.mandatoryUpdate : l10n.updateAvailable),
          content: Text(
            isForce
                ? l10n.updateMessageMandatory(status.latestVersion ?? "latest")
                : l10n.updateMessageOptional(status.latestVersion ?? "latest"),
          ),
          actions: [
            if (!isForce)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.later),
              ),
            TextButton(
              onPressed: () {
                if (storeUrl.isNotEmpty) {
                  _launchURL(storeUrl);
                }
              },
              child: Text(l10n.update),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
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
          home: widget.initialScreen,
          builder: (context, child) {
            return ConnectivityWrapper(child: child!);
          },
        );
      },
    );
  }
}
