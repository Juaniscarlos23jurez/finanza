import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
              _buildBalanceCard(),
              const SizedBox(height: 32),
              _buildSectionTitle('Tus Metas'),
              const SizedBox(height: 16),
              _buildGoalsList(),
              const SizedBox(height: 32),
              _buildSectionTitle('Gastos por Categoría'),
              const SizedBox(height: 16),
              _buildCategoryChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, Juan',
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: AppTheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Dashboard Central',
              style: GoogleFonts.manrope(
                fontSize: 24,
                color: AppTheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              )
            ],
          ),
          child: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BALANCE TOTAL',
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.6),
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$12,450.00',
            style: GoogleFonts.manrope(
              fontSize: 36,
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildMiniStat('Ingresos', '+\$4,200', Colors.greenAccent),
              const SizedBox(width: 32),
              _buildMiniStat('Egresos', '-\$1,840', Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.6),
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 16,
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.primary,
          ),
        ),
        Text(
          'Ver todo',
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildGoalCard('Viaje Japón', 0.65, '\$3,250 / \$5,000'),
          const SizedBox(width: 16),
          _buildGoalCard('MacBook Pro', 0.40, '\$800 / \$2,000'),
        ],
      ),
    );
  }

  Widget _buildGoalCard(String title, double progress, String detail) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.background,
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 8),
          Text(
            detail,
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: AppTheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primary, width: 10),
            ),
            child: const Center(child: Text('70%')),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: [
                _buildCategoryItem('Comida', '35%', Colors.orange),
                _buildCategoryItem('Renta', '25%', Colors.blue),
                _buildCategoryItem('Ocio', '10%', Colors.purple),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String label, String percent, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(label, style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          Text(percent, style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
