import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/nutrition_service.dart';
import '../services/auth_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final NutritionService _nutritionService = NutritionService();
  final AuthService _authService = AuthService();
  
  int _streak = 0;
  String _userName = 'Tú';
  List<Map<String, dynamic>> _ranking = [];
  List<FlSpot> _weightSpots = [];
  
  StreamSubscription? _streakSubscription;
  StreamSubscription? _rankingSubscription;
  StreamSubscription? _weightSubscription;

  double _currentWeight = 0;
  double _weightDiff = 0;
  bool _canRegisterToday = true;
  DateTime? _lastRegistrationTime;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _listenToStreak();
    _listenToRanking();
    _listenToWeight();
  }

  Future<void> _loadProfile() async {
    final result = await _authService.getProfile();
    if (result['success'] == true && mounted) {
      setState(() {
        _userName = result['data']['name'] ?? 'Tú';
      });
      // Sync initial ranking
      _nutritionService.syncUserRanking(_userName, _streak);
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
        _nutritionService.syncUserRanking(_userName, newStreak);
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
            {'name': '🔥 FitWarrior', 'streak': 42},
            {'name': '🥗 NutriChampion', 'streak': 38},
            {'name': '🏋️ BeastMode', 'streak': 25},
            {'name': '🍎 GreenLife', 'streak': 15},
            {'name': '🥑 HealthyHero', 'streak': 12},
          ];
          // Add self if not there
          if (!rankList.any((e) => e['name'] == _userName)) {
            rankList.add({'name': _userName, 'streak': _streak});
          }
          rankList.sort((a, b) => (b['streak'] ?? 0).compareTo(a['streak'] ?? 0));
        }

        setState(() {
          _ranking = rankList;
        });
      }
    });
  }

  void _listenToWeight() {
    _weightSubscription = _nutritionService.getWeightHistory().listen((event) {
      if (mounted) {
        final List<FlSpot> spots = [];
        double current = 0;
        double diff = 0;
        bool canRegister = true;
        DateTime? lastTime;

        if (event.snapshot.value != null) {
          final Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
          final sortedKeys = data.keys.toList()..sort();
          
          final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
          if (sortedKeys.contains(today)) {
            canRegister = false;
            final lastEntry = data[today];
            if (lastEntry['timestamp'] != null) {
              lastTime = DateTime.fromMillisecondsSinceEpoch(lastEntry['timestamp'] as int);
            }
          }

          if (sortedKeys.isNotEmpty) {
            final latestKey = sortedKeys.last;
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
        setState(() {
          _weightSpots = spots;
          _currentWeight = current;
          _weightDiff = diff;
          _canRegisterToday = canRegister;
          _lastRegistrationTime = lastTime;
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
              _buildAnimatedItem(2, _buildWeightSection()),
              const SizedBox(height: 32),
              _buildAnimatedItem(3, _buildRankingSection()),
              const SizedBox(height: 32),
              _buildAnimatedItem(4, _buildMilestones()),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EL ESPEJO DE DATOS',
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppTheme.secondary,
            letterSpacing: 2,
          ),
        ),
        Text(
          'Tu Evolución',
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
                'RACHA ACTUAL',
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
              '${value.toInt()} Días',
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 56,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¡Estás en el top ${(_ranking.indexWhere((e) => e['name'] == _userName) + 1).clamp(1, 100)} del ranking!',
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

  Widget _buildWeightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Peso Corporal',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
              ),
            ),
            IconButton(
              onPressed: _canRegisterToday ? _showLogWeightDialog : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ya registraste tu peso hoy. ¡Vuelve mañana!'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              icon: Icon(
                _canRegisterToday ? Icons.add_circle_outline : Icons.check_circle, 
                color: _canRegisterToday ? AppTheme.primary : Colors.green
              ),
            ),
          ],
        ),
        if (!_canRegisterToday)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Próximo registro disponible en unos días.',
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: AppTheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   _buildWeightStat('Actual', '$_currentWeight', 'kg'),
                   _buildWeightStat(
                     'Tendencia', 
                     '${_weightDiff > 0 ? '+' : ''}${_weightDiff.toStringAsFixed(1)}', 
                     'kg',
                     color: _weightDiff < 0 ? Colors.green : (_weightDiff > 0 ? Colors.red : AppTheme.secondary),
                   ),
                ],
              ),
              const Divider(height: 32),
              SizedBox(
                height: 180,
                child: _weightSpots.isEmpty 
                  ? const Center(child: Text('Sin datos suficientes'))
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
        ),
      ],
    );
  }

  Widget _buildWeightStat(String label, String value, String unit, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 12,
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
    final weightController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Registrar Peso',
              style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.primary),
            ),
            const SizedBox(height: 8),
            Text('Ingresa tu peso actual en kg', style: GoogleFonts.manrope(color: AppTheme.secondary)),
            const SizedBox(height: 24),
            TextField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                suffixText: 'kg',
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
                ),
                onPressed: () async {
                  final double? weight = double.tryParse(weightController.text);
                  if (weight != null) {
                    await _nutritionService.saveWeight(weight);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Peso registrado con éxito')),
                    );
                  }
                },
                child: Text('Guardar', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ranking de Guerrero',
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
                        const CircleAvatar(
                          radius: 14,
                          backgroundColor: AppTheme.background,
                          child: Icon(Icons.person, size: 16, color: AppTheme.secondary),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hitos Alcanzados',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        _buildMilestoneItem('Guerrero Consistente', 'Has mantenido tu racha por 3 o más días.', Icons.workspace_premium, Colors.amber, _streak >= 3),
        _buildMilestoneItem('Control de Peso', 'Has registrado tu primer peso en el sistema.', Icons.monitor_weight, Colors.green, _weightSpots.isNotEmpty),
        _buildMilestoneItem('Maestro del Ranking', '¡Has entrado en el Top 5 global!', Icons.auto_awesome, Colors.purple, _ranking.indexWhere((e) => e['name'] == _userName) < 5 && _ranking.isNotEmpty),
      ],
    );
  }

  Widget _buildMilestoneItem(String title, String subtitle, IconData icon, Color color, bool achieved) {
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
                  achieved ? subtitle : 'Bloqueado',
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
