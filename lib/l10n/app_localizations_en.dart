// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get accountSection => 'ACCOUNT';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get scheduleReport => 'Schedule Report';

  @override
  String get otherSection => 'OTHER';

  @override
  String get feedback => 'Feedback';

  @override
  String get termsConditions => 'Terms and Conditions';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get logout => 'Log Out';

  @override
  String get deleteAccount => 'Delete my account permanently';

  @override
  String get deleteAccountTitle => 'Delete account?';

  @override
  String get deleteAccountContent =>
      'This action will close your current session.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get feedbackTitle => 'Give us your Feedback';

  @override
  String get feedbackSubtitle =>
      'Your opinion helps us improve the experience for everyone.';

  @override
  String get feedbackTypeQuestion => 'What is your comment about?';

  @override
  String get typeSuggestion => 'Suggestion';

  @override
  String get typeError => 'Error';

  @override
  String get typeCompliment => 'Compliment';

  @override
  String get feedbackHint => 'Tell us what you like or what we can improve...';

  @override
  String get sendFeedback => 'Send Comments';

  @override
  String get feedbackSuccess => 'Thanks for your feedback!';

  @override
  String get fullName => 'Full Name';

  @override
  String get email => 'Email';

  @override
  String get userId => 'User ID';

  @override
  String get close => 'Close';

  @override
  String get scheduleReportTitle => 'Schedule Report';

  @override
  String get reportDescription =>
      'You will receive an Excel file with your transactions and an AI-generated financial analysis.';

  @override
  String get sendReportTo => 'Send report to:';

  @override
  String get frequencyQuestion => 'Every how many days?';

  @override
  String daysLoop(int count) {
    return '$count days';
  }

  @override
  String get confirmAndSchedule => 'Confirm and Schedule';

  @override
  String get configSaved => 'Configuration saved successfully!';

  @override
  String get language => 'Language';

  @override
  String get fillAllFields => 'Please fill all fields';

  @override
  String googleError(String error) {
    return 'Google Error: $error';
  }

  @override
  String appleError(String error) {
    return 'Apple Error: $error';
  }

  @override
  String get welcomeBack => 'Welcome\nback.';

  @override
  String get password => 'Password';

  @override
  String get loggingIn => 'Logging in...';

  @override
  String get login => 'Log In';

  @override
  String get or => 'OR';

  @override
  String get loading => 'Loading...';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get register => 'Sign Up';

  @override
  String get createAccount => 'Create\nAccount.';

  @override
  String get name => 'Name';

  @override
  String get registering => 'Registering...';

  @override
  String get signUp => 'Sign Up';

  @override
  String get transactions => 'Transactions';

  @override
  String get filterByDate => 'Filter by Date';

  @override
  String get ready => 'Done';

  @override
  String get all => 'All';

  @override
  String get incomes => 'Income';

  @override
  String get expenses => 'Expenses';

  @override
  String get clearDate => 'Clear Date';

  @override
  String get noDataChart => 'No data to chart';

  @override
  String get trend => 'Trend (7 days)';

  @override
  String get weeklyExpenses => 'Weekly Expenses';

  @override
  String get weeklyIncome => 'Weekly Income';

  @override
  String get byCategory => 'By Category';

  @override
  String get seeFull => 'See Full';

  @override
  String get noTransactions => 'No transactions';

  @override
  String get opens => 'Open:';

  @override
  String get closes => 'Close:';

  @override
  String get noDescription => 'No description';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get description => 'Description';

  @override
  String get amount => 'Amount';

  @override
  String get date => 'Date';

  @override
  String get save => 'Save';

  @override
  String get categoryLabel => 'Category';

  @override
  String get paymentMethod => 'Payment Details';

  @override
  String get delete => 'Delete';

  @override
  String get deleteTransactionConfirm =>
      'Are you sure you want to delete this transaction?';

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String deleteError(String error) {
    return 'Error deleting: $error';
  }

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get general => 'General';

  @override
  String get others => 'Others';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get balanceTrend => 'Balance Trend';

  @override
  String get yourGoals => 'Your Goals';

  @override
  String get expensesByCategory => 'Expenses by Category';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get noRecentActivity => 'No recent activity';

  @override
  String hello(String name) {
    return 'Hello, $name';
  }

  @override
  String get helloSimple => 'Hello';

  @override
  String get totalBalance => 'TOTAL BALANCE';

  @override
  String get newGoal => 'New Goal';

  @override
  String get goalNameHint => 'Goal Name (e.g. Trip)';

  @override
  String get targetAmountHint => 'Target Amount (\$)';

  @override
  String get noActiveGoals => 'No active goals';

  @override
  String get goal => 'Goal';

  @override
  String get deposit => 'Deposit';

  @override
  String get withdraw => 'Withdraw';

  @override
  String get add => 'Add';

  @override
  String get withdrawFromGoal => 'Withdraw from Goal';

  @override
  String get depositToGoal => 'Deposit to Goal';

  @override
  String get available => 'Available';

  @override
  String get saved => 'Saved';

  @override
  String get remaining => 'Remaining';

  @override
  String get amountToWithdraw => 'Amount to withdraw';

  @override
  String get amountToDeposit => 'Amount to deposit';

  @override
  String get allAmount => 'All';

  @override
  String get enterValidAmount => 'Enter a valid amount';

  @override
  String cannotWithdrawMore(String amount) {
    return 'Cannot withdraw more than \$$amount';
  }

  @override
  String withdrewAmount(String amount, String goal) {
    return 'Withdrew \$$amount from \"$goal\"';
  }

  @override
  String depositedAmount(String amount, String goal) {
    return 'Deposited \$$amount to \"$goal\"!';
  }

  @override
  String get deleteGoal => 'Delete Goal';

  @override
  String get deleteGoalConfirm => 'Are you sure you want to delete this goal?';

  @override
  String goalAlreadySavedWarning(String amount) {
    return 'You already have \$$amount saved in this goal.';
  }

  @override
  String goalDeleted(String goal) {
    return 'Goal \"$goal\" deleted';
  }

  @override
  String get distribution => 'Distribution';

  @override
  String get noExpensesRegistered => 'No expenses registered';

  @override
  String get invitationTitle => 'Invitation!';

  @override
  String invitationBody(String name, String goal) {
    return '$name invited you to collaborate on: $goal';
  }

  @override
  String get invitationQuestion =>
      'Do you want to accept this invitation and share progress?';

  @override
  String get reject => 'Reject';

  @override
  String get accept => 'Accept';

  @override
  String get invitationAccepted => 'Invitation accepted';

  @override
  String get unknownUser => 'Someone';

  @override
  String get defaultGoalName => 'a goal';

  @override
  String get addSaving => 'Add Saving';

  @override
  String get withdrawFunds => 'Withdraw Funds';

  @override
  String get savingAddedSuccess => 'Saving added successfully';

  @override
  String get insufficientFunds => 'Insufficient funds';

  @override
  String get withdrawalSuccess => 'Withdrawal successful';

  @override
  String get currentBalance => 'Current balance';

  @override
  String get progress => 'Progress';

  @override
  String get invite => 'Invite+';

  @override
  String get progressChartComingSoon => 'Progress chart coming soon!';

  @override
  String get contribution => 'Contribution';

  @override
  String get withdrawal => 'Withdrawal';

  @override
  String get goalCreation => 'Goal creation';

  @override
  String get inviteCollaboratorTitle => 'Invite Collaborator';

  @override
  String get inviteCollaboratorSubtitle => 'Share this goal with someone else';

  @override
  String get invitationUserCode => 'User Code';

  @override
  String get userCodeHint => 'e.g. JUAN-1234';

  @override
  String get enterValidCode => 'Enter a valid code';

  @override
  String invitationSentTo(String code) {
    return 'Invitation sent to $code';
  }

  @override
  String get errorSendingInvitation => 'Error sending invitation';

  @override
  String get sendInvitation => 'Send Invitation';

  @override
  String errorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get aiThinking => 'AI is thinking...';

  @override
  String speechError(String error) {
    return 'Voice error: $error';
  }

  @override
  String get voiceRecognitionUnavailable => 'Voice recognition not available';

  @override
  String get listening => 'Listening...';

  @override
  String get typeHere => 'Type here...';

  @override
  String get assistantGreeting => 'Hi! I\'m your financial assistant.';

  @override
  String get assistantDescription =>
      'I can help you record expenses, create goals, and analyze your finances with AI.';

  @override
  String get questionExamples => 'QUESTION EXAMPLES';

  @override
  String get fastExpense => 'Fast Expense';

  @override
  String get fastExpenseSubtitle => '\"Earned 3000 and spent 50\"';

  @override
  String get newGoalSubtitle => '\"Save for trip\"';

  @override
  String get iaAnalysis => 'AI Analysis';

  @override
  String get iaAnalysisSubtitle => '\"6-month projection\"';

  @override
  String get exportSubtitle => '\"Download CSV\"';

  @override
  String get finanzasAi => 'FINANCES AI';

  @override
  String get history => 'HISTORY';

  @override
  String get newChat => 'New Chat';

  @override
  String get noSavedConversations => 'No saved conversations.';

  @override
  String get untitledConversation => 'Untitled Conversation';

  @override
  String get transactionSavedSuccess => 'Transaction recorded correctly';

  @override
  String get aiAssistant => 'AI ASSISTANT';

  @override
  String get youLabel => 'YOU';

  @override
  String get premiumAnalysis => 'Premium Analysis';

  @override
  String get exclusiveContent => 'Exclusive unlockable content.';

  @override
  String get deepAiAnalysis => 'Deep AI Analysis';

  @override
  String get aiGeneratedAnalysis => 'Analysis generated by Finance AI';

  @override
  String get strategicReportInfo =>
      'This report contains high-value strategic information.';

  @override
  String get unlockVideo => 'Watch Video to Unlock';

  @override
  String get contentUnlocked => 'Content unlocked!';

  @override
  String adLoadError(String error) {
    return 'Could not load ad. Try again. ($error)';
  }

  @override
  String get csvReady => 'Excel/CSV Report Ready';

  @override
  String get reportLocked => 'Report Locked';

  @override
  String get downloadAdPrompt => 'Watch an ad to download';

  @override
  String get shareCsv => 'Share / Save CSV';

  @override
  String get shareCsvText => 'Here is my financial report.';

  @override
  String csvShareError(String error) {
    return 'Error sharing CSV: $error';
  }

  @override
  String get transactionSummary => 'Transaction Summary';

  @override
  String get concept => 'Concept';

  @override
  String get result => 'Result';

  @override
  String get impact => 'Impact';

  @override
  String get resultingBalance => 'Resulting Balance';

  @override
  String get noRecentData => 'No recent data';

  @override
  String multiTransactionTitle(int count) {
    return '$count Transactions';
  }

  @override
  String saveAllTransactions(int count) {
    return 'Save $count Transactions';
  }

  @override
  String get allSaved => 'All Saved';

  @override
  String transactionsSavedCount(int count) {
    return '$count transactions saved';
  }

  @override
  String get goalSuggestion => 'Goal Suggestion';

  @override
  String objective(String amount) {
    return 'Objective: $amount';
  }

  @override
  String get createGoal => 'Create Goal';

  @override
  String get goalCreated => 'Goal Created';

  @override
  String get analysisAvailable => 'Analysis Available';

  @override
  String get viewChartsPrompt =>
      'Go to the \'Transactions\' tab to see the charts.';

  @override
  String get ticketGenerated => 'Ticket Generated';

  @override
  String get confirmAndSave => 'Confirm and Save';

  @override
  String get balanceActual => 'CURRENT BALANCE';

  @override
  String saveError(String error) {
    return 'Error saving: $error';
  }

  @override
  String get total => 'Total';

  @override
  String get transaction => 'Transaction';

  @override
  String get exportCSV => 'Export';

  @override
  String get amountLabel => 'Amount';

  @override
  String get fastExpenseSuggestion =>
      'Today I earned 3000 and spent 50 on coffee';

  @override
  String get newGoalSuggestion => 'I want to save for a trip';

  @override
  String get aiAnalysisSuggestion =>
      'Give me a strategic analysis of my finances for the next 6 months';

  @override
  String get exportCsvSuggestion => 'Export my transactions to CSV';

  @override
  String get transactionAi => 'AI Transaction';

  @override
  String get goalAiDescription => 'Goal created by AI';

  @override
  String get shareLinkAndCode => 'Share Link and Code';

  @override
  String get onboardingWelcome => 'Welcome to Finance AI';

  @override
  String get onboardingSubtitle =>
      'Let\'s set up your financial profile in a few simple steps.';

  @override
  String get stepBudgetTitle => '3. Your Budget';

  @override
  String get stepBudgetSubtitle =>
      'How much do you plan to spend monthly in total?';

  @override
  String stepBudgetHint(String amount) {
    return 'e.g. $amount';
  }

  @override
  String get monthlyAvailableMoney => 'Monthly Available Money';

  @override
  String get incomeMinusDebts => 'Your income minus your debts.';

  @override
  String get howMuchToAssign => 'How much will you assign to your expenses?';

  @override
  String get budgetLimitInfo =>
      'This will be your monthly limit for expenses outside of your debts.';

  @override
  String get stepSaleTitle => '2. First Sale';

  @override
  String get stepSaleSubtitle => 'Record your first sale or income of the day.';

  @override
  String get stepSaleHint => 'e.g. Product sale';

  @override
  String get stepSourcesTitle => '1. Money Sources';

  @override
  String get stepSourcesSubtitle => 'Add your regular income sources.';

  @override
  String get addSource => 'Add Source';

  @override
  String get sourceName => 'Source name';

  @override
  String get sourceNameHint => 'Salary, Freelance, etc.';

  @override
  String get sourceAmount => 'Amount';

  @override
  String get sourceFrequency => 'Frequency';

  @override
  String get frequencyWeekly => 'Weekly';

  @override
  String get frequencyMonthly => 'Monthly';

  @override
  String get finish => 'Finish';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get onboardingComplete => 'Setup completed!';

  @override
  String get budgetRequired => 'Please enter a valid budget';

  @override
  String get saleRequired => 'Please record your first sale';

  @override
  String get sourcesRequired => 'Please add at least one income source';

  @override
  String get stepDebtTitle => '2. Your Debts';

  @override
  String get stepDebtSubtitle => 'Record your current debts to help us plan.';

  @override
  String get debtsRequired =>
      'Please add at least one debt or enter 0 if you have none.';

  @override
  String get addDebt => 'Add Debt';

  @override
  String get debtName => 'Debt name';

  @override
  String get debtNameHint => 'Credit card, Loan, etc.';

  @override
  String get debtAmount => 'Total amount';

  @override
  String get debtInterest => 'Interest (%)';

  @override
  String get debtDueDate => 'Due date';

  @override
  String get stepGoalTitle => '4. Your Goals';

  @override
  String get stepGoalSubtitle => 'What are you saving for?';

  @override
  String get addGoal => 'Add Goal';

  @override
  String get goalName => 'Goal name';

  @override
  String get goalNameHintOnboarding => 'Trip, Car, Emergencies...';

  @override
  String get goalTarget => 'Target amount';

  @override
  String get onboardingSummary => 'Financial Summary';

  @override
  String get onboardingSummarySubtitle =>
      'This is how your configured finances look.';

  @override
  String get estimatedMonthlyBalance => 'Estimated Monthly Balance';

  @override
  String get totalDebts => 'Total Debts';

  @override
  String get totalGoals => 'Budget for Goals';

  @override
  String get myBudget => 'My Budget';

  @override
  String get budgetUsed => 'Budget Used';

  @override
  String get remainingBudget => 'Remaining';

  @override
  String get debtsTitle => 'My Debts';

  @override
  String get chartBudget => 'Budget';

  @override
  String get chartSavings => 'Savings';

  @override
  String get chartDebt => 'Debt';

  @override
  String get onboardingSummaryExplanation =>
      'This summary shows the relationship between your income, budgeted monthly expenses, and debts. The \'Monthly Balance\' is the free money you have each month to save or invest.';

  @override
  String get totalMonthlyIncome => 'Total Monthly Income';

  @override
  String get monthlyBudgetLimit => 'Monthly Budget Limit';

  @override
  String savingCapacityFormula(Object balance, Object budget, Object income) {
    return 'Income ($income) - Expenses ($budget) = $balance free for goals and emergencies.';
  }

  @override
  String get savingCapacityTitle => 'Your monthly saving capacity';

  @override
  String get debtPayment => 'Monthly payment';

  @override
  String debtPaymentSummary(String interest, String amount) {
    return '$interest% - Payments: $amount';
  }

  @override
  String get debtPaymentHint => 'e.g. 500';

  @override
  String get monthlyDebtCommitment => 'Monthly Debt Commitment';

  @override
  String get realSavingCapacity => 'Real Saving Capacity';

  @override
  String get advisorContext => 'As your financial advisor, I suggest...';

  @override
  String get financialHealthGood =>
      'Your financial health looks solid. You have a positive surplus for your goals.';

  @override
  String get financialHealthWarning =>
      'Attention: Your monthly commitments exceed your income. You need to adjust your budget.';

  @override
  String get netCashFlow => 'Net Cash Flow';

  @override
  String savingCapacityFormulaRefined(
    Object balance,
    Object budget,
    Object debt,
    Object income,
  ) {
    return 'Income ($income) - Expenses ($budget) - Debt Payments ($debt) = $balance free.';
  }

  @override
  String get skip => 'Skip';

  @override
  String get skipOnboardingTitle => 'Skip Setup?';

  @override
  String get skipOnboardingMessage =>
      'If you have already configured your profile before, you can skip this step. Otherwise, we recommend completing it so the AI can give you better advice.';

  @override
  String get monthlyBudgetLabel => 'Monthly Budget';

  @override
  String get addDebtTitle => 'New Debt';

  @override
  String get debtMonthlyPayment => 'Monthly Payment';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get noBudgetSet => 'You haven\'t set a budget yet';

  @override
  String get noDebtsSet => 'No debts registered';

  @override
  String get setupBudget => 'Set Up Budget';

  @override
  String get setupDebts => 'Register Debts';

  @override
  String messageTooLong(int maxLength) {
    return 'Message is too long. Maximum $maxLength characters.';
  }
}
