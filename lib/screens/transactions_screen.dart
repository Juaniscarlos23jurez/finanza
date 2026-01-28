import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
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
  bool _showCalendar = false;
  List<dynamic> _allTransactions = [];
  List<dynamic> _filteredTransactions = [];
  String _currentFilter = 'Todos';
  double _currentTotalBalance = 0.0;

  // Calendar & Date Range State
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

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

  Future<void> _fetchTransactions() async {
    try {
      if (mounted) setState(() => _isLoading = true);
      
      final data = await _financeService.getFinanceData();
      final records = data['records'] as List<dynamic>;
      final summary = data['summary'] as Map<String, dynamic>;
      
      // Calculate current balance from summary
      double income = double.tryParse(summary['total_income'].toString()) ?? 0.0;
      double expense = double.tryParse(summary['total_expense'].toString()) ?? 0.0;
      
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
      _filteredTransactions = _allTransactions.where((t) {
        bool matchesType = true;
        if (filter == 'Ingresos') matchesType = t['type'] == 'income';
        if (filter == 'Gastos') matchesType = t['type'] == 'expense';

        bool matchesDate = true;
        if (_rangeStart != null) {
          DateTime tDate = DateTime.parse(t['date'] ?? DateTime.now().toIso8601String());
          if (_rangeEnd != null) {
            matchesDate = (tDate.isAfter(_rangeStart!) || isSameDay(tDate, _rangeStart!)) && 
                          (tDate.isBefore(_rangeEnd!) || isSameDay(tDate, _rangeEnd!));
          } else {
            matchesDate = isSameDay(tDate, _rangeStart!);
          }
        }
        return matchesType && matchesDate;
      }).toList();
    });
  }

  Color? _getDayColor(DateTime day) {
    double income = 0;
    double expense = 0;
    String dayStr = DateFormat('yyyy-MM-dd').format(day);
    
    bool hasData = false;
    for (var t in _allTransactions) {
      if ((t['date'] ?? '').toString().startsWith(dayStr)) {
        hasData = true;
        double amt = double.tryParse(t['amount'].toString()) ?? 0;
        if (t['type'] == 'income') {
          income += amt;
        } else {
          expense += amt;
        }
      }
    }

    if (!hasData) return null;
    return income >= expense ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3);
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) return 'Hoy';
    if (checkDate == yesterday) return 'Ayer';
    // Simplified date format without locale dependency issues if 'es' not loaded
    return '${date.day}/${date.month}/${date.year}'; 
  }

  Map<String, Map<String, double>> _calculateDailyBalances() {
    if (_currentFilter != 'Todos') return {}; // Only sensible for 'Todos'

    Map<String, Map<String, double>> dailyBalances = {};
    double runningBalance = _currentTotalBalance;

    // Group first to iterate day by day
    Map<String, List<dynamic>> byDay = {};
    for (var t in _allTransactions) {
      String dateStr = t['date'] ?? DateTime.now().toIso8601String();
      String key = _getDateLabel(DateTime.parse(dateStr));
      if (!byDay.containsKey(key)) byDay[key] = [];
      byDay[key]!.add(t);
    }

    // Iterate keys (Dates) in order (assuming they are inserted in order because _allTransactions is sorted)
    for (var key in byDay.keys) {
      double close = runningBalance;
      double netChange = 0.0;
      
      for (var t in byDay[key]!) {
        double amount = double.tryParse(t['amount'].toString()) ?? 0.0;
        bool isIncome = t['type'] == 'income';
        if (isIncome) {
          netChange += amount;
        } else {
          netChange -= amount;
        }
      }

      // Open = Close - NetChange
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
            if (_showCalendar) _buildCalendar(),
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

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
        calendarFormat: _calendarFormat,
        rangeStartDay: _rangeStart,
        rangeEndDay: _rangeEnd,
        rangeSelectionMode: RangeSelectionMode.enforced,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onRangeSelected: (start, end, focusedDay) {
          setState(() {
            _rangeStart = start;
            _rangeEnd = end;
            _focusedDay = focusedDay;
            _applyFilter(_currentFilter);
          });
        },
        onFormatChanged: (format) {
          setState(() => _calendarFormat = format);
        },
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            final color = _getDayColor(day);
            if (color != null) {
              return Container(
                margin: const EdgeInsets.all(4),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Text('${day.day}', style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            }
            return null;
          },
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonDecoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          formatButtonTextStyle: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
        ),
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
          rangeHighlightColor: AppTheme.primary,
          rangeStartDecoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
          rangeEndDecoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Movimientos',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _showCalendar = !_showCalendar),
                icon: Icon(
                  _showCalendar ? Icons.calendar_today_rounded : Icons.calendar_month_rounded,
                  color: _showCalendar ? AppTheme.primary : AppTheme.secondary,
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _showCharts = !_showCharts),
                icon: Icon(
                  _showCharts ? Icons.list_rounded : Icons.bar_chart_rounded,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          ...['Todos', 'Ingresos', 'Gastos'].map((filter) {
            final isSelected = _currentFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilterChip(
                selected: isSelected,
                label: Text(filter),
                onSelected: (_) => _applyFilter(filter),
                backgroundColor: Colors.white,
                selectedColor: AppTheme.primary,
                checkmarkColor: Colors.white,
                labelStyle: GoogleFonts.manrope(
                  color: isSelected ? Colors.white : AppTheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.1),
                  ),
                ),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            );
          }),
          if (_rangeStart != null)
             TextButton.icon(
               onPressed: () {
                 setState(() {
                   _rangeStart = null;
                   _rangeEnd = null;
                   _applyFilter(_currentFilter);
                 });
               },
               icon: const Icon(Icons.close_rounded, size: 16, color: Colors.redAccent),
               label: Text(
                 'Limpiar Fecha', 
                 style: GoogleFonts.manrope(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)
               ),
               style: TextButton.styleFrom(
                 padding: const EdgeInsets.symmetric(horizontal: 16),
                 backgroundColor: Colors.redAccent.withOpacity(0.1),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
               ),
             ),
        ],
      ),
    );
  }

  Widget _buildChartsView() {
    if (_filteredTransactions.isEmpty) {
      return Center(child: Text('No hay datos para graficar', style: GoogleFonts.manrope(color: AppTheme.secondary)));
    }

    final pieData = _getPieData();
    final barData = _getWeeklySpendingData();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Container(
            height: 380,
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
            height: 320,
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
                      maxY: barData.isEmpty ? 100 : barData.map((e) => e.barRods.first.toY).fold(0.0, (p, c) => p > c ? p : c) * 1.3,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => AppTheme.primary,
                          tooltipBorderRadius: BorderRadius.circular(12),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                             return BarTooltipItem(
                               '\$${rod.toY.toStringAsFixed(0)}',
                               GoogleFonts.manrope(
                                 color: Colors.white, 
                                 fontWeight: FontWeight.bold,
                                 fontSize: 14,
                               ),
                             );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < 7) {
                                final date = DateTime.now().subtract(Duration(days: 6 - index));
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    DateFormat('E').format(date).substring(0, 1),
                                    style: GoogleFonts.manrope(
                                      color: AppTheme.secondary, 
                                      fontSize: 12, 
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              if (value == 0) return const SizedBox.shrink();
                              return Text(
                                '\$${(value / 1000).toStringAsFixed(1)}k',
                                style: GoogleFonts.manrope(color: AppTheme.secondary.withOpacity(0.5), fontSize: 10),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.withOpacity(0.05),
                          strokeWidth: 1,
                        ),
                      ),
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

    if (total == 0) return [];

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
    List<BarChartGroupData> barGroups = [];
    DateTime now = DateTime.now();
    
    // We want the last 7 days, 0..6
    for (int i = 0; i < 7; i++) {
        // x=0 maps to 6 days ago, x=6 maps to today
        // i goes 0 to 6
        DateTime day = now.subtract(Duration(days: 6 - i));
        String dayStr = DateFormat('yyyy-MM-dd').format(day);

        double dailyTotal = 0.0;
        for (var t in _allTransactions) {
          if (t['type'] == 'expense' && (t['date'] ?? '').toString().startsWith(dayStr)) {
             dailyTotal += double.tryParse(t['amount'].toString()) ?? 0.0;
          }
        }

        barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: dailyTotal,
              gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.7)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 10, // Small base for zero data
                color: Colors.grey.withOpacity(0.05),
              ),
            ),
          ],
        ),
      );
    }
    return barGroups;
  }

  Widget _buildLegend(List<PieChartSectionData> sections) {
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
            _buildDateSeparator(key, balance: balances?['close']),
            ...items.map((item) => _buildTransactionItem(item)),
            if (balances?['open'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 24, right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildSmallBalance('Abre:', balances!['open']!),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDateSeparator(String label, {double? balance}) {
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
          if (balance != null)
            _buildSmallBalance('Cierra:', balance),
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
    
    // Parse date and format time
    final String dateStr = item['date'] ?? DateTime.now().toIso8601String();
    DateTime? transactionDate;
    String timeStr = '';
    try {
      transactionDate = DateTime.parse(dateStr);
      timeStr = DateFormat('HH:mm').format(transactionDate); // 24h format, e.g., "14:30"
    } catch (_) {
      timeStr = '';
    }
    
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
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
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
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      category,
                      style: GoogleFonts.manrope(color: AppTheme.secondary, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    if (timeStr.isNotEmpty) ...[
                      Text(
                        '  •  ',
                        style: GoogleFonts.manrope(color: AppTheme.secondary.withOpacity(0.5), fontSize: 12),
                      ),
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: AppTheme.secondary.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeStr,
                        style: GoogleFonts.manrope(
                          color: AppTheme.secondary.withOpacity(0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => _showEditDialog(item),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(Icons.edit_rounded, size: 16, color: AppTheme.secondary.withOpacity(0.5)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _showDeleteConfirmation(item),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent.withOpacity(0.5)),
                    ),
                  ),
                ],
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
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  // Refresh happens automatically via stream
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

  void _showDeleteConfirmation(Map<String, dynamic> item) {
    if (item['id'] == null) return;
    
    final String description = item['description'] ?? 'esta transacción';
    final double amount = double.tryParse(item['amount'].toString()) ?? 0.0;
    final bool isIncome = item['type'] == 'income';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            ),
            const SizedBox(width: 12),
            Text('Eliminar', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro de eliminar este movimiento?',
              style: GoogleFonts.manrope(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          description,
                          style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          '${isIncome ? "+" : "-"}\$${amount.toStringAsFixed(2)}',
                          style: GoogleFonts.manrope(
                            color: isIncome ? Colors.green : Colors.redAccent,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.manrope(color: AppTheme.secondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              
              try {
                await _financeService.deleteRecord(item['id']);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Movimiento eliminado'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Refresh happens automatically via stream
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al eliminar: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Eliminar', style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold)),
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
