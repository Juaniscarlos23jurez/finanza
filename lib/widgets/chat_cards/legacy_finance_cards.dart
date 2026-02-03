import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/nutrition_service.dart';
import '../../services/chat_service.dart';
import '../../services/gamification_service.dart';

class TransactionCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String? conversationId;
  final String? messageId;

  const TransactionCard({
    super.key, 
    required this.data,
    this.conversationId,
    this.messageId,
  });

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
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

  Future<void> _saveTransaction() async {
    setState(() => _isSaving = true);
    try {
      await _nutritionService.addMealToToday({
        'name': widget.data['description'] ?? 'Registro AI',
        'calories': double.tryParse(widget.data['amount'].toString()) ?? 0.0,
        'category': widget.data['category'] ?? 'General',
      }, isCompleted: true);

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

        // Trigger Gamification & Macro Checks
        GamificationService().checkAndShowModal(context, PandaTrigger.mealLogged);
        GamificationService().checkAndTriggerMacroCelebrations(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.mealRegistered)),
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
    final bool isExpense = widget.data['is_expense'] ?? true;
    final double amount = double.tryParse(widget.data['amount'].toString()) ?? 0.0;
    final String category = widget.data['category'] ?? 'General';
    final String description = widget.data['description'] ?? 'Transacción';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.ticketGenerated, style: GoogleFonts.manrope(color: AppTheme.secondary, fontSize: 12, fontWeight: FontWeight.bold)),
              Icon(isExpense ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, 
                   color: isExpense ? Colors.redAccent : Colors.green, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isExpense ? Colors.redAccent : Colors.green).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isExpense ? Icons.shopping_bag_outlined : Icons.attach_money,
                  color: isExpense ? Colors.redAccent : Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(description, style: GoogleFonts.manrope(color: AppTheme.secondary, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.totalLabel, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(
                '${isExpense ? "-" : "+"}\$${amount.toStringAsFixed(2)}',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w900, 
                  fontSize: 20,
                  color: isExpense ? AppTheme.primary : Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_isSaving || _isSaved) ? null : _saveTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSaved ? Colors.green : AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_isSaved ? Icons.check_circle_outline : Icons.save_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _isSaved ? l10n.savedLabel : l10n.confirmSave,
                        style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
            ),
          )
        ],
      ),
    );
  }
}

class MultiTransactionCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String? conversationId;
  final String? messageId;

  const MultiTransactionCard({
    super.key, 
    required this.data,
    this.conversationId,
    this.messageId,
  });

  @override
  State<MultiTransactionCard> createState() => _MultiTransactionCardState();
}

class _MultiTransactionCardState extends State<MultiTransactionCard> {
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

