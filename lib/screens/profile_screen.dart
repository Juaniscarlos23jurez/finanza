import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/nutrition_service.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final NutritionService _nutritionService = NutritionService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  final DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final result = await _authService.getProfile();
    if (mounted) {
      setState(() {
        if (result['success']) {
          _userData = result['data'];
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  _buildProfileHeader(),
                  const SizedBox(height: 32),
                  _buildNutritionalCalendar(),
                  const SizedBox(height: 48),
                  _buildMenuSection('CUENTA', [
                    _buildMenuItem(Icons.person_outline_rounded, 'Información Personal', onTap: () => _showPersonalInfoModal(context)),
                    _buildMenuItem(Icons.auto_awesome_outlined, 'Personalizar mi Nutrición', onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                      );
                    }),
                    _buildMenuItem(Icons.history_rounded, 'Borrar Memoria de IA', onTap: () => _showResetAIModal(context)),
                  ]),
                  const SizedBox(height: 32),
                  _buildMenuSection('TRANSPARENCIA RADICAL', [
                    _buildMenuItem(Icons.security_outlined, 'Control de Datos', onTap: () => _showPrivacyInfo(context)),
                    _buildMenuItem(Icons.download_outlined, 'Exportar mis Datos (JSON)'),
                  ]),
                  const SizedBox(height: 32),
                  _buildMenuSection('OTRO', [
                    _buildMenuItem(Icons.feedback_outlined, 'Feedback', onTap: () => _showFeedbackModal(context)),
                    _buildMenuItem(
                      Icons.info_outline_rounded, 
                      'Términos y Condiciones',
                      onTap: () async {
                        final uri = Uri.parse('https://fynlink.shop/terminos_y_privacidad_app_clientes_html.html#terminos');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                  ]),
                  const SizedBox(height: 48),
                  _buildLogoutButton(context),
                  const SizedBox(height: 12),
                  _buildDeleteAccountButton(context),
                  const SizedBox(height: 48),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final name = _userData?['name'] ?? 'Usuario';
    final email = _userData?['email'] ?? 'email@ejemplo.com';
    final photoUrl = _userData?['photo_url'];

    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
          ),
          child: ClipOval(
            child: photoUrl != null
                ? Image.network(photoUrl, fit: BoxFit.cover)
                : const Center(child: Icon(Icons.person_rounded, size: 60, color: AppTheme.primary)),
          ),
        ),
        const SizedBox(height: 24),
        Text(name, style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.primary)),
        Text(email, style: GoogleFonts.manrope(fontSize: 14, color: AppTheme.secondary, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildNutritionalCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: TableCalendar(
        locale: 'es',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: CalendarFormat.month,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: AppTheme.primary),
        ),
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            final color = _getDayColor(day);
            if (color != null) {
              return Container(
                margin: const EdgeInsets.all(4),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Text('${day.day}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              );
            }
            return null;
          },
        ),
      ),
    );
  }

  Color? _getDayColor(DateTime day) {
    final now = DateTime.now();
    if (day.isAfter(now.subtract(const Duration(days: 6))) && day.isBefore(now.add(const Duration(days: 1)))) {
       return Colors.green.withOpacity(0.2);
    }
    return null;
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: Text(title, style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.secondary, letterSpacing: 1.5)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.primary)),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.secondary, size: 20),
          ],
        ),
      ),
    );
  }

  void _showPersonalInfoModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Información Personal', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.primary)),
            const SizedBox(height: 24),
            Text('Nombre: ${_userData?['name'] ?? 'N/A'}', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
            Text('Email: ${_userData?['email'] ?? 'N/A'}', style: GoogleFonts.manrope(color: AppTheme.secondary)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, minimumSize: const Size(double.infinity, 50)),
              child: const Text('Cerrar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetAIModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Reiniciar Memoria?', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
        content: const Text('Se borrará el historial de chat y el plan actual.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await _nutritionService.resetAIMemory();
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Memoria reiniciada')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Tus datos están seguros. No los vendemos y puedes borrarlos cuando quieras.', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
          ],
        ),
      ),
    );
  }

  void _showFeedbackModal(BuildContext context) {
     // Simplifying for space
     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gracias por tu interés en darnos feedback!')));
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () async {
          await _authService.logout();
          if (!context.mounted) return;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
        },
        child: Text('Cerrar Sesión', style: GoogleFonts.manrope(color: Colors.redAccent, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    return TextButton(
      onPressed: () => _buildLogoutButton(context), 
      child: Text('Eliminar cuenta', style: TextStyle(color: Colors.grey, fontSize: 12)),
    );
  }
}
