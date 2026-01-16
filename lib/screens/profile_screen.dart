import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),
              _buildProfileHeader(),
              const SizedBox(height: 48),
              _buildMenuSection('CUENTA', [
                _buildMenuItem(Icons.person_outline_rounded, 'Información Personal'),
                _buildMenuItem(Icons.account_balance_wallet_outlined, 'Métodos de Pago'),
                _buildMenuItem(Icons.notifications_none_rounded, 'Notificaciones'),
              ]),
              const SizedBox(height: 32),
              _buildMenuSection('SEGURIDAD', [
                _buildMenuItem(Icons.lock_outline_rounded, 'Cambiar Contraseña'),
                _buildMenuItem(Icons.fingerprint_rounded, 'Face ID / Touch ID', hasSwitch: true),
              ]),
              const SizedBox(height: 32),
              _buildMenuSection('OTRO', [
                _buildMenuItem(Icons.help_outline_rounded, 'Ayuda y Soporte'),
                _buildMenuItem(Icons.info_outline_rounded, 'Términos y Condiciones'),
              ]),
              const SizedBox(height: 48),
              _buildLogoutButton(context),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                  )
                ],
              ),
              child: const Center(
                child: Icon(Icons.person_rounded, size: 60, color: AppTheme.primary),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Juan Pérez',
          style: GoogleFonts.manrope(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppTheme.primary,
          ),
        ),
        Text(
          'juan.perez@email.com',
          style: GoogleFonts.manrope(
            fontSize: 14,
            color: AppTheme.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppTheme.secondary,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
              )
            ],
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {bool hasSwitch = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
          ),
          if (hasSwitch)
            Switch.adaptive(
              value: true,
              onChanged: (v) {},
              activeColor: AppTheme.primary,
            )
          else
            const Icon(Icons.chevron_right_rounded, color: AppTheme.secondary, size: 20),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          foregroundColor: Colors.redAccent,
        ),
        child: Text(
          'Cerrar Sesión',
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
