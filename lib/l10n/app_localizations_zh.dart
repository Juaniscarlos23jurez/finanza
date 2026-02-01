// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get accountSection => '账户';

  @override
  String get personalInfo => '个人信息';

  @override
  String get scheduleReport => '安排报告';

  @override
  String get otherSection => '其他';

  @override
  String get feedback => '反馈';

  @override
  String get termsConditions => '条款和条件';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get logout => '退出登录';

  @override
  String get deleteAccount => '永久删除我的账户';

  @override
  String get deleteAccountTitle => '删除账户？';

  @override
  String get deleteAccountContent => '此操作将结束您当前的会话。';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确认';

  @override
  String get feedbackTitle => '给我们反馈';

  @override
  String get feedbackSubtitle => '您的意见有助于我们改善所有人的体验。';

  @override
  String get feedbackTypeQuestion => '您的评论关于什么？';

  @override
  String get typeSuggestion => '建议';

  @override
  String get typeError => '错误';

  @override
  String get typeCompliment => '赞扬';

  @override
  String get feedbackHint => '告诉我们您喜欢什么或我们可以改进什么...';

  @override
  String get sendFeedback => '发送评论';

  @override
  String get feedbackSuccess => '感谢您的反馈！';

  @override
  String get fullName => '全名';

  @override
  String get email => '电子邮件';

  @override
  String get userId => '用户ID';

  @override
  String get close => '关闭';

  @override
  String get scheduleReportTitle => '安排报告';

  @override
  String get reportDescription => '您将收到包含您的交易和AI生成的财务分析的Excel文件。';

  @override
  String get sendReportTo => '发送报告至：';

  @override
  String get frequencyQuestion => '每多少天？';

  @override
  String daysLoop(int count) {
    return '$count 天';
  }

  @override
  String get confirmAndSchedule => '确认并安排';

  @override
  String get configSaved => '配置已成功保存！';

  @override
  String get language => '语言';

  @override
  String get fillAllFields => '请填写所有必填项';

  @override
  String googleError(String error) {
    return 'Google错误: $error';
  }

  @override
  String appleError(String error) {
    return 'Apple错误: $error';
  }

  @override
  String get welcomeBack => '欢迎\n回来。';

  @override
  String get password => '密码';

  @override
  String get loggingIn => '登录中...';

  @override
  String get login => '登录';

  @override
  String get or => '或';

  @override
  String get loading => '加载中...';

  @override
  String get continueWithGoogle => '使用Google继续';

  @override
  String get continueWithApple => '使用Apple继续';

  @override
  String get dontHaveAccount => '没有账户？ ';

  @override
  String get register => '注册';

  @override
  String get createAccount => '创建\n账户';

  @override
  String get name => '姓名';

  @override
  String get registering => '注册中...';

  @override
  String get signUp => '注册';

  @override
  String get transactions => '交易';

  @override
  String get filterByDate => '按日期筛选';

  @override
  String get ready => '完成';

  @override
  String get all => '全部';

  @override
  String get incomes => '收入';

  @override
  String get expenses => '支出';

  @override
  String get clearDate => '清除日期';

  @override
  String get noDataChart => '无图表数据';

  @override
  String get trend => '趋势（7天）';

  @override
  String get weeklyExpenses => '每周支出';

  @override
  String get weeklyIncome => '每周收入';

  @override
  String get byCategory => '按类别';

  @override
  String get seeFull => '查看全部';

  @override
  String get noTransactions => '无交易';

  @override
  String get opens => '开盘:';

  @override
  String get closes => '收盘:';

  @override
  String get noDescription => '无描述';

  @override
  String get editTransaction => '编辑交易';

  @override
  String get description => '描述';

  @override
  String get amount => '金额';

  @override
  String get date => '日期';

  @override
  String get save => '保存';

  @override
  String get categoryLabel => 'Categoría';

  @override
  String get delete => '删除';

  @override
  String get deleteTransactionConfirm => '您确定要删除此交易吗？';

  @override
  String get transactionDeleted => '交易已删除';

  @override
  String deleteError(String error) {
    return '删除错误: $error';
  }

  @override
  String get today => '今天';

  @override
  String get yesterday => '昨天';

  @override
  String get general => '常规';

  @override
  String get others => '其他';

  @override
  String get dashboard => '仪表板';

  @override
  String get balanceTrend => '余额趋势';

  @override
  String get yourGoals => '您的目标';

  @override
  String get expensesByCategory => '按类别支出';

  @override
  String get recentTransactions => '最近交易';

  @override
  String get noRecentActivity => '无近期活动';

  @override
  String hello(String name) {
    return '你好，$name';
  }

  @override
  String get helloSimple => '你好';

  @override
  String get totalBalance => '总余额';

  @override
  String get newGoal => '新目标';

  @override
  String get goalNameHint => '目标名称（例如：旅行）';

  @override
  String get targetAmountHint => '目标金额（\$）';

  @override
  String get noActiveGoals => '无活跃目标';

  @override
  String get goal => '目标';

  @override
  String get deposit => '存入';

  @override
  String get withdraw => '取出';

  @override
  String get add => '添加';

  @override
  String get withdrawFromGoal => '从目标取出';

  @override
  String get depositToGoal => '存入目标';

  @override
  String get available => '可用';

  @override
  String get saved => '已存';

  @override
  String get remaining => '剩余';

  @override
  String get amountToWithdraw => '提取金额';

  @override
  String get amountToDeposit => '存入金额';

  @override
  String get allAmount => '全部';

  @override
  String get enterValidAmount => '请输入有效金额';

  @override
  String cannotWithdrawMore(String amount) {
    return '提取金额不能超过 \$$amount';
  }

  @override
  String withdrewAmount(String amount, String goal) {
    return '从 \"$goal\" 提取了 \$$amount';
  }

  @override
  String depositedAmount(String amount, String goal) {
    return '向 \"$goal\" 存入了 \$$amount！';
  }

  @override
  String get deleteGoal => '删除目标';

  @override
  String get deleteGoalConfirm => '您确定要删除此目标吗？';

  @override
  String goalAlreadySavedWarning(String amount) {
    return '您已在此目标中存入 \$$amount。';
  }

  @override
  String goalDeleted(String goal) {
    return '目标 \"$goal\" 已删除';
  }

  @override
  String get distribution => '分布';

  @override
  String get noExpensesRegistered => '无支出记录';

  @override
  String get invitationTitle => '邀请！';

  @override
  String invitationBody(String name, String goal) {
    return '$name 邀请您协作目标：$goal';
  }

  @override
  String get invitationQuestion => '您想接受此邀请并分享进度吗？';

  @override
  String get reject => '拒绝';

  @override
  String get accept => '接受';

  @override
  String get invitationAccepted => '邀请已接受';

  @override
  String get unknownUser => '某人';

  @override
  String get defaultGoalName => '一个目标';

  @override
  String get addSaving => '添加储蓄';

  @override
  String get withdrawFunds => '提取资金';

  @override
  String get savingAddedSuccess => '储蓄添加成功';

  @override
  String get insufficientFunds => '余额不足';

  @override
  String get withdrawalSuccess => '提取成功';

  @override
  String get currentBalance => '当前余额';

  @override
  String get progress => '进度';

  @override
  String get invite => '邀请+';

  @override
  String get progressChartComingSoon => '进度图表即将推出！';

  @override
  String get contribution => '贡献';

  @override
  String get withdrawal => '提取';

  @override
  String get goalCreation => '目标创建';

  @override
  String get inviteCollaboratorTitle => '邀请协作伙伴';

  @override
  String get inviteCollaboratorSubtitle => '与他人分享此目标';

  @override
  String get invitationUserCode => '用户代码';

  @override
  String get userCodeHint => '例如：JUAN-1234';

  @override
  String get enterValidCode => '请输入有效的代码';

  @override
  String invitationSentTo(String code) {
    return '邀请已发送至 $code';
  }

  @override
  String get errorSendingInvitation => '发送邀请时出错';

  @override
  String get sendInvitation => '发送邀请';

  @override
  String errorGeneric(String error) {
    return '错误: $error';
  }

  @override
  String get aiThinking => '人工智能正在思考...';

  @override
  String speechError(String error) {
    return '语音错误: $error';
  }

  @override
  String get voiceRecognitionUnavailable => '语音识别不可用';

  @override
  String get listening => '正在倾听...';

  @override
  String get typeHere => '在此输入...';

  @override
  String get assistantGreeting => '你好！我是你的财务助手。';

  @override
  String get assistantDescription => '我可以帮你记录支出、创建目标并使用 AI 分析你的财务状况。';

  @override
  String get questionExamples => '问题示例';

  @override
  String get fastExpense => '快速支出';

  @override
  String get fastExpenseSubtitle => '“赚了 3000，花了 50”';

  @override
  String get newGoalSubtitle => '“为旅行攒钱”';

  @override
  String get iaAnalysis => 'AI 分析';

  @override
  String get iaAnalysisSubtitle => '“6 个月预测”';

  @override
  String get exportSubtitle => '“下载 CSV”';

  @override
  String get finanzasAi => '财务 AI';

  @override
  String get history => '历史记录';

  @override
  String get newChat => '新聊天';

  @override
  String get noSavedConversations => '没有保存的对话。';

  @override
  String get untitledConversation => '无标题对话';

  @override
  String get transactionSavedSuccess => '交易记录成功';

  @override
  String get aiAssistant => 'AI 助手';

  @override
  String get youLabel => '你';

  @override
  String get premiumAnalysis => '高级分析';

  @override
  String get exclusiveContent => '独家可解锁内容。';

  @override
  String get deepAiAnalysis => 'AI 深度分析';

  @override
  String get aiGeneratedAnalysis => '由财务 AI 生成的分析';

  @override
  String get strategicReportInfo => '这份报告包含高价值的战略信息。';

  @override
  String get unlockVideo => '观看视频解锁';

  @override
  String get contentUnlocked => '内容已解锁！';

  @override
  String adLoadError(String error) {
    return '无法加载广告。请重试。($error)';
  }

  @override
  String get csvReady => 'Excel/CSV 报告已就绪';

  @override
  String get reportLocked => '报告已锁定';

  @override
  String get downloadAdPrompt => '观看广告下载';

  @override
  String get shareCsv => '分享 / 保存 CSV';

  @override
  String get shareCsvText => '这是我的财务报告。';

  @override
  String csvShareError(String error) {
    return '分享 CSV 时出错: $error';
  }

  @override
  String get transactionSummary => '交易摘要';

  @override
  String get concept => '项目';

  @override
  String get result => '结果';

  @override
  String get impact => '影响';

  @override
  String get resultingBalance => '最终余额';

  @override
  String get noRecentData => '无近期数据';

  @override
  String multiTransactionTitle(int count) {
    return '$count 笔交易';
  }

  @override
  String saveAllTransactions(int count) {
    return '保存 $count 笔交易';
  }

  @override
  String get allSaved => '已全部保存';

  @override
  String transactionsSavedCount(int count) {
    return '已保存 $count 笔交易';
  }

  @override
  String get goalSuggestion => '目标建议';

  @override
  String objective(String amount) {
    return '目标: $amount';
  }

  @override
  String get createGoal => '创建目标';

  @override
  String get goalCreated => '目标已创建';

  @override
  String get analysisAvailable => '分析可用';

  @override
  String get viewChartsPrompt => '前往“交易”选项卡查看图表。';

  @override
  String get ticketGenerated => '已生成票据';

  @override
  String get confirmAndSave => '确认并保存';

  @override
  String get balanceActual => '当前余额';

  @override
  String saveError(String error) {
    return '保存出错: $error';
  }

  @override
  String get total => '总计';

  @override
  String get transaction => '交易';

  @override
  String get exportCSV => '导出';

  @override
  String get amountLabel => '金额';

  @override
  String get fastExpenseSuggestion => '今天我赚了3000，花了50买咖啡';

  @override
  String get newGoalSuggestion => '我想为旅行攒钱';

  @override
  String get aiAnalysisSuggestion => '请对我未来6个月的财务状况进行战略分析';

  @override
  String get exportCsvSuggestion => '将我的交易导出为 CSV';

  @override
  String get transactionAi => 'AI 交易';

  @override
  String get goalAiDescription => '由 AI 创建的目标';

  @override
  String get shareLinkAndCode => '分享链接和代码';

  @override
  String get onboardingWelcome => 'Bienvenido a Finanzas AI';

  @override
  String get onboardingSubtitle =>
      'Vamos a configurar tu perfil financiero en unos simples pasos.';

  @override
  String get stepBudgetTitle => '1. Tu Presupuesto';

  @override
  String get stepBudgetSubtitle =>
      '¿Cuánto planeas gastar mensualmente en total?';

  @override
  String get stepBudgetHint => 'Ej. 5000';

  @override
  String get stepSaleTitle => '2. Primera Venta';

  @override
  String get stepSaleSubtitle => 'Registra tu primera venta o ingreso del día.';

  @override
  String get stepSaleHint => 'Ej. Venta de producto';

  @override
  String get stepSourcesTitle => '2. Fuentes de Dinero';

  @override
  String get stepSourcesSubtitle => 'Agrega tus fuentes de ingresos regulares.';

  @override
  String get addSource => 'Agregar Fuente';

  @override
  String get sourceName => 'Nombre de la fuente';

  @override
  String get sourceAmount => 'Monto';

  @override
  String get sourceFrequency => 'Frecuencia';

  @override
  String get frequencyWeekly => 'Semanal';

  @override
  String get frequencyMonthly => 'Mensual';

  @override
  String get finish => 'Finalizar';

  @override
  String get next => 'Siguiente';

  @override
  String get back => 'Atrás';

  @override
  String get onboardingComplete => '¡Configuración completada!';

  @override
  String get budgetRequired => 'Por favor ingresa un presupuesto válido';

  @override
  String get saleRequired => 'Por favor registra tu primera venta';

  @override
  String get sourcesRequired =>
      'Por favor agrega al menos una fuente de ingresos';

  @override
  String get stepDebtTitle => '3. Tus Deudas';

  @override
  String get stepDebtSubtitle =>
      'Registra tus deudas actuales para ayudarte a planear.';

  @override
  String get addDebt => 'Agregar Deuda';

  @override
  String get debtName => 'Nombre de la deuda';

  @override
  String get debtAmount => 'Monto total';

  @override
  String get debtInterest => 'Interés (%)';

  @override
  String get debtDueDate => 'Fecha de pago';

  @override
  String get stepGoalTitle => '4. Tus Metas';

  @override
  String get stepGoalSubtitle => '¿Para qué estás ahorrando?';

  @override
  String get addGoal => 'Agregar Meta';

  @override
  String get goalName => 'Nombre de la meta';

  @override
  String get goalTarget => 'Monto objetivo';

  @override
  String get onboardingSummary => 'Resumen Financiero';

  @override
  String get onboardingSummarySubtitle =>
      'Así se ven tus finanzas configuradas.';

  @override
  String get estimatedMonthlyBalance => 'Balance Mensual Estimado';

  @override
  String get totalDebts => 'Deudas Totales';

  @override
  String get totalGoals => 'Presupuesto para Metas';

  @override
  String get myBudget => 'Mi Presupuesto';

  @override
  String get budgetUsed => 'Presupuesto Usado';

  @override
  String get remainingBudget => 'Restante';

  @override
  String get debtsTitle => 'Mis Deudas';

  @override
  String get chartBudget => 'Presupuesto';

  @override
  String get chartSavings => 'Ahorros';

  @override
  String get chartDebt => 'Deuda';

  @override
  String get onboardingSummaryExplanation =>
      'Este resumen muestra la relación entre tus ingresos, gastos mensuales presupuestados y deudas. El \'Balance Mensual\' es el dinero disponible que tienes cada mes para ahorrar o invertir.';

  @override
  String get totalMonthlyIncome => 'Ingreso Mensual Total';

  @override
  String get monthlyBudgetLimit => 'Límite de Presupuesto';

  @override
  String savingCapacityFormula(Object balance, Object budget, Object income) {
    return 'Ingreso ($income) - Gastos ($budget) = $balance libres para metas y emergencias.';
  }

  @override
  String get savingCapacityTitle => 'Tu capacidad de ahorro mensual';

  @override
  String get debtPayment => 'Pago mensual';

  @override
  String get debtPaymentHint => 'Ej. 500';

  @override
  String get monthlyDebtCommitment => 'Compromiso Mensual de Deuda';

  @override
  String get realSavingCapacity => 'Capacidad de Ahorro Real';

  @override
  String get advisorContext => 'Como tu asesor financiero, te sugiero...';

  @override
  String get financialHealthGood =>
      'Tu salud financiera se ve sólida. Tienes un excedente positivo para tus metas.';

  @override
  String get financialHealthWarning =>
      'Atención: Tus compromisos mensuales superan tus ingresos. Necesitas ajustar tu presupuesto.';

  @override
  String get netCashFlow => 'Flujo de Caja Neto';

  @override
  String savingCapacityFormulaRefined(
    Object balance,
    Object budget,
    Object debt,
    Object income,
  ) {
    return 'Ingresos ($income) - Gastos ($budget) - Pagos Deuda ($debt) = $balance libres.';
  }
}
