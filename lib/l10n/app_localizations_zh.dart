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
  String get aiThinking => 'La IA está pensando...';

  @override
  String speechError(String error) {
    return 'Error de voz: $error';
  }

  @override
  String get voiceRecognitionUnavailable =>
      'Reconocimiento de voz no disponible';

  @override
  String get listening => 'Escuchando...';

  @override
  String get typeHere => 'Escribe aquí...';

  @override
  String get assistantGreeting => '¡Hola! Soy tu asistente financiero.';

  @override
  String get assistantDescription =>
      'Puedo ayudarte a registrar gastos, crear metas y analizar tus finanzas con IA.';

  @override
  String get questionExamples => 'EJEMPLOS DE PREGUNTAS';

  @override
  String get fastExpense => 'Gasto Rápido';

  @override
  String get fastExpenseSubtitle => '\"Gané 3000 y gasté 50\"';

  @override
  String get newGoalSubtitle => '\"Ahorrar para viaje\"';

  @override
  String get iaAnalysis => 'Análisis IA';

  @override
  String get iaAnalysisSubtitle => '\"Proyección 6 meses\"';

  @override
  String get exportSubtitle => '\"Descargar CSV\"';

  @override
  String get finanzasAi => 'FINANZAS AI';

  @override
  String get history => 'HISTORIAL';

  @override
  String get newChat => 'Nuevo Chat';

  @override
  String get noSavedConversations => 'No hay conversaciones guardadas.';

  @override
  String get untitledConversation => 'Conversación sin título';

  @override
  String get transactionSavedSuccess => 'Movimiento registrado correctamente';

  @override
  String get aiAssistant => 'ASISTENTE IA';

  @override
  String get youLabel => 'TÚ';

  @override
  String get premiumAnalysis => 'Análisis Premium';

  @override
  String get exclusiveContent => 'Contenido exclusivo desbloqueable.';

  @override
  String get deepAiAnalysis => 'Análisis Profundo con IA';

  @override
  String get aiGeneratedAnalysis => 'Análisis generado por Finanzas AI';

  @override
  String get strategicReportInfo =>
      'Este reporte contiene información estratégica de alto valor.';

  @override
  String get unlockVideo => 'Ver Video para Desbloquear';

  @override
  String get contentUnlocked => '¡Contenido desbloqueado!';

  @override
  String adLoadError(String error) {
    return 'No se pudo cargar el anuncio. Intenta de nuevo. ($error)';
  }

  @override
  String get csvReady => 'Reporte Excel/CSV Listo';

  @override
  String get reportLocked => 'Reporte Bloqueado';

  @override
  String get downloadAdPrompt => 'Ve un anuncio para descargar';

  @override
  String get shareCsv => 'Compartir / Guardar CSV';

  @override
  String get shareCsvText => 'Aquí tienes mi reporte financiero.';

  @override
  String csvShareError(String error) {
    return 'Error al compartir CSV: $error';
  }

  @override
  String get transactionSummary => 'Resumen de Movimientos';

  @override
  String get concept => 'Concepto';

  @override
  String get result => 'Resultó';

  @override
  String get impact => 'Impacto';

  @override
  String get resultingBalance => 'Balance Resultante';

  @override
  String get noRecentData => 'Sin datos recientes';

  @override
  String multiTransactionTitle(int count) {
    return '$count Transacciones';
  }

  @override
  String saveAllTransactions(int count) {
    return 'Guardar $count Transacciones';
  }

  @override
  String get allSaved => 'Todo Guardado';

  @override
  String transactionsSavedCount(int count) {
    return '$count transacciones guardadas';
  }

  @override
  String get goalSuggestion => 'Sugerencia de Meta';

  @override
  String objective(String amount) {
    return 'Objetivo: $amount';
  }

  @override
  String get createGoal => 'Crear Meta';

  @override
  String get goalCreated => 'Meta Creada';

  @override
  String get analysisAvailable => 'Análisis Disponible';

  @override
  String get viewChartsPrompt =>
      'Ve a la pestaña \"Movimientos\" para ver los gráficos.';

  @override
  String get ticketGenerated => 'Ticket Generado';

  @override
  String get confirmAndSave => 'Confirmar y Guardar';

  @override
  String get balanceActual => 'BALANCE ACTUAL';
}