  Future<void> _saveAllTransactions(List<dynamic> transactions) async {
    setState(() => _isSaving = true);
    try {
      final List<Map<String, dynamic>> meals = transactions.map((t) => {
        'name': t['description'] ?? 'Registro AI',
        'calories': double.tryParse(t['amount'].toString()) ?? 0.0,
        'category': t['category'] ?? 'General',
      }).toList();

      for (var meal in meals) {
        await _nutritionService.addMealToToday(meal, isCompleted: true);
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

        // Trigger Gamification & Macro Checks
        GamificationService().checkAndShowModal(context, PandaTrigger.mealLogged);
        GamificationService().checkAndTriggerMacroCelebrations(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${transactions.length} registros guardados')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> transactions = widget.data['transactions'] ?? [];
    if (transactions.isEmpty) return const SizedBox.shrink();

    double totalIncome = 0;
    double totalExpense = 0;
    for (var t in transactions) {
      final amount = double.tryParse(t['amount'].toString()) ?? 0;
      if (t['is_expense'] == true) {
        totalExpense += amount;
      } else {
        totalIncome += amount;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.receipt_long_rounded, size: 18, color: AppTheme.primary),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l10n.transactionsCount(transactions.length),
                    style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (totalIncome >= totalExpense ? Colors.green : Colors.red).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  totalIncome >= totalExpense 
                      ? '+\$${(totalIncome - totalExpense).toStringAsFixed(2)}' 
                      : '-\$${(totalExpense - totalIncome).toStringAsFixed(2)}',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: totalIncome >= totalExpense ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...transactions.map((t) {
            final bool isExpense = t['is_expense'] ?? true;
            final double amount = double.tryParse(t['amount'].toString()) ?? 0;
            final String desc = t['description'] ?? 'Transacción';
            final String category = t['category'] ?? 'General';

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isExpense ? Colors.red : Colors.green).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isExpense ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                      size: 16,
                      color: isExpense ? Colors.red : Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(desc, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(category, style: GoogleFonts.manrope(fontSize: 11, color: AppTheme.secondary)),
                      ],
                    ),
                  ),
                  Text(
                    '${isExpense ? "-" : "+"}\$${amount.toStringAsFixed(2)}',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: isExpense ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(l10n.income, style: GoogleFonts.manrope(fontSize: 10, color: AppTheme.secondary)),
                    Text('+\$${totalIncome.toStringAsFixed(2)}', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
                Container(width: 1, height: 30, color: Colors.grey.withValues(alpha: 0.2)),
                Column(
                  children: [
                    Text(l10n.expenses, style: GoogleFonts.manrope(fontSize: 10, color: AppTheme.secondary)),
                    Text('-\$${totalExpense.toStringAsFixed(2)}', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.red)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_isSaving || _isSaved) ? null : () => _saveAllTransactions(transactions),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSaved ? Colors.green : AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_isSaved ? Icons.check_circle_outline : Icons.save_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _isSaved ? l10n.everythingSaved : l10n.saveAllTransactions(transactions.length),
                          style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionListCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const TransactionListCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<dynamic> items = data['items'] ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.table_chart_rounded, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                l10n.movementsSummary,
                style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text(l10n.concept, style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary))),
                Expanded(child: Text(l10n.amountLabel, style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary), textAlign: TextAlign.right)),
                Expanded(child: Text(l10n.resulted, style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary), textAlign: TextAlign.right)),
                Expanded(child: Text(l10n.impact, style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary), textAlign: TextAlign.right)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...items.take(5).map((item) {
            final bool isExpense = item['is_expense'] ?? true;
            final double amount = double.tryParse(item['amount'].toString()) ?? 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['description'] ?? 'Item', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(item['date'] ?? '', style: GoogleFonts.manrope(fontSize: 10, color: AppTheme.secondary)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text('\$${amount.toStringAsFixed(0)}', textAlign: TextAlign.right, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  Expanded(
                    child: Text('\$${(double.tryParse(item['balance']?.toString() ?? '') ?? 0.0).toStringAsFixed(0)}', textAlign: TextAlign.right, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primary)),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isExpense ? Colors.red : Colors.green).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isExpense ? l10n.downTrend : l10n.upTrend,
                          style: GoogleFonts.manrope(fontSize: 9, fontWeight: FontWeight.bold, color: isExpense ? Colors.red : Colors.green),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (items.isEmpty)
             Center(child: Text(l10n.noRecentData, style: GoogleFonts.manrope(fontSize: 12, color: AppTheme.secondary)))
          else ...[
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.resultingBalance, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.secondary)),
                Text(
                  '\$${(double.tryParse(data['total_balance']?.toString() ?? '') ?? double.tryParse(data['balance']?.toString() ?? '') ?? 0.0).toStringAsFixed(2)}',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.primary),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class BalanceCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const BalanceCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final double total = double.tryParse(data['total'].toString()) ?? 0.0;
    final double income = double.tryParse(data['income'].toString()) ?? 0.0;
    final double expenses = double.tryParse(data['expenses'].toString()) ?? 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Text(l10n.currentBalanceLabel, style: GoogleFonts.manrope(color: Colors.white70, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('\$${total.toStringAsFixed(2)}', style: GoogleFonts.manrope(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat(l10n.income, '+\$${income.toStringAsFixed(0)}', Colors.greenAccent),
              _buildMiniStat(l10n.expenses, '-\$${expenses.toStringAsFixed(0)}', Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.manrope(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.manrope(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
