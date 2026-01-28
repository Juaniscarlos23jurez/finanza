import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import '../theme/app_theme.dart';
import '../services/nutrition_service.dart';

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

  @override
  void initState() {
    super.initState();
    _planStream = _nutritionService.getPlan();
    _dailyMealsStream = _nutritionService.getDailyMeals();
  }

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
                        return _buildEmptyState();
                      }

                      // Main Content
                      return _buildContent(planData, dailyMeals);
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

  Widget _buildEmptyState() {
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
              'No tienes un plan activo',
              style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
            const SizedBox(height: 12),
            Text(
              'Ve al Chat y pídele a la IA que cree un plan nutricional para ti.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(fontSize: 14, color: AppTheme.secondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ANTI-TRACKER',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.secondary,
                  letterSpacing: 2.0,
                ),
              ),
              Text(
                'Plan de Hoy',
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
                   'Toca para comer', 
                   style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)
                 )
               ],
             ),
          )
        ],
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic>? plan, List<Map<String, dynamic>> dailyMeals) {
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
          _buildSummaryCard(targetCalories, macros, dailyMeals), // Pass dailyMeals to calculate eaten cals
          const SizedBox(height: 32),
          Text(
            'Menú Inteligente',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          ...mealsToShow.asMap().entries.map((entry) {
            return _buildInteractiveMealItem(entry.value, entry.key, usingDailyMeals, mealsToShow);
          }),
          
          if (!usingDailyMeals && mealsToShow.isNotEmpty)
             Padding(
               padding: const EdgeInsets.only(top: 20),
               child: Center(
                 child: Text(
                   'Toca un platillo para empezar el día',
                   style: GoogleFonts.manrope(color: AppTheme.secondary.withValues(alpha: 0.5), fontStyle: FontStyle.italic),
                 ),
               ),
             )
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int targetCalories, Map macros, List<Map<String, dynamic>> dailyMeals) {
    // Calculate consumed
    int consumed = 0;
    for (var meal in dailyMeals) {
      if (meal['completed'] == true) {
        consumed += int.tryParse(meal['calories']?.toString() ?? '0') ?? 0;
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
                'PROGRESO DIARIO',
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
              _buildMacroStat('Proteína', '${macros['protein']}g', Colors.red.shade200),
              _buildMacroStat('Carbos', '${macros['carbs']}g', Colors.orange.shade200),
              _buildMacroStat('Grasas', '${macros['fats']}g', Colors.amber.shade200),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.manrope(fontSize: 16, color: color, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Widget _buildInteractiveMealItem(Map meal, int index, bool isLive, List allExisitingMeals) {
    final bool isCompleted = meal['completed'] ?? false;
    final String title = meal['name'] ?? 'Comida';
    final String time = meal['time'] ?? 'Flexible';
    final String details = meal['details'] ?? '';
    final String id = meal['id'] ?? 'temp_$index';

    return GestureDetector(
      onTap: () async {
        if (isLive) {
          // Toggle existing
          await _nutritionService.toggleMealCompletion(id, !isCompleted);
        } else {
          // Initialize and toggle this one
          await _nutritionService.initializeTodayMeals(allExisitingMeals, index);
        }
      },
      child: AnimatedContainer(
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
            // Checkbox Area
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? Colors.green : AppTheme.secondary.withValues(alpha: 0.3),
                  width: 2
                )
              ),
              child: isCompleted 
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
            ),
            const SizedBox(width: 16),
            Expanded(
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
                      Text(
                        time,
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
          ],
        ),
      ),
    );
  }
}
