import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/nutrition_service.dart';
import '../../services/chat_service.dart';

class NutritionGoalCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String? conversationId;
  final String? messageId;

  const NutritionGoalCard({
    super.key, 
    required this.data,
    this.conversationId,
    this.messageId,
  });

  @override
  State<NutritionGoalCard> createState() => _NutritionGoalCardState();
}

class _NutritionGoalCardState extends State<NutritionGoalCard> {
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

  Future<void> _createNutritionGoal() async {
    setState(() => _isSaving = true);
    try {
      await _nutritionService.saveGoal(widget.data);
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
          const SnackBar(
            content: Text('Meta creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear meta: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.flag_rounded, color: AppTheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.suggestedNutritionGoal,
                  style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.secondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(widget.data['title'] ?? l10n.goalLabel, style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 4),
          Text('${l10n.targetLabel}: ${widget.data['target_value']}', style: GoogleFonts.manrope(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(widget.data['reason'] ?? '', style: GoogleFonts.manrope(color: AppTheme.secondary, fontSize: 13, height: 1.4)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_isSaving || _isSaved) ? null : _createNutritionGoal,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSaved ? Colors.green : AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(_isSaved ? l10n.goalCreated : l10n.createGoal, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class GoalSuggestionCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String? conversationId;
  final String? messageId;

  const GoalSuggestionCard({
    super.key, 
    required this.data,
    this.conversationId,
    this.messageId,
  });

  @override
  State<GoalSuggestionCard> createState() => _GoalSuggestionCardState();
}

class _GoalSuggestionCardState extends State<GoalSuggestionCard> {
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

  Future<void> _createGoal() async {
    setState(() => _isSaving = true);
    try {
      await _nutritionService.saveGoal({
        'title': widget.data['title'],
        'target_amount': double.tryParse(widget.data['target_amount'].toString()) ?? 0.0,
        'target_date': DateTime.now().add(const Duration(days: 30)).toIso8601String().split('T')[0],
        'current_amount': 0.0,
        'status': 'active',
        'description': widget.data['reason'] ?? 'Meta creada por AI',
      });

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
          const SnackBar(content: Text('Meta creada exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear meta: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.blueAccent.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.flag_rounded, color: Colors.blueAccent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.goalSuggestion,
                  style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.secondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(widget.data['title'] ?? l10n.goalLabel, style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 4),
          Text(l10n.targetObjective(widget.data['target_amount']?.toString() ?? '0'), style: GoogleFonts.manrope(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(widget.data['reason'] ?? '', style: GoogleFonts.manrope(color: AppTheme.secondary, fontSize: 13, height: 1.4)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_isSaving || _isSaved) ? null : _createGoal,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSaved ? Colors.green : Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(_isSaved ? l10n.goalCreated : l10n.createGoal, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
