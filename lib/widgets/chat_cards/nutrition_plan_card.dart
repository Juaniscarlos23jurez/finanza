import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/nutrition_service.dart';
import '../../services/chat_service.dart';

class NutritionPlanCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String? conversationId;
  final String? messageId;

  const NutritionPlanCard({
    super.key, 
    required this.data,
    this.conversationId,
    this.messageId,
  });

  @override
  State<NutritionPlanCard> createState() => _NutritionPlanCardState();
}

class _NutritionPlanCardState extends State<NutritionPlanCard> {
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

  Future<void> _saveNutritionPlan() async {
    setState(() => _isSaving = true);
    try {
      await _nutritionService.savePlan(widget.data);
      
      final List<dynamic> days = widget.data['days'] ?? (widget.data['meals'] != null ? [{'day': 'Hoy', 'meals': widget.data['meals']}] : []);
      if (days.isNotEmpty) {
        final List<dynamic> dailyMeals = days[0]['meals'] ?? [];
        await _nutritionService.saveDailyMeals(dailyMeals);
      }

      if (mounted) {
        setState(() {
          _isSaving = false;
          _isSaved = true;
        });

        // Persist state in RTDB
        if (widget.conversationId != null && widget.messageId != null) {
          final newData = Map<String, dynamic>.from(widget.data);
          newData['is_saved'] = true;
          _chatService.updateMessageData(
            conversationId: widget.conversationId!,
            messageId: widget.messageId!,
            newData: newData,
          ).catchError((e) => debugPrint('Error updating message data: $e'));
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.planSaved),
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
    final List<dynamic> days = data['days'] ?? (data['meals'] != null ? [{'day': 'Hoy', 'meals': data['meals']}] : []);
    final int calories = int.tryParse(data['daily_calories'].toString()) ?? 0;
    final Map macros = data['macros'] ?? {};

    return DefaultTabController(
      length: days.length,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.personalizedPlan, 
                        style: GoogleFonts.manrope(color: Colors.white.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      const Icon(Icons.auto_awesome, color: Colors.amber, size: 16),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text('$calories kcal / ${l10n.daysLabel.substring(0, 1).toLowerCase()}', style: GoogleFonts.manrope(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                         decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                         child: Text(l10n.goalReached, style: GoogleFonts.manrope(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                       ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMacroDisplay(l10n.protein.substring(0, 4), '${macros['protein'] ?? 0}g', Colors.red.shade200),
                      _buildMacroDisplay(l10n.carbs.substring(0, 4), '${macros['carbs'] ?? 0}g', Colors.orange.shade200),
                      _buildMacroDisplay(l10n.fats.substring(0, 4), '${macros['fats'] ?? 0}g', Colors.amber.shade200),
                    ],
                  ),
                ],
              ),
            ),
            if (days.length > 1)
              TabBar(
                isScrollable: true,
                labelColor: AppTheme.primary,
                unselectedLabelColor: AppTheme.secondary,
                indicatorColor: AppTheme.accent,
                dividerColor: Colors.transparent,
                labelStyle: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: days.map<Widget>((d) => Tab(text: d['day']?.toString() ?? l10n.todayLabel)).toList(),
              ),
            SizedBox(
              height: 250,
              child: TabBarView(
                children: days.map<Widget>((dayData) {
                  final List<dynamic> meals = dayData['meals'] ?? [];
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: meals.map((meal) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Text(meal['time'] ?? '00:00', style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.secondary)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(meal['name'] ?? '', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary)),
                                  Text(meal['details'] ?? '', style: GoogleFonts.manrope(fontSize: 12, color: AppTheme.secondary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isSaving || _isSaved) ? null : _saveNutritionPlan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSaved ? Colors.green : AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSaving 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(_isSaved ? l10n.planSaved : l10n.activatePlan, 
                        style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroDisplay(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.manrope(color: color, fontSize: 16, fontWeight: FontWeight.w900)),
        Text(label, style: GoogleFonts.manrope(color: Colors.white.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
