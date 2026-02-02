import 'package:flutter/material.dart';
import 'package:geminifinanzas/l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../services/auth_service.dart';
import 'onboarding_screen.dart';
import 'main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.fillAllFields)),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.register(
      name: name,
      email: email,
      password: password,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        (route) => false,
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    debugPrint('Step 1: Button Pressed - Starting Google Sign In (Register)');
    setState(() => _isLoading = true);
    try {
      debugPrint('Step 2: Opening Google Account Selector');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        debugPrint('Step 2: Aborted - User closed the selector');
        setState(() => _isLoading = false);
        return;
      }
      debugPrint('Step 3: Account Selected: ${googleUser.email}');

      debugPrint('Step 4: Getting Authentication Tokens');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      debugPrint('Step 4: ID Token obtained (length: ${googleAuth.idToken?.length})');

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint('Step 5: Authenticating with Firebase using Credential');
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      debugPrint('Step 6: Firebase Auth Success: ${userCredential.user?.uid}');

      final String? idToken = await userCredential.user?.getIdToken();
      debugPrint('Step 7: Firebase idToken extracted (length: ${idToken?.length})');

      if (idToken != null) {
        debugPrint('Step 8: Sending idToken to Laravel Backend');
        final result = await _authService.loginWithFirebaseIdToken(
          idToken: idToken,
          provider: 'google.com',
        );
        debugPrint('Step 9: Backend Result Success: ${result['success']}');
        _processAuthResult(result);
      } else {
        debugPrint('Error: idToken is NULL after Firebase login');
      }
    } catch (e) {
      debugPrint('CRITICAL ERROR during Google Sign In: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.googleError(e.toString()))),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAppleSignIn() async {
    debugPrint('Step 1: Apple Button Pressed (Register)');
    setState(() => _isLoading = true);
    try {
      debugPrint('Step 2: Starting Apple Auth Provider Flow');
      final appleProvider = AppleAuthProvider();
      appleProvider.addScope('email');
      appleProvider.addScope('name');
      
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithProvider(appleProvider);
      
      debugPrint('Step 3: Apple/Firebase Auth Success: ${userCredential.user?.uid}');
      final String? idToken = await userCredential.user?.getIdToken();
      debugPrint('Step 4: Firebase idToken extracted (length: ${idToken?.length})');

      if (idToken != null) {
        debugPrint('Step 5: Sending Apple idToken to Laravel Backend');
        final result = await _authService.loginWithFirebaseIdToken(
          idToken: idToken,
          provider: 'apple.com',
        );
        debugPrint('Step 6: Backend Result Success: ${result['success']}');
        _processAuthResult(result);
      } else {
        debugPrint('Error: Apple idToken is NULL');
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: No se pudo obtener el token de autenticación.')),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('CRITICAL ERROR during Apple Sign In (Firebase): ${e.code} - ${e.message}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Apple Auth Error: ${e.message} (Code: ${e.code})')),
      );
    } catch (e) {
      debugPrint('CRITICAL ERROR during Apple Sign In: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.appleError(e.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _processAuthResult(Map<String, dynamic> result) async {
    if (result['success']) {
      if (!mounted) return;
      
      final bool onboardingComplete = await _authService.isOnboardingComplete();
      if (!mounted) return;

      if (onboardingComplete) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          (route) => false,
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.createAccount,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 48),
              CustomTextField(
                label: AppLocalizations.of(context)!.name,
                controller: _nameController,
                hintText: 'John Doe',
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: AppLocalizations.of(context)!.email,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                hintText: 'john@example.com',
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: AppLocalizations.of(context)!.password,
                controller: _passwordController,
                obscureText: true,
                hintText: '••••••••',
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: _isLoading ? AppLocalizations.of(context)!.registering : AppLocalizations.of(context)!.signUp,
                onPressed: _isLoading ? () {} : _handleRegister,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Divider(color: AppTheme.secondary.withValues(alpha: 0.3))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      AppLocalizations.of(context)!.or,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Expanded(child: Divider(color: AppTheme.secondary.withValues(alpha: 0.3))),
                ],
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: _isLoading ? AppLocalizations.of(context)!.loading : AppLocalizations.of(context)!.continueWithGoogle,
                onPressed: _isLoading ? () {} : _handleGoogleSignIn,
                isOutlined: true,
                icon: FontAwesomeIcons.google,
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: _isLoading ? AppLocalizations.of(context)!.loading : AppLocalizations.of(context)!.continueWithApple,
                onPressed: _isLoading ? () {} : _handleAppleSignIn,
                isOutlined: true,
                icon: FontAwesomeIcons.apple,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
