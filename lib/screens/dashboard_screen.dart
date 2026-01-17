import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/finance_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FinanceService _financeService = FinanceService();
  StreamSubscription? _updateSubscription;
  bool _isLoading = true;
  Map<String, dynamic> _summary = {
    'total_income': 0.0,
    'total_expense': 0.0,
    'total_cost': 0.0,
  };
  Map<String, double> _categoryStats = {};

  List<dynamic> _goals = [];
  List<dynamic> _recentTransactions = [];
  List<FlSpot> _balanceHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchFinanceData();
    _updateSubscription = _financeService.onDataUpdated.listen((_) {
      _fetchFinanceData();
    });
  }

  @override
  void dispose() {
    _updateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchFinanceData() async {
    try {
      final futures = await Future.wait([
        _financeService.getFinanceData(),
        _financeService.getGoals(),
      ]);

      final data = futures[0] as Map<String, dynamic>;
      final goals = futures[1] as List<dynamic>;

      final summary = data['summary'] as Map<String, dynamic>;
      final records = data['records'] as List<dynamic>;

      // Sort for recent transactions
      records.sort((a, b) {
        final dateA = DateTime.tryParse(a['date'] ?? '') ?? DateTime(2000);
        final dateB = DateTime.tryParse(b['date'] ?? '') ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });
      final recent = records.take(5).toList();

      // Calculate category stats client-side
      final Map<String, double> stats = {};
      double totalExpense = 0.0;

      for (var record in records) {
        if (record['type'] == 'expense') {
          final double amount = double.tryParse(record['amount'].toString()) ?? 0.0;
          final String category = record['category'] ?? 'General';
          
          stats[category] = (stats[category] ?? 0.0) + amount;
          totalExpense += amount;
        }
      }

      if (totalExpense > 0) {
        stats.updateAll((key, value) => (value / totalExpense) * 100);
      }

      // Calculate balance history for last 7 days
      final List<FlSpot> historySpots = [];
      double runningBalance = (double.tryParse((summary['total_income'] ?? 0).toString()) ?? 0.0) - 
                             (double.tryParse((summary['total_expense'] ?? 0).toString()) ?? 0.0);
      
      // Group all transactions by date (descending)
      Map<String, double> dailyNet = {};
      for (var record in records) {
        String date = (record['date'] ?? '').toString().split('T')[0];
        if (date.isEmpty) continue;
        
        double amount = double.tryParse(record['amount'].toString()) ?? 0.0;
        if (record['type'] == 'expense') {
          dailyNet[date] = (dailyNet[date] ?? 0.0) - amount;
        } else {
          dailyNet[date] = (dailyNet[date] ?? 0.0) + amount;
        }
      }

      // We want today and the previous 6 days
      DateTime now = DateTime.now();
      for (int i = 0; i < 7; i++) {
        DateTime day = now.subtract(Duration(days: i));
        String dayStr = DateFormat('yyyy-MM-dd').format(day);
        
        // Spot X: 6 (today) down to 0 (6 days ago)
        historySpots.add(FlSpot((6 - i).toDouble(), runningBalance));
        
        // Subtract today's net change to get yesterday's balance
        runningBalance -= (dailyNet[dayStr] ?? 0.0);
      }

      if (mounted) {
        setState(() {
          _summary = summary;
          _categoryStats = stats;
          _goals = goals;
          _recentTransactions = recent;
          _balanceHistory = historySpots.reversed.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Silently fail for now or show snackbar
        debugPrint('Error loading dashboard data: $e');
      }
    }
  }

  double get _totalBalance {
    double balance = (double.tryParse((_summary['total_income'] ?? 0).toString()) ?? 0.0) - (double.tryParse((_summary['total_expense'] ?? 0).toString()) ?? 0.0);
    return balance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : RefreshIndicator(
              onRefresh: _fetchFinanceData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildBalanceCard(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Movimiento de Balance'),
                    const SizedBox(height: 16),
                    _buildHistoryChart(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Tus Metas', onAdd: _showAddGoalDialog),
                    const SizedBox(height: 16),
                    _buildGoalsList(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Gastos por Categoría'),
                    const SizedBox(height: 16),
                    _buildCategoryChart(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Movimientos Recientes'),
                    const SizedBox(height: 16),
                    _buildRecentTransactions(),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  // ... (Header and BalanceCard remain the same) ...
  // ... (Previous methods) ...

  Widget _buildRecentTransactions() {
    if (_recentTransactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Center(child: Text('Sin actividad reciente', style: GoogleFonts.manrope(color: AppTheme.secondary))),
      );
    }

    return Column(
      children: _recentTransactions.map((t) => _buildTransactionItem(t)).toList(),
    );
  }

  Widget _buildHistoryChart() {
    if (_balanceHistory.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 240,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
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
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => AppTheme.primary,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  return LineTooltipItem(
                    '\$ ${barSpot.y.toStringAsFixed(0)}',
                    GoogleFonts.manrope(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1000,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withValues(alpha: 0.05),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < 7) {
                    final date = DateTime.now().subtract(Duration(days: 6 - index));
                    return Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        DateFormat('E').format(date).substring(0, 1),
                        style: GoogleFonts.manrope(
                          color: AppTheme.secondary.withValues(alpha: 0.6), 
                          fontSize: 10, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _balanceHistory,
              isCurved: true,
              color: AppTheme.primary,
              barWidth: 5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 3,
                  strokeColor: AppTheme.primary,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [AppTheme.primary.withValues(alpha: 0.2), AppTheme.primary.withValues(alpha: 0.0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
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
    
    // Simple icon logic (reused conceptualy)
    IconData icon = Icons.attach_money;
    if (category.toLowerCase().contains('comida')) icon = Icons.restaurant;
    if (category.toLowerCase().contains('transporte')) icon = Icons.directions_car;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isIncome ? Colors.green : AppTheme.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: isIncome ? Colors.green : AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(
                  item['date'] ?? '',
                  style: GoogleFonts.manrope(fontSize: 10, color: AppTheme.secondary),
                ),
              ],
            ),
          ),
          Text(
            amountStr,
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w800,
              color: isIncome ? Colors.green : AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ... (Keep existing methods: _buildHeader, _buildBalanceCard, _buildSectionTitle, _showAddGoalDialog, _buildGoalsList, _buildGoalCard, _buildCategoryChart, _buildCategoryItem) ...

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, Juan', // Could fetch from profile if desired
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: AppTheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Panel de Control',
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
            'SALDO TOTAL',
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.6),
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${_totalBalance.toStringAsFixed(2)}',
            style: GoogleFonts.manrope(
              fontSize: 36,
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildMiniStat(
                'Ingresos', 
                '+\$${(_summary['total_income'] ?? 0).toStringAsFixed(0)}', 
                Colors.greenAccent
              ),
              const SizedBox(width: 32),
              _buildMiniStat(
                'Egresos', 
                '-\$${(_summary['total_expense'] ?? 0).toStringAsFixed(0)}', 
                Colors.redAccent
              ),
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

  Widget _buildSectionTitle(String title, {VoidCallback? onAdd}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
              ),
            ),
            if (onAdd != null) ...[
              const SizedBox(width: 12),
              InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, size: 20, color: AppTheme.primary),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  void _showAddGoalDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Nueva Meta', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Nombre de la meta (ej. Viaje)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Monto objetivo (\$)', prefixText: '\$'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                final double? amount = double.tryParse(amountController.text);
                if (titleController.text.isEmpty || amount == null) return;

                setDialogState(() => isSaving = true);
                
                try {
                  await _financeService.createGoal({
                    'title': titleController.text,
                    'target_amount': amount,
                    'current_amount': 0,
                    'deadline': DateTime.now().add(const Duration(days: 90)).toIso8601String().split('T')[0],
                  });
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  _fetchFinanceData(); // Refresh UI
                } catch (e) {
                  if (!context.mounted) return;
                  setDialogState(() => isSaving = false);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: isSaving 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildGoalsList() {
    if (_goals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            'No tienes metas activas',
            style: GoogleFonts.manrope(color: AppTheme.secondary),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _goals.map((goal) {
          final double target = double.tryParse(goal['target_amount'].toString()) ?? 1.0;
          final double current = double.tryParse(goal['current_amount'].toString()) ?? 0.0;
          final double progress = (current / target).clamp(0.0, 1.0);
          final String title = goal['title'] ?? 'Meta';

          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildGoalCard(
              title, 
              progress, 
              '\$${current.toStringAsFixed(0)} / \$${target.toStringAsFixed(0)}'
            ),
          );
        }).toList(),
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
    if (_categoryStats.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            'No hay gastos registrados',
            style: GoogleFonts.manrope(color: AppTheme.secondary),
          ),
        ),
      );
    }

    // Sort categories by percentage descending
    var sortedEntries = _categoryStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Take top 5 for display
    final displayEntries = sortedEntries.take(5).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 60,
                sections: displayEntries.map((e) {
                  return PieChartSectionData(
                    color: _getChartColor(e.key),
                    value: e.value,
                    title: '${e.value.toStringAsFixed(0)}%',
                    radius: 20,
                    showTitle: e.value > 5,
                    titleStyle: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: displayEntries.map((e) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _getChartColor(e.key),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    e.key,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.secondary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _getChartColor(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('comida')) return Colors.orangeAccent;
    if (cat.contains('renta') || cat.contains('hogar')) return Colors.blueAccent;
    if (cat.contains('ocio') || cat.contains('entretenimiento')) return Colors.purpleAccent;
    if (cat.contains('transporte') || cat.contains('viajes')) return Colors.cyanAccent;
    if (cat.contains('salud')) return Colors.redAccent;
    return AppTheme.primary.withValues(alpha: 0.7);
  }


}
