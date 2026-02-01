// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get accountSection => 'CUENTA';

  @override
  String get personalInfo => 'Información Personal';

  @override
  String get scheduleReport => 'Programar Envío de Reporte';

  @override
  String get otherSection => 'OTRO';

  @override
  String get feedback => 'Feedback';

  @override
  String get termsConditions => 'Términos y Condiciones';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get deleteAccount => 'Eliminar mi cuenta permanentemente';

  @override
  String get deleteAccountTitle => '¿Eliminar cuenta?';

  @override
  String get deleteAccountContent => 'Esta acción cerrará tu sesión actual.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get feedbackTitle => 'Danos tu Feedback';

  @override
  String get feedbackSubtitle =>
      'Tu opinión nos ayuda a mejorar la experiencia para todos.';

  @override
  String get feedbackTypeQuestion => '¿De qué trata tu comentario?';

  @override
  String get typeSuggestion => 'Sugerencia';

  @override
  String get typeError => 'Error';

  @override
  String get typeCompliment => 'Felicitación';

  @override
  String get feedbackHint => 'Cuéntanos qué te gusta o qué podemos mejorar...';

  @override
  String get sendFeedback => 'Enviar Comentarios';

  @override
  String get feedbackSuccess => '¡Gracias por tu feedback!';

  @override
  String get fullName => 'Nombre Completo';

  @override
  String get email => 'Correo Electrónico';

  @override
  String get userId => 'ID de Usuario';

  @override
  String get close => 'Cerrar';

  @override
  String get scheduleReportTitle => 'Programar Reporte';

  @override
  String get reportDescription =>
      'Recibirás un Excel con tus movimientos y un análisis financiero generado por IA.';

  @override
  String get sendReportTo => 'Enviar reporte a:';

  @override
  String get frequencyQuestion => '¿Cada cuántos días?';

  @override
  String daysLoop(int count) {
    return '$count días';
  }

  @override
  String get confirmAndSchedule => 'Confirmar y Programar';

  @override
  String get configSaved => '¡Configuración guardada con éxito!';

  @override
  String get language => 'Idioma';

  @override
  String get fillAllFields => 'Por favor llena todos los campos';

  @override
  String googleError(String error) {
    return 'Error con Google:';
  }

  @override
  String appleError(String error) {
    return 'Error con Apple:';
  }

  @override
  String get welcomeBack => 'Bienvenido\nde nuevo.';

  @override
  String get password => 'Contraseña';

  @override
  String get loggingIn => 'Iniciando sesión...';

  @override
  String get login => 'Iniciar Sesión';

  @override
  String get or => 'O';

  @override
  String get loading => 'Cargando...';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get continueWithApple => 'Continuar con Apple';

  @override
  String get dontHaveAccount => '¿No tienes cuenta? ';

  @override
  String get register => 'Regístrate';

  @override
  String get createAccount => 'Crear\nCuenta.';

  @override
  String get name => 'Nombre';

  @override
  String get registering => 'Registrando...';

  @override
  String get signUp => 'Registrarse';

  @override
  String get transactions => 'Movimientos';

  @override
  String get filterByDate => 'Filtrar por Fecha';

  @override
  String get ready => 'Listo';

  @override
  String get all => 'Todos';

  @override
  String get incomes => 'Ingresos';

  @override
  String get expenses => 'Gastos';

  @override
  String get clearDate => 'Limpiar Fecha';

  @override
  String get noDataChart => 'No hay datos para graficar';

  @override
  String get trend => 'Tendencia (7 días)';

  @override
  String get weeklyExpenses => 'Gastos Semanales';

  @override
  String get weeklyIncome => 'Ingresos Semanales';

  @override
  String get byCategory => 'Por Categoría';

  @override
  String get seeFull => 'Ver completo';

  @override
  String get noTransactions => 'No hay movimientos';

  @override
  String get opens => 'Abre:';

  @override
  String get closes => 'Cierra:';

  @override
  String get noDescription => 'Sin descripción';

  @override
  String get editTransaction => 'Editar Movimiento';

  @override
  String get description => 'Descripción';

  @override
  String get amount => 'Monto';

  @override
  String get date => 'Fecha';

  @override
  String get save => 'Guardar';

  @override
  String get categoryLabel => 'Categoría';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteTransactionConfirm =>
      '¿Estás seguro de eliminar este movimiento?';

  @override
  String get transactionDeleted => 'Movimiento eliminado';

  @override
  String deleteError(String error) {
    return 'Error al eliminar:';
  }

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String get general => 'General';

  @override
  String get others => 'Otros';

  @override
  String get dashboard => 'Panel de Control';

  @override
  String get balanceTrend => 'Movimiento de Balance';

  @override
  String get yourGoals => 'Tus Metas';

  @override
  String get expensesByCategory => 'Gastos por Categoría';

  @override
  String get recentTransactions => 'Movimientos Recientes';

  @override
  String get noRecentActivity => 'Sin actividad reciente';

  @override
  String hello(String name) {
    return 'Hola, $name';
  }

  @override
  String get helloSimple => 'Hola';

  @override
  String get totalBalance => 'SALDO TOTAL';

  @override
  String get newGoal => 'Nueva Meta';

  @override
  String get goalNameHint => 'Nombre de la meta (ej. Viaje)';

  @override
  String get targetAmountHint => 'Monto objetivo (\$)';

  @override
  String get noActiveGoals => 'No tienes metas activas';

  @override
  String get goal => 'Meta';

  @override
  String get deposit => 'Abonar';

  @override
  String get withdraw => 'Retirar';

  @override
  String get add => 'Añadir';

  @override
  String get withdrawFromGoal => 'Retirar de Meta';

  @override
  String get depositToGoal => 'Abonar a Meta';

  @override
  String get available => 'Disponible';

  @override
  String get saved => 'Ahorrado';

  @override
  String get remaining => 'Restante';

  @override
  String get amountToWithdraw => 'Monto a retirar';

  @override
  String get amountToDeposit => 'Monto a abonar';

  @override
  String get allAmount => 'Todo';

  @override
  String get enterValidAmount => 'Ingresa un monto válido';

  @override
  String cannotWithdrawMore(String amount) {
    return 'No puedes retirar más de \$$amount';
  }

  @override
  String withdrewAmount(String amount, String goal) {
    return 'Retiraste \$$amount de \"$goal\"';
  }

  @override
  String depositedAmount(String amount, String goal) {
    return '¡Abonaste \$$amount a \"$goal\"!';
  }

  @override
  String get deleteGoal => 'Eliminar Meta';

  @override
  String get deleteGoalConfirm => '¿Estás seguro de eliminar esta meta?';

  @override
  String goalAlreadySavedWarning(String amount) {
    return 'Ya tienes \$$amount ahorrados en esta meta.';
  }

  @override
  String goalDeleted(String goal) {
    return 'Meta \"$goal\" eliminada';
  }

  @override
  String get distribution => 'Distribución';

  @override
  String get noExpensesRegistered => 'No hay gastos registrados';

  @override
  String get invitationTitle => '¡Invitación!';

  @override
  String invitationBody(String name, String goal) {
    return '$name te ha invitado a colaborar en la meta: $goal';
  }

  @override
  String get invitationQuestion =>
      '¿Deseas aceptar esta invitación y compartir el progreso?';

  @override
  String get reject => 'Rechazar';

  @override
  String get accept => 'Aceptar';

  @override
  String get invitationAccepted => 'Invitación aceptada';

  @override
  String get unknownUser => 'Alguien';

  @override
  String get defaultGoalName => 'una meta';

  @override
  String get addSaving => 'Añadir Ahorro';

  @override
  String get withdrawFunds => 'Retirar Fondos';

  @override
  String get savingAddedSuccess => 'Ahorro añadido exitosamente';

  @override
  String get insufficientFunds => 'Fondos insuficientes';

  @override
  String get withdrawalSuccess => 'Retiro realizado exitosamente';

  @override
  String get currentBalance => 'Saldo actual';

  @override
  String get progress => 'Progreso';

  @override
  String get invite => 'Invitar+';

  @override
  String get progressChartComingSoon => '¡Gráfica de progreso próximamente!';

  @override
  String get contribution => 'Contribución';

  @override
  String get withdrawal => 'Retiro';

  @override
  String get goalCreation => 'Creación de meta';

  @override
  String get inviteCollaboratorTitle => 'Invitar Colaborador';

  @override
  String get inviteCollaboratorSubtitle => 'Comparte esta meta con alguien más';

  @override
  String get invitationUserCode => 'Código de Usuario';

  @override
  String get userCodeHint => 'ej. JUAN-1234';

  @override
  String get enterValidCode => 'Ingresa un código válido';

  @override
  String invitationSentTo(String code) {
    return 'Invitación enviada a $code';
  }

  @override
  String get errorSendingInvitation => 'Error al enviar invitación';

  @override
  String get sendInvitation => 'Enviar Invitación';

  @override
  String errorGeneric(String error) {
    return 'Error:';
  }

  @override
  String get aiThinking => 'La IA está pensando...';

  @override
  String speechError(String error) {
    return 'Error de voz:';
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
    return 'Error al compartir CSV:';
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
  String get balanceActual => 'SALDO ACTUAL';

  @override
  String saveError(String error) {
    return 'Error al guardar:';
  }

  @override
  String get total => 'Total';

  @override
  String get transaction => 'Transacción';

  @override
  String get exportCSV => 'Exportar';

  @override
  String get amountLabel => 'Monto';

  @override
  String get fastExpenseSuggestion => 'Hoy gané 3000 y gasté 50 en café';

  @override
  String get newGoalSuggestion => 'Quiero ahorrar para un viaje';

  @override
  String get aiAnalysisSuggestion =>
      'Hazme un análisis estratégico de mis finanzas para los próximos 6 meses';

  @override
  String get exportCsvSuggestion => 'Exportar mis movimientos a CSV';

  @override
  String get transactionAi => 'Transacción AI';

  @override
  String get goalAiDescription => 'Meta creada por AI';

  @override
  String get shareLinkAndCode => 'Compartir Enlace y Código';

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
