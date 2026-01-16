import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterTabs(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildDateSeparator('HOY'),
                  _buildTransactionItem('Netflix Subscription', 'Ocio', '-\$12.99', Icons.play_circle_outline, Colors.redAccent),
                  _buildTransactionItem('Starbucks Coffee', 'Comida', '-\$5.50', Icons.coffee_outlined, Colors.orangeAccent),
                  _buildTransactionItem('Salary Deposit', 'Trabajo', '+\$2,450.00', Icons.account_balance_wallet_outlined, Colors.greenAccent),
                  const SizedBox(height: 24),
                  _buildDateSeparator('AYER'),
                  _buildTransactionItem('Apple Store Charge', 'Tech', '-\$199.00', Icons.laptop_mac_outlined, Colors.grey),
                  _buildTransactionItem('Uber Trip', 'Transporte', '-\$15.20', Icons.directions_car_outlined, Colors.blueAccent),
                  _buildTransactionItem('Freelance Project', 'Trabajo', '+\$400.00', Icons.code_rounded, Colors.greenAccent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Movimientos',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppTheme.primary,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.search_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        children: [
          _buildTab('Todos', true),
          _buildTab('Ingresos', false),
          _buildTab('Gastos', false),
          _buildTab('Mensual', false),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primary : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: isSelected ? Colors.white : AppTheme.secondary,
        ),
      ),
    );
  }

  Widget _buildDateSeparator(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppTheme.secondary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildTransactionItem(String title, String category, String amount, IconData icon, Color color) {
    bool isIncome = amount.startsWith('+');
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                Text(
                  category,
                  style: GoogleFonts.manrope(color: AppTheme.secondary, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w900,
              fontSize: 15,
              color: isIncome ? Colors.green : AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
