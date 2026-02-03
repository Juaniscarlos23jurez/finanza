import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/nutrition_service.dart';
import '../../services/chat_service.dart';
import '../../services/gamification_service.dart';

class MealCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String? conversationId;
  final String? messageId;

  const MealCard({
    super.key, 
    required this.data,
    this.conversationId,
    this.messageId,
  });

  @override
  State<MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<MealCard> {
  bool _isSaving = false;
  late bool _isSaved;
  final NutritionService _nutritionService = NutritionService();
  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    _isSaved = widget.data['is_saved'] == true;
  }

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  Future<void> _saveMeal() async {
    setState(() => _isSaving = true);
    try {
      // Register meal as completed for today
      await _nutritionService.addMealToToday(widget.data, isCompleted: true);
      
      if (mounted) {
        setState(() {
          _isSaving = false;
          _isSaved = true;
        });

        // Persist state in RTDB (for the chat message itself)
        if (widget.conversationId != null && widget.messageId != null) {
          final newData = Map<String, dynamic>.from(widget.data);
          newData['is_saved'] = true;
          _chatService.updateMessageData(
            conversationId: widget.conversationId!,
            messageId: widget.messageId!,
            newData: newData,
          ).catchError((e) => debugPrint('Error updating message data: $e'));
        }

        // Trigger Gamification & Macro Checks (The "Menu" experience)
        GamificationService().checkAndShowModal(context, PandaTrigger.mealLogged);
        GamificationService().checkAndTriggerMacroCelebrations(context);

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
    final Map<String, dynamic> data = widget.data;
    final String name = data['name'] ?? 'Comida';
    final int calories = int.tryParse(data['calories'].toString()) ?? 0;
    final int protein = int.tryParse(data['protein'].toString()) ?? 0;
    final int carbs = int.tryParse(data['carbs'].toString()) ?? 0;
    final int fats = int.tryParse(data['fats'].toString()) ?? 0;
    final double score = double.tryParse(data['score']?.toString() ?? '0') ?? 0;
    final String description = data['description'] ?? '';
    
    final Map<String, dynamic>? recipe = data['recipe'] is Map ? Map<String, dynamic>.from(data['recipe'] as Map) : null;
    final List<dynamic> ingredients = recipe?['ingredients'] ?? [];
    final List<dynamic> steps = recipe?['steps'] ?? [];

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
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.accent, AppTheme.accent.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.nutritionalRecord, 
                        style: GoogleFonts.manrope(color: Colors.white.withValues(alpha: 0.8), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                      Text(name, 
                        style: GoogleFonts.manrope(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                if (score > 0) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: Text(score.toStringAsFixed(1), style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.w900)),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (description.isNotEmpty) ...[
                  Text(description, style: GoogleFonts.manrope(color: AppTheme.secondary, fontSize: 13, height: 1.4)),
                  const SizedBox(height: 20),
                ],
                Row(
                  children: [
                    Expanded(child: _buildMacroPill(l10n.protein, '${protein}g', Colors.red.shade400, Icons.fitness_center)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildMacroPill(l10n.carbs, '${carbs}g', Colors.orange.shade400, Icons.grain)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildMacroPill(l10n.fats, '${fats}g', Colors.amber.shade600, Icons.opacity)),
                  ],
                ),
                
                if (ingredients.isNotEmpty || steps.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  if (ingredients.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.shopping_basket_outlined, size: 18, color: AppTheme.primary),
                        const SizedBox(width: 8),
                        Text(l10n.ingredients.toUpperCase(), style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.0, color: AppTheme.primary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...ingredients.map((ing) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, size: 6, color: AppTheme.accent),
                          const SizedBox(width: 10),
                          Expanded(child: Text(ing.toString(), style: GoogleFonts.manrope(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w500))),
                        ],
                      ),
                    )),
                    const SizedBox(height: 20),
                  ],

                  if (steps.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.restaurant_menu_rounded, size: 18, color: AppTheme.primary),
                        const SizedBox(width: 8),
                        Text(l10n.instructions.toUpperCase(), style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.0, color: AppTheme.primary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...steps.asMap().entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle),
                            alignment: Alignment.center,
                            child: Text('${entry.key + 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(entry.value.toString(), style: GoogleFonts.manrope(fontSize: 13, color: AppTheme.primary, height: 1.4))),
                        ],
                      ),
                    )),
                  ],
                ],

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(l10n.totalCaloriesLabel, style: GoogleFonts.manrope(color: AppTheme.secondary, fontSize: 9, fontWeight: FontWeight.w900)),
                         Text('$calories kcal', style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                       ],
                     ),
                     ElevatedButton(
                       onPressed: (_isSaving || _isSaved) ? null : _saveMeal,
                       style: ElevatedButton.styleFrom(
                         backgroundColor: _isSaved ? Colors.green : AppTheme.primary,
                         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                         elevation: 0,
                       ),
                       child: _isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(_isSaved ? l10n.savedLabel : l10n.registerBtn, style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.white)),
                     ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroPill(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.manrope(color: color, fontSize: 14, fontWeight: FontWeight.w800)),
          Text(label, style: GoogleFonts.manrope(color: color.withValues(alpha: 0.7), fontSize: 8, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
