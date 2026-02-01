import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:geminifinanzas/l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../services/finance_service.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import 'dart:async';
import 'package:share_plus/share_plus.dart';

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
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
  final NumberFormat _preciseCurrencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  String _formatCurrency(double amount, {bool precise = false}) {
    return (precise ? _preciseCurrencyFormat : _currencyFormat).format(amount);
  }

  StreamSubscription? _syncSubscription;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _goal = widget.goal;
    _setupSync();
    // Fetch full goal details including transactions immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshGoal();
    });
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
    try {
      final int? id = int.tryParse(_goal['id'].toString());
      if (id == null) return;
      
      debugPrint("DEBUG: Refreshing specific goal ID: $id via API");
      Map<String, dynamic> updatedGoal = await _financeService.getGoal(id);
      
      if (updatedGoal.isNotEmpty && mounted) {
        debugPrint("DEBUG: Updated goal found via direct fetch. Keys: ${updatedGoal.keys}");
        
        // Robust check for transaction lists
        List<dynamic> getBestList(Map<String, dynamic> goal) {
           final keys = ['transactions', 'records', 'history', 'contributions', 'items', 'logs'];
           for (var key in keys) {
             final val = goal[key];
             if (val is List && val.isNotEmpty) return val;
           }
           return [];
        }

        List<dynamic> txs = getBestList(updatedGoal);
        
        // Fallback: If no transactions in goal object, fetch global records and filter
        // This solves the issue where some goal responses are "thin"
        if (txs.isEmpty) {
          debugPrint("DEBUG: No transactions found in standard keys. Fetching global records as fallback...");
          try {
            final globalData = await _financeService.getFinanceData();
            final allRecords = globalData['records'] as List<dynamic>? ?? [];
            txs = allRecords.where((r) {
              final gid = r['financial_goal_id']?.toString() ?? r['goal_id']?.toString();
              return gid == id.toString();
            }).toList();
            debugPrint("DEBUG: Fallback found ${txs.length} transactions for goal $id.");
            
            // Inject filtered records into a new map to update state
            updatedGoal = Map<String, dynamic>.from(updatedGoal);
            updatedGoal['transactions'] = txs;
          } catch (e) {
            debugPrint("DEBUG: Error in global fallback: $e");
          }
        } else {
          debugPrint("DEBUG: Transactions extracted count: ${txs.length}");
        }

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
                if (!isDeposit) {
                   final current = double.tryParse(_goal['current_amount'].toString()) ?? 0.0;
                   if (val > current) {
                     if (!context.mounted) return;
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                         content: Text(l10n.insufficientFunds), backgroundColor: Colors.red));
                     setState(() => _isLoading = false);
                     return;
                   }
                }

                final Map<String, dynamic> result = isDeposit 
                  ? await _financeService.contributeToGoal(_goal['id'], val)
                  : await _financeService.withdrawFromGoal(_goal['id'], val);

                if (mounted) {
                   if (result.containsKey('goal')) {
                     debugPrint("DEBUG: Updating goal from transaction result");
                     setState(() {
                       _goal = result['goal'];
                     });
                   } else if (result.containsKey('data')) {
                     debugPrint("DEBUG: Updating goal from transaction result (data key)");
                     setState(() {
                       _goal = result['data'];
                     });
                   }
                }

                if (isDeposit) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(l10n.savingAddedSuccess), backgroundColor: Colors.green));
                } else {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(l10n.withdrawalSuccess), backgroundColor: Colors.orange));
                }
                
                // Still refresh to be safe, but we already updated state above
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
    
    // Robust check for transaction lists
    List<dynamic> getBestList(Map<String, dynamic> goal) {
      final keys = ['transactions', 'records', 'history', 'contributions', 'items', 'logs'];
      for (var key in keys) {
        final val = goal[key];
        if (val is List && val.isNotEmpty) return val;
      }
      return (goal['transactions'] ?? goal['records'] ?? []) as List<dynamic>;
    }
    
    final List<dynamic> transactionsList = getBestList(_goal);
    
    debugPrint("DEBUG: Rendering goal: ${_goal['title']} (ID: ${_goal['id']})");
    debugPrint("DEBUG: Current amount: $current, Target amount: $target");
    debugPrint("DEBUG: Transactions raw list size: ${transactionsList.length}");
    
    // Sort transactions by date descending
    final List<dynamic> transactions = List.from(transactionsList);
    transactions.sort((a, b) {
      final dateA = DateTime.tryParse(a['created_at']?.toString() ?? a['date']?.toString() ?? '') ?? DateTime(2000);
      final dateB = DateTime.tryParse(b['created_at']?.toString() ?? b['date']?.toString() ?? '') ?? DateTime(2000);
      return dateB.compareTo(dateA);
    });

    if (transactions.isNotEmpty) {
      debugPrint("DEBUG: Sorted transactions count: ${transactions.length}");
    }

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
                            text: _formatCurrency(current),
                            style: GoogleFonts.manrope(
                              color: AppTheme.primary,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          TextSpan(
                            text: ' / ${_formatCurrency(target)}',
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
                          debugPrint("DEBUG: Mapping transaction: $t");
                          final String type = (t['type'] ?? '').toString().toLowerCase();
                          final String category = (t['category'] ?? '').toString().toLowerCase();
                          final String description = (t['description'] ?? '').toString().toLowerCase();
                          
                          // Correct mapping for this backend:
                          // Abonos (contributions) are labeled as 'expense' (from wallet) or 'ahorro' category.
                          // Retiros (withdrawals) are labeled as 'income' (to wallet) or 'retiro' category.
                          final bool isContribution = type == 'contribution' ||
                              type == 'deposit' ||
                              type == 'expense' ||
                              category.contains('ahorro') ||
                              description.contains('abono') ||
                              (description.contains('meta') && !description.contains('retiro'));
                              
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

              // Ad Banner at Bottom - REMOVED AS REQUESTED
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
              const SizedBox(height: 12),
              // New Share Link Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final code = await _authService.getOrCreateUserCode();
                    final appLink = "https://geminifinanzas.page.link/download"; // Placeholder or real link
                    final shareText = "${l10n.inviteCollaboratorSubtitle}\n\n"
                        "${l10n.invitationUserCode}: $code\n\n"
                        "${l10n.goal}: ${_goal['title']}\n"
                        "Download: $appLink";
                    
                    await SharePlus.instance.share(ShareParams(text: shareText));
                  },
                  icon: const Icon(Icons.share_rounded, color: Colors.purpleAccent),
                  label: Text(
                    l10n.shareLinkAndCode,
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.purpleAccent,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: const BorderSide(color: Colors.purpleAccent),
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
            '${isIncome ? '+' : '-'}${_formatCurrency(amount, precise: true)}',
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
