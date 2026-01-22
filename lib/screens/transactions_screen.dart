import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../theme/app_theme.dart';
import '../services/finance_service.dart';
import 'category_details_screen.dart';
import '../widgets/native_ad_widget.dart';

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
  // bool _showCalendar = false; // Removed as requested
  List<dynamic> _allTransactions = [];
  List<dynamic> _filteredTransactions = [];
  String _currentFilter = 'Todos';
  double _currentTotalBalance = 0.0;

  // Calendar & Date Range State
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  int _pieTouchedIndex = -1;

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
    return income >= expense ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3);
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
            // Calendar is now a modal
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

  // Calendar Logic moved to Modal
  void _showCalendarModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(height: 16),
                  Text('Filtrar por Fecha', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TableCalendar(
                      locale: 'es',
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      calendarFormat: CalendarFormat.month,
                      rangeStartDay: _rangeStart,
                      rangeEndDay: _rangeEnd,
                      rangeSelectionMode: RangeSelectionMode.enforced,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                         // Update parent state too
                         setState(() {
                           _selectedDay = selectedDay;
                           _focusedDay = focusedDay;
                         });
                         // Update local modal state
                         setModalState(() {
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
                        setModalState(() {
                           _focusedDay = focusedDay;
                        });
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
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      calendarStyle: const CalendarStyle(
                        todayDecoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                        rangeHighlightColor: AppTheme.primary,
                        rangeStartDecoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                        rangeEndDecoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('Listo', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
                onPressed: _showCalendarModal,
                icon: Icon(
                  Icons.calendar_month_rounded,
                  color: (_rangeStart != null) ? AppTheme.primary : AppTheme.secondary,
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
                    color: isSelected ? Colors.transparent : Colors.grey.withValues(alpha: 0.1),
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
                 backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
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


    final weeklyExpenses = _getWeeklyData(isExpense: true);
    final weeklyIncome = _getWeeklyData(isExpense: false);
    final lineData = _getIncomeExpenseTrend();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Line Chart: Income vs Expenses Trend
          Container(
            height: 350,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tendencia (7 días)', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16)),
                    Row(
                      children: [
                        _buildLegendDot(Colors.green, 'Ingresos'),
                        const SizedBox(width: 8),
                        _buildLegendDot(Colors.redAccent, 'Gastos'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => AppTheme.primary,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              return LineTooltipItem(
                                '\$${spot.y.toStringAsFixed(0)}',
                                GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        // Income Line
                        LineChartBarData(
                          spots: lineData['income']!,
                          isCurved: true,
                          color: Colors.green,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                             show: true, 
                             color: Colors.green.withValues(alpha: 0.1)
                          ),
                        ),
                        // Expense Line
                        LineChartBarData(
                          spots: lineData['expense']!,
                          isCurved: true,
                          color: Colors.redAccent,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                             show: true, 
                             color: Colors.redAccent.withValues(alpha: 0.1)
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          // 2. Bar Chart: Weekly Expenses
          Container(
            height: 320,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gastos Semanales', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                const SizedBox(height: 24),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      borderData: FlBorderData(show: false),
                      barTouchData: BarTouchData(
                        enabled: false, // Disable touch interaction since we show checks permanently
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => Colors.transparent,
                          tooltipPadding: EdgeInsets.zero,
                          tooltipMargin: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '\$${rod.toY.toStringAsFixed(0)}',
                              GoogleFonts.manrope(
                                color: Colors.white, 
                                fontWeight: FontWeight.bold, 
                                fontSize: 10,
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
                            getTitlesWidget: (value, meta) {
                               final index = value.toInt();
                               if (index >= 0 && index < 7) {
                                 final date = DateTime.now().subtract(Duration(days: 6 - index));
                                 return Padding(
                                   padding: const EdgeInsets.only(top: 8),
                                   child: Text(DateFormat('E').format(date)[0], style: GoogleFonts.manrope(color: Colors.white, fontSize: 12)),
                                 );
                               }
                               return const SizedBox();
                            },
                          ),
                         ),
                         leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                         topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                         rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // Hide right titles
                      ),
                      gridData: FlGridData(show: false), // Hide grid for cleaner look
                      barGroups: weeklyExpenses,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. Bar Chart: Weekly Income
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
                Text('Ingresos Semanales', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 24),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      borderData: FlBorderData(show: false),
                      barTouchData: BarTouchData(
                        enabled: false, // Disable touch interaction since we show checks permanently
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => Colors.transparent,
                          tooltipPadding: EdgeInsets.zero,
                          tooltipMargin: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '\$${rod.toY.toStringAsFixed(0)}',
                              GoogleFonts.manrope(
                                color: Colors.black, 
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
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
                            getTitlesWidget: (value, meta) {
                               final index = value.toInt();
                               if (index >= 0 && index < 7) {
                                 final date = DateTime.now().subtract(Duration(days: 6 - index));
                                 return Padding(
                                   padding: const EdgeInsets.only(top: 8),
                                   child: Text(DateFormat('E').format(date)[0], style: GoogleFonts.manrope(color: AppTheme.secondary, fontSize: 12)),
                                 );
                               }
                               return const SizedBox();
                            },
                          ),
                         ),
                         leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                         topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                         rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(show: false),
                      barGroups: weeklyIncome,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 4. Pie Chart
          _buildPieChartSection(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String text) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.manrope(fontSize: 10, color: AppTheme.secondary, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Map<String, List<FlSpot>> _getIncomeExpenseTrend() {
    // Generate spots for last 7 days
    Map<String, List<FlSpot>> result = {
      'income': [],
      'expense': []
    };
    
    DateTime now = DateTime.now();
    for (int i = 0; i < 7; i++) {
       DateTime day = now.subtract(Duration(days: 6 - i));
       String dayStr = DateFormat('yyyy-MM-dd').format(day);
       
       double iTotal = 0.0;
       double eTotal = 0.0;

        for (var t in _allTransactions) {
          if ((t['date'] ?? '').toString().startsWith(dayStr)) {
             double amt = double.tryParse(t['amount'].toString()) ?? 0.0;
             if (t['type'] == 'income') {
               iTotal += amt;
             } else {
               eTotal += amt;
             }
          }
       }
       result['income']!.add(FlSpot(i.toDouble(), iTotal));
       result['expense']!.add(FlSpot(i.toDouble(), eTotal));
    }
    return result;
  }
  
  List<MapEntry<String, double>> _getCategoryEntries() {
    Map<String, double> categoryTotals = {};
    for (var t in _filteredTransactions) {
      if (t['type'] == 'expense') {
        double amount = double.tryParse(t['amount'].toString()) ?? 0.0;
        String cat = t['category'] ?? 'Otros';
        categoryTotals[cat] = (categoryTotals[cat] ?? 0.0) + amount;
      }
    }
    var entries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  Widget _buildPieChartSection() {
    var sortedEntries = _getCategoryEntries();
    // Group small values into "Otros" if we have too many
    List<MapEntry<String, double>> displayEntries = [];
    if (sortedEntries.length > 5) {
      displayEntries = sortedEntries.take(4).toList();
      double othersValue = sortedEntries.skip(4).fold(0.0, (sum, item) => sum + item.value);
      displayEntries.add(MapEntry('Otros', othersValue));
    } else {
      displayEntries = sortedEntries.toList();
    }
    
    final total = sortedEntries.fold(0.0, (sum, e) => sum + e.value);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 24, bottom: 32, left: 24, right: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Por Categoría',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CategoryDetailsScreen()),
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  children: [
                    Text(
                      'Ver completo',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppTheme.primary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _pieTouchedIndex = -1;
                        return;
                      }
                      _pieTouchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: List.generate(displayEntries.length, (i) {
                  final e = displayEntries[i];
                  final isTouched = i == _pieTouchedIndex;
                  final fontSize = isTouched ? 20.0 : 14.0;
                  final radius = isTouched ? 60.0 : 50.0;
                  const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
                  final percentage = total > 0 ? (e.value / total) * 100 : 0.0;
                  
                  // Only show label if percentage is significant or if touched
                  final showLabel = percentage >= 5.0 || isTouched;

                  return PieChartSectionData(
                    color: _getCategoryColor(e.key),
                    value: e.value,
                    title: showLabel ? '${percentage.toStringAsFixed(0)}%' : '',
                    radius: radius,
                    titleStyle: GoogleFonts.manrope(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: shadows,
                    ),
                    badgeWidget: isTouched 
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Text(
                              e.key,
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                          ) 
                        : null,
                    badgePositionPercentageOffset: 1.3,
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildPieLegend(displayEntries, total),
        ],
      ),
    );
  }

  Widget _buildPieLegend(List<MapEntry<String, double>> entries, double total) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: entries.asMap().entries.map((entry) {
        final index = entry.key;
        final e = entry.value;
        final isTouched = index == _pieTouchedIndex;
        final percentage = (e.value / total) * 100;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _pieTouchedIndex = isTouched ? -1 : index;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isTouched 
                  ? _getCategoryColor(e.key).withValues(alpha: 0.1) 
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: isTouched 
                  ? Border.all(color: _getCategoryColor(e.key), width: 1)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(e.key),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _getCategoryColor(e.key).withValues(alpha: 0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  e.key,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: isTouched ? FontWeight.w800 : FontWeight.w600,
                    color: isTouched ? AppTheme.primary : AppTheme.secondary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${percentage.toStringAsFixed(0)}%)',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: isTouched ? FontWeight.w800 : FontWeight.normal,
                    color: isTouched ? AppTheme.primary : AppTheme.secondary.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  
  List<BarChartGroupData> _getWeeklyData({required bool isExpense}) {
    List<BarChartGroupData> barGroups = [];
    DateTime now = DateTime.now();
    
    for (int i = 0; i < 7; i++) {
        DateTime day = now.subtract(Duration(days: 6 - i));
        String dayStr = DateFormat('yyyy-MM-dd').format(day);

        double dailyTotal = 0.0;
        for (var t in _allTransactions) {
          bool typeMatch = isExpense ? t['type'] == 'expense' : t['type'] == 'income';
          if (typeMatch && (t['date'] ?? '').toString().startsWith(dayStr)) {
             dailyTotal += double.tryParse(t['amount'].toString()) ?? 0.0;
          }
        }

        barGroups.add(
        BarChartGroupData(
          x: i,
          showingTooltipIndicators: dailyTotal > 0 ? [0] : [],
          barRods: [
            BarChartRodData(
              toY: dailyTotal,
              color: isExpense ? Colors.white : null,
              gradient: isExpense 
                  ? null
                  : LinearGradient(
                      colors: [Colors.green, Colors.green.withValues(alpha: 0.6)],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
              width: 12,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 10, 
                color: isExpense 
                    ? Colors.grey.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.05),
              ),
            ),
          ],
        ),
      );
    }
    return barGroups;
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

    // List with Ads logic
    final List<dynamic> flatList = [];
    int counter = 0;
    
    // Flatten grouped data into a linear list + Separators
    // We do this to easily inject ads
    for (var i = 0; i < groupedResponse.length; i++) {
      String key = groupedResponse.keys.elementAt(i);
      List<dynamic> items = groupedResponse[key]!;
      final balances = dailyBalances[key];

      // Add Date Header
      flatList.add({'type': 'header', 'data': key, 'balance': balances?['close']});
      
      // Add Transactions
      for (var item in items) {
        flatList.add({'type': 'item', 'data': item});
        counter++;
        
        // Inject Ad every 6 transactions
        if (counter % 6 == 0) {
          flatList.add({'type': 'ad'});
        }
      }

      // Add Daily Summary footer if exists
      if (balances?['open'] != null) {
        flatList.add({'type': 'footer', 'open': balances!['open']});
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: flatList.length,
      itemBuilder: (context, index) {
        final item = flatList[index];
        
        if (item['type'] == 'header') {
           return _buildDateSeparator(item['data'], balance: item['balance']);
        } else if (item['type'] == 'footer') {
           return Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 24, right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildSmallBalance('Abre:', item['open']),
                  ],
                ),
              );
        } else if (item['type'] == 'ad') {
          return const NativeAdWidget();
        }
        
        return _buildTransactionItem(item['data']);
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
                  (transactionDate != null) 
                      ? DateFormat('dd/MM/yyyy HH:mm').format(transactionDate) 
                      : (dateStr.isNotEmpty ? dateStr : ''),
                  style: GoogleFonts.manrope(color: AppTheme.secondary, fontSize: 10),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      category,
                      style: GoogleFonts.manrope(color: AppTheme.secondary, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
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
                      child: Icon(Icons.edit_rounded, size: 16, color: AppTheme.secondary.withValues(alpha: 0.5)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _showDeleteConfirmation(item),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent.withValues(alpha: 0.5)),
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
                color: Colors.redAccent.withValues(alpha: 0.1),
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
    
    // Ingresos
    if (cat.contains('salario') || cat.contains('nomina') || cat.contains('sueldo')) return Icons.monetization_on_rounded;
    if (cat.contains('inversíon') || cat.contains('crypto') || cat.contains('stocks')) return Icons.trending_up_rounded;
    if (cat.contains('negocio') || cat.contains('venta')) return Icons.store_rounded;

    // Gastos - Pareja & Amor
    if (cat.contains('novia') || cat.contains('novio') || cat.contains('pareja') || cat.contains('amor')) return Icons.favorite_rounded;
    if (cat.contains('cita') || cat.contains('date') || cat.contains('romantico') || cat.contains('cena')) return Icons.dining_rounded;
    if (cat.contains('aniversario') || cat.contains('boda')) return Icons.volunteer_activism_rounded;
    if (cat.contains('flores') || cat.contains('rosas') || cat.contains('ramo')) return Icons.local_florist_rounded;
    if (cat.contains('motel') || cat.contains('hotel')) return Icons.bed_rounded;

    // Gastos - Hogar & Servicios
    if (cat.contains('casa') || cat.contains('hogar') || cat.contains('renta') || cat.contains('alquiler')) return Icons.home_rounded;
    if (cat.contains('servicios') || cat.contains('luz') || cat.contains('agua') || cat.contains('internet')) return Icons.electric_bolt_rounded;
    if (cat.contains('mantenimiento') || cat.contains('reparación')) return Icons.build_rounded;

    // Gastos - Comida & Super
    if (cat.contains('super') || cat.contains('despensa') || cat.contains('walmart')) return Icons.shopping_cart_rounded;
    if (cat.contains('comida') || cat.contains('restaurante') || cat.contains('food')) return Icons.restaurant_rounded;
    if (cat.contains('café') || cat.contains('coffee') || cat.contains('starbucks')) return Icons.coffee_rounded;
    if (cat.contains('bebida') || cat.contains('bar') || cat.contains('fiesta') || cat.contains('cerveza') || cat.contains('alcohol')) return Icons.local_bar_rounded;

    // Gastos - Transporte
    if (cat.contains('transporte') || cat.contains('uber') || cat.contains('taxi') || cat.contains('metro')) return Icons.directions_car_rounded;
    if (cat.contains('gasolina') || cat.contains('combustible')) return Icons.local_gas_station_rounded;
    if (cat.contains('viajes') || cat.contains('vuelo') || cat.contains('avión')) return Icons.flight_takeoff_rounded;

    // Gastos - Personal & Salud
    if (cat.contains('salud') || cat.contains('medico') || cat.contains('farmacia') || cat.contains('doctor')) return Icons.medical_services_rounded;
    if (cat.contains('gym') || cat.contains('deporte') || cat.contains('fitness') || cat.contains('entrenamiento')) return Icons.fitness_center_rounded;
    if (cat.contains('ropa') || cat.contains('compras') || cat.contains('shopping') || cat.contains('moda')) return Icons.shopping_bag_rounded;
    if (cat.contains('cuidado') || cat.contains('belleza') || cat.contains('peluqueria') || cat.contains('barberia')) return Icons.face_rounded;

    // Gastos - Educación & Trabajo
    if (cat.contains('educacion') || cat.contains('escuela') || cat.contains('curso') || cat.contains('universidad')) return Icons.school_rounded;
    if (cat.contains('code') || cat.contains('dev') || cat.contains('trabajo') || cat.contains('software')) return Icons.code_rounded;
    if (cat.contains('tech') || cat.contains('apple') || cat.contains('electrónica') || cat.contains('gadget')) return Icons.laptop_mac_rounded;

    // Gastos - Ocio & Varios
    if (cat.contains('ocio') || cat.contains('flix') || cat.contains('cine') || cat.contains('streaming')) return Icons.movie_creation_rounded;
    if (cat.contains('juegos') || cat.contains('videojuegos') || cat.contains('steam') || cat.contains('psn')) return Icons.sports_esports_rounded;
    if (cat.contains('musica') || cat.contains('spotify') || cat.contains('concierto')) return Icons.music_note_rounded;
    if (cat.contains('mascota') || cat.contains('veterinario')) return Icons.pets_rounded;
    if (cat.contains('regalo') || cat.contains('donacion')) return Icons.card_giftcard_rounded;
    if (cat.contains('banco') || cat.contains('transferencia') || cat.contains('comisión')) return Icons.account_balance_rounded;
    if (cat.contains('ahorro')) return Icons.savings_rounded;
    if (cat.contains('seguro')) return Icons.security_rounded;

    return Icons.receipt_long_rounded; 
  }

  Color _getCategoryColor(String category) {
    final cat = category.toLowerCase();
    
    // Ingresos
    if (cat.contains('salario') || cat.contains('nomina') || cat.contains('sueldo')) return Colors.green[700]!;
    if (cat.contains('inversíon') || cat.contains('crypto')) return Colors.teal[700]!;
    if (cat.contains('negocio') || cat.contains('venta')) return Colors.blue[800]!;
    if (cat.contains('income')) return Colors.green;

    // Pareja
    if (cat.contains('novia') || cat.contains('novio') || cat.contains('amor')) return Colors.pinkAccent;
    if (cat.contains('cita') || cat.contains('romantico') || cat.contains('cena')) return Colors.redAccent;
    if (cat.contains('flores') || cat.contains('regalo')) return Colors.pink[400]!;
    if (cat.contains('motel')) return Colors.deepPurple;

    // Gastos
    if (cat.contains('casa') || cat.contains('hogar') || cat.contains('renta')) return Colors.brown;
    if (cat.contains('servicios') || cat.contains('luz') || cat.contains('agua')) return Colors.amber[700]!;
    
    if (cat.contains('super') || cat.contains('despensa')) return Colors.lightGreen[600]!;
    if (cat.contains('comida') || cat.contains('restaurante')) return Colors.orangeAccent;
    if (cat.contains('café') || cat.contains('coffee')) return Colors.brown[300]!;
    if (cat.contains('bebida') || cat.contains('fiesta') || cat.contains('cerveza')) return Colors.purpleAccent;

    if (cat.contains('transporte') || cat.contains('uber')) return Colors.blueAccent;
    if (cat.contains('gasolina')) return Colors.deepOrange;
    if (cat.contains('viajes') || cat.contains('avión')) return Colors.lightBlueAccent;

    if (cat.contains('salud') || cat.contains('medico')) return Colors.red;
    if (cat.contains('gym') || cat.contains('fitness')) return Colors.black87;
    if (cat.contains('ropa') || cat.contains('shopping')) return Colors.purple;

    if (cat.contains('educacion') || cat.contains('escuela')) return Colors.indigo;
    if (cat.contains('tech') || cat.contains('apple')) return Colors.grey[800]!;
    if (cat.contains('code') || cat.contains('dev')) return Colors.black;

    if (cat.contains('ocio') || cat.contains('cine')) return Colors.deepPurpleAccent;
    if (cat.contains('juegos') || cat.contains('steam')) return Colors.indigoAccent;
    if (cat.contains('mascota')) return Colors.orange[800]!;
    if (cat.contains('ahorro')) return Colors.teal;

    return AppTheme.primary;
  }
}
