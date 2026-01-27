import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/nutrition_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final NutritionService _nutritionService = NutritionService();
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  void _loadProgress() async {
    final streak = await _nutritionService.calculateDailyStreak();
    if (mounted) setState(() => _streak = streak);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildStreakCard(),
              const SizedBox(height: 32),
              _buildSectionTitle('Hitos Alcanzados'),
              const SizedBox(height: 16),
              _buildMilestonesGrid(),
              const SizedBox(height: 32),
              _buildSectionTitle('Próxima Recompensa'),
              const SizedBox(height: 16),
              _buildRewardCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PROGRESO',
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppTheme.secondary,
            letterSpacing: 2.0,
          ),
        ),
        Text(
          'Espejo de Datos',
          style: GoogleFonts.manrope(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 64),
          const SizedBox(height: 16),
          Text(
            '$_streak Días',
            style: GoogleFonts.manrope(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          Text(
            'Racha de alimentación sana',
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '¡Vas por excelente camino! No rompas la racha para desbloquear el siguiente nivel.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppTheme.primary,
      ),
    );
  }

  Widget _buildMilestonesGrid() {
    final milestones = [
      {'name': 'Primer Paso', 'icon': Icons.flare_rounded, 'unlocked': true},
      {'name': 'Semana Keto', 'icon': Icons.egg_rounded, 'unlocked': true},
      {'name': 'Chef Saludable', 'icon': Icons.restaurant_menu_rounded, 'unlocked': false},
      {'name': 'Hércules', 'icon': Icons.fitness_center_rounded, 'unlocked': false},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: milestones.length,
      itemBuilder: (context, index) {
        final m = milestones[index];
        final bool unlocked = m['unlocked'] as bool;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: unlocked ? Border.all(color: AppTheme.primary.withValues(alpha: 0.1)) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                m['icon'] as IconData,
                color: unlocked ? AppTheme.accent : AppTheme.secondary.withValues(alpha: 0.2),
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                m['name'] as String,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: unlocked ? AppTheme.primary : AppTheme.secondary.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRewardCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 40),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Descuento Amazon Fresh',
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Completa 7 días para obtener un cupón del 5%.',
                  style: GoogleFonts.manrope(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
