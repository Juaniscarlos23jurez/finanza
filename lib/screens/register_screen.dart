import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';
import 'onboarding_screen.dart';

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
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  bool _isLoading = false;
  bool _isAIEnabled = false;
  bool _showAIError = false;

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena todos los campos')),
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

    _processAuthResult(result);
  }

  Future<void> _handleGoogleSignIn() async {

    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null) {
        throw Exception('No se pudo obtener el ID Token de Google');
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final String? idToken = await userCredential.user?.getIdToken();

      if (idToken != null) {
        final result = await _authService.loginWithFirebaseIdToken(
          idToken: idToken,
          provider: 'google.com',
        );
        _processAuthResult(result);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error con Google: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAppleSignIn() async {

    setState(() => _isLoading = true);
    try {
      final appleProvider = AppleAuthProvider();
      appleProvider.addScope('email');
      appleProvider.addScope('name');
      
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithProvider(appleProvider);
      final String? idToken = await userCredential.user?.getIdToken();

      if (idToken != null) {
        final result = await _authService.loginWithFirebaseIdToken(
          idToken: idToken,
          provider: 'apple.com',
        );
        _processAuthResult(result);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error con Apple: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _processAuthResult(Map<String, dynamic> result) async {
    if (result['success']) {
      if (!mounted) return;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('ai_enabled', true); // Default true now that we move consent to usage
      final bool onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => onboardingCompleted ? const MainScreen() : const OnboardingScreen(),
        ),
        (route) => false,
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
                'Crear\nCuenta.',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 48),
              CustomTextField(
                label: 'Nombre',
                controller: _nameController,
                hintText: 'John Doe',
              ),
              const SizedBox(height: 24),
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
              const SizedBox(height: 16),
              const SizedBox(height: 24),
              CustomButton(
                text: _isLoading ? 'Registrando...' : 'Registrarse',
                onPressed: _isLoading ? () {} : _handleRegister,
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
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: _isLoading ? '...' : 'Google',
                      onPressed: _isLoading ? () {} : _handleGoogleSignIn,
                      isOutlined: true,
                      icon: FontAwesomeIcons.google,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: _isLoading ? '...' : 'Apple',
                      onPressed: _isLoading ? () {} : _handleAppleSignIn,
                      isOutlined: true,
                      icon: FontAwesomeIcons.apple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.secondary,
                            height: 1.5,
                          ),
                      children: [
                        const TextSpan(text: 'Al registrarte, aceptas nuestros '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: GestureDetector(
                            onTap: () async {
                              final uri = Uri.parse('https://fynlink.shop/terminos_y_privacidad_app_clientes_html.html#terminos');
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              }
                            },
                            child: Text(
                              'Términos y Condiciones',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                            ),
                          ),
                        ),
                        const TextSpan(text: ', la '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: GestureDetector(
                            onTap: () async {
                              final uri = Uri.parse('https://fynlink.shop/terminos_y_privacidad_app_clientes_html.html#privacidad');
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              }
                            },
                            child: Text(
                              'Política de Privacidad',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                            ),
                          ),
                        ),
                        const TextSpan(text: ' y el uso de '),
                        TextSpan(
                          text: 'IA (Google Gemini)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const TextSpan(text: '.'),
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
