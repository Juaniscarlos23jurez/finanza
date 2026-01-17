import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

      if (mounted) {
        setState(() {
          _summary = summary;
          _categoryStats = stats;
          _goals = goals;
          _recentTransactions = recent;
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

  double get _totalBalance => 
    ((_summary['total_income'] ?? 0) as num).toDouble() - ((_summary['total_expense'] ?? 0) as num).toDouble();

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
                  if (mounted) Navigator.pop(context);
                  _fetchFinanceData(); // Refresh UI
                } catch (e) {
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
    
    // Take top 3 for display
    if (sortedEntries.length > 3) {
      sortedEntries = sortedEntries.sublist(0, 3);
    }

    final topCategory = sortedEntries.isNotEmpty ? sortedEntries.first : null;

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
            // Show percentage of the top category
            child: Center(
              child: Text(
                '${topCategory?.value.toStringAsFixed(0)}%',
                style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: sortedEntries.map((e) {
                // Assign simplified colors for now
                Color color = Colors.grey;
                if (e.key.toLowerCase().contains('comida')) color = Colors.orange;
                else if (e.key.toLowerCase().contains('renta')) color = Colors.blue;
                else if (e.key.toLowerCase().contains('ocio')) color = Colors.purple;
                else color = AppTheme.primary.withValues(alpha: 0.5);

                return _buildCategoryItem(e.key, '${e.value.toStringAsFixed(1)}%', color);
              }).toList(),
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
