import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:geminifinanzas/l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../services/auth_service.dart';
import '../services/finance_service.dart';
import 'main_screen.dart';
import 'package:intl/intl.dart';
import '../utils/number_formatter.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final AuthService _authService = AuthService();
  final FinanceService _financeService = FinanceService();
  
  int _currentStep = 0;
  final int _totalSteps = 5;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _budgetController.addListener(() => setState(() {}));
  }

  bool _isStepValid() {
    if (_currentStep == 0) { // Sources
      return _incomeSources.isNotEmpty;
    } else if (_currentStep == 1) { // Debts
      return true; // Debts are now optional
    } else if (_currentStep == 2) { // Budget
      final text = _budgetController.text.trim().replaceAll(RegExp(r'[^\d]'), '');
      return text.isNotEmpty && double.tryParse(text) != null;
    }
    return true;
  }

  String _formatAmount(double amount) {
    return NumberFormat('#,###.##').format(amount);
  }

  // Step 1: Budget
  final TextEditingController _budgetController = TextEditingController();

  // Step 2: Income Sources (Previous Step 3)
  final List<Map<String, dynamic>> _incomeSources = [];
  final TextEditingController _sourceNameController = TextEditingController();
  final TextEditingController _sourceAmountController = TextEditingController();
  String _selectedFrequency = 'Monthly';

  // Step 3: Debts (Previous Step 4)
  final List<Map<String, dynamic>> _debts = [];
  final TextEditingController _debtNameController = TextEditingController();
  final TextEditingController _debtAmountController = TextEditingController();
  final TextEditingController _debtInterestController = TextEditingController();
  final TextEditingController _debtPaymentController = TextEditingController();

  // Step 4: Goals (Previous Step 5)
  final List<Map<String, dynamic>> _goals = [];
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _goalTargetController = TextEditingController();

  void _nextStep() {
    final l10n = AppLocalizations.of(context)!;
    
    // Validations for mandatory steps
    if (_currentStep == 0) { // Sources
      if (_incomeSources.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.sourcesRequired)));
        return;
      }
    } else if (_currentStep == 1) { // Debts
      // Debts are optional, no validation required here
    } else if (_currentStep == 2) { // Budget
      final budgetStr = _budgetController.text.trim().replaceAll(RegExp(r'[^\d]'), '');
      if (budgetStr.isEmpty || double.tryParse(budgetStr) == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.budgetRequired)));
        return;
      }
    }

    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    } else {
      _finishOnboarding();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  Future<void> _finishOnboarding() async {
    final budgetStr = _budgetController.text.trim().replaceAll(RegExp(r'[^\d]'), '');

    if (budgetStr.isEmpty || double.tryParse(budgetStr) == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.budgetRequired)));
      return;
    }

    if (_incomeSources.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.sourcesRequired)));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Save all data in a single atomic-like operation
      await _authService.saveFullOnboardingData(
        budget: double.parse(budgetStr),
        incomeSources: _incomeSources,
        debts: _debts,
      );

      // Create goals separately (as they use a different service/logic)
      for (var goal in _goals) {
        await _financeService.createGoal({
          'title': goal['name'],
          'target_amount': (goal['target'] as num).toDouble(),
        });
      }

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorGeneric(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addIncomeSource() {
    final name = _sourceNameController.text.trim();
    final amount = _sourceAmountController.text.trim().replaceAll(RegExp(r'[^\d]'), '');
    if (name.isNotEmpty && amount.isNotEmpty && double.tryParse(amount) != null) {
      setState(() {
        _incomeSources.add({'name': name, 'amount': double.parse(amount), 'frequency': _selectedFrequency});
        _sourceNameController.clear();
        _sourceAmountController.clear();
      });
    }
  }

  void _addDebt() {
    final name = _debtNameController.text.trim();
    final amount = _debtAmountController.text.trim().replaceAll(RegExp(r'[^\d]'), '');
    final interest = _debtInterestController.text.trim();
    final payment = _debtPaymentController.text.trim().replaceAll(RegExp(r'[^\d]'), '');
    
    if (name.isNotEmpty && amount.isNotEmpty && double.tryParse(amount) != null) {
      setState(() {
        _debts.add({
          'name': name, 
          'amount': double.parse(amount), 
          'interest': double.tryParse(interest) ?? 0.0,
          'monthly_payment': double.tryParse(payment) ?? 0.0,
          'date': DateTime.now().toIso8601String(),
        });
        _debtNameController.clear();
        _debtAmountController.clear();
        _debtInterestController.clear();
        _debtPaymentController.clear();
      });
    }
  }

  void _addGoal() {
    final name = _goalNameController.text.trim();
    final target = _goalTargetController.text.trim().replaceAll(RegExp(r'[^\d]'), '');
    if (name.isNotEmpty && target.isNotEmpty && double.tryParse(target) != null) {
      setState(() {
        _goals.add({'name': name, 'target': double.parse(target)});
        _goalNameController.clear();
        _goalTargetController.clear();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // Progress Bar
              Row(
                children: [
                   IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                    onPressed: _currentStep > 0 ? _prevStep : null,
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / _totalSteps,
                      backgroundColor: AppTheme.secondary.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text("${_currentStep + 1}/$_totalSteps", style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildSourcesStep(l10n),
                    _buildDebtStep(l10n),
                    _buildBudgetStep(l10n),
                    _buildGoalStep(l10n),
                    _buildSummaryStep(l10n),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: _isLoading 
                    ? l10n.loading 
                    : (_currentStep == _totalSteps - 1 ? l10n.finish : l10n.next),
                onPressed: (_isLoading || !_isStepValid()) ? null : _nextStep,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetStep(AppLocalizations l10n) {
    double totalIncome = _incomeSources.fold(0, (sum, item) {
      double val = (item['amount'] as num).toDouble();
      return sum + (item['frequency'] == 'Weekly' ? val * 4 : val);
    });
    double monthlyDebtPayments = _debts.fold(0, (sum, item) => sum + ((item['monthly_payment'] ?? 0) as num).toDouble());
    double recommended = totalIncome - monthlyDebtPayments;

    return _buildStepLayout(
      title: l10n.stepBudgetTitle,
      subtitle: l10n.stepBudgetSubtitle,
      content: [
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
               Text(
                l10n.monthlyAvailableMoney,
                style: GoogleFonts.manrope(fontSize: 14, color: AppTheme.secondary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                "\$${_formatAmount(recommended)}",
                style: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.primary),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.incomeMinusDebts,
                style: GoogleFonts.manrope(fontSize: 12, color: AppTheme.secondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        CustomTextField(
          label: l10n.howMuchToAssign,
          controller: _budgetController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [ThousandsSeparatorInputFormatter()],
          hintText: l10n.stepBudgetHint(_formatAmount(recommended * 0.7)),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.budgetLimitInfo,
          style: GoogleFonts.manrope(fontSize: 13, color: AppTheme.secondary, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }


  Widget _buildSourcesStep(AppLocalizations l10n) {
    return _buildStepLayout(
      title: l10n.stepSourcesTitle,
      subtitle: l10n.stepSourcesSubtitle,
      content: [
        const SizedBox(height: 32),
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.trending_up_rounded, size: 50, color: Colors.green),
          ),
        ),
        const SizedBox(height: 32),
        CustomTextField(label: l10n.sourceName, controller: _sourceNameController, hintText: l10n.sourceNameHint),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(flex: 2, child: CustomTextField(label: l10n.amount, controller: _sourceAmountController, keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: [ThousandsSeparatorInputFormatter()], hintText: "0.00")),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.2)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedFrequency,
                    onChanged: (v) => setState(() => _selectedFrequency = v!),
                    items: [
                      DropdownMenuItem(value: 'Weekly', child: Text(l10n.frequencyWeekly)),
                      DropdownMenuItem(value: 'Monthly', child: Text(l10n.frequencyMonthly)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomButton(text: l10n.addSource, onPressed: _addIncomeSource, isOutlined: true),
        const SizedBox(height: 16),
        Expanded(child: _buildItemList(_incomeSources, (i) => setState(() => _incomeSources.removeAt(i)))),
      ],
    );
  }

  Widget _buildDebtStep(AppLocalizations l10n) {
    return _buildStepLayout(
      title: l10n.stepDebtTitle,
      subtitle: l10n.stepDebtSubtitle,
      content: [
        const SizedBox(height: 32),
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.credit_card_off_rounded, size: 50, color: Colors.redAccent),
          ),
        ),
        const SizedBox(height: 32),
        CustomTextField(label: l10n.debtName, controller: _debtNameController, hintText: l10n.debtNameHint),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: CustomTextField(label: l10n.debtAmount, controller: _debtAmountController, keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: [ThousandsSeparatorInputFormatter()], hintText: "0.00")),
            const SizedBox(width: 12),
            Expanded(child: CustomTextField(label: l10n.debtPayment, controller: _debtPaymentController, keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: [ThousandsSeparatorInputFormatter()], hintText: l10n.debtPaymentHint)),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(label: l10n.debtInterest, controller: _debtInterestController, keyboardType: const TextInputType.numberWithOptions(decimal: true), hintText: "0%"),
        const SizedBox(height: 16),
        CustomButton(text: l10n.addDebt, onPressed: _addDebt, isOutlined: true),
        const SizedBox(height: 16),
        Expanded(child: _buildItemList(_debts, (i) => setState(() => _debts.removeAt(i)))),
      ],
    );
  }

  Widget _buildGoalStep(AppLocalizations l10n) {
    return _buildStepLayout(
      title: l10n.stepGoalTitle,
      subtitle: l10n.stepGoalSubtitle,
      content: [
        const SizedBox(height: 32),
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.auto_awesome_rounded, size: 50, color: AppTheme.primary),
          ),
        ),
        const SizedBox(height: 32),
        CustomTextField(label: l10n.goalName, controller: _goalNameController, hintText: l10n.goalNameHintOnboarding),
        const SizedBox(height: 16),
        CustomTextField(label: l10n.goalTarget, controller: _goalTargetController, keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: [ThousandsSeparatorInputFormatter()], hintText: "0.00"),
        const SizedBox(height: 16),
        CustomButton(text: l10n.addGoal, onPressed: _addGoal, isOutlined: true),
        const SizedBox(height: 16),
        Expanded(child: _buildItemList(_goals, (i) => setState(() => _goals.removeAt(i)), isGoal: true)),
      ],
    );
  }

  Widget _buildSummaryStep(AppLocalizations l10n) {
    double totalIncome = _incomeSources.fold(0, (sum, item) {
      double val = (item['amount'] as num).toDouble();
      return sum + (item['frequency'] == 'Weekly' ? val * 4 : val);
    });
    double budget = double.tryParse(_budgetController.text.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
    double monthlyDebtPayments = _debts.fold(0, (sum, item) => sum + ((item['monthly_payment'] ?? 0) as num).toDouble());
    double netBalance = totalIncome - budget - monthlyDebtPayments;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.onboardingSummary, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(l10n.onboardingSummarySubtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.secondary)),
          const SizedBox(height: 32),
          
          // Chart Section
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(value: budget, color: Colors.orangeAccent, title: l10n.chartBudget, radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                  if (monthlyDebtPayments > 0) PieChartSectionData(value: monthlyDebtPayments, color: Colors.redAccent, title: l10n.chartDebt, radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                  if (netBalance > 0) PieChartSectionData(value: netBalance, color: Colors.greenAccent, title: l10n.chartSavings, radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
                centerSpaceRadius: 40,
                sectionsSpace: 3,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Main Stats
          _buildSummaryCard(
            icon: Icons.payments_rounded,
            label: l10n.totalMonthlyIncome,
            value: "\$${_formatAmount(totalIncome)}",
            color: Colors.blueAccent,
          ),
          _buildSummaryCard(
            icon: Icons.account_balance_wallet_rounded,
            label: l10n.monthlyBudgetLimit,
            value: "\$${_formatAmount(budget)}",
            color: Colors.orangeAccent,
          ),
          _buildSummaryCard(
            icon: Icons.credit_card_off_rounded,
            label: l10n.monthlyDebtCommitment,
            value: "\$${_formatAmount(monthlyDebtPayments)}",
            color: Colors.redAccent,
          ),
          
          const Divider(height: 48),
          
          // Result Section (Advisor Perspective)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: (netBalance >= 0 ? Colors.green : Colors.red).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: (netBalance >= 0 ? Colors.green : Colors.red).withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      netBalance >= 0 ? Icons.check_circle_rounded : Icons.warning_rounded, 
                      color: netBalance >= 0 ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.realSavingCapacity,
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 16, color: netBalance >= 0 ? Colors.green : Colors.red),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  "\$${_formatAmount(netBalance)}",
                  style: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w900, color: netBalance >= 0 ? Colors.green : Colors.red),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.savingCapacityFormulaRefined(
                    "\$${_formatAmount(totalIncome)}", 
                    "\$${_formatAmount(budget)}", 
                    "\$${_formatAmount(monthlyDebtPayments)}",
                    "\$${_formatAmount(netBalance)}"
                  ),
                  style: GoogleFonts.manrope(
                    fontSize: 14, 
                    color: AppTheme.secondary,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Advisor Message
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.advisorContext,
                  style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  netBalance >= 0 ? l10n.financialHealthGood : l10n.financialHealthWarning,
                  style: GoogleFonts.manrope(fontSize: 13, color: AppTheme.secondary, height: 1.5),
                ),
              ],
            ),
          ),

          if (_goals.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text(l10n.yourGoals, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary)),
            const SizedBox(height: 16),
            ..._goals.map((goal) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.orangeAccent.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.stars_rounded, color: Colors.orangeAccent, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Text(goal['name'], style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 15))),
                  Text("\$${_formatAmount((goal['target'] as num).toDouble())}", style: GoogleFonts.manrope(fontWeight: FontWeight.w900, color: AppTheme.primary, fontSize: 16)),
                ],
              ),
            )),
          ],

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildStepLayout({required String title, required String subtitle, required List<Widget> content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 28)),
        const SizedBox(height: 8),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.secondary)),
        ...content,
      ],
    );
  }

  Widget _buildItemList(List<Map<String, dynamic>> items, Function(int) onDelete, {bool isGoal = false}) {
    final l10n = AppLocalizations.of(context)!;
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.1)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(item['name'], style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
            subtitle: Text(isGoal 
                ? "" 
                : (item.containsKey('interest') 
                    ? l10n.debtPaymentSummary(
                        item['interest'].toString(), 
                        "\$${_formatAmount((item['monthly_payment'] ?? 0).toDouble())}"
                      ) 
                    : (item['frequency'] ?? ""))),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("\$${_formatAmount(isGoal ? (item['target'] as num).toDouble() : (item['amount'] as num).toDouble())}", style: GoogleFonts.manrope(color: isGoal ? AppTheme.primary : (item.containsKey('interest') ? Colors.redAccent : Colors.green), fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close, size: 20, color: Colors.grey), onPressed: () => onDelete(index)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard({required IconData icon, required String label, required String value, required Color color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600))),
          Text(value, style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
