import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/finance_service.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final FinanceService _financeService = FinanceService();
  bool _isLoading = true;
  bool _showCharts = false;
  List<dynamic> _allTransactions = [];
  List<dynamic> _filteredTransactions = [];
  String _currentFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      final data = await _financeService.getFinanceData();
      final records = data['records'] as List<dynamic>;
      
      // Sort by date descending
      records.sort((a, b) {
        DateTime dateA = DateTime.parse(a['date'] ?? DateTime.now().toString());
        DateTime dateB = DateTime.parse(b['date'] ?? DateTime.now().toString());
        return dateB.compareTo(dateA);
      });

      if (mounted) {
        setState(() {
          _allTransactions = records;
          _applyFilter(_currentFilter);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Clean fail, maybe show empty state
      }
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      _currentFilter = filter;
      if (filter == 'Todos') {
        _filteredTransactions = List.from(_allTransactions);
      } else if (filter == 'Ingresos') {
        _filteredTransactions = _allTransactions.where((t) => t['type'] == 'income').toList();
      } else if (filter == 'Gastos') {
        _filteredTransactions = _allTransactions.where((t) => t['type'] == 'expense').toList();
      }
    });
  }

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
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : _showCharts 
                  ? _buildChartsView()
                  : _buildTransactionsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsView() {
    if (_filteredTransactions.isEmpty) {
      return Center(child: Text('No hay datos para graficar', style: GoogleFonts.manrope(color: AppTheme.secondary)));
    }

    // Process data for charts
    final pieData = _getPieData();
    final barData = _getWeeklySpendingData();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Container(
            height: 300,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Text('Distribución', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 24),
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: pieData,
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildLegend(pieData),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 300,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Últimos 7 Días', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 24),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: barData.map((e) => e.barRods.first.toY).fold(0.0, (p, c) => p > c ? p : c) * 1.2,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < 7) {
                                return Text(
                                  DateFormat('E').format(DateTime.now().subtract(Duration(days: 6 - index))).substring(0, 1),
                                  style: GoogleFonts.manrope(color: AppTheme.secondary, fontSize: 10),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: barData,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getPieData() {
    Map<String, double> categoryTotals = {};
    double total = 0.0;

    for (var t in _filteredTransactions) {
      double amount = double.tryParse(t['amount'].toString()) ?? 0.0;
      String cat = t['category'] ?? 'Otros';
      categoryTotals[cat] = (categoryTotals[cat] ?? 0.0) + amount;
      total += amount;
    }

    return categoryTotals.entries.map((e) {
      final isLarge = e.value / total > 0.15;
      return PieChartSectionData(
        color: _getCategoryColor(e.key),
        value: e.value,
        title: '${(e.value / total * 100).toStringAsFixed(0)}%',
        radius: isLarge ? 60 : 50,
        titleStyle: GoogleFonts.manrope(
          fontSize: isLarge ? 14 : 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _getWeeklySpendingData() {
    final now = DateTime.now();
    List<BarChartGroupData> groups = [];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      double dailyTotal = 0.0;
      
      for (var t in _filteredTransactions) {
        final tDate = DateTime.parse(t['date']);
        if (tDate.year == date.year && tDate.month == date.month && tDate.day == date.day) {
           dailyTotal += double.tryParse(t['amount'].toString()) ?? 0.0;
        }
      }

      groups.add(
        BarChartGroupData(
          x: 6 - i,
          barRods: [
            BarChartRodData(
              toY: dailyTotal,
              color: AppTheme.primary,
              width: 12,
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 1, // Min height placeholder
                color: AppTheme.background,
              ),
            ),
          ],
        ),
      );
    }
    return groups;
  }

  Widget _buildLegend(List<PieChartSectionData> sections) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: sections.map((section) {
        // Find category name from color is tricky without storing it, 
        // simplificaton: we iterate categories again roughly or rely on color
        // For distinct colors it's okay. 
        // Better: We will just skip legend names for this snippet to keep it concise or generic
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(color: section.color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(
              section.value.toStringAsFixed(0),
              style: GoogleFonts.manrope(color: AppTheme.secondary, fontSize: 10),
            )
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTransactionsList() {
    if (_filteredTransactions.isEmpty) {
      return Center(
        child: Text(
          'No hay movimientos',
          style: GoogleFonts.manrope(color: AppTheme.secondary, fontSize: 16),
        ),
      );
    }

    // Group by date
    Map<String, List<dynamic>> groupedResponse = {};
    for (var transaction in _filteredTransactions) {
      String dateStr = transaction['date'] ?? DateTime.now().toIso8601String();
      DateTime date = DateTime.parse(dateStr);
      String key = _getDateLabel(date);
      
      if (!groupedResponse.containsKey(key)) {
        groupedResponse[key] = [];
      }
      groupedResponse[key]!.add(transaction);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: groupedResponse.length,
      itemBuilder: (context, index) {
        String key = groupedResponse.keys.elementAt(index);
        List<dynamic> items = groupedResponse[key]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateSeparator(key),
            ...items.map((item) => _buildTransactionItem(item)),
          ],
        );
      },
    );
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) return 'HOY';
    if (checkDate == yesterday) return 'AYER';
    return DateFormat('dd MMM, yyyy').format(date).toUpperCase();
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
          InkWell(
            onTap: () => setState(() => _showCharts = !_showCharts),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _showCharts ? AppTheme.primary : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Icon(
                _showCharts ? Icons.list_rounded : Icons.bar_chart_rounded,
                color: _showCharts ? Colors.white : AppTheme.primary,
              ),
            ),
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
          _buildTab('Todos'),
          _buildTab('Ingresos'),
          _buildTab('Gastos'),
        ],
      ),
    );
  }

  Widget _buildTab(String label) {
    bool isSelected = _currentFilter == label;
    return GestureDetector(
      onTap: () => _applyFilter(label),
      child: Container(
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

  Widget _buildTransactionItem(Map<String, dynamic> item) {
    final String title = item['description'] ?? 'Sin descripción';
    final String category = item['category'] ?? 'General';
    final double amountVal = double.tryParse(item['amount'].toString()) ?? 0.0;
    final bool isIncome = item['type'] == 'income';
    final String amountStr = '${isIncome ? "+" : "-"}\$${amountVal.toStringAsFixed(2)}';
    
    final IconData icon = _getCategoryIcon(category);
    final Color color = _getCategoryColor(category);

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
            amountStr,
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

  IconData _getCategoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('code') || cat.contains('dev') || cat.contains('trabajo')) return Icons.code_rounded;
    if (cat.contains('comida') || cat.contains('restaurante')) return Icons.restaurant_rounded;
    if (cat.contains('café') || cat.contains('coffee')) return Icons.coffee_rounded;
    if (cat.contains('transporte') || cat.contains('uber')) return Icons.directions_car_rounded;
    if (cat.contains('ocio') || cat.contains('flix')) return Icons.movie_creation_outlined;
    if (cat.contains('tech') || cat.contains('apple')) return Icons.laptop_mac_rounded;
    if (cat.contains('ahorro')) return Icons.savings_rounded;
    return Icons.account_balance_wallet_outlined;
  }

  Color _getCategoryColor(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('income') || cat.contains('trabajo')) return Colors.green;
    if (cat.contains('ocio')) return Colors.purpleAccent;
    if (cat.contains('comida')) return Colors.orangeAccent;
    if (cat.contains('tech')) return Colors.blueGrey;
    return AppTheme.primary;
  }
}
