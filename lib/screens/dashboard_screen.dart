import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geminifinanzas/l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../services/finance_service.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import 'category_details_screen.dart';
import 'goal_detail_screen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FinanceService _financeService = FinanceService();
  final AuthService _authService = AuthService();
  final FirebaseService _firebaseService = FirebaseService();
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
  final NumberFormat _preciseCurrencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  String _formatCurrency(double amount, {bool precise = false}) {
    return (precise ? _preciseCurrencyFormat : _currencyFormat).format(amount);
  }

  StreamSubscription? _updateSubscription;
  StreamSubscription? _invitationSubscription;
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
  double _userBudget = 0.0;
  List<Map<String, dynamic>> _userDebts = [];
  String _userName = '';
  String _userCode = '';

  @override
  void initState() {
    super.initState();
    _fetchFinanceData();
    _fetchUserProfile();
    _requestNotificationPermissionAndSaveFCM();
    _updateSubscription = _financeService.onDataUpdated.listen((_) {
      _fetchFinanceData();
    });
    _setupInvitationListener();

  }

  Future<void> _setupInvitationListener() async {
    final email = await _authService.getUserEmail();
    if (email != null) {
      _invitationSubscription = _firebaseService.listenToInvitations(email).listen((event) {
        if (event.snapshot.value != null) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          data.forEach((key, value) {
            if (value['status'] == 'pending') {
              _showInvitationDialog(key.toString(), value as Map<dynamic, dynamic>);
            }
          });
        }
      });
    }
  }

  void _showInvitationDialog(String key, Map<dynamic, dynamic> invitation) async {
    final String fromName = invitation['fromName'] ?? AppLocalizations.of(context)!.unknownUser;
    final String goalName = invitation['goalName'] ?? AppLocalizations.of(context)!.defaultGoalName;
    final email = await _authService.getUserEmail();

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.people_alt_rounded, color: AppTheme.primary),
            const SizedBox(width: 12),
            Text(AppLocalizations.of(context)!.invitationTitle, style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: GoogleFonts.manrope(color: AppTheme.primary, fontSize: 16),
                children: [
                  TextSpan(text: AppLocalizations.of(context)!.invitationBody(fromName, goalName)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.invitationQuestion,
              style: GoogleFonts.manrope(color: AppTheme.secondary, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (email != null) await _firebaseService.removeInvitation(email, key);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.reject, style: GoogleFonts.manrope(color: AppTheme.secondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Parse goalId safely
                int? goalId;
                if (invitation['goalId'] is int) {
                  goalId = invitation['goalId'];
                } else if (invitation['goalId'] is String) {
                  goalId = int.tryParse(invitation['goalId']);
                }

                if (goalId != null) {
                  // Call API to link user to goal
                  await _financeService.joinGoal(goalId);
                  
                  // If successful, remove from Firebase
                  if (email != null) await _firebaseService.removeInvitation(email, key);
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.invitationAccepted), backgroundColor: Colors.green),
                    );
                    _fetchFinanceData(); // Refresh to see new goal
                  }
                } else {
                   debugPrint("Error: Invalid goalId in invitation: ${invitation['goalId']}");
                   if (email != null) await _firebaseService.removeInvitation(email, key); // Remove invalid
                   if (context.mounted) Navigator.pop(context);
                }
              } catch (e) {
                debugPrint("Error accepting invitation: $e");
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(AppLocalizations.of(context)!.accept, style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
          // Also fetch/create invitation code
          final code = await _authService.getOrCreateUserCode();
          final email = await _authService.getUserEmail();
          if (code != null && email != null && mounted) {
            setState(() {
              _userCode = code;
            });
            // Register mapping in Firebase
            await _firebaseService.registerUserCode(email, code);
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
    }
  }

  @override
  void dispose() {
    _updateSubscription?.cancel();
    _invitationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchFinanceData() async {
    try {
      final futures = await Future.wait([
        _financeService.getFinanceData(),
        _financeService.getGoals(),
        _authService.getBudget(),
        _authService.getDebts(),
      ]);

      final data = futures[0] as Map<String, dynamic>;
      final goals = futures[1] as List<dynamic>;
      final budget = futures[2] as double?;
      final debts = futures[3] as List<Map<String, dynamic>>;

      if (!mounted) return;

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
          final String category = record['category'] ?? AppLocalizations.of(context)!.general;
          
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
          _userBudget = budget ?? 0.0;
          _userDebts = debts;
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
                    _buildBudgetSection(),
                    const SizedBox(height: 32),
                    _buildSectionTitle(AppLocalizations.of(context)!.balanceTrend),
                    const SizedBox(height: 16),
                    _buildHistoryChart(),
                    const SizedBox(height: 32),
                    _buildSectionTitle(AppLocalizations.of(context)!.yourGoals, onAdd: _showAddGoalDialog),
                    const SizedBox(height: 16),
                    _buildGoalsList(),
                    const SizedBox(height: 32),
                    _buildDebtsSection(),
                    const SizedBox(height: 32),
                    _buildSectionTitle(AppLocalizations.of(context)!.expensesByCategory),
                    const SizedBox(height: 16),
                    _buildCategoryChart(),
                    const SizedBox(height: 32),
                    _buildSectionTitle(AppLocalizations.of(context)!.recentTransactions),
                    const SizedBox(height: 16),
                    _buildRecentTransactions(),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildBudgetSection() {
    final l10n = AppLocalizations.of(context)!;
    if (_userBudget <= 0) return const SizedBox.shrink();

    final double totalExpense = double.tryParse((_summary['total_expense'] ?? 0).toString()) ?? 0.0;
    final double progress = (totalExpense / _userBudget).clamp(0.0, 1.0);
    final double remaining = _userBudget - totalExpense;
    final bool isOverBudget = totalExpense > _userBudget;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.myBudget),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.budgetUsed, style: GoogleFonts.manrope(color: AppTheme.secondary, fontWeight: FontWeight.bold)),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.manrope(
                      color: isOverBudget ? Colors.redAccent : AppTheme.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(isOverBudget ? Colors.redAccent : AppTheme.primary),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.amount, style: GoogleFonts.manrope(fontSize: 10, color: AppTheme.secondary)),
                      Text('${_formatCurrency(totalExpense)} / ${_formatCurrency(_userBudget)}', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(l10n.remainingBudget, style: GoogleFonts.manrope(fontSize: 10, color: AppTheme.secondary)),
                      Text(
                        _formatCurrency(remaining),
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.bold,
                          color: remaining < 0 ? Colors.redAccent : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDebtsSection() {
    final l10n = AppLocalizations.of(context)!;
    if (_userDebts.isEmpty) return const SizedBox.shrink();

    double totalDebt = _userDebts.fold(0.0, (sum, item) => sum + (double.tryParse(item['amount'].toString()) ?? 0.0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.debtsTitle),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.redAccent.withValues(alpha: 0.1), Colors.redAccent.withValues(alpha: 0.05)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.totalDebts, style: GoogleFonts.manrope(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
              Text(
                _formatCurrency(totalDebt, precise: true),
                style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.redAccent),
              ),
              const SizedBox(height: 16),
              ..._userDebts.map((debt) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(debt['name'] ?? '', style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.bold)),
                          Text(
                            '${l10n.debtPayment}: ${_formatCurrency(double.tryParse(debt['monthly_payment'].toString()) ?? 0.0)} (${debt['interest'] ?? 0}%)',
                            style: GoogleFonts.manrope(fontSize: 11, color: AppTheme.secondary),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          _formatCurrency(double.tryParse(debt['amount'].toString()) ?? 0.0),
                          style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.payment_rounded, size: 20, color: Colors.blueAccent),
                          onPressed: () => _showPayDebtDialog(debt),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          visualDensity: VisualDensity.compact,
                          tooltip: l10n.deposit, // Reusing existing l10n for "Abonar" or podobne
                        ),
                      ],
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  // ... (Header and BalanceCard remain the same) ...
  // ... (Previous methods) ...

  void _showPayDebtDialog(Map<String, dynamic> debt) {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController amountController = TextEditingController(
      text: (double.tryParse(debt['monthly_payment'].toString()) ?? 0.0).toStringAsFixed(0)
    );
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text("${l10n.depositToGoal}: ${debt['name']}", style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Registra el pago de este mes. Esto creará un gasto y descontará del saldo total de la deuda.",
                style: GoogleFonts.manrope(fontSize: 13, color: AppTheme.secondary),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.amount,
                  hintText: "0.00",
                  prefixText: "\$ ",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel, style: GoogleFonts.manrope(color: AppTheme.secondary)),
            ),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                final double? amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0) return;

                setDialogState(() => isSaving = true);
                try {
                  // 1. Create transaction record
                  await _financeService.createRecord({
                    'description': "Pago: ${debt['name']}",
                    'amount': amount,
                    'type': 'expense',
                    'category': 'Deuda',
                    'date': DateTime.now().toIso8601String(),
                  });

                  // 2. Update debt balance
                  await _authService.payDebt(debt['name'], amount);

                  if (!context.mounted) return;
                  Navigator.pop(context);
                  _fetchFinanceData(); // Refresh everything
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Pago registrado exitosamente"), backgroundColor: Colors.green),
                  );
                } catch (e) {
                  if (context.mounted) {
                    setDialogState(() => isSaving = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(l10n.confirm, style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    if (_recentTransactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Center(child: Text(AppLocalizations.of(context)!.noRecentActivity, style: GoogleFonts.manrope(color: AppTheme.secondary))),
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
                    _formatCurrency(barSpot.y),
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
                        DateFormat('E', Localizations.localeOf(context).toString()).format(date).substring(0, 1),
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
    final String title = item['description'] ?? AppLocalizations.of(context)!.noDescription;
    final String category = item['category'] ?? AppLocalizations.of(context)!.general;
    final double amountVal = double.tryParse(item['amount'].toString()) ?? 0.0;
    final bool isIncome = item['type'] == 'income';
    final String amountStr = '${isIncome ? "+" : "-"}${_formatCurrency(amountVal, precise: true)}';
    
    // Parse Date
    String formattedDate = '';
    try {
      final dateStr = item['date'] ?? ''; 
      if (dateStr.isNotEmpty) {
        final date = DateTime.parse(dateStr).toLocal();
        formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);
      }
    } catch (_) {
      formattedDate = item['date'] ?? '';
    }

    // Simple icon logic (reused conceptualy)
    IconData icon = Icons.attach_money;
    if (category.toLowerCase().contains('comida')) icon = Icons.restaurant;
    if (category.toLowerCase().contains('transporte')) icon = Icons.directions_car;
    // ... add more if needed or use a helper function

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
                  formattedDate,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _userName.isNotEmpty ? AppLocalizations.of(context)!.hello(_userName) : AppLocalizations.of(context)!.helloSimple,
          style: GoogleFonts.manrope(
            fontSize: 14,
            color: AppTheme.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          AppLocalizations.of(context)!.dashboard,
          style: GoogleFonts.manrope(
            fontSize: 24,
            color: AppTheme.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (_userCode.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.purpleAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.qr_code_2_rounded, size: 14, color: Colors.purpleAccent),
                const SizedBox(width: 6),
                Text(
                  _userCode,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.purpleAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
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
            AppLocalizations.of(context)!.totalBalance,
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.6),
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatCurrency(_totalBalance, precise: true),
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
                AppLocalizations.of(context)!.incomes, 
                '+${_formatCurrency((_summary['total_income'] ?? 0).toDouble())}', 
                Colors.greenAccent
              ),
              const SizedBox(width: 32),
              _buildMiniStat(
                AppLocalizations.of(context)!.expenses, 
                '-${_formatCurrency((_summary['total_expense'] ?? 0).toDouble())}', 
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
          title: Text(AppLocalizations.of(context)!.newGoal, style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.goalNameHint),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.targetAmountHint, prefixText: '\$'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
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
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.errorGeneric(e.toString()))));
                }
              },
              child: isSaving 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                : Text(AppLocalizations.of(context)!.save),
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
            AppLocalizations.of(context)!.noActiveGoals,
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
    final String title = goal['title'] ?? AppLocalizations.of(context)!.goal;
    final int? goalId = goal['id'];
    final int percentage = (progress * 100).round();
    
    // Premium Color Palette based on progress
    Color primaryColor;
    Color secondaryColor;
    
    if (percentage < 30) {
      primaryColor = const Color(0xFF6B4CFF); // Deep Purple
      secondaryColor = const Color(0xFFB8A5FF);
    } else if (percentage < 70) {
      primaryColor = const Color(0xFFFF8F4C); // Rich Orange
      secondaryColor = const Color(0xFFFFCFA5);
    } else {
      primaryColor = const Color(0xFF00C896); // Vivid Teal
      secondaryColor = const Color(0xFF9AFFD9);
    }

    return GestureDetector(
      onTap: goalId != null ? () {
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => GoalDetailScreen(goal: goal))
        ).then((_) => _fetchFinanceData()); // Refresh on return
      } : null,
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 20, bottom: 20, top: 10), // Margin for shadow
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              // Decorative background blob
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon and Menu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.star_rounded,
                            color: primaryColor,
                            size: 24,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showDeleteGoalConfirmation(goal),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.transparent, // Hitbox expansion
                            child: Icon(Icons.more_horiz_rounded, color: AppTheme.secondary.withValues(alpha: 0.5)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Title
                    Text(
                      title,
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: AppTheme.primary,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Amounts
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _formatCurrency(current),
                          style: GoogleFonts.manrope(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primary,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '/ ${_formatCurrency(target)}',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondary.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Progress Bar
                    Row(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppTheme.background,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: progress,
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [primaryColor, secondaryColor],
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryColor.withValues(alpha: 0.4),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$percentage%',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showContributeToGoalDialog(goal),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_circle_outline_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.deposit,
                              style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
    final String title = goal['title'] ?? AppLocalizations.of(context)!.goal;
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
                      isWithdrawMode ? AppLocalizations.of(context)!.withdrawFromGoal : AppLocalizations.of(context)!.depositToGoal,
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
                                AppLocalizations.of(context)!.deposit,
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
                                AppLocalizations.of(context)!.withdraw,
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
                          isWithdrawMode ? AppLocalizations.of(context)!.available : AppLocalizations.of(context)!.saved,
                          style: GoogleFonts.manrope(fontSize: 10, color: AppTheme.secondary),
                        ),
                        Text(
                          _formatCurrency(current, precise: true),
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
                          isWithdrawMode ? AppLocalizations.of(context)!.goal : AppLocalizations.of(context)!.remaining,
                          style: GoogleFonts.manrope(fontSize: 10, color: AppTheme.secondary),
                        ),
                        Text(
                          isWithdrawMode 
                              ? _formatCurrency(target, precise: true)
                              : _formatCurrency(remaining, precise: true),
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
                  labelText: isWithdrawMode ? AppLocalizations.of(context)!.amountToWithdraw : AppLocalizations.of(context)!.amountToDeposit,
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
                    label: Text(amount == current.toInt() && isWithdrawMode ? AppLocalizations.of(context)!.allAmount : '\$$amount'),
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
              child: Text(AppLocalizations.of(context)!.cancel, style: GoogleFonts.manrope(color: AppTheme.secondary)),
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
                    SnackBar(content: Text(AppLocalizations.of(context)!.enterValidAmount)),
                  );
                  return;
                }

                if (isWithdrawMode && amount > current) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.cannotWithdrawMore(current.toStringAsFixed(2))),
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
                        content: Text(AppLocalizations.of(context)!.withdrewAmount(amount.toStringAsFixed(2), title)),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  } else {
                    await _financeService.contributeToGoal(goalId, amount);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)!.depositedAmount(amount.toStringAsFixed(2), title)),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  _fetchFinanceData(); // Refresh UI
                } catch (e) {
                  if (!context.mounted) return;
                  setDialogState(() => isSaving = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.errorGeneric(e.toString())), backgroundColor: Colors.red),
                  );
                }
              },
              child: isSaving 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                : Text(isWithdrawMode ? AppLocalizations.of(context)!.withdraw : AppLocalizations.of(context)!.deposit, style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
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
                AppLocalizations.of(context)!.deleteGoal,
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
              AppLocalizations.of(context)!.deleteGoalConfirm,
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
                          '${_formatCurrency(current)} de ${_formatCurrency(target)}',
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
                        AppLocalizations.of(context)!.goalAlreadySavedWarning(current.toStringAsFixed(0)),
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
            child: Text(AppLocalizations.of(context)!.cancel, style: GoogleFonts.manrope(color: AppTheme.secondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              
              try {
                await _financeService.deleteGoal(goalId);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.goalDeleted(title)),
                    backgroundColor: Colors.green,
                  ),
                );
                _fetchFinanceData(); // Refresh UI
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.errorGeneric(e.toString())), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(AppLocalizations.of(context)!.delete, style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  int _touchedIndex = -1;

  Widget _buildCategoryChart() {
    if (_categoryStats.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.noExpensesRegistered,
            style: GoogleFonts.manrope(color: AppTheme.secondary),
          ),
        ),
      );
    }

    // Sort categories by percentage descending
    var sortedEntries = _categoryStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Group small values into "Otros" if we have too many
    List<MapEntry<String, double>> displayEntries = [];
    if (sortedEntries.length > 5) {
      displayEntries = sortedEntries.take(4).toList();
      double othersValue = sortedEntries.skip(4).fold(0.0, (sum, item) => sum + item.value);
      displayEntries.add(MapEntry(AppLocalizations.of(context)!.others, othersValue));
    } else {
      displayEntries = sortedEntries.toList();
    }

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
          // Header with Title and "Ver completo" button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.distribution,
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
                      AppLocalizations.of(context)!.seeFull,
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
          
          // Chart
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
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: List.generate(displayEntries.length, (i) {
                  final e = displayEntries[i];
                  final isTouched = i == _touchedIndex;
                  final fontSize = isTouched ? 20.0 : 14.0;
                  final radius = isTouched ? 60.0 : 50.0;
                  const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

                  // Only show label if percentage is significant or if touched
                  final showLabel = e.value >= 5.0 || isTouched;

                  return PieChartSectionData(
                    color: _getChartColor(e.key),
                    value: e.value,
                    title: showLabel ? '${e.value.toStringAsFixed(0)}%' : '',
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
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: displayEntries.map((e) {
              final index = displayEntries.indexOf(e);
              final isTouched = index == _touchedIndex;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _touchedIndex = isTouched ? -1 : index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isTouched 
                        ? _getChartColor(e.key).withValues(alpha: 0.1) 
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: isTouched 
                        ? Border.all(color: _getChartColor(e.key), width: 1)
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getChartColor(e.key),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _getChartColor(e.key).withValues(alpha: 0.4),
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
                        '(${e.value.toStringAsFixed(0)}%)',
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
