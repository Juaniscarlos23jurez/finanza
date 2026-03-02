import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:nutrigpt/services/nutrition_service.dart';
import '../theme/app_theme.dart';
import '../services/finance_service.dart';
import '../services/gamification_service.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onChallengeClick;
  const DashboardScreen({super.key, this.onChallengeClick});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  final FinanceService _financeService = FinanceService();
  final NutritionService _nutritionService = NutritionService();
  StreamSubscription? _updateSubscription;
  StreamSubscription? _mealsSubscription;
  StreamSubscription? _goalsSubscription;
  StreamSubscription? _planSubscription;
  StreamSubscription? _streakSubscription;
  StreamSubscription? _historySubscription;
  StreamSubscription? _weightSubscription;
  StreamSubscription? _visualGoalSubscription;
  Map<String, dynamic>? _visualGoal;
  bool _isLoading = true;
  bool _challengeCompleted = false;
  int _streak = 0;
  final Map<String, dynamic> _summary = {
    'total_income': 0.0, // Used for calories consumed
    'total_expense': 2000.0, // Used for daily calorie goal
    'total_cost': 0.0,
  };


  List<dynamic> _goals = [];
  List<Map<String, dynamic>> _dailyMeals = [];
  List<FlSpot> _balanceHistory = [];
  String _userName = '';

  // Weight Tracking States
  double _currentWeight = 0;
  double _weightDiff = 0;
  List<FlSpot> _weightSpots = [];
  Map<String, double> _weightHistory = {};
  bool _canRegisterToday = true;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _fetchUserProfile();
    _listenToDailyMeals();
    _listenToStreak();
    _listenToHistory();
    _listenToGoals();
    _listenToPlan();
    _listenToWeightData();
    _listenToVisualGoal();
    _requestNotificationPermissionAndSaveFCM();
    _updateSubscription = _financeService.onDataUpdated.listen((_) {
      _fetchInitialData();
    });
    _syncGamification();
  }

  Future<void> _syncGamification() async {
    final result = await _nutritionService.validateAndSyncGamification();
    if (result.isNotEmpty && mounted) {
      if (result['streak_lost'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Has perdido tu racha por falta de actividad y vidas.'),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _listenToStreak() {
    _streakSubscription = _nutritionService.getStreak().listen((event) {
      if (event.snapshot.value != null && mounted) {
        setState(() {
          _streak = int.tryParse(event.snapshot.value.toString()) ?? 0;
        });
      }
    });
  }

  void _listenToHistory() {
    _historySubscription = _nutritionService.getHistory().listen((event) {
      if (event.snapshot.value != null && mounted) {
        final Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        final List<FlSpot> historySpots = [];
        
        // Convert map to sorted list by date
        final sortedKeys = data.keys.toList()..sort();
        
        // Take last 7 days
        final recentKeys = sortedKeys.length > 7 
            ? sortedKeys.sublist(sortedKeys.length - 7) 
            : sortedKeys;

        for (int i = 0; i < recentKeys.length; i++) {
          final key = recentKeys[i];
          final val = data[key];
          final double calories = double.tryParse(val['calories']?.toString() ?? '0') ?? 0;
          historySpots.add(FlSpot(i.toDouble(), calories));
        }

        setState(() {
          _balanceHistory = historySpots;
        });
      }
    });
  }

  void _listenToGoals() {
    _goalsSubscription = _nutritionService.getGoals().listen((event) {
      if (event.snapshot.value != null && mounted) {
        final Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        final List<dynamic> goalsList = [];
        final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

        data.forEach((key, value) {
          final goal = Map<String, dynamic>.from(value as Map);
          final String goalType = goal['goal_type']?.toString() ?? '';
          
          // Treat exercise and distance as daily by default if the flag is missing (backward compatibility)
          final bool isDaily = goal['is_daily'] == true || 
                             (goal['is_daily'] == null && (goalType == 'exercise_minutes' || goalType == 'distance_km'));

          if (isDaily) {
            final String lastUpdate = goal['last_update_date']?.toString() ?? '';
            if (lastUpdate != today) {
              // Trigger a background reset
              _nutritionService.resetDailyGoal(key);
              // Show as 0 in current view
              goal['current_amount'] = 0;
              goal['last_update_date'] = today;
            }
          }
          
          goalsList.add(goal);
        });
        setState(() {
          _goals = goalsList;
        });
      }
    });
  }

  void _listenToPlan() {
    _planSubscription = _nutritionService.getPlan().listen((event) {
      if (event.snapshot.value != null && mounted) {
        final Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _summary['total_expense'] = double.tryParse(data['daily_calories']?.toString() ?? '2000') ?? 2000.0;
        });
      }
    });
  }

  void _listenToDailyMeals() {
    _mealsSubscription = _nutritionService.getDailyMeals().listen((event) {
      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        final List<Map<String, dynamic>> mealsList = [];
        double totalCaloriesConsumed = 0;
        data.forEach((key, value) {
          final meal = Map<String, dynamic>.from(value as Map);
          mealsList.add(meal);
          if (meal['completed'] == true) {
            final double cals = double.tryParse(meal['calories']?.toString() ?? '0') ?? 0;
            totalCaloriesConsumed += cals;
          }
        });
        
        if (mounted) {
          setState(() {
            _dailyMeals = mealsList;
            _summary['total_income'] = totalCaloriesConsumed;
            _nutritionService.saveDailyTotal(totalCaloriesConsumed);
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _dailyMeals = [];
            _summary['total_income'] = 0.0;
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

  void _listenToWeightData() {
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _weightSubscription = _nutritionService.getWeightHistory().listen((event) {
      if (mounted && event.snapshot.value != null) {
        final Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        
        bool canRegister = !data.containsKey(today);
        double current = 0;
        double diff = 0;
        List<FlSpot> spots = [];

        if (data.isNotEmpty) {
          final sortedKeys = data.keys.toList()..sort();
          final latestKey = sortedKeys.last;
          
          if (data[latestKey] is Map) {
            current = double.tryParse(data[latestKey]['weight']?.toString() ?? '0') ?? 0;
            
            if (sortedKeys.length >= 2) {
              final previousKey = sortedKeys[sortedKeys.length - 2];
              final prevWeight = double.tryParse(data[previousKey]['weight']?.toString() ?? '0') ?? 0;
              diff = current - prevWeight;
            }
          }

          final recentKeys = sortedKeys.length > 10 
              ? sortedKeys.sublist(sortedKeys.length - 10) 
              : sortedKeys;

          for (int i = 0; i < recentKeys.length; i++) {
            final key = recentKeys[i];
            final double weight = double.tryParse(data[key]['weight']?.toString() ?? '0') ?? 0;
            spots.add(FlSpot(i.toDouble(), weight));
          }
        }

        if (mounted) {
          setState(() {
            _weightSpots = spots;
            _currentWeight = current;
            _weightDiff = diff;
            _canRegisterToday = canRegister;
            _challengeCompleted = !canRegister;
            _weightHistory = data.map((key, value) => MapEntry(
                  key.toString(),
                  double.tryParse((value as Map)['weight']?.toString() ?? '0') ?? 0.0,
                ));
          });
        }
      } else if (mounted) {
        setState(() {
          _canRegisterToday = true;
          _currentWeight = 0;
          _weightDiff = 0;
          _weightSpots = [];
          _weightHistory = {};
        });
      }
    });
  }

  void _listenToVisualGoal() {
    _visualGoalSubscription = _nutritionService.getUserProfile().asStream().listen((event) {
        // Since it's a field in profile, we listen to the whole profile for now or just get it once
        // Actually NutritionService.getUserProfile returns a Future. Let's make it a stream or just fetch it in initState.
    });
    
    // Better: create a specific stream for visual goal if we want real-time.
    // For now I'll use a fetch in _fetchInitialData or similar.
  }

  Future<void> _fetchVisualGoal() async {
    debugPrint('DASHBOARD: Fetching user profile for visual goal...');
    final profile = await _nutritionService.getUserProfile();
    debugPrint('DASHBOARD: Profile data: $profile');
    if (profile != null && profile.containsKey('visual_goal')) {
      debugPrint('DASHBOARD: Visual goal found: ${profile['visual_goal']}');
      if (mounted) {
        setState(() {
          _visualGoal = Map<String, dynamic>.from(profile['visual_goal'] as Map);
        });
      }
    } else {
      debugPrint('DASHBOARD: No visual_goal key in profile.');
    }
  }

  @override
  void dispose() {
    _updateSubscription?.cancel();
    _mealsSubscription?.cancel();
    _goalsSubscription?.cancel();
    _planSubscription?.cancel();
    _streakSubscription?.cancel();
    _historySubscription?.cancel();
    _weightSubscription?.cancel();
    _visualGoalSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    try {
      debugPrint('DASHBOARD: Starting initial data fetch...');
      // Prioritize visual goal
      await _fetchVisualGoal();
      
      // Other services
      await _financeService.getFinanceData();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('DASHBOARD: Error in _fetchInitialData: $e');
      if (mounted) {
        setState(() => _isLoading = false);
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : RefreshIndicator(
              onRefresh: () async {
                await _fetchInitialData();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    if (!_challengeCompleted) ...[
                      _buildDailyChallenge(l10n),
                      const SizedBox(height: 24),
                    ],
                    _buildVisualGoalCard(),
                    const SizedBox(height: 24),
                    _buildCalorieCard(),
                    const SizedBox(height: 32),
                    _buildSectionTitle(l10n.caloricHistory7d),
                    const SizedBox(height: 16),
                    _buildHistoryChart(),
                    const SizedBox(height: 32),
                    _buildSectionTitle(l10n.myGoals, onAdd: _showAddGoalDialog),
                    const SizedBox(height: 16),
                    _buildGoalsList(),
                    const SizedBox(height: 32),
                    _buildSectionTitle(l10n.bodyWeight),
                    const SizedBox(height: 16),
                    _buildWeightSection(),
                    const SizedBox(height: 32),
                    _buildSectionTitle(l10n.todayPlan),
                    const SizedBox(height: 16),
                    _buildDailyTimeline(l10n),
                    const SizedBox(height: 48),
                    _buildCitationsSection(l10n),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildCitationsSection(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book_rounded, color: AppTheme.primary, size: 20),
              const SizedBox(width: 12),
              Text(
                l10n.healthCitationsTitle,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.healthDisclaimer,
            style: GoogleFonts.manrope(
              fontSize: 11,
              color: AppTheme.secondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildSourceLink(l10n.whoDietSource, 'https://www.who.int/news-room/fact-sheets/detail/healthy-diet'),
          _buildSourceLink(l10n.usdaDietSource, 'https://www.dietaryguidelines.gov/'),
        ],
      ),
    );
  }

  Widget _buildSourceLink(String label, String url) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            const Icon(Icons.link_rounded, color: AppTheme.accent, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 13, 
                  color: AppTheme.accent, 
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCitationsDialog({required String title, required String content, bool showSources = false}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppTheme.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title, 
                    style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.primary)
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              content,
              style: GoogleFonts.manrope(fontSize: 14, color: AppTheme.primary.withValues(alpha: 0.8), height: 1.6),
            ),
            if (showSources) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                l10n.sourcesLabel,
                style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.secondary, letterSpacing: 1.2),
              ),
              const SizedBox(height: 12),
              _buildSourceLink(l10n.whoDietSource, 'https://www.who.int/news-room/fact-sheets/detail/healthy-diet'),
              _buildSourceLink(l10n.usdaDietSource, 'https://www.dietaryguidelines.gov/'),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                l10n.closeBtn, 
                style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold)
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ... (Header and BalanceCard remain the same) ...
  // ... (Previous methods) ...

  Widget _buildVisualGoalCard() {
    debugPrint('DASHBOARD: Building visual goal card. _visualGoal: $_visualGoal');
    if (_visualGoal == null) {
       debugPrint('DASHBOARD: _visualGoal is null, skipping card.');
       return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: Colors.amber, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${l10n.aiVision}: ${(_visualGoal!['prompt'] ?? l10n.targetLabel.toUpperCase()).toString().toUpperCase()}',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: AppTheme.primary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _showCitationsDialog(
                  title: l10n.aiVision,
                  content: l10n.aiVisionDisclaimer,
                  showSources: true,
                ),
                icon: Icon(Icons.info_outline_rounded, color: AppTheme.primary.withValues(alpha: 0.4), size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        _visualGoal!['original_image'],
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.nowLabel, style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.arrow_forward_rounded, color: AppTheme.accent),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.network(
                            _visualGoal!['ai_goal_image'],
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            color: Colors.purple.withValues(alpha: 0.3),
                            colorBlendMode: BlendMode.plus,
                          ),
                          Container(
                            color: Colors.black.withValues(alpha: 0.2),
                          ),
                          const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.yourGoalLabel, style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.accent)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.accent.withValues(alpha: 0.1)),
            ),
            child: Text(
              l10n.aiPredictionMsg,
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: AppTheme.primary.withValues(alpha: 0.8),
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildDailyTimeline(AppLocalizations l10n) {
    if (_dailyMeals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(
          children: [
            Icon(Icons.calendar_today_outlined, color: AppTheme.secondary.withValues(alpha: 0.3), size: 48),
            const SizedBox(height: 16),
            Text(l10n.noPlanToday, style: GoogleFonts.manrope(color: AppTheme.secondary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(l10n.askAiPlanChat, style: GoogleFonts.manrope(color: AppTheme.secondary.withValues(alpha: 0.6), fontSize: 12)),
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
            onTap: () async {
              await _nutritionService.toggleMealCompletion(id, !isCompleted);
              
              // Check if all meals are now completed to potentially increment streak
              if (!isCompleted) {
                bool allDone = true;
                for (var m in _dailyMeals) {
                  if (m['id'] != id && m['completed'] != true) {
                    allDone = false;
                    break;
                  }
                }
                if (allDone) {
                  final updated = await _nutritionService.updateStreak(1);
                  if (mounted) {
                    GamificationService().checkAndShowModal(
                      context, 
                      updated ? PandaTrigger.streakKeep : PandaTrigger.mealLogged
                    );
                  }
                } else {
                  if (mounted) {
                    GamificationService().checkAndShowModal(context, PandaTrigger.mealLogged);
                  }
                }
              }
            },
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

  Widget _buildHeader() {
    return StreamBuilder<DatabaseEvent>(
      stream: _nutritionService.getGamificationStats(),
      builder: (context, snapshot) {
        int lives = 5;
        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final data = snapshot.data!.snapshot.value as Map;
          lives = data['lives'] ?? 5;
        } else {
           // Try to init if null
           _nutritionService.initializeGamificationStats();
        }
        final l10n = AppLocalizations.of(context)!;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(l10n),
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: AppTheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _userName.isNotEmpty ? 'Hola, $_userName' : l10n.profile, // Or another key if more appropriate
                  style: GoogleFonts.manrope(
                    fontSize: 24,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            if (_visualGoal != null && _visualGoal!['original_image'] != null)
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(_visualGoal!['original_image']),
                ),
              ),

            GestureDetector(
              onTap: () => _handleCheatMeal(lives),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      '$lives',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildDailyChallenge(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.deepPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star_rounded, color: Colors.amber, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dailyChallenge,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.white70,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  l10n.logCurrentWeight,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: widget.onChallengeClick,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.purple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              l10n.goBtn,
              style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 20) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  Future<void> _handleCheatMeal(int currentLives) async {
    final l10n = AppLocalizations.of(context)!;
    if (currentLives <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noLivesLeft))
      );
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text(l10n.useLifeTitle),
        content: Text(l10n.useLifeDesc),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancelLabel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.goBtn)),
        ],
      )
    );

    if (confirm == true) {
      final success = await _nutritionService.consumeLife();
      if (success && mounted) {
        GamificationService().checkAndShowModal(context, PandaTrigger.lifeUsed);
      }
    }
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
                '$_streak ${l10n.daysStreakLabel}',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              const Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 24),
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
                l10n.remainingLabel, 
                '${remaining.toStringAsFixed(0)} kcal', 
                Colors.orangeAccent
              ),
              const SizedBox(width: 32),
              _buildMiniStat(
              l10n.targetLabel, 
              '${target.toStringAsFixed(0)} kcal', 
              Colors.greenAccent
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _showCitationsDialog(
                title: l10n.targetLabel,
                content: l10n.calorieTargetInfo,
                showSources: true,
              ),
              icon: Icon(Icons.info_outline_rounded, color: Colors.white.withValues(alpha: 0.6), size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
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
    String selectedType = 'weight'; // weight, exercise_minutes, distance_km

    bool isDaily = true;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setBottomSheetState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.newGoalTitle,
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.newGoalSubtitle,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: AppTheme.secondary,
                ),
              ),
              const SizedBox(height: 32),
              // Goal Type Selector
              Text(
                l10n.goalTypeLabel,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildGoalTypeChip(
                      l10n.goalWeight,
                      'weight',
                      selectedType == 'weight',
                      () => setBottomSheetState(() {
                        selectedType = 'weight';
                        titleController.text = l10n.goalWeight;
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildGoalTypeChip(
                      l10n.goalExercise,
                      'exercise_minutes',
                      selectedType == 'exercise_minutes',
                      () => setBottomSheetState(() {
                        selectedType = 'exercise_minutes';
                        titleController.text = l10n.goalExercise;
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildGoalTypeChip(
                      l10n.goalDistance,
                      'distance_km',
                      selectedType == 'distance_km',
                      () => setBottomSheetState(() {
                        selectedType = 'distance_km';
                        titleController.text = l10n.goalDistance;
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: l10n.goalNameLabel,
                  hintText: _getGoalHint(selectedType),
                  prefixIcon: Icon(_getGoalIcon(selectedType)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: AppTheme.background,
                ),
                style: GoogleFonts.manrope(),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: l10n.goalTargetValueLabel,
                  hintText: _getGoalValueHint(selectedType),
                  suffixText: _getGoalUnit(selectedType),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: AppTheme.background,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.manrope(),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.replay_rounded, color: AppTheme.primary),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Objetivo Recurrente',
                              style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              'Se reinicia cada día',
                              style: GoogleFonts.manrope(fontSize: 12, color: AppTheme.secondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Switch(
                      value: isDaily,
                      onChanged: (val) => setBottomSheetState(() => isDaily = val),
                      activeTrackColor: AppTheme.primary,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  onPressed: isSaving ? null : () async {
                    final double? amount = double.tryParse(amountController.text);
                    if (titleController.text.isEmpty || amount == null) return;

                    setBottomSheetState(() => isSaving = true);
                    
                    try {
                      await _nutritionService.saveGoal({
                        'title': titleController.text,
                        'target_amount': amount,
                        'current_amount': 0,
                        'goal_type': selectedType,
                        'unit': _getGoalUnit(selectedType),
                        'is_daily': isDaily,
                        'deadline': DateTime.now().add(Duration(days: isDaily ? 365 : 30)).toIso8601String().split('T')[0],
                      });
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.goalCreatedSuccess), backgroundColor: Colors.green),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      setBottomSheetState(() => isSaving = false);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  },
                  child: isSaving 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) 
                    : Text(l10n.createGoalBtn, style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalTypeChip(String label, String type, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppTheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  String _getGoalHint(String type) {
    switch (type) {
      case 'weight':
        return 'ej. Perder 5kg';
      case 'exercise_minutes':
        return 'ej. 30 min diarios';
      case 'distance_km':
        return 'ej. Correr 5km';
      default:
        return '';
    }
  }

  IconData _getGoalIcon(String type) {
    switch (type) {
      case 'weight':
        return Icons.monitor_weight_outlined;
      case 'exercise_minutes':
        return Icons.timer_outlined;
      case 'distance_km':
        return Icons.directions_run;
      default:
        return Icons.flag;
    }
  }

  String _getGoalValueHint(String type) {
    switch (type) {
      case 'weight':
        return 'ej. 70';
      case 'exercise_minutes':
        return 'ej. 30';
      case 'distance_km':
        return 'ej. 5';
      default:
        return '';
    }
  }

  String _getGoalUnit(String type) {
    switch (type) {
      case 'weight':
        return 'kg';
      case 'exercise_minutes':
        return 'min';
      case 'distance_km':
        return 'km';
      default:
        return '';
    }
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
    final double realProgress = current / target;
    final double progress = realProgress.clamp(0.0, 1.0);
    final String title = goal['title'] ?? 'Meta';
    final String? goalId = goal['id']?.toString();
    final String goalType = goal['goal_type'] ?? '';
    final String unit = goal['unit'] ?? '';
    final int percentage = (realProgress * 100).round();
    
    // Color based on progress
    Color progressColor = percentage < 30 
        ? Colors.orange 
        : percentage < 70 
            ? Colors.amber 
            : Colors.green;

    // Get icon based on goal type
    IconData goalIcon = _getGoalIcon(goalType);

    return GestureDetector(
      onTap: goalId != null ? () => _showContributeToGoalDialog(goal) : null,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              progressColor.withValues(alpha: 0.1),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: progressColor.withValues(alpha: 0.1), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: progressColor.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: progressColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(goalIcon, color: progressColor, size: 20),
                ),
                Text(
                  '$percentage%',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: progressColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: AppTheme.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (goal['is_daily'] == true)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Día',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${current.toStringAsFixed(1)} de ${target.toStringAsFixed(1)} $unit',
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.secondary,
              ),
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppTheme.background,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: goalId != null ? () => _showContributeToGoalDialog(goal) : null,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.progressLabel,
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () => _showDeleteGoalConfirmation(goal),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: Colors.redAccent,
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

  void _showContributeToGoalDialog(Map<String, dynamic> goal) async {
    final amountController = TextEditingController();
    bool isSaving = false;
    bool isWithdrawMode = false;
    bool showHistory = false;
    
    final double target = double.tryParse(goal['target_amount'].toString()) ?? 1.0;
    double current = double.tryParse(goal['current_amount'].toString()) ?? 0.0;
    final String title = goal['title'] ?? 'Meta';
    final String? goalId = goal['id']?.toString();
    final String goalType = goal['goal_type'] ?? '';
    final String unit = goal['unit'] ?? '';

    // If it's a weight goal, fetch current weight from Firebase
    if (goalType == 'weight') {
      try {
        final weightSnapshot = await _nutritionService.getWeightHistory().first;
        if (weightSnapshot.snapshot.exists) {
          final Map<dynamic, dynamic> weightData = weightSnapshot.snapshot.value as Map<dynamic, dynamic>;
          if (weightData.isNotEmpty) {
            // Get the most recent weight entry
            final sortedKeys = weightData.keys.toList()..sort((a, b) => b.toString().compareTo(a.toString()));
            final latestWeight = weightData[sortedKeys.first];
            current = double.tryParse(latestWeight['weight']?.toString() ?? '0') ?? current;
          }
        }
      } catch (e) {
        debugPrint('Error fetching weight: $e');
      }
    }

    final double remaining = (target - current).clamp(0, target);

    if (goalId == null) return;
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setBottomSheetState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.manrope(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primary,
                          ),
                        ),
                        Text(
                          isWithdrawMode ? l10n.subtractLabel : l10n.addLabel,
                          style: GoogleFonts.manrope(fontSize: 14, color: AppTheme.secondary),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          isWithdrawMode ? Icons.trending_down : Icons.trending_up,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => setBottomSheetState(() => showHistory = !showHistory),
                        icon: Icon(showHistory ? Icons.edit_note : Icons.history, size: 16),
                        label: Text(
                          showHistory ? l10n.registerAction : l10n.historyAction,
                          style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.secondary,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 30),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Progress Overview
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildModalStat(l10n.actualLabel, '${current.toStringAsFixed(1)} $unit', AppTheme.primary),
                    ),
                    Container(height: 40, width: 1, color: Colors.grey.withValues(alpha: 0.2)),
                    Expanded(
                      child: _buildModalStat(l10n.targetLabel, '${target.toStringAsFixed(1)} $unit', AppTheme.secondary),
                    ),
                    Container(height: 40, width: 1, color: Colors.grey.withValues(alpha: 0.2)),
                    Expanded(
                      child: _buildModalStat(l10n.restLabel, '${remaining.toStringAsFixed(1)} $unit', Colors.orangeAccent),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              if (showHistory)
                Expanded(
                  child: StreamBuilder<DatabaseEvent>(
                    stream: _nutritionService.getGoalHistory(goalId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      final data = snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;
                      if (data == null || data.isEmpty) {
                        return Center(
                          child: Text(
                            l10n.noRecordsYet,
                            style: GoogleFonts.manrope(color: AppTheme.secondary),
                          ),
                        );
                      }
                      
                      final sortedHistory = data.entries.toList()
                        ..sort((a, b) => b.value['timestamp'].compareTo(a.value['timestamp']));
                      
                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 16),
                        itemCount: sortedHistory.length,
                        itemBuilder: (context, index) {
                          final item = sortedHistory[index].value;
                          final bool isW = item['type'] == 'withdrawal';
                          final double hAmount = double.tryParse(item['amount'].toString()) ?? 0.0;
                          final date = DateTime.fromMillisecondsSinceEpoch(item['timestamp'] ?? 0);
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.background,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: (isW ? Colors.orange : Colors.green).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isW ? Icons.remove : Icons.add,
                                    color: isW ? Colors.orange : Colors.green,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isW ? l10n.withdrawnLabel : l10n.contributedLabel,
                                        style: GoogleFonts.manrope(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('dd/MM/yyyy HH:mm').format(date),
                                        style: GoogleFonts.manrope(
                                          fontSize: 12,
                                          color: AppTheme.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${isW ? "-" : "+"}${hAmount.toStringAsFixed(1)} $unit',
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.w900,
                                    color: isW ? Colors.orange : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                )
              else ...[
                // Mode Toggle
                Row(
                  children: [
                    Expanded(
                      child: _buildModeButton(
                        l10n.addLabel, 
                        Icons.add_circle_outline, 
                        !isWithdrawMode, 
                        () => setBottomSheetState(() => isWithdrawMode = false)
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildModeButton(
                        l10n.subtractLabel, 
                        Icons.remove_circle_outline, 
                        isWithdrawMode, 
                        () => setBottomSheetState(() => isWithdrawMode = true)
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: l10n.amountToLog,
                    prefixIcon: const Icon(Icons.edit_note),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: AppTheme.background,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  style: GoogleFonts.manrope(),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isWithdrawMode ? Colors.orangeAccent : AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 0,
                    ),
                    onPressed: isSaving ? null : () async {
                      final double? amount = double.tryParse(amountController.text);
                      if (amount == null || amount <= 0) return;

                      setBottomSheetState(() => isSaving = true);
                      
                      try {
                        // Calculate new current value
                        final double newCurrent = isWithdrawMode ? current - amount : current + amount;
                        final bool wasIncomplete = current < target;
                        final bool isNowComplete = newCurrent >= target;
                        
                        await _nutritionService.updateGoalProgress(
                          goalId, 
                          amount, 
                          isWithdrawal: isWithdrawMode
                        );
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        
                        // Check if goal was just completed
                        if (wasIncomplete && isNowComplete && !isWithdrawMode) {
                          // Show Panda Modal for goal completion!
                          GamificationService().checkAndShowModal(context, PandaTrigger.goalMet);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.progressUpdatedSuccess),
                              backgroundColor: isWithdrawMode ? Colors.orange : Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        setBottomSheetState(() => isSaving = false);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                    child: isSaving 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) 
                      : Text(l10n.confirmBtn, style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.manrope(fontSize: 12, color: AppTheme.secondary)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }

  Widget _buildModeButton(String label, IconData icon, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: active ? AppTheme.primary : AppTheme.background,
          borderRadius: BorderRadius.circular(16),
          border: active ? null : Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? Colors.white : AppTheme.secondary, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.bold,
                color: active ? Colors.white : AppTheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteGoalConfirmation(Map<String, dynamic> goal) {
    final l10n = AppLocalizations.of(context)!;
    final String title = goal['title'] ?? 'esta meta';
    final String? goalId = goal['id']?.toString();

    if (goalId == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.deleteGoalTitle, style: GoogleFonts.manrope(fontWeight: FontWeight.w900)),
        content: Text(l10n.deleteGoalDesc.replaceAll('{title}', title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancelLabel, style: GoogleFonts.manrope(color: AppTheme.secondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              try {
                await _nutritionService.deleteGoal(goalId);
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.goalDeleted)),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: Text(l10n.deleteBtn),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
              l10n.bodyWeight,
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: () => _showCitationsDialog(
                title: l10n.bodyWeight,
                content: l10n.weightMonitoringInfo,
                showSources: true,
              ),
              icon: Icon(Icons.info_outline_rounded, color: AppTheme.secondary.withValues(alpha: 0.5), size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const Spacer(),
            IconButton(
                onPressed: _showLogWeightDialog,
                icon: Icon(
                  _canRegisterToday ? Icons.add_circle_outline : Icons.edit_note_rounded, 
                  color: _canRegisterToday ? AppTheme.primary : AppTheme.secondary,
                  size: 20,
                ),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          if (!_canRegisterToday)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 12),
              child: Text(
                l10n.weightNextLog,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  color: AppTheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               _buildWeightStat(l10n.current, '$_currentWeight', 'kg'),
               _buildWeightStat(
                 l10n.trend, 
                 '${_weightDiff > 0 ? '+' : ''}${_weightDiff.toStringAsFixed(1)}', 
                 'kg',
                 color: _weightDiff < 0 ? Colors.green : (_weightDiff > 0 ? Colors.red : AppTheme.secondary),
               ),
            ],
          ),
          const Divider(height: 48),
          SizedBox(
            height: 180,
            child: _weightSpots.isEmpty 
                ? Center(
                    child: Text(
                      l10n.logWeightToSeeProgress,
                      style: GoogleFonts.manrope(color: AppTheme.secondary, fontSize: 13),
                    ),
                  )
              : LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _weightSpots,
                        isCurved: true,
                        color: AppTheme.primary,
                        barWidth: 6,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [AppTheme.primary.withValues(alpha: 0.2), Colors.transparent],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightStat(String label, String value, String unit, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppTheme.secondary,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: color ?? AppTheme.primary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showLogWeightDialog() {
    final weightController = TextEditingController(
      text: _currentWeight > 0 ? _currentWeight.toString() : ''
    );
    bool isSaving = false;
    bool showHistory = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    showHistory ? l10n.weightHistoryTitle : (_canRegisterToday ? l10n.logWeight : l10n.updateWeight),
                    style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.primary),
                  ),
                  TextButton.icon(
                    onPressed: () => setModalState(() => showHistory = !showHistory),
                    icon: Icon(showHistory ? Icons.edit_note : Icons.history, size: 20),
                    label: Text(
                      showHistory ? l10n.registerAction : l10n.historyAction,
                      style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(foregroundColor: AppTheme.secondary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (showHistory) ...[
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                  child: _weightHistory.isEmpty
                      ? Center(child: Text(l10n.noRecordsYet, style: GoogleFonts.manrope(color: AppTheme.secondary)))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _weightHistory.length,
                          itemBuilder: (context, index) {
                            final keys = _weightHistory.keys.toList()..sort((a, b) => b.compareTo(a));
                            final dateStr = keys[index];
                            final weight = _weightHistory[dateStr];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
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
                                        dateStr,
                                        style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      Text(
                                        l10n.dailyLog,
                                        style: GoogleFonts.manrope(fontSize: 12, color: AppTheme.secondary),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${weight?.toStringAsFixed(1)} kg',
                                    style: GoogleFonts.manrope(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ] else ...[
                if (!_canRegisterToday)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.orange, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          l10n.weightAlreadyLoggedHint,
                          style: GoogleFonts.manrope(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                Text(l10n.enterWeightHint, style: GoogleFonts.manrope(color: AppTheme.secondary)),
                const SizedBox(height: 24),
                TextField(
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    suffixText: 'kg',
                    hintText: '0.0',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: isSaving ? null : () async {
                      final String rawValue = weightController.text.replaceAll(',', '.').trim();
                      final double? weight = double.tryParse(rawValue);
                      
                      if (weight == null || weight <= 0 || weight > 500) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.invalidWeightError), backgroundColor: Colors.redAccent),
                        );
                        return;
                      }

                      setModalState(() => isSaving = true);
                      
                      try {
                        await _nutritionService.saveWeight(weight);
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.weightSuccess), backgroundColor: Colors.green),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        setModalState(() => isSaving = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.saveErrorMsg(e.toString())), backgroundColor: Colors.redAccent),
                        );
                      }
                    },
                    child: isSaving
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : Text(l10n.save, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }


}
