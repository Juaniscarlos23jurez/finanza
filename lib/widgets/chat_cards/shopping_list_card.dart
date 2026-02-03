import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/nutrition_service.dart';
import '../../services/chat_service.dart';

class ShoppingListCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String? conversationId;
  final String? messageId;

  const ShoppingListCard({
    super.key, 
    required this.data,
    this.conversationId,
    this.messageId,
  });

  @override
  State<ShoppingListCard> createState() => _ShoppingListCardState();
}

class _ShoppingListCardState extends State<ShoppingListCard> {
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

  Future<void> _saveShoppingList(List<dynamic> items) async {
    setState(() => _isSaving = true);
    try {
      await _nutritionService.saveShoppingList(items);
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
            content: Text(l10n.addedToPantry),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: l10n.showLabel,
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
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
    final String title = widget.data['title'] ?? l10n.shoppingList;
    final List<dynamic> items = widget.data['items'] ?? [];

    if (items.isEmpty) return const SizedBox.shrink();

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
              gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shopping_cart, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.shoppingListGenerated,
                        style: GoogleFonts.manrope(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        title,
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.itemsCount(items.length),
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ...items.map((item) {
                  final String name = item['name'] ?? item.toString();
                  final String quantity = item['quantity'] ?? '1 ${l10n.itemQuantityUnit}';
                  final String category = item['category'] ?? l10n.catOthers;
                  
                  Color categoryColor = AppTheme.secondary;
                  IconData categoryIcon = Icons.shopping_basket_outlined;
                  
                  if (category.toLowerCase().contains('proteína') || category.toLowerCase().contains('protein')) {
                    categoryColor = Colors.red.shade400;
                    categoryIcon = Icons.egg_outlined;
                  } else if (category.toLowerCase().contains('verdura') || category.toLowerCase().contains('vegetable')) {
                    categoryColor = Colors.green.shade400;
                    categoryIcon = Icons.eco_outlined;
                  } else if (category.toLowerCase().contains('fruta') || category.toLowerCase().contains('fruit')) {
                    categoryColor = Colors.orange.shade400;
                    categoryIcon = Icons.apple_outlined;
                  } else if (category.toLowerCase().contains('grano') || category.toLowerCase().contains('grain')) {
                    categoryColor = Colors.amber.shade600;
                    categoryIcon = Icons.grain_outlined;
                  } else if (category.toLowerCase().contains('lácteo') || category.toLowerCase().contains('dairy')) {
                    categoryColor = Colors.blue.shade300;
                    categoryIcon = Icons.water_drop_outlined;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(categoryIcon, size: 18, color: categoryColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.manrope(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppTheme.primary,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    quantity,
                                    style: GoogleFonts.manrope(
                                      fontSize: 11,
                                      color: AppTheme.secondary.withValues(alpha: 0.7),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: categoryColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      category,
                                      style: GoogleFonts.manrope(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: categoryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_isSaving || _isSaved) ? null : () => _saveShoppingList(items),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSaved ? Colors.green : AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isSaved ? Icons.check_circle : Icons.add_shopping_cart,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isSaved ? l10n.addedToPantry : l10n.addAllToPantry,
                                style: GoogleFonts.manrope(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  color: Colors.white,
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
      ),
    );
  }
}
