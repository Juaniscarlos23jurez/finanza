import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';
import 'onboarding_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  bool _isLoading = false;
  bool _isAIEnabled = true;

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena todos los campos')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final result = await _authService.login(email, password);
    setState(() => _isLoading = false);

    _processAuthResult(result);
  }

  Future<void> _handleGoogleSignIn() async {
    debugPrint('Step 1: Button Pressed - Starting Google Sign In');
    setState(() => _isLoading = true);
    try {
      debugPrint('Step 2: Opening Google Account Selector');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('Step 2: Aborted - User closed the selector');
        setState(() => _isLoading = false);
        return;
      }
      debugPrint('Step 3: Account Selected: ${googleUser.email}');

      debugPrint('Step 4: Getting Authentication Tokens');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      debugPrint('Step 4: ID Token obtained (length: ${googleAuth.idToken?.length})');

      if (googleAuth.idToken == null) {
        throw Exception('No se pudo obtener el ID Token de Google');
      }

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
        throw Exception('No se pudo obtener el token de Firebase');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('FIREBASE AUTH ERROR: ${e.code} - ${e.message}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de Firebase: ${e.message}')),
      );
    } catch (e) {
      debugPrint('CRITICAL ERROR during Google Sign In: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error con Google: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    debugPrint('Step 1: Apple Button Pressed');
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
      }
    } catch (e) {
      debugPrint('CRITICAL ERROR during Apple Sign In: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error con Apple: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _processAuthResult(Map<String, dynamic> result) async {
    if (result['success']) {
      if (!mounted) return;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('ai_enabled', _isAIEnabled);
      final bool onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => onboardingCompleted ? const MainScreen() : const OnboardingScreen(),
        ),
      );
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Text(
                'Bienvenido\nde nuevo.',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 48),
              CustomTextField(
                label: 'Correo Electrónico',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                hintText: 'john@example.com',
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Contraseña',
                controller: _passwordController,
                obscureText: true,
                hintText: '••••••••',
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: _isLoading ? 'Iniciando sesión...' : 'Iniciar Sesión',
                onPressed: _isLoading ? () {} : _handleLogin,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _isAIEnabled,
                      onChanged: (value) {
                        setState(() {
                          _isAIEnabled = value ?? true;
                        });
                      },
                      activeColor: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Habilitar funciones de IA (Google Gemini)',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final uri = Uri.parse('https://fynlink.shop/terminos_y_privacidad_app_clientes_html.html#privacidad');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Text(
                    'Política de Privacidad',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Divider(color: AppTheme.secondary.withValues(alpha: 0.3))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'O',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Expanded(child: Divider(color: AppTheme.secondary.withValues(alpha: 0.3))),
                ],
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: _isLoading ? 'Cargando...' : 'Continuar con Google',
                onPressed: _isLoading ? () {} : _handleGoogleSignIn,
                isOutlined: true,
                icon: FontAwesomeIcons.google,
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: _isLoading ? 'Cargando...' : 'Continuar con Apple',
                onPressed: _isLoading ? () {} : _handleAppleSignIn,
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
                      text: "¿No tienes cuenta? ",
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: 'Regístrate',
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
