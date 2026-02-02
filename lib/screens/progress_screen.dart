import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

import '../theme/app_theme.dart';
import '../services/nutrition_service.dart';
import '../services/auth_service.dart';
import '../services/fitness_service.dart';
import '../l10n/app_localizations.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final NutritionService _nutritionService = NutritionService();
  final AuthService _authService = AuthService();
  final FitnessService _fitnessService = FitnessService();
  
  int _streak = 0;
  String _userName = 'Tú';
  String _userEmoji = '🦊';
  List<Map<String, dynamic>> _ranking = [];
  
  bool _hasWeightData = false;
  
  StreamSubscription? _streakSubscription;
  StreamSubscription? _rankingSubscription;
  StreamSubscription? _weightSubscription;

  // Fitness data
  int _todaySteps = 0;
  int _todayCalories = 0;
  String _todayDistance = '0.0';
  int _todayActiveMinutes = 0;
  bool _fitnessAuthorized = false;
  List<FlSpot> _stepsSpots = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _listenToStreak();
    _listenToRanking();
    _listenToWeightStatus();
    _initializeFitness();
    _syncGamification();
  }

  void _listenToWeightStatus() {
    _weightSubscription = _nutritionService.getWeightHistory().listen((event) {
      if (mounted) {
        setState(() {
          _hasWeightData = event.snapshot.value != null;
        });
      }
    });
  }

  Future<void> _syncGamification() async {
    await _nutritionService.validateAndSyncGamification();
  }

  Future<void> _initializeFitness() async {
    debugPrint('🏃 [FITNESS] Iniciando proceso de autorización...');
    try {
      final authorized = await _fitnessService.requestAuthorization();
      debugPrint('🏃 [FITNESS] Resultado de autorización: $authorized');
      
      if (mounted) {
        setState(() {
          _fitnessAuthorized = authorized;
        });
        debugPrint('🏃 [FITNESS] Estado actualizado: _fitnessAuthorized = $_fitnessAuthorized');
        
        if (authorized) {
          debugPrint('🏃 [FITNESS] Autorización concedida, cargando datos...');
          _loadFitnessData();
        } else {
          debugPrint('⚠️ [FITNESS] Autorización denegada o no disponible');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [FITNESS] Error en _initializeFitness: $e');
      debugPrint('❌ [FITNESS] StackTrace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al solicitar permisos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadFitnessData() async {
    debugPrint('📊 [FITNESS] Cargando datos de fitness...');
    try {
      final data = await _fitnessService.syncFitnessData();
      debugPrint('📊 [FITNESS] Datos recibidos: $data');
      
      final history = await _fitnessService.getStepsHistory(days: 7);
      debugPrint('📊 [FITNESS] Historial recibido: ${history.length} días');
      
      if (mounted) {
        setState(() {
          _todaySteps = data['steps'] ?? 0;
          _todayCalories = data['calories'] ?? 0;
          _todayDistance = data['distance'] ?? '0.0';
          _todayActiveMinutes = data['activeMinutes'] ?? 0;
          
          debugPrint('📊 [FITNESS] Pasos: $_todaySteps, Calorías: $_todayCalories, Distancia: $_todayDistance km, Minutos: $_todayActiveMinutes');
          
          // Crear datos para gráfico de pasos
          _stepsSpots = history.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble(), (entry.value['steps'] as int).toDouble());
          }).toList();
          
          debugPrint('📊 [FITNESS] Gráfico creado con ${_stepsSpots.length} puntos');
        });
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [FITNESS] Error en _loadFitnessData: $e');
      debugPrint('❌ [FITNESS] StackTrace: $stackTrace');
    }
  }

  Future<void> _loadProfile() async {
    final result = await _authService.getProfile();
    final emoji = await _nutritionService.getUserEmoji();
    if (result['success'] == true && mounted) {
      setState(() {
        _userName = result['data']['name'] ?? 'Tú';
        _userEmoji = emoji ?? '🦊';
      });
      // Sync initial ranking
      _nutritionService.syncUserRanking(_userName, _streak, emoji: _userEmoji);
    }
  }

  void _listenToStreak() {
    _streakSubscription = _nutritionService.getStreak().listen((event) {
      if (event.snapshot.value != null && mounted) {
        final newStreak = int.tryParse(event.snapshot.value.toString()) ?? 0;
        setState(() {
          _streak = newStreak;
        });
        // Sync streak to global ranking
        _nutritionService.syncUserRanking(_userName, newStreak, emoji: _userEmoji);
      }
    });
  }

  void _listenToRanking() {
    _rankingSubscription = _nutritionService.getGlobalRanking().listen((event) {
      if (mounted) {
        List<Map<String, dynamic>> rankList = [];
        if (event.snapshot.value != null) {
          final Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
          data.forEach((key, value) {
            rankList.add(Map<String, dynamic>.from(value as Map));
          });
          // Sort descending by streak
          rankList.sort((a, b) => (b['streak'] ?? 0).compareTo(a['streak'] ?? 0));
        }

        // If no data or too few, inject fake competitive data for gamification
        if (rankList.length < 3) {
          rankList = [
            {'name': 'FitWarrior', 'streak': 42, 'emoji': '🔥'},
            {'name': 'NutriChampion', 'streak': 38, 'emoji': '🥗'},
            {'name': 'BeastMode', 'streak': 25, 'emoji': '🏋️'},
            {'name': 'GreenLife', 'streak': 15, 'emoji': '🍎'},
            {'name': 'HealthyHero', 'streak': 12, 'emoji': '🥑'},
          ];
          // Add self if not there
          if (!rankList.any((e) => e['name'] == _userName)) {
            rankList.add({'name': _userName, 'streak': _streak, 'emoji': _userEmoji});
          }
          rankList.sort((a, b) => (b['streak'] ?? 0).compareTo(a['streak'] ?? 0));
        }

        setState(() {
          _ranking = rankList;
        });
      }
    });
  }



  @override
  void dispose() {
    _streakSubscription?.cancel();
    _rankingSubscription?.cancel();
    _weightSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAnimatedItem(0, _buildHeader()),
              const SizedBox(height: 32),
              _buildAnimatedItem(1, _buildStreakCard()),
              const SizedBox(height: 32),
              _buildAnimatedItem(2, _buildFitnessSection()),
              const SizedBox(height: 32),
              _buildAnimatedItem(4, _buildRankingSection()),
              const SizedBox(height: 32),
              _buildAnimatedItem(5, _buildMilestones()),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedItem(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.progressTitle,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppTheme.secondary,
            letterSpacing: 2,
          ),
        ),
        Text(
          l10n.progressSubtitle,
          style: GoogleFonts.manrope(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.redAccent, Colors.red.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.currentStreak,
                style: GoogleFonts.manrope(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const Icon(Icons.local_fire_department_rounded, color: Colors.yellowAccent, size: 24),
            ],
          ),
          const SizedBox(height: 16),
          TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 2),
            tween: Tween(begin: 0, end: _streak.toDouble()),
            builder: (context, value, child) => Text(
              '${value.toInt()} ${l10n.daysLabel}',
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 56,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.rankingTop.replaceAll('{n}', ((_ranking.indexWhere((e) => e['name'] == _userName) + 1).clamp(1, 100)).toString()),
            style: GoogleFonts.manrope(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFitnessSection() {
    final l10n = AppLocalizations.of(context)!;
    // Si no está autorizado, mostrar mensaje de autorización
    if (!_fitnessAuthorized) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.watch_rounded, size: 64, color: Colors.blue.shade700),
            const SizedBox(height: 16),
            Text(
              l10n.connectWatch,
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppTheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.fitnessAuthDesc,
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: AppTheme.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _initializeFitness,
              icon: const Icon(Icons.health_and_safety),
              label: Text(l10n.authAccess, style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      );
    }

    // UI normal cuando está autorizado
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.physicalActivity,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.secondary,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  l10n.fromWatch,
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: _loadFitnessData,
              icon: const Icon(Icons.refresh, color: AppTheme.primary),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Tarjetas de métricas
        Row(
          children: [
            Expanded(
              child: _buildFitnessCard(
                '🚶',
                _todaySteps.toString(),
                l10n.steps,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFitnessCard(
                '🔥',
                _todayCalories.toString(),
                l10n.calories,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFitnessCard(
                '📍',
                '$_todayDistance km',
                l10n.distance,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFitnessCard(
                '⏱️',
                '$_todayActiveMinutes min',
                l10n.active,
                Colors.purple,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Gráfico de pasos de la semana
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.stepsWeek,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: _stepsSpots.isEmpty
                    ? const Center(child: Text('Sin datos suficientes'))
                    : LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _stepsSpots,
                              isCurved: true,
                              color: Colors.blue,
                              barWidth: 4,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.withValues(alpha: 0.2),
                                    Colors.transparent
                                  ],
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
        ),
      ],
    );
  }

  Widget _buildFitnessCard(String emoji, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondary,
            ),
          ),
        ],
      ),
    );
  }





  Widget _buildRankingSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.warriorRanking,
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
              ),
            ],
          ),
          child: _ranking.isEmpty 
            ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
            : Column(
                children: _ranking.take(5).toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final user = entry.value;
                  final bool isMe = user['name'] == _userName;
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color: isMe ? AppTheme.primary.withValues(alpha: 0.05) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${index + 1}',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w900,
                            color: index < 3 ? Colors.orange : AppTheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: AppTheme.background,
                          child: Text(
                            user['emoji'] ?? '🦊',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            user['name'] ?? 'Usuario',
                            style: GoogleFonts.manrope(
                              fontWeight: isMe ? FontWeight.w800 : FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${user['streak'] ?? 0}',
                              style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
        ),
      ],
    );
  }

  Widget _buildMilestones() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.milestones,
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        _buildMilestoneItem(l10n.milestoneStreakTitle, l10n.milestoneStreakDesc, Icons.workspace_premium, Colors.amber, _streak >= 3),
        _buildMilestoneItem(l10n.milestoneWeightTitle, l10n.milestoneWeightDesc, Icons.monitor_weight, Colors.green, _hasWeightData),
        _buildMilestoneItem(l10n.milestoneRankingTitle, l10n.milestoneRankingDesc, Icons.auto_awesome, Colors.purple, _ranking.indexWhere((e) => e['name'] == _userName) < 5 && _ranking.isNotEmpty),
        if (_fitnessAuthorized) ...[
          _buildMilestoneItem(l10n.milestoneStepsTitle, l10n.milestoneStepsDesc, Icons.directions_walk, Colors.blue, _todaySteps >= 10000),
          _buildMilestoneItem(l10n.milestoneCaloriesTitle, l10n.milestoneCaloriesDesc, Icons.local_fire_department, Colors.deepOrange, _todayCalories >= 500),
        ],
      ],
    );
  }

  Widget _buildMilestoneItem(String title, String subtitle, IconData icon, Color color, bool achieved) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: achieved ? Colors.white : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: achieved ? null : Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          if (achieved)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 5,
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: achieved ? color.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: achieved ? color : Colors.grey, size: 24),
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
                    color: achieved ? AppTheme.primary : AppTheme.secondary,
                  ),
                ),
                Text(
                  achieved ? subtitle : l10n.locked,
                  style: GoogleFonts.manrope(fontSize: 12, color: AppTheme.secondary),
                ),
              ],
            ),
          ),
          if (!achieved)
            const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
