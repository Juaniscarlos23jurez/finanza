import 'dart:async';
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
  StreamSubscription? _updateSubscription;
  bool _isLoading = true;
  bool _showCharts = false;
  List<dynamic> _allTransactions = [];
  List<dynamic> _filteredTransactions = [];
  String _currentFilter = 'Todos';
  double _currentTotalBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
    _updateSubscription = _financeService.onDataUpdated.listen((_) {
      _fetchTransactions();
    });
  }

  @override
  void dispose() {
    _updateSubscription?.cancel();
    super.dispose();
  }

      final data = await _financeService.getFinanceData();
      final records = data['records'] as List<dynamic>;
      final summary = data['summary'] as Map<String, dynamic>;
      
      // Calculate current balance from summary
      double income = (summary['total_income'] as num?)?.toDouble() ?? 0.0;
      double expense = (summary['total_expense'] as num?)?.toDouble() ?? 0.0;
      
      // Sort by date descending
      records.sort((a, b) {
        DateTime dateA = DateTime.parse(a['date'] ?? DateTime.now().toString());
        DateTime dateB = DateTime.parse(b['date'] ?? DateTime.now().toString());
        return dateB.compareTo(dateA); // Newest first
      });

      if (mounted) {
        setState(() {
          _allTransactions = records;
          _currentTotalBalance = income - expense;
          _applyFilter(_currentFilter);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
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

  Map<String, Map<String, double>> _calculateDailyBalances() {
    if (_currentFilter != 'Todos') return {}; // Only sensible for 'Todos'

    Map<String, Map<String, double>> dailyBalances = {};
    double runningBalance = _currentTotalBalance;

    // Use a copy of all transactions sorted DESC (already sorted in fetch)
    // We need to group them first to handle day boundaries correctly while iterating backwards?
    // Actually, iterating strictly backwards record by record is easier.
    
    // Group first to iterate day by day
    Map<String, List<dynamic>> byDay = {};
    for (var t in _allTransactions) {
      String dateStr = t['date'] ?? DateTime.now().toIso8601String();
      String key = _getDateLabel(DateTime.parse(dateStr));
      if (!byDay.containsKey(key)) byDay[key] = [];
      byDay[key]!.add(t);
    }

    // Iterate keys (Dates) in order (assuming they are inserted in order because _allTransactions is sorted)
    // Keys in Dart Map from _allTransactions loop should preserve insertion order (descending date)
    
    for (var key in byDay.keys) {
      double close = runningBalance;
      double netChange = 0.0;
      
      for (var t in byDay[key]!) {
        double amount = (t['amount'] as num).toDouble();
        bool isIncome = t['type'] == 'income';
        if (isIncome) {
          netChange += amount;
        } else {
          netChange -= amount;
        }
      }

      // Open = Close - NetChange
      // (e.g. Started with 100, earned 50. Close = 150. Open = 150 - 50 = 100).
      double open = close - netChange;
      
      dailyBalances[key] = {'open': open, 'close': close};
      
      // Update running balance for the NEXT iteration (yesterday's close is today's open)
      runningBalance = open;
    }

    return dailyBalances;
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
            height: 350, // Increased height for legend
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
                const SizedBox(height: 24),
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
                Text('Últimos 7 Días (Gastos)', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 24),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: barData.map((e) => e.barRods.first.toY).fold(0.0, (p, c) => p > c ? p : c) * 1.2,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => Colors.blueGrey,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                             return BarTooltipItem(
                               '\$${rod.toY.toStringAsFixed(0)}',
                               const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                             );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < 7) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    DateFormat('E').format(DateTime.now().subtract(Duration(days: 6 - index))).substring(0, 1),
                                    style: GoogleFonts.manrope(color: AppTheme.secondary, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
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

  // ... _getPieData ...
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
        // Hack to store category name for legend logic loop if needed, 
        // but our legend builder re-calculates or needs access to map keys.
        // Simplified: The builder above just regenerated sections. We need to pass meaningful data to legend.
      );
    }).toList();
  }

  // ... _getWeeklySpendingData ...

  Widget _buildLegend(List<PieChartSectionData> sections) {
    // Re-derive categories from filtered transactions since sections don't hold the string key easily accessible 
    // without a custom data class extension.
    Map<String, double> categoryTotals = {};
    for (var t in _filteredTransactions) {
      double amount = double.tryParse(t['amount'].toString()) ?? 0.0;
      String cat = t['category'] ?? 'Otros';
      categoryTotals[cat] = (categoryTotals[cat] ?? 0.0) + amount;
    }
    
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: categoryTotals.entries.map((e) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12, height: 12,
              decoration: BoxDecoration(color: _getCategoryColor(e.key), shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              e.key,
              style: GoogleFonts.manrope(color: AppTheme.secondary, fontSize: 12, fontWeight: FontWeight.w600),
            ),
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

    final dailyBalances = _calculateDailyBalances();

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
        final balances = dailyBalances[key]; // {'open': X, 'close': Y}
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateSeparator(key, open: balances?['open'], close: balances?['close']),
            ...items.map((item) => _buildTransactionItem(item)),
          ],
        );
      },
    );
  }

  Widget _buildDateSeparator(String label, {double? open, double? close}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
              letterSpacing: 1.2,
            ),
          ),
          if (open != null && close != null)
            Row(
              children: [
                _buildSmallBalance('Abre:', open),
                const SizedBox(width: 12),
                _buildSmallBalance('Cierra:', close),
              ],
            )
        ],
      ),
    );
  }
  
  Widget _buildSmallBalance(String label, double amount) {
    return Row(
      children: [
        Text(
          '$label ',
          style: GoogleFonts.manrope(fontSize: 10, color: AppTheme.secondary, fontWeight: FontWeight.bold),
        ),
        Text(
          '\$${amount.toStringAsFixed(0)}',
          style: GoogleFonts.manrope(fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.w900),
        ),
      ],
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amountStr,
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: isIncome ? Colors.green : AppTheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => _showEditDialog(item),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(Icons.edit_rounded, size: 16, color: AppTheme.secondary.withValues(alpha: 0.5)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> item) {
    if (item['id'] == null) return;
    
    final descController = TextEditingController(text: item['description']);
    final amountController = TextEditingController(text: item['amount'].toString());
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Editar Movimiento', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Monto'),
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
                if (descController.text.isEmpty || amount == null) return;

                setDialogState(() => isSaving = true);
                
                try {
                  await _financeService.updateRecord(item['id'], {
                    'description': descController.text,
                    'amount': amount,
                    // Keep existing values for others
                    'category': item['category'],
                    'type': item['type'],
                    'date': item['date'],
                  });
                  if (mounted) Navigator.pop(context);
                  // Refresh happens automatically via stream
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
