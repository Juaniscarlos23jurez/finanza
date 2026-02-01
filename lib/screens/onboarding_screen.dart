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
  final int _totalSteps = 6;
  bool _isLoading = false;

  // Step 1: Budget
  final TextEditingController _budgetController = TextEditingController();

  // Step 2: First Sale
  final TextEditingController _saleDescController = TextEditingController();
  final TextEditingController _saleAmountController = TextEditingController();

  // Step 3: Income Sources
  final List<Map<String, dynamic>> _incomeSources = [];
  final TextEditingController _sourceNameController = TextEditingController();
  final TextEditingController _sourceAmountController = TextEditingController();
  String _selectedFrequency = 'Monthly';

  // Step 4: Debts
  final List<Map<String, dynamic>> _debts = [];
  final TextEditingController _debtNameController = TextEditingController();
  final TextEditingController _debtAmountController = TextEditingController();
  final TextEditingController _debtInterestController = TextEditingController();

  // Step 5: Goals
  final List<Map<String, dynamic>> _goals = [];
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _goalTargetController = TextEditingController();

  void _nextStep() {
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
    final budgetStr = _budgetController.text.trim();
    final saleAmountStr = _saleAmountController.text.trim();
    final saleDesc = _saleDescController.text.trim();

    if (budgetStr.isEmpty || double.tryParse(budgetStr) == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.budgetRequired)));
      return;
    }

    if (saleAmountStr.isEmpty || double.tryParse(saleAmountStr) == null || saleDesc.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.saleRequired)));
      return;
    }

    if (_incomeSources.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.sourcesRequired)));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Save Budget
      await _authService.saveBudget(double.parse(budgetStr));

      // 2. Register First Sale as Transaction
      await _financeService.createRecord({
        'description': saleDesc,
        'amount': double.parse(saleAmountStr),
        'type': 'income',
        'category': 'Ventas',
        'date': DateTime.now().toIso8601String(),
      });

      // 3. Save Income Sources
      await _authService.saveIncomeSources(_incomeSources);

      // 4. Save Debts
      await _authService.saveDebts(_debts);

      // 5. Create Goals
      for (var goal in _goals) {
        await _financeService.createGoal({
          'title': goal['name'],
          'target_amount': (goal['target'] as num).toDouble(),
        });
      }

      // 6. Mark Onboarding as Complete
      await _authService.setOnboardingComplete(true);

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
    final amount = _sourceAmountController.text.trim();
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
    final amount = _debtAmountController.text.trim();
    final interest = _debtInterestController.text.trim();
    if (name.isNotEmpty && amount.isNotEmpty && double.tryParse(amount) != null) {
      setState(() {
        _debts.add({
          'name': name, 
          'amount': double.parse(amount), 
          'interest': double.tryParse(interest) ?? 0.0,
          'date': DateTime.now().toIso8601String(),
        });
        _debtNameController.clear();
        _debtAmountController.clear();
        _debtInterestController.clear();
      });
    }
  }

  void _addGoal() {
    final name = _goalNameController.text.trim();
    final target = _goalTargetController.text.trim();
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
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildBudgetStep(l10n),
                    _buildSaleStep(l10n),
                    _buildSourcesStep(l10n),
                    _buildDebtStep(l10n),
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
                onPressed: _isLoading ? () {} : _nextStep,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetStep(AppLocalizations l10n) {
    return _buildStepLayout(
      title: l10n.stepBudgetTitle,
      subtitle: l10n.stepBudgetSubtitle,
      content: [
        const SizedBox(height: 40),
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_balance_wallet_outlined, size: 80, color: AppTheme.primary),
          ),
        ),
        const SizedBox(height: 48),
        CustomTextField(
          label: l10n.amount,
          controller: _budgetController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          hintText: l10n.stepBudgetHint,
        ),
      ],
    );
  }

  Widget _buildSaleStep(AppLocalizations l10n) {
    return _buildStepLayout(
      title: l10n.stepSaleTitle,
      subtitle: l10n.stepSaleSubtitle,
      content: [
        const SizedBox(height: 32),
        CustomTextField(
          label: l10n.description,
          controller: _saleDescController,
          hintText: l10n.stepSaleHint,
        ),
        const SizedBox(height: 24),
        CustomTextField(
          label: l10n.amount,
          controller: _saleAmountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          hintText: "0.00",
        ),
      ],
    );
  }

  Widget _buildSourcesStep(AppLocalizations l10n) {
    return _buildStepLayout(
      title: l10n.stepSourcesTitle,
      subtitle: l10n.stepSourcesSubtitle,
      content: [
        const SizedBox(height: 16),
        CustomTextField(label: l10n.sourceName, controller: _sourceNameController, hintText: "Sueldo, Freelance, etc."),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(flex: 2, child: CustomTextField(label: l10n.amount, controller: _sourceAmountController, keyboardType: const TextInputType.numberWithOptions(decimal: true), hintText: "0.00")),
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
        const SizedBox(height: 16),
        CustomTextField(label: l10n.debtName, controller: _debtNameController, hintText: "Tarjeta de crédito, Préstamo, etc."),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: CustomTextField(label: l10n.debtAmount, controller: _debtAmountController, keyboardType: const TextInputType.numberWithOptions(decimal: true), hintText: "0.00")),
            const SizedBox(width: 12),
            Expanded(child: CustomTextField(label: l10n.debtInterest, controller: _debtInterestController, keyboardType: const TextInputType.numberWithOptions(decimal: true), hintText: "0%")),
          ],
        ),
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
        const SizedBox(height: 16),
        CustomTextField(label: l10n.goalName, controller: _goalNameController, hintText: "Viaje, Carro, Emergencias..."),
        const SizedBox(height: 16),
        CustomTextField(label: l10n.goalTarget, controller: _goalTargetController, keyboardType: const TextInputType.numberWithOptions(decimal: true), hintText: "0.00"),
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
    double budget = double.tryParse(_budgetController.text) ?? 0;
    double totalDebt = _debts.fold(0, (sum, item) => sum + (item['amount'] as num).toDouble());
    
    return _buildStepLayout(
      title: l10n.onboardingSummary,
      subtitle: l10n.onboardingSummarySubtitle,
      content: [
        const SizedBox(height: 24),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(value: budget, color: Colors.orangeAccent, title: 'Budget', radius: 50, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                PieChartSectionData(value: totalIncome > budget ? totalIncome - budget : 0.1, color: Colors.greenAccent, title: 'Savings', radius: 50, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                if (totalDebt > 0) PieChartSectionData(value: totalDebt / 10, color: Colors.redAccent, title: 'Debt', radius: 50, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 32),
        _buildSummaryRow(l10n.estimatedMonthlyBalance, "\$${(totalIncome - budget).toStringAsFixed(2)}", Colors.green),
        _buildSummaryRow(l10n.totalDebts, "\$${totalDebt.toStringAsFixed(2)}", Colors.redAccent),
        _buildSummaryRow(l10n.totalGoals, "${_goals.length} ${l10n.yourGoals}", AppTheme.primary),
      ],
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
            subtitle: Text(isGoal ? "" : (item['frequency'] ?? "${item['interest']}%")),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("\$${isGoal ? item['target'] : item['amount']}", style: GoogleFonts.manrope(color: isGoal ? AppTheme.primary : (item.containsKey('interest') ? Colors.redAccent : Colors.green), fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close, size: 20, color: Colors.grey), onPressed: () => onDelete(index)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.manrope(fontSize: 16)),
          Text(value, style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }
}
