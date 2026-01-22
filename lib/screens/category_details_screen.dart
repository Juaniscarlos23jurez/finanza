import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/finance_service.dart';

class CategoryDetailsScreen extends StatefulWidget {
  const CategoryDetailsScreen({super.key});

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  final FinanceService _financeService = FinanceService();
  bool _isLoading = true;
  Map<String, double> _categoryAmounts = {};
  double _totalExpense = 0.0;

  // Colors for categories to match Dashboard
  Color _getCategoryColor(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('comida')) return Colors.orangeAccent;
    if (cat.contains('renta') || cat.contains('hogar')) return Colors.blueAccent;
    if (cat.contains('ocio') || cat.contains('entretenimiento')) return Colors.purpleAccent;
    if (cat.contains('transporte') || cat.contains('viajes')) return Colors.cyanAccent;
    if (cat.contains('salud')) return Colors.redAccent;
    return AppTheme.primary.withValues(alpha: 0.7);
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _financeService.getFinanceData();
      final records = data['records'] as List<dynamic>;

      final Map<String, double> amounts = {};
      double total = 0.0;

      for (var record in records) {
        if (record['type'] == 'expense') {
          final double amount = double.tryParse(record['amount'].toString()) ?? 0.0;
          final String category = record['category'] ?? 'General';
          
          amounts[category] = (amounts[category] ?? 0.0) + amount;
          total += amount;
        }
      }

      if (mounted) {
        setState(() {
          _categoryAmounts = amounts;
          _totalExpense = total;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading category details: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedEntries = _categoryAmounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Detalle de Gastos',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : sortedEntries.isEmpty
              ? Center(
                  child: Text(
                    'No hay gastos registrados',
                    style: GoogleFonts.manrope(
                      color: AppTheme.secondary,
                      fontSize: 16,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: sortedEntries.length,
                  itemBuilder: (context, index) {
                    final entry = sortedEntries[index];
                    final category = entry.key;
                    final amount = entry.value;
                    final percentage = _totalExpense > 0 ? (amount / _totalExpense * 100) : 0.0;
                    final color = _getCategoryColor(category);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                '${percentage.toStringAsFixed(0)}%',
                                style: GoogleFonts.manrope(
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category,
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: percentage / 100,
                                  backgroundColor: color.withValues(alpha: 0.1),
                                  color: color,
                                  minHeight: 6,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '\$${amount.toStringAsFixed(0)}',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
