import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nutrigpt/services/nutrition_service.dart';
import '../theme/app_theme.dart';
import '../services/finance_service.dart';
import '../services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  final FinanceService _financeService = FinanceService();
  final NutritionService _nutritionService = NutritionService();
  StreamSubscription? _updateSubscription;
  StreamSubscription? _mealsSubscription;
  bool _isLoading = true;
  Map<String, dynamic> _summary = {
    'total_income': 0.0,
    'total_expense': 0.0,
    'total_cost': 0.0,
  };
  Map<String, double> _categoryStats = {};

  List<dynamic> _goals = [];
  List<Map<String, dynamic>> _dailyMeals = [];
  List<FlSpot> _balanceHistory = [];
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _fetchFinanceData();
    _fetchUserProfile();
    _listenToDailyMeals();
    _requestNotificationPermissionAndSaveFCM();
    _updateSubscription = _financeService.onDataUpdated.listen((_) {
      _fetchFinanceData();
    });
  }

  void _listenToDailyMeals() {
    _mealsSubscription = _nutritionService.getDailyMeals().listen((event) {
      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        final List<Map<String, dynamic>> mealsList = [];
        data.forEach((key, value) {
          mealsList.add(Map<String, dynamic>.from(value as Map));
        });
        
        // Optionally sort by time if needed
        if (mounted) {
          setState(() {
            _dailyMeals = mealsList;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _dailyMeals = [];
          });
        }
      }
    });
  }

  Future<void> _fetchUserProfile() async {
    try {
      final result = await _authService.getProfile();
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];
        if (mounted) {
          setState(() {
            _userName = data['name'] ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
    }
  }

  @override
  void dispose() {
    _updateSubscription?.cancel();
    _mealsSubscription?.cancel();
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
      // recent is used if needed, but the current UI shows a daily timeline instead.

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

  Future<void> _requestNotificationPermissionAndSaveFCM() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized || 
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        
        String? fcmToken = await messaging.getToken();
        if (fcmToken != null) {
          debugPrint('FCM Token: $fcmToken');
          _saveFCMTokenToBackend(fcmToken);
        }
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
  }

  Future<void> _saveFCMTokenToBackend(String fcmToken) async {
    final String devicePlatform = Platform.isIOS ? 'ios' : Platform.isAndroid ? 'android' : 'web';
    
    await _authService.updateProfile(
      fcmToken: fcmToken,
      devicePlatform: devicePlatform,
    );
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
                    _buildCalorieCard(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Historial Calórico (7 días)'),
                    const SizedBox(height: 16),
                    _buildHistoryChart(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Mis Objetivos', onAdd: _showAddGoalDialog),
                    const SizedBox(height: 16),
                    _buildGoalsList(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Distribución de Macros'),
                    const SizedBox(height: 16),
                    _buildCategoryChart(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Plan de Hoy'),
                    const SizedBox(height: 16),
                    _buildDailyTimeline(),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  // ... (Header and BalanceCard remain the same) ...
  // ... (Previous methods) ...

  Widget _buildDailyTimeline() {
    if (_dailyMeals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(
          children: [
            Icon(Icons.calendar_today_outlined, color: AppTheme.secondary.withValues(alpha: 0.3), size: 48),
            const SizedBox(height: 16),
            Text('Sin plan para hoy', style: GoogleFonts.manrope(color: AppTheme.secondary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Pídele un plan a la IA en el chat', style: GoogleFonts.manrope(color: AppTheme.secondary.withValues(alpha: 0.6), fontSize: 12)),
          ],
        ),
      );
    }

    // Sort meals if needed, for now use the order they come in
    return Column(
      children: _dailyMeals.map((meal) => _buildMealHabitItem(meal)).toList(),
    );
  }

  Widget _buildMealHabitItem(Map<String, dynamic> meal) {
    final String title = meal['name'] ?? 'Comida';
    final String time = meal['time'] ?? '--:--';
    final String id = meal['id'] ?? '';
    final bool isCompleted = meal['completed'] ?? false;
    final int calories = int.tryParse(meal['calories']?.toString() ?? '0') ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted ? AppTheme.accent.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isCompleted ? Border.all(color: AppTheme.accent.withValues(alpha: 0.2)) : null,
        boxShadow: [
          if (!isCompleted)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => _nutritionService.toggleMealCompletion(id, !isCompleted),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? AppTheme.accent : Colors.transparent,
                border: Border.all(
                  color: isCompleted ? AppTheme.accent : AppTheme.secondary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.check,
                size: 16,
                color: isCompleted ? Colors.white : Colors.transparent,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold, 
                    fontSize: 14,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted ? AppTheme.secondary : AppTheme.primary,
                  )
                ),
                Text(
                  '$time • $calories kcal',
                  style: GoogleFonts.manrope(fontSize: 10, color: AppTheme.secondary),
                ),
              ],
            ),
          ),
          if (isCompleted)
             const Icon(Icons.auto_awesome, color: Colors.amber, size: 16),
        ],
      ),
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
                    '${barSpot.y.toStringAsFixed(0)} kcal',
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

  // ... (Keep existing methods: _buildHeader, _buildBalanceCard, _buildSectionTitle, _showAddGoalDialog, _buildGoalsList, _buildGoalCard, _buildCategoryChart, _buildCategoryItem) ...

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _userName.isNotEmpty ? 'Hola, $_userName' : 'Hola',
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
    );
  }

  Widget _buildCalorieCard() {
    final double consumed = double.tryParse((_summary['total_income'] ?? 0).toString()) ?? 0.0;
    final double target = double.tryParse((_summary['total_expense'] ?? 0).toString()) ?? 2000.0;
    final double remaining = (target - consumed).clamp(0, target);
    final double progress = (consumed / target).clamp(0, 1.0);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CONSUMO DE HOY',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              const Icon(Icons.bolt_rounded, color: Colors.amber, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${consumed.toStringAsFixed(0)} kcal',
            style: GoogleFonts.manrope(
              fontSize: 42,
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          // Simple progress indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildMiniStat(
                'Faltan', 
                '${remaining.toStringAsFixed(0)} kcal', 
                Colors.orangeAccent
              ),
              const SizedBox(width: 32),
              _buildMiniStat(
                'Meta', 
                '${target.toStringAsFixed(0)} kcal', 
                Colors.greenAccent
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
          title: Text('Nuevo Objetivo', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Nombre del objetivo (ej. Perder Peso)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Valor objetivo (kg, kcal, etc.)'),
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
                    'deadline': DateTime.now().add(const Duration(days: 30)).toIso8601String().split('T')[0],
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
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildGoalCard(goal),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGoalCard(Map<String, dynamic> goal) {
    final double target = double.tryParse(goal['target_amount'].toString()) ?? 1.0;
    final double current = double.tryParse(goal['current_amount'].toString()) ?? 0.0;
    final double progress = (current / target).clamp(0.0, 1.0);
    final String title = goal['title'] ?? 'Meta';
    final int? goalId = goal['id'];
    final int percentage = (progress * 100).round();
    
    // Color based on progress
    Color progressColor = percentage < 30 
        ? Colors.orange 
        : percentage < 70 
            ? Colors.amber 
            : Colors.green;

    return GestureDetector(
      onTap: goalId != null ? () => _showContributeToGoalDialog(goal) : null,
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con icono y título
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: progressColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.flag_rounded,
                    color: progressColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Progress bar con gradiente
            Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [progressColor.withValues(alpha: 0.7), progressColor],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: progressColor.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Porcentaje y montos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$percentage%',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: progressColor,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      current.toStringAsFixed(0),
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    Text(
                      'objetivo ${target.toStringAsFixed(0)}',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        color: AppTheme.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Botones de abonar y eliminar
            Row(
              children: [
                // Botón Abonar
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_task_rounded, size: 16, color: AppTheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Progreso',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Botón Eliminar
                GestureDetector(
                  onTap: () => _showDeleteGoalConfirmation(goal),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 16,
                      color: Colors.redAccent.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showContributeToGoalDialog(Map<String, dynamic> goal) {
    final amountController = TextEditingController();
    bool isSaving = false;
    bool isWithdrawMode = false; // Toggle entre abonar y retirar
    
    final double target = double.tryParse(goal['target_amount'].toString()) ?? 1.0;
    final double current = double.tryParse(goal['current_amount'].toString()) ?? 0.0;
    final double remaining = target - current;
    final String title = goal['title'] ?? 'Meta';
    final int? goalId = goal['id'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isWithdrawMode 
                      ? Colors.orange.withValues(alpha: 0.1)
                      : AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isWithdrawMode ? Icons.output_rounded : Icons.savings,
                  color: isWithdrawMode ? Colors.orange : AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isWithdrawMode ? 'Retirar de Meta' : 'Abonar a Meta',
                      style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      title,
                      style: GoogleFonts.manrope(fontSize: 12, color: AppTheme.secondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Toggle Abonar / Retirar
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setDialogState(() {
                          isWithdrawMode = false;
                          amountController.clear();
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isWithdrawMode ? AppTheme.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                size: 18,
                                color: !isWithdrawMode ? Colors.white : AppTheme.secondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Abonar',
                                style: GoogleFonts.manrope(
                                  fontWeight: FontWeight.bold,
                                  color: !isWithdrawMode ? Colors.white : AppTheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: current > 0 ? () => setDialogState(() {
                          isWithdrawMode = true;
                          amountController.clear();
                        }) : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isWithdrawMode ? Colors.orange : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.output_rounded,
                                size: 18,
                                color: isWithdrawMode 
                                    ? Colors.white 
                                    : (current > 0 ? AppTheme.secondary : AppTheme.secondary.withValues(alpha: 0.3)),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Retirar',
                                style: GoogleFonts.manrope(
                                  fontWeight: FontWeight.bold,
                                  color: isWithdrawMode 
                                      ? Colors.white 
                                      : (current > 0 ? AppTheme.secondary : AppTheme.secondary.withValues(alpha: 0.3)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Progress actual
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isWithdrawMode ? 'Disponible' : 'Ahorrado',
                          style: GoogleFonts.manrope(fontSize: 10, color: AppTheme.secondary),
                        ),
                        Text(
                          '\$${current.toStringAsFixed(2)}',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.bold, 
                            fontSize: 18,
                            color: isWithdrawMode ? Colors.orange : AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isWithdrawMode ? 'Meta' : 'Restante',
                          style: GoogleFonts.manrope(fontSize: 10, color: AppTheme.secondary),
                        ),
                        Text(
                          isWithdrawMode 
                              ? '\$${target.toStringAsFixed(2)}'
                              : '\$${remaining.toStringAsFixed(2)}',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.bold, 
                            fontSize: 18,
                            color: isWithdrawMode ? AppTheme.secondary : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: isWithdrawMode ? 'Monto a retirar' : 'Monto a abonar',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              // Quick amounts
              Wrap(
                spacing: 8,
                children: (isWithdrawMode 
                    ? [100, 500, current.toInt()].where((a) => a > 0 && a <= current).toList()
                    : [100, 500, 1000]
                ).map((amount) {
                  return ActionChip(
                    label: Text(amount == current.toInt() && isWithdrawMode ? 'Todo' : '\$$amount'),
                    onPressed: () {
                      amountController.text = amount.toString();
                    },
                    backgroundColor: (isWithdrawMode ? Colors.orange : AppTheme.primary).withValues(alpha: 0.1),
                    labelStyle: GoogleFonts.manrope(
                      color: isWithdrawMode ? Colors.orange : AppTheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar', style: GoogleFonts.manrope(color: AppTheme.secondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isWithdrawMode ? Colors.orange : AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: isSaving ? null : () async {
                final double? amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0 || goalId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ingresa un monto válido')),
                  );
                  return;
                }

                if (isWithdrawMode && amount > current) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('No puedes retirar más de \$${current.toStringAsFixed(2)}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                setDialogState(() => isSaving = true);
                
                try {
                  if (isWithdrawMode) {
                    await _financeService.withdrawFromGoal(goalId, amount);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Retiraste \$${amount.toStringAsFixed(2)} de "$title"'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  } else {
                    await _financeService.contributeToGoal(goalId, amount);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('¡Abonaste \$${amount.toStringAsFixed(2)} a "$title"!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  _fetchFinanceData(); // Refresh UI
                } catch (e) {
                  if (!context.mounted) return;
                  setDialogState(() => isSaving = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              },
              child: isSaving 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                : Text(isWithdrawMode ? 'Retirar' : 'Abonar', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }


  void _showDeleteGoalConfirmation(Map<String, dynamic> goal) {
    final String title = goal['title'] ?? 'esta meta';
    final double current = double.tryParse(goal['current_amount'].toString()) ?? 0.0;
    final double target = double.tryParse(goal['target_amount'].toString()) ?? 1.0;
    final int? goalId = goal['id'];

    if (goalId == null) return;

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
            Expanded(
              child: Text(
                'Eliminar Meta',
                style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro de eliminar esta meta?',
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.flag_rounded, color: AppTheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          '\$${current.toStringAsFixed(0)} de \$${target.toStringAsFixed(0)}',
                          style: GoogleFonts.manrope(
                            color: AppTheme.secondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (current > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ya tienes \$${current.toStringAsFixed(0)} ahorrados en esta meta.',
                        style: GoogleFonts.manrope(fontSize: 11, color: Colors.orange.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                await _financeService.deleteGoal(goalId);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Meta "$title" eliminada'),
                    backgroundColor: Colors.green,
                  ),
                );
                _fetchFinanceData(); // Refresh UI
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
