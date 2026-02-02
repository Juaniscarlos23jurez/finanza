import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/nutrition_service.dart';

class MultiMealCard extends StatefulWidget {
  final Map<String, dynamic> data;

  const MultiMealCard({super.key, required this.data});

  @override
  State<MultiMealCard> createState() => _MultiMealCardState();
}

class _MultiMealCardState extends State<MultiMealCard> {
  bool _isSaving = false;
  bool _isSaved = false;
  final NutritionService _nutritionService = NutritionService();

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  Future<void> _saveAllMeals(List<dynamic> meals) async {
    setState(() => _isSaving = true);
    try {
      await _nutritionService.saveDailyMeals(meals);
      if (mounted) {
        setState(() {
          _isSaving = false;
          _isSaved = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.mealRegistered),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorSaving(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> meals = widget.data['meals'] ?? [];
    if (meals.isEmpty) return const SizedBox.shrink();

    int totalCalories = 0;
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFats = 0;

    for (var meal in meals) {
      totalCalories += (int.tryParse(meal['calories']?.toString() ?? '0') ?? 0);
      totalProtein += (int.tryParse(meal['protein']?.toString() ?? '0') ?? 0);
      totalCarbs += (int.tryParse(meal['carbs']?.toString() ?? '0') ?? 0);
      totalFats += (int.tryParse(meal['fats']?.toString() ?? '0') ?? 0);
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.dailyMealsTitle, 
                      style: GoogleFonts.manrope(color: Colors.white.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    Text(l10n.itemsCount(meals.length), 
                      style: GoogleFonts.manrope(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                  child: Text('$totalCalories kcal', style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ...meals.map((meal) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.restaurant_menu, size: 16, color: AppTheme.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(meal['name'] ?? 'Comida', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary)),
                              Text(meal['description'] ?? '', style: GoogleFonts.manrope(fontSize: 11, color: AppTheme.secondary)),
                            ],
                          ),
                        ),
                        Text('${meal['calories']} kcal', style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.primary)),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSmallMacro(l10n.protein.substring(0, 4), '${totalProtein}g', Colors.red.shade400),
                    _buildSmallMacro(l10n.carbs.substring(0, 4), '${totalCarbs}g', Colors.orange.shade400),
                    _buildSmallMacro(l10n.fats.substring(0, 4), '${totalFats}g', Colors.amber.shade600),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_isSaving || _isSaved) ? null : () => _saveAllMeals(meals),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSaved ? Colors.green : AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isSaving 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(_isSaved ? l10n.everythingSaved : l10n.registerAll, 
                        style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallMacro(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.manrope(color: color, fontSize: 15, fontWeight: FontWeight.w900)),
        Text(label, style: GoogleFonts.manrope(color: AppTheme.secondary, fontSize: 9, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
