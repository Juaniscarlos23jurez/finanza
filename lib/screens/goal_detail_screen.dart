import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:geminifinanzas/l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../services/finance_service.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../widgets/native_ad_widget.dart';
import 'dart:async';

class GoalDetailScreen extends StatefulWidget {
  final Map<String, dynamic> goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  late Map<String, dynamic> _goal;
  final FinanceService _financeService = FinanceService();
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();
  StreamSubscription? _syncSubscription;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _goal = widget.goal;
    _setupSync();
  }

  void _setupSync() {
    final int? goalId = int.tryParse(_goal['id'].toString());
    if (goalId != null) {
      _syncSubscription = _firebaseService.listenToGoalUpdates(goalId).listen((event) {
        if (event.snapshot.value != null && mounted) {
          debugPrint("Real-time update detected for goal $goalId");
          _refreshGoal();
        }
      });
    }
  }

  @override
  void dispose() {
    _syncSubscription?.cancel();
    super.dispose();
  }

  Future<void> _refreshGoal() async {
    // Only refreshing the specific goal logic would typically require finding it again in the list
    // For simplicity, we can just re-fetch all goals or ideally have a single getGoal endpoint.
    // Here we'll rely on the actions updating the local state or re-fetching goals.
    try {
      final goals = await _financeService.getGoals();
      final updatedGoal = goals.firstWhere((g) => g['id'].toString() == _goal['id'].toString(), orElse: () => null);
      if (updatedGoal != null && mounted) {
        setState(() {
          _goal = updatedGoal;
        });
      }
    } catch (e) {
      debugPrint("Error refreshing goal: $e");
    }
  }

  Future<void> _handleTransaction({required bool isDeposit}) async {
    final amountController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isDeposit ? l10n.addSaving : l10n.withdrawFunds,
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.amount,
                prefixText: '\$ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel, style: GoogleFonts.manrope(color: AppTheme.secondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final val = double.tryParse(amountController.text);
              if (val == null || val <= 0) return;

              Navigator.pop(context);
              setState(() => _isLoading = true);

              try {
                if (isDeposit) {
                  await _financeService.contributeToGoal(_goal['id'], val);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(l10n.savingAddedSuccess), backgroundColor: Colors.green));
                } else {
                  final current = double.tryParse(_goal['current_amount'].toString()) ?? 0.0;
                  if (val > current) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(l10n.insufficientFunds), backgroundColor: Colors.red));
                    setState(() => _isLoading = false);
                    return;
                  }
                  await _financeService.withdrawFromGoal(_goal['id'], val);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(l10n.withdrawalSuccess), backgroundColor: Colors.orange));
                }
                
                await _refreshGoal();
                final int? goalId = int.tryParse(_goal['id'].toString());
                if (goalId != null) {
                  await _firebaseService.notifyGoalUpdate(goalId);
                }
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.errorGeneric(e.toString())), backgroundColor: Colors.red));
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDeposit ? AppTheme.primary : Colors.orange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(isDeposit ? l10n.add : l10n.withdraw, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final double target = double.tryParse(_goal['target_amount'].toString()) ?? 1.0;
    final double current = double.tryParse(_goal['current_amount'].toString()) ?? 0.0;
    final double progress = (current / target).clamp(0.0, 1.0);
    final int percentage = (progress * 100).round();
    final String title = _goal['title'] ?? l10n.goal;
    final List<dynamic> transactionsList = (_goal['transactions'] ?? _goal['history'] ?? _goal['records'] ?? _goal['contributions'] ?? []) as List<dynamic>;
    
    // Sort transactions by date descending
    final List<dynamic> transactions = List.from(transactionsList);
    transactions.sort((a, b) {
      final dateA = DateTime.tryParse(a['created_at']?.toString() ?? a['date']?.toString() ?? '') ?? DateTime(2000);
      final dateB = DateTime.tryParse(b['created_at']?.toString() ?? b['date']?.toString() ?? '') ?? DateTime(2000);
      return dateB.compareTo(dateA);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title, style: GoogleFonts.manrope(color: AppTheme.primary, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              if (_isLoading) const LinearProgressIndicator(color: AppTheme.primary),
              const SizedBox(height: 20),
              
              // Header Info
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.currentBalance,
                      style: GoogleFonts.manrope(color: AppTheme.secondary, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '\$${current.toStringAsFixed(0)}',
                            style: GoogleFonts.manrope(
                              color: AppTheme.primary,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          TextSpan(
                            text: ' / \$${target.toStringAsFixed(0)}',
                            style: GoogleFonts.manrope(
                              color: AppTheme.secondary.withValues(alpha: 0.6),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Circular Progress
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 8,
                            backgroundColor: Colors.grey.withValues(alpha: 0.1),
                            color: AppTheme.primary,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.monetization_on_outlined, size: 24, color: AppTheme.primary),
                            Text(
                              '$percentage%',
                              style: GoogleFonts.manrope(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    icon: Icons.add_rounded,
                    label: l10n.add,
                    color: AppTheme.primary,
                    onTap: () => _handleTransaction(isDeposit: true),
                  ),
                  _buildActionButton(
                    icon: Icons.remove_rounded,
                    label: l10n.withdraw,
                    color: Colors.orange,
                    onTap: () => _handleTransaction(isDeposit: false),
                  ),
                  _buildActionButton(
                    icon: Icons.show_chart_rounded,
                    label: l10n.progress,
                    color: Colors.blueAccent,
                    onTap: () {
                      // Just a placeholder for potential charts view
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.progressChartComingSoon)));
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.share_rounded,
                    label: l10n.invite,
                    color: Colors.purpleAccent,
                    onTap: _showInviteDialog,
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Transactions Section Title
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.recentTransactions,
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (transactions.isNotEmpty)
                        ...transactions.map((t) {
                          final bool isContribution = t['type'] == 'contribution' ||
                              t['type'] == 'deposit' ||
                              (double.tryParse(t['amount']?.toString() ?? '0') ?? 0) > 0;
                          final double amount = (double.tryParse(t['amount']?.toString() ?? '0') ?? 0).abs();

                          return _buildGoalTransactionItem(
                            date: DateTime.tryParse(t['created_at']?.toString() ?? t['date']?.toString() ?? '') ??
                                DateTime.now(),
                            amount: amount,
                            isIncome: isContribution,
                            description: t['description'] ?? (isContribution ? l10n.contribution : l10n.withdrawal),
                          );
                        })
                      else
                        _buildGoalTransactionItem(
                          date: DateTime.now(),
                          amount: 0.0,
                          isIncome: true,
                          description: l10n.goalCreation,
                        ),
                    ],
                  ),
                ),
              ),

              // Ad Banner at Bottom
              const Padding(
                padding: EdgeInsets.only(top: 16, bottom: 8),
                child: NativeAdWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInviteDialog() {
    final codeController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    bool isSending = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purpleAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.person_add_rounded, color: Colors.purpleAccent, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.inviteCollaboratorTitle,
                          style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.primary),
                        ),
                        Text(
                          l10n.inviteCollaboratorSubtitle,
                          style: GoogleFonts.manrope(color: AppTheme.secondary, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                l10n.invitationUserCode,
                style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: l10n.userCodeHint,
                  hintStyle: GoogleFonts.manrope(color: Colors.grey.withValues(alpha: 0.5)),
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.qr_code_2_rounded, color: AppTheme.secondary),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSending ? null : () async {
                    if (codeController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.enterValidCode)),
                      );
                      return;
                    }

                    setModalState(() => isSending = true);

                    // Send actual invitation via Firebase
                    final userEmail = await _authService.getUserEmail();
                    final userName = (await _authService.getProfile())['data']?['name'] ?? l10n.unknownUser;
                    
                    if (userEmail != null) {
                      final int? goalId = int.tryParse(_goal['id'].toString());
                      if (goalId != null) {
                        final result = await _firebaseService.sendInvitationByCode(
                          fromEmail: userEmail,
                          fromName: userName,
                          toCode: codeController.text.trim().toUpperCase(),
                          goalId: goalId,
                          goalName: _goal['title'] ?? l10n.goal,
                        );

                        if (!mounted) return;
                        
                        if (result['success'] == true) {
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.invitationSentTo(codeController.text.trim())),
                              backgroundColor: Colors.purpleAccent,
                            ),
                          );
                        } else {
                          setModalState(() => isSending = false);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result['message'] ?? l10n.errorSendingInvitation),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: isSending
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          l10n.sendInvitation,
                          style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalTransactionItem({
    required DateTime date,
    required double amount,
    required bool isIncome,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                DateFormat('MMM d, yyyy', Localizations.localeOf(context).toString()).format(date),
                style: GoogleFonts.manrope(color: AppTheme.secondary, fontSize: 12),
              ),
            ],
          ),
          Text(
            '${isIncome ? '+' : '-'}\$${amount.toStringAsFixed(0)}',
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
