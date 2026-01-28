import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import '../theme/app_theme.dart';
import '../services/nutrition_service.dart';
import '../services/gamification_service.dart';
import '../l10n/app_localizations.dart';

class NutritionPlanScreen extends StatefulWidget {
  const NutritionPlanScreen({super.key});

  @override
  State<NutritionPlanScreen> createState() => _NutritionPlanScreenState();
}

class _NutritionPlanScreenState extends State<NutritionPlanScreen> {
  final NutritionService _nutritionService = NutritionService();
  
  // Need to listen to two streams: Plan (for targets) and Daily Meals (for execution)
  late Stream<DatabaseEvent> _planStream;
  late Stream<DatabaseEvent> _dailyMealsStream;
  
  // Track which macro goals have been celebrated today to avoid duplicates
  final Set<String> _celebratedMacros = {};

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _planStream = _nutritionService.getPlan();
    _dailyMealsStream = _nutritionService.getDailyMeals();
    _statsStream = _nutritionService.getGamificationStats();
  }

  late Stream<DatabaseEvent> _statsStream;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: StreamBuilder<DatabaseEvent>(
                stream: _planStream,
                builder: (context, planSnapshot) {
                  return StreamBuilder<DatabaseEvent>(
                    stream: _dailyMealsStream,
                    builder: (context, mealsSnapshot) {
                      if (planSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                      }

                      // Parse Plan Data
                      Map<String, dynamic>? planData;
                      if (planSnapshot.hasData && planSnapshot.data!.snapshot.value != null) {
                        planData = Map<String, dynamic>.from(planSnapshot.data!.snapshot.value as Map);
                      }

                      // Parse Daily Meals Data
                      List<Map<String, dynamic>> dailyMeals = [];
                      if (mealsSnapshot.hasData && mealsSnapshot.data!.snapshot.value != null) {
                         final Map<dynamic, dynamic> data = mealsSnapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                         // Sort by ID to maintain order
                         final sortedKeys = data.keys.toList()..sort((a, b) {
                           // Assuming keys are meal_0, meal_1...
                           int idA = int.tryParse(a.toString().split('_').last) ?? 0;
                           int idB = int.tryParse(b.toString().split('_').last) ?? 0;
                           return idA.compareTo(idB); 
                         });
                         
                         for (var key in sortedKeys) {
                           dailyMeals.add(Map<String, dynamic>.from(data[key] as Map));
                         }
                      }

                      if (planData == null && dailyMeals.isEmpty) {
                        return _buildEmptyState(context);
                      }

                      // Main Content
                      return _buildContent(context, planData, dailyMeals);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.description_outlined, size: 64, color: AppTheme.primary),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noActivePlan,
              style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.goToChatPlan,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(fontSize: 14, color: AppTheme.secondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return StreamBuilder<DatabaseEvent>(
      stream: _statsStream,
      builder: (context, snapshot) {
        final l10n = AppLocalizations.of(context)!;
        int lives = 5;
        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final data = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
          lives = data['lives'] ?? 5;
        }

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    children: [
                      Text(
                        l10n.antiTracker,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.secondary,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Lives Counter (Clickable for Cheat Meal)
                      GestureDetector(
                        onTap: () => _handleCheatMeal(lives),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3))
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.favorite, size: 14, color: Colors.redAccent),
                              const SizedBox(width: 4),
                              Text(
                                '$lives', 
                                style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent)
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                   ),
                  Text(
                    l10n.todayPlan,
                    style: GoogleFonts.manrope(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              // Visual Hint
              Container(
                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                 decoration: BoxDecoration(
                   color: Colors.green.withValues(alpha: 0.1),
                   borderRadius: BorderRadius.circular(20),
                   border: Border.all(color: Colors.green.withValues(alpha: 0.2))
                 ),
                 child: Row(
                   children: [
                     const Icon(Icons.check_circle_outline, size: 14, color: Colors.green),
                     const SizedBox(width: 4),
                     Text(
                       l10n.tapToEat, 
                       style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)
                     )
                   ],
                 ),
              )
            ],
          ),
        );
      }
    );
  }

  Future<void> _checkMacroGoals(Map meal) async {
    // Get current plan to check targets
    final planSnapshot = await _nutritionService.getPlan().first;
    if (!planSnapshot.snapshot.exists) return;
    
    final planData = Map<String, dynamic>.from(planSnapshot.snapshot.value as Map);
    final Map macroTargets = planData['macros'] ?? {};
    
    // Get all daily meals to calculate totals
    final mealsSnapshot = await _nutritionService.getDailyMeals().first;
    if (!mealsSnapshot.snapshot.exists) return;
    
    final Map<dynamic, dynamic> mealsData = mealsSnapshot.snapshot.value as Map<dynamic, dynamic>;
    
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFats = 0;
    
    mealsData.forEach((key, value) {
      final mealData = Map<String, dynamic>.from(value as Map);
      if (mealData['completed'] == true) {
        totalProtein += double.tryParse(mealData['protein']?.toString() ?? '0') ?? 0;
        totalCarbs += double.tryParse(mealData['carbs']?.toString() ?? '0') ?? 0;
        totalFats += double.tryParse(mealData['fats']?.toString() ?? '0') ?? 0;
      }
    });
    
    // Check each macro and trigger modal if goal reached (and not already celebrated)
    final targetProtein = macroTargets['protein'] ?? 0;
    final targetCarbs = macroTargets['carbs'] ?? 0;
    final targetFats = macroTargets['fats'] ?? 0;
    
    if (totalProtein >= targetProtein && !_celebratedMacros.contains('protein')) {
      _celebratedMacros.add('protein');
      if (mounted) {
        GamificationService().checkAndShowModal(context, PandaTrigger.goalMet);
      }
    }
    
    if (totalCarbs >= targetCarbs && !_celebratedMacros.contains('carbs')) {
      _celebratedMacros.add('carbs');
      if (mounted) {
        GamificationService().checkAndShowModal(context, PandaTrigger.goalMet);
      }
    }
    
    if (totalFats >= targetFats && !_celebratedMacros.contains('fats')) {
      _celebratedMacros.add('fats');
      if (mounted) {
        GamificationService().checkAndShowModal(context, PandaTrigger.goalMet);
      }
    }
  }

  Future<void> _handleCheatMeal(int currentLives) async {
    if (currentLives <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No te quedan vidas para Cheat Meals 😱'))
      );
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text('¿Usar una vida?'),
        content: const Text('Esto registrará un Cheat Meal y consumirá 1 corazón ❤️.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('¡Dale!')),
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

  Widget _buildContent(BuildContext context, Map<String, dynamic>? plan, List<Map<String, dynamic>> dailyMeals) {
    final l10n = AppLocalizations.of(context)!;
    // If we have dailyMeals, calculate stats from them, otherwise from Plan
    int targetCalories = 2000;
    Map macros = {'protein': 0, 'carbs': 0, 'fats': 0};
    
    if (plan != null) {
      targetCalories = plan['daily_calories'] ?? 2000;
      macros = plan['macros'] ?? macros;
    }

    // Determine which list of meals to show
    // If dailyMeals exists, show it (IT IS THE TRUTH)
    // If not, show Plan meals (TEMPLATE)
    final bool usingDailyMeals = dailyMeals.isNotEmpty;
    final List mealsToShow = usingDailyMeals ? dailyMeals : (plan?['meals'] ?? []);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(context, targetCalories, macros, dailyMeals), // Pass dailyMeals to calculate eaten cals
          const SizedBox(height: 24),
          _buildMacroProgressChart(context, macros, dailyMeals),
          const SizedBox(height: 32),
          Text(
            l10n.smartMenu,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          ...mealsToShow.asMap().entries.map((entry) {
            return _buildInteractiveMealItem(context, entry.value, entry.key, usingDailyMeals, mealsToShow);
          }),
          
          if (!usingDailyMeals && mealsToShow.isNotEmpty)
             Padding(
               padding: const EdgeInsets.only(top: 20),
               child: Center(
                 child: Text(
                   l10n.tapDishStart,
                   style: GoogleFonts.manrope(color: AppTheme.secondary.withValues(alpha: 0.5), fontStyle: FontStyle.italic),
                 ),
               ),
             )
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, int targetCalories, Map macros, List<Map<String, dynamic>> dailyMeals) {
    final l10n = AppLocalizations.of(context)!;
    // Calculate consumed calories and macros
    int consumed = 0;
    double consumedProtein = 0;
    double consumedCarbs = 0;
    double consumedFats = 0;
    
    for (var meal in dailyMeals) {
      if (meal['completed'] == true) {
        consumed += int.tryParse(meal['calories']?.toString() ?? '0') ?? 0;
        
        // Extract macros from meal (if available)
        consumedProtein += double.tryParse(meal['protein']?.toString() ?? '0') ?? 0;
        consumedCarbs += double.tryParse(meal['carbs']?.toString() ?? '0') ?? 0;
        consumedFats += double.tryParse(meal['fats']?.toString() ?? '0') ?? 0;
      }
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
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
                l10n.dailyProgress,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Text(
                  '${((consumed/targetCalories)*100).clamp(0, 100).toInt()}%',
                   style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold)
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
               Text(
                '$consumed',
                style: GoogleFonts.manrope(
                  fontSize: 48,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  height: 1.0
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 4),
                child: Text(
                  '/ $targetCalories kcal',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroStat(
                l10n.protein, 
                '${consumedProtein.toInt()}/${macros['protein']}g', 
                Colors.red.shade200,
                consumedProtein >= (macros['protein'] ?? 0)
              ),
              _buildMacroStat(
                l10n.carbs, 
                '${consumedCarbs.toInt()}/${macros['carbs']}g', 
                Colors.orange.shade200,
                consumedCarbs >= (macros['carbs'] ?? 0)
              ),
              _buildMacroStat(
                l10n.fats, 
                '${consumedFats.toInt()}/${macros['fats']}g', 
                Colors.amber.shade200,
                consumedFats >= (macros['fats'] ?? 0)
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroStat(String label, String value, Color color, [bool isComplete = false]) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.manrope(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold),
            ),
            if (isComplete) ...[
              const SizedBox(width: 4),
              const Icon(Icons.check_circle, size: 12, color: Colors.greenAccent),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 14, 
            color: isComplete ? Colors.greenAccent : color, 
            fontWeight: FontWeight.w800
          ),
        ),
      ],
    );
  }

  Widget _buildMacroProgressChart(BuildContext context, Map macros, List<Map<String, dynamic>> dailyMeals) {
    final l10n = AppLocalizations.of(context)!;
    // Calculate consumed macros
    double consumedProtein = 0;
    double consumedCarbs = 0;
    double consumedFats = 0;
    
    for (var meal in dailyMeals) {
      if (meal['completed'] == true) {
        consumedProtein += double.tryParse(meal['protein']?.toString() ?? '0') ?? 0;
        consumedCarbs += double.tryParse(meal['carbs']?.toString() ?? '0') ?? 0;
        consumedFats += double.tryParse(meal['fats']?.toString() ?? '0') ?? 0;
      }
    }

    final targetProtein = (macros['protein'] ?? 0).toDouble();
    final targetCarbs = (macros['carbs'] ?? 0).toDouble();
    final targetFats = (macros['fats'] ?? 0).toDouble();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.macroProgress,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.todayLabel,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accent,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildMacroProgressBar(
            l10n.protein,
            consumedProtein,
            targetProtein,
            Colors.red,
            '🥩',
          ),
          const SizedBox(height: 20),
          _buildMacroProgressBar(
            l10n.carbs,
            consumedCarbs,
            targetCarbs,
            Colors.orange,
            '🍞',
          ),
          const SizedBox(height: 20),
          _buildMacroProgressBar(
            l10n.fats,
            consumedFats,
            targetFats,
            Colors.amber,
            '🥑',
          ),
        ],
      ),
    );
  }

  Widget _buildMacroProgressBar(String label, double consumed, double target, Color color, String emoji) {
    final progress = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;
    final isComplete = consumed >= target;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  '${consumed.toInt()}g',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: isComplete ? Colors.green : color,
                  ),
                ),
                Text(
                  ' / ${target.toInt()}g',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondary.withValues(alpha: 0.6),
                  ),
                ),
                if (isComplete) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.check_circle, size: 16, color: Colors.green),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            // Background bar
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            // Progress bar
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              height: 8,
              width: MediaQuery.of(context).size.width * 0.8 * progress,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isComplete 
                    ? [Colors.green, Colors.greenAccent]
                    : [color, color.withValues(alpha: 0.6)],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: (isComplete ? Colors.green : color).withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toInt()}% completado',
          style: GoogleFonts.manrope(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppTheme.secondary.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveMealItem(BuildContext context, Map meal, int index, bool isLive, List allExisitingMeals) {
    final bool isCompleted = meal['completed'] ?? false;
    final String title = meal['name'] ?? 'Comida';
    final String details = meal['details'] ?? '';
    final String id = meal['id'] ?? 'temp_$index';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isCompleted ? Border.all(color: Colors.green.withValues(alpha: 0.3), width: 1.5) : Border.all(color: Colors.transparent),
        boxShadow: [
          if (!isCompleted)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          // Checkbox Area (Tap here to complete)
          GestureDetector(
            onTap: () async {
              if (isLive) {
                final bool newStatus = !isCompleted;
                await _nutritionService.toggleMealCompletion(id, newStatus);
                if (!context.mounted) return;
                if (newStatus) {
                   GamificationService().checkAndShowModal(context, PandaTrigger.mealLogged);
                   _checkMacroGoals(meal);
                }
              } else {
                await _nutritionService.initializeTodayMeals(allExisitingMeals, index);
                if (!context.mounted) return;
                GamificationService().checkAndShowModal(context, PandaTrigger.mealLogged);
                _checkMacroGoals(meal);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32, // Slightly larger touch area
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? Colors.green : AppTheme.secondary.withValues(alpha: 0.3),
                  width: 2
                )
              ),
              child: isCompleted 
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
            ),
          ),
          const SizedBox(width: 16),
          // Content Area (Tap here to see Recipe)
          Expanded(
            child: GestureDetector(
              onTap: () => _showRecipeModal(context, meal),
              child: Container(
                color: Colors.transparent, // Make entire area tappable
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w800, 
                              fontSize: 16,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                              color: isCompleted ? AppTheme.secondary.withValues(alpha: 0.6) : AppTheme.primary
                            ),
                          ),
                        ),
                        if (meal['calories'] != null)
                          Text(
                            '${meal['calories']} kcal',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: isCompleted ? Colors.green.withValues(alpha: 0.6) : AppTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (details.isNotEmpty)
                      Text(
                        details,
                        maxLines: isCompleted ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 13, 
                          color: AppTheme.secondary.withValues(alpha: isCompleted ? 0.4 : 1.0), 
                          height: 1.4
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRecipeModal(BuildContext context, Map meal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 40, 
                  height: 4, 
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))
                ),
              ),
              const SizedBox(height: 24),
              Text(
                meal['name'] ?? l10n.recipe,
                style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.primary),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.local_fire_department_rounded, size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text('${meal['calories'] ?? 0} kcal', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                  const SizedBox(width: 16),
                  const Icon(Icons.timer_outlined, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text('15-20 min', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: AppTheme.secondary)), // Placeholder or data
                ],
              ),
              const SizedBox(height: 32),
              if (meal['recipe'] != null) ...[
                Text(l10n.ingredients, style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                const SizedBox(height: 12),
                ...?meal['recipe']['ingredients']?.map<Widget>((ing) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 6, color: AppTheme.accent),
                      const SizedBox(width: 12),
                      Expanded(child: Text(ing.toString(), style: GoogleFonts.manrope(fontSize: 15, color: AppTheme.secondary))),
                    ],
                  ),
                )),
                const SizedBox(height: 32),
                Text(l10n.instructions, style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                const SizedBox(height: 12),
                ...?meal['recipe']['steps']?.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Text('${entry.key + 1}', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(entry.value.toString(), style: GoogleFonts.manrope(fontSize: 15, color: AppTheme.secondary, height: 1.5))),
                    ],
                  ),
                )),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
