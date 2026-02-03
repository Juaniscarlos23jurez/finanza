import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import '../theme/app_theme.dart';
import '../services/nutrition_service.dart';
import '../services/gamification_service.dart';
import '../services/ai_service.dart';
import '../l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class NutritionPlanScreen extends StatefulWidget {
  const NutritionPlanScreen({super.key});

  @override
  State<NutritionPlanScreen> createState() => _NutritionPlanScreenState();
}

class _NutritionPlanScreenState extends State<NutritionPlanScreen> {
  final NutritionService _nutritionService = NutritionService();
  final AiService _aiService = AiService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateTime _selectedDate = DateTime.now();
  
  // Need to listen to two streams: Plan (for targets) and Daily Meals (for execution)
  late Stream<DatabaseEvent> _planStream;
  
  // Track which macro goals have been celebrated today to avoid duplicates
  final Set<String> _celebratedMacros = {};

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _planStream = _nutritionService.getPlan();
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
            _buildDateSelector(),
            Expanded(
              child: StreamBuilder<DatabaseEvent>(
                stream: _planStream,
                builder: (context, planSnapshot) {
                  return StreamBuilder<DatabaseEvent>(
                    stream: _nutritionService.getMealsForDate(_selectedDate),
                    builder: (context, mealsSnapshot) {
                      return StreamBuilder<DatabaseEvent>(
                        stream: _nutritionService.getRecurringMealsForDay(_selectedDate.weekday),
                        builder: (context, recurringSnapshot) {
                          if (planSnapshot.connectionState == ConnectionState.waiting && 
                              mealsSnapshot.connectionState == ConnectionState.waiting &&
                              recurringSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                          }

                          // Parse Plan Data
                          Map<String, dynamic>? planData;
                          if (planSnapshot.hasData && planSnapshot.data!.snapshot.value != null) {
                            planData = Map<String, dynamic>.from(planSnapshot.data!.snapshot.value as Map);
                          }

                          // Parse Daily/Specific Meals Data
                          Map<String, Map<String, dynamic>> finalMealsMap = {};
                          
                          if (mealsSnapshot.hasData && mealsSnapshot.data!.snapshot.value != null) {
                            final Map<dynamic, dynamic> data = mealsSnapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                            data.forEach((key, value) {
                               finalMealsMap[key.toString()] = Map<String, dynamic>.from(value as Map);
                            });
                          }

                          // Merge with Recurring Meals
                          if (recurringSnapshot.hasData && recurringSnapshot.data!.snapshot.value != null) {
                            final Map<dynamic, dynamic> recData = recurringSnapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                            recData.forEach((key, value) {
                              final String id = key.toString();
                              // Only add if not already in finalMealsMap (which contains overrides like 'completed')
                              if (!finalMealsMap.containsKey(id)) {
                                final meal = Map<String, dynamic>.from(value as Map);
                                meal['completed'] = false; // Default for templates not yet interacted with
                                finalMealsMap[id] = meal;
                              }
                            });
                          }

                          List<Map<String, dynamic>> mergedMeals = finalMealsMap.values.toList();
                          // Sort by ID or time to maintain order
                          mergedMeals.sort((a, b) {
                            int idA = int.tryParse(a['id']?.toString().split('_').last ?? '0') ?? 0;
                            int idB = int.tryParse(b['id']?.toString().split('_').last ?? '0') ?? 0;
                            return idA.compareTo(idB);
                          });

                          if (planData == null && mergedMeals.isEmpty) {
                            return _buildEmptyState(context);
                          }

                          // Main Content
                          return _buildContent(context, planData, mergedMeals);
                        },
                      );
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

  Widget _buildDateSelector() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14, // Show 2 weeks: last week and next week
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final date = DateTime.now().subtract(const Duration(days: 3)).add(Duration(days: index));
          final bool isSelected = DateUtils.isSameDay(date, _selectedDate);
          final bool isToday = DateUtils.isSameDay(date, DateTime.now());

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                ],
                border: isToday && !isSelected
                    ? Border.all(color: AppTheme.primary, width: 2)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text(
                    DateFormat('E').format(date).toUpperCase(),
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white70 : AppTheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? Colors.white : AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
    List mealsToShow = usingDailyMeals ? dailyMeals : (plan?['meals'] ?? []);

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      mealsToShow = mealsToShow.where((meal) {
        final title = (meal['name'] ?? '').toString().toLowerCase();
        final details = (meal['details'] ?? '').toString().toLowerCase();
        return title.contains(_searchQuery.toLowerCase()) || 
               details.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(context, targetCalories, macros, dailyMeals), // Pass dailyMeals to calculate eaten cals
          const SizedBox(height: 24),
          _buildMacroProgressChart(context, macros, dailyMeals),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.smartMenu,
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
              TextButton.icon(
                onPressed: _showAddRecipeFromVideoDialog,
                icon: const Icon(Icons.video_collection_outlined, size: 18),
                label: Text(
                  l10n.uploadPlanBtn,
                  style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.05),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                hintStyle: GoogleFonts.manrope(color: AppTheme.secondary.withValues(alpha: 0.5)),
                border: InputBorder.none,
                icon: const Icon(Icons.search, color: AppTheme.secondary),
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18), 
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      }
                    )
                  : null,
              ),
            ),
          ),
          const SizedBox(height: 24),
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
          GestureDetector(
            onTap: () => _showEditMacrosDialog(context, targetCalories, macros),
            child: Row(
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
          ),
        ],
      ),
    );
  }

  void _showEditMacrosDialog(BuildContext context, int currentCalories, Map macros) {
    final proteinController = TextEditingController(text: '${macros['protein'] ?? 0}');
    final carbsController = TextEditingController(text: '${macros['carbs'] ?? 0}');
    final fatsController = TextEditingController(text: '${macros['fats'] ?? 0}');
    final calsController = TextEditingController(text: '$currentCalories');

    void updateCals() {
      final p = int.tryParse(proteinController.text) ?? 0;
      final c = int.tryParse(carbsController.text) ?? 0;
      final f = int.tryParse(fatsController.text) ?? 0;
      final total = (p * 4) + (c * 4) + (f * 9);
      calsController.text = total.toString();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 32, left: 32, right: 32,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.macroDistribution,
              style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.primary),
            ),
            const SizedBox(height: 24),
            _buildEditField(l10n.protein, '🥩', proteinController, Colors.red, onChanged: (_) => updateCals()),
            const SizedBox(height: 16),
            _buildEditField(l10n.carbs, '🍞', carbsController, Colors.orange, onChanged: (_) => updateCals()),
            const SizedBox(height: 16),
            _buildEditField(l10n.fats, '🥑', fatsController, Colors.amber, onChanged: (_) => updateCals()),
            const SizedBox(height: 16),
            _buildEditField(l10n.totalCaloriesLabel, '🔥', calsController, AppTheme.primary),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                final p = int.tryParse(proteinController.text) ?? 0;
                final c = int.tryParse(carbsController.text) ?? 0;
                final f = int.tryParse(fatsController.text) ?? 0;
                final cal = int.tryParse(calsController.text) ?? 0;

                await _nutritionService.updatePlanMacros(
                  protein: p,
                  carbs: c,
                  fats: f,
                  calories: cal,
                );
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(l10n.save.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(String label, String emoji, TextEditingController controller, Color color, {Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.secondary),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 18),
          decoration: InputDecoration(
            prefixIcon: Center(widthFactor: 1, child: Text(emoji, style: const TextStyle(fontSize: 20))),
            suffixText: label.contains('Cal') ? 'kcal' : 'g',
            suffixStyle: const TextStyle(fontWeight: FontWeight.bold),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: color.withValues(alpha: 0.2))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: color, width: 2)),
          ),
        ),
      ],
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

    return GestureDetector(
      onTap: () => _showEditMacrosDialog(context, targetProtein.toInt() * 4 + targetCarbs.toInt() * 4 + targetFats.toInt() * 9, macros),
      child: Container(
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
                  child: Row(
                    children: [
                      const Icon(Icons.edit_rounded, size: 10, color: AppTheme.accent),
                      const SizedBox(width: 4),
                      Text(
                        l10n.todayLabel,
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.accent,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
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

  Widget _buildInteractiveMealItem(BuildContext context, Map meal, int index, bool usingDailyMeals, List allExisitingMeals) {
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
              final bool isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());
              if (usingDailyMeals) {
                final bool newStatus = !isCompleted;
                await _nutritionService.toggleMealCompletionForDate(_selectedDate, id, newStatus);
                if (!context.mounted) return;
                if (newStatus && isToday) {
                   GamificationService().checkAndShowModal(context, PandaTrigger.mealLogged);
                   _checkMacroGoals(meal);
                }
              } else {
                await _nutritionService.initializeMealsForDate(_selectedDate, allExisitingMeals, index);
                if (!context.mounted) return;
                if (isToday) {
                  GamificationService().checkAndShowModal(context, PandaTrigger.mealLogged);
                  _checkMacroGoals(meal);
                }
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
                        const SizedBox(width: 8),
                        Builder(
                          builder: (context) {
                            final String? videoUrl = meal['original_video_url']?.toString().toLowerCase();
                            String label = 'IA';
                            Color color = AppTheme.accent;
                            IconData icon = Icons.auto_awesome;

                            if (videoUrl != null) {
                              if (videoUrl.contains('youtube.com') || videoUrl.contains('youtu.be')) {
                                label = 'YouTube';
                                color = Colors.redAccent;
                                icon = Icons.play_circle_fill;
                              } else if (videoUrl.contains('tiktok.com')) {
                                label = 'TikTok';
                                color = Colors.black87;
                                icon = Icons.music_note;
                              }
                            }

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(icon, size: 10, color: color),
                                  const SizedBox(width: 4),
                                  Text(
                                    label,
                                    style: GoogleFonts.manrope(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: color,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        if (meal['calories'] != null)
                          Text(
                            '${meal['calories']} kcal',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: isCompleted ? Colors.green.withValues(alpha: 0.6) : AppTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(width: 8),
                        const SizedBox(width: 8),
                        // Flexible Repetition Button
                        GestureDetector(
                          onTap: () => _showRepeatOptionsModal(context, meal),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.calendar_month_outlined, size: 14, color: AppTheme.accent),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.repeatOnDaysBtn,
                                  style: GoogleFonts.manrope(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.accent,
                                  ),
                                ),
                              ],
                            ),
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
          child: Column(
            children: [
               // Sticky drag handle
               Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  child: Container(
                    width: 40, 
                    height: 4, 
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))
                  ),
               ),
               Expanded(
                 child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                  children: [
                    Text(
                      meal['name'] ?? l10n.recipe,
                      style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.primary, height: 1.2),
                    ),
                    const SizedBox(height: 16),
                    // Quick Stats Row
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildRecipeStat(Icons.local_fire_department_rounded, '${meal['calories'] ?? 0}', 'kcal', Colors.orange),
                          _buildRecipeStat(Icons.bolt, '${meal['protein'] ?? 0}g', 'Prot', Colors.red.shade400),
                          _buildRecipeStat(Icons.grain, '${meal['carbs'] ?? 0}g', 'Carb', Colors.orange.shade400),
                          _buildRecipeStat(Icons.water_drop, '${meal['fats'] ?? 0}g', 'Gras', Colors.amber.shade400),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    if (meal['recipe'] != null) ...[
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.shopping_basket_outlined, color: Colors.green),
                          ),
                          const SizedBox(width: 12),
                          Text(l10n.ingredients, style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            ...?meal['recipe']['ingredients']?.map<Widget>((ing) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 6),
                                    child: Icon(Icons.circle, size: 6, color: AppTheme.accent),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(ing.toString(), style: GoogleFonts.manrope(fontSize: 15, color: AppTheme.secondary, fontWeight: FontWeight.w500))),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.menu_book_outlined, color: AppTheme.primary),
                          ),
                          const SizedBox(width: 12),
                          Text(l10n.instructions, style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...?meal['recipe']['steps']?.asMap().entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(color: AppTheme.secondary, borderRadius: BorderRadius.circular(8)),
                              child: Text('${entry.key + 1}', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(child: Text(entry.value.toString(), style: GoogleFonts.manrope(fontSize: 16, color: AppTheme.primary, height: 1.6))),
                          ],
                        ),
                      )),
                    ],
                    const SizedBox(height: 32),
                    
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('¿Eliminar plato?'),
                                  content: const Text('Esta receta se quitará de este día.'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                if (!context.mounted) return;
                                Navigator.pop(context);
                                final sm = ScaffoldMessenger.of(context);
                                await _nutritionService.deleteMealFromDate(_selectedDate, meal['id']?.toString() ?? '');
                                sm.showSnackBar(
                                  const SnackBar(content: Text('Plato eliminado'), behavior: SnackBarBehavior.floating)
                                );
                              }
                            },
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            label: const Text('Eliminar del día', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                              foregroundColor: Colors.redAccent,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Container()), // Placeholder for balance
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                     // Buttons
                    Row(
                      children: [
                         if (meal['original_video_url'] != null) ...[
                           Expanded(
                             child: ElevatedButton.icon(
                                onPressed: () => launchUrl(Uri.parse(meal['original_video_url'])),
                                icon: const Icon(Icons.play_circle_outline, color: Colors.white),
                                label: Text(l10n.viewOriginalVideo, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                             ),
                           ),
                           const SizedBox(width: 12),
                         ],
                         Expanded(
                           child: ElevatedButton.icon(
                              onPressed: () async {
                                Navigator.pop(context);
                                final sm = ScaffoldMessenger.of(context);
                                await _nutritionService.addMealToDate(_selectedDate, Map<String, dynamic>.from(meal));
                                sm.showSnackBar(
                                   const SnackBar(content: Text('Plato duplicado hoy'), behavior: SnackBarBehavior.floating,)
                                );
                              },
                              icon: const Icon(Icons.copy, color: Colors.white),
                              label: Text('Copiar hoy', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                           ),
                         ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
               ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeStat(IconData icon, String value, String unit, Color color) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.primary)),
        Text(unit, style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.secondary.withValues(alpha: 0.5))),
      ],
    );
  }

  Future<void> _showAddRecipeFromVideoDialog() async {
    final TextEditingController urlController = TextEditingController();
    bool isLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.importFromVideo,
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 20),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nuestra IA analizará el video para extraer ingredientes, pasos y nutrición.',
                style: GoogleFonts.manrope(fontSize: 13, color: AppTheme.secondary, height: 1.5),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: urlController,
                autofocus: true,
                enabled: !isLoading,
                decoration: InputDecoration(
                  hintText: 'YouTube o TikTok URL',
                  labelText: l10n.videoUrlHint,
                  labelStyle: GoogleFonts.manrope(color: AppTheme.secondary),
                  hintStyle: GoogleFonts.manrope(color: AppTheme.secondary.withValues(alpha: 0.4)),
                  prefixIcon: const Icon(Icons.link, color: AppTheme.primary),
                  filled: true,
                  fillColor: AppTheme.primary.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                  ),
                ),
              ),
              if (isLoading) ...[
                const SizedBox(height: 32),
                Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 3),
                      const SizedBox(height: 16),
                      Text(
                        l10n.processingVideo,
                        style: GoogleFonts.manrope(
                          fontSize: 14, 
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: Text(
                l10n.cancelLabel,
                style: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: AppTheme.secondary),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                final url = urlController.text.trim();
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);

                if (url.isEmpty || (!url.contains('youtube.com') && !url.contains('youtu.be') && !url.contains('tiktok.com'))) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(l10n.invalidUrl),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                  return;
                }

                setStateDialog(() => isLoading = true);

                try {
                  final message = await _aiService.processVideoUrl(url);
                  
                  if (!mounted) return;

                  if (message.isGenUI && message.data?['type'] == 'meal') {
                    final meal = Map<String, dynamic>.from(message.data!);
                    meal['original_video_url'] = url; // Save the source URL
                    await _nutritionService.addMealToDate(_selectedDate, meal);
                    
                    if (!mounted) return;
                    navigator.pop();
                    
                    messenger.showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(child: Text('¡Receta "${meal['name']}" añadida con éxito! 🥗')),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                    
                    // Show the recipe modal for the newly added meal
                    if (context.mounted) {
                      _showRecipeModal(context, meal);
                    }
                  } else {
                    throw Exception('La IA no pudo generar un formato de receta válido. Intenta con otro video.');
                  }
                } catch (e) {
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                } finally {
                  if (mounted) setStateDialog(() => isLoading = false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                l10n.confirmBtn,
                style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRepeatOptionsModal(BuildContext context, Map meal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(
              l10n.selectRecurringDays,
              style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.primary),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(7, (index) {
                final dayNum = index + 1;
                final List<String> dayNames = [
                  l10n.monday, l10n.tuesday, l10n.wednesday, 
                  l10n.thursday, l10n.friday, l10n.saturday, l10n.sunday
                ];
                return FilterChip(
                  label: Text(dayNames[index], style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.bold)),
                  selected: false,
                  onSelected: (bool selected) async {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(context);
                    await _nutritionService.setRecurringMeal(dayNum, Map<String, dynamic>.from(meal));
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(l10n.repeatOnDays(dayNames[index])),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppTheme.accent,
                      )
                    );
                  },
                  selectedColor: AppTheme.accent.withValues(alpha: 0.2),
                  checkmarkColor: AppTheme.accent,
                  backgroundColor: AppTheme.background,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide.none,
                );
              }),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.copyToSpecificDate,
              style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primary),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(primary: AppTheme.primary),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) {
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  await _nutritionService.addMealToDate(picked, Map<String, dynamic>.from(meal));
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Copiado al ${DateFormat('dd/MM').format(picked)}'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppTheme.accent,
                    )
                  );
                }
              },
              icon: const Icon(Icons.calendar_today_outlined),
              label: const Text('Calendario'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary.withValues(alpha: 0.05),
                foregroundColor: AppTheme.primary,
                elevation: 0,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
