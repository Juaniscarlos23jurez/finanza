// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get accountSection => 'ACCOUNT';

  @override
  String get personalInfo => 'Informazioni Personali';

  @override
  String get scheduleReport => 'Programma Rapporto';

  @override
  String get otherSection => 'ALTRO';

  @override
  String get feedback => 'Feedback';

  @override
  String get termsConditions => 'Termini e Condizioni';

  @override
  String get privacyPolicy => 'Informativa sulla Privacy';

  @override
  String get logout => 'Disconnettersi';

  @override
  String get deleteAccount => 'Elimina il mio account in modo permanente';

  @override
  String get deleteAccountTitle => 'Eliminare l\'account?';

  @override
  String get deleteAccountContent =>
      'Questa azione terminerà la tua sessione corrente.';

  @override
  String get cancel => 'Annulla';

  @override
  String get confirm => 'Conferma';

  @override
  String get feedbackTitle => 'Dacci il tuo Feedback';

  @override
  String get feedbackSubtitle =>
      'La tua opinione ci aiuta a migliorare l\'esperienza per tutti.';

  @override
  String get feedbackTypeQuestion => 'Di cosa tratta il tuo commento?';

  @override
  String get typeSuggestion => 'Suggerimento';

  @override
  String get typeError => 'Errore';

  @override
  String get typeCompliment => 'Complimento';

  @override
  String get feedbackHint =>
      'Dicci cosa ti piace o cosa possiamo migliorare...';

  @override
  String get sendFeedback => 'Invia Commenti';

  @override
  String get feedbackSuccess => 'Grazie per il tuo feedback!';

  @override
  String get fullName => 'Nome Completo';

  @override
  String get email => 'E-mail';

  @override
  String get userId => 'ID Utente';

  @override
  String get close => 'Chiudi';

  @override
  String get scheduleReportTitle => 'Programma Rapporto';

  @override
  String get reportDescription =>
      'Riceverai un file Excel con le tue transazioni e un\'analisi finanziaria generata dall\'IA.';

  @override
  String get sendReportTo => 'Invia rapporto a:';

  @override
  String get frequencyQuestion => 'Ogni quanti giorni?';

  @override
  String daysLoop(int count) {
    return '$count giorni';
  }

  @override
  String get confirmAndSchedule => 'Conferma e Programma';

  @override
  String get configSaved => 'Configurazione salvata con successo!';

  @override
  String get language => 'Lingua';

  @override
  String get fillAllFields => 'Si prega di compilare tutti i campi';

  @override
  String googleError(String error) {
    return 'Errore Google: $error';
  }

  @override
  String appleError(String error) {
    return 'Errore Apple: $error';
  }

  @override
  String get welcomeBack => 'Bentornato.';

  @override
  String get password => 'Password';

  @override
  String get loggingIn => 'Accesso in corso...';

  @override
  String get login => 'Accedi';

  @override
  String get or => 'O';

  @override
  String get loading => 'Caricamento...';

  @override
  String get continueWithGoogle => 'Continua con Google';

  @override
  String get continueWithApple => 'Continua con Apple';

  @override
  String get dontHaveAccount => 'Non hai un account? ';

  @override
  String get register => 'Registrati';

  @override
  String get createAccount => 'Crea\nAccount.';

  @override
  String get name => 'Nome';

  @override
  String get registering => 'Registrazione in corso...';

  @override
  String get signUp => 'Registrati';

  @override
  String get transactions => 'Transazioni';

  @override
  String get filterByDate => 'Filtra per Data';

  @override
  String get ready => 'Fatto';

  @override
  String get all => 'Tutti';

  @override
  String get incomes => 'Entrate';

  @override
  String get expenses => 'Uscite';

  @override
  String get clearDate => 'Cancella Data';

  @override
  String get noDataChart => 'Nessun dato da mostrare';

  @override
  String get trend => 'Tendenza (7 giorni)';

  @override
  String get weeklyExpenses => 'Spese Settimanali';

  @override
  String get weeklyIncome => 'Entrate Settimanali';

  @override
  String get byCategory => 'Per Categoria';

  @override
  String get seeFull => 'Vedi Tutto';

  @override
  String get noTransactions => 'Nessuna transazione';

  @override
  String get opens => 'Apre:';

  @override
  String get closes => 'Chiude:';

  @override
  String get noDescription => 'Nessuna descrizione';

  @override
  String get editTransaction => 'Modifica Transazione';

  @override
  String get description => 'Descrizione';

  @override
  String get amount => 'Importo';

  @override
  String get date => 'Data';

  @override
  String get save => 'Salva';

  @override
  String get categoryLabel => 'Categoría';

  @override
  String get delete => 'Elimina';

  @override
  String get deleteTransactionConfirm =>
      'Sei sicuro di voler eliminare questa transazione?';

  @override
  String get transactionDeleted => 'Transazione eliminata';

  @override
  String deleteError(String error) {
    return 'Errore eliminazione: $error';
  }

  @override
  String get today => 'Oggi';

  @override
  String get yesterday => 'Ieri';

  @override
  String get general => 'Generale';

  @override
  String get others => 'Altri';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get balanceTrend => 'Tendenza del Saldo';

  @override
  String get yourGoals => 'I Tuoi Obiettivi';

  @override
  String get expensesByCategory => 'Spese per Categoria';

  @override
  String get recentTransactions => 'Transazioni Recenti';

  @override
  String get noRecentActivity => 'Nessuna attività recente';

  @override
  String hello(String name) {
    return 'Ciao, $name';
  }

  @override
  String get helloSimple => 'Ciao';

  @override
  String get totalBalance => 'SALDO TOTALE';

  @override
  String get newGoal => 'Nuovo Obiettivo';

  @override
  String get goalNameHint => 'Nome Obiettivo (es. Viaggio)';

  @override
  String get targetAmountHint => 'Importo Target (\$)';

  @override
  String get noActiveGoals => 'Nessun obiettivo attivo';

  @override
  String get goal => 'Obiettivo';

  @override
  String get deposit => 'Deposita';

  @override
  String get withdraw => 'Preleva';

  @override
  String get add => 'Aggiungi';

  @override
  String get withdrawFromGoal => 'Preleva dall\'Obiettivo';

  @override
  String get depositToGoal => 'Deposita nell\'Obiettivo';

  @override
  String get available => 'Disponibile';

  @override
  String get saved => 'Risparmiato';

  @override
  String get remaining => 'Rimanente';

  @override
  String get amountToWithdraw => 'Importo da prelevare';

  @override
  String get amountToDeposit => 'Importo da depositare';

  @override
  String get allAmount => 'Tutto';

  @override
  String get enterValidAmount => 'Inserisci un importo valido';

  @override
  String cannotWithdrawMore(String amount) {
    return 'Non puoi prelevare più di \$$amount';
  }

  @override
  String withdrewAmount(String amount, String goal) {
    return 'Prelevati \$$amount da \"$goal\"';
  }

  @override
  String depositedAmount(String amount, String goal) {
    return 'Depositati \$$amount in \"$goal\"!';
  }

  @override
  String get deleteGoal => 'Elimina Obiettivo';

  @override
  String get deleteGoalConfirm =>
      'Sei sicuro di voler eliminare questo obiettivo?';

  @override
  String goalAlreadySavedWarning(String amount) {
    return 'Hai già risparmiato \$$amount in questo obiettivo.';
  }

  @override
  String goalDeleted(String goal) {
    return 'Obiettivo \"$goal\" eliminato';
  }

  @override
  String get distribution => 'Distribuzione';

  @override
  String get noExpensesRegistered => 'Nessuna spesa registrata';

  @override
  String get invitationTitle => 'Invito!';

  @override
  String invitationBody(String name, String goal) {
    return '$name ti ha invitato a collaborare a: $goal';
  }

  @override
  String get invitationQuestion =>
      'Vuoi accettare questo invito e condividere i progressi?';

  @override
  String get reject => 'Rifiuta';

  @override
  String get accept => 'Accetta';

  @override
  String get invitationAccepted => 'Invito accettato';

  @override
  String get unknownUser => 'Qualcuno';

  @override
  String get defaultGoalName => 'un obiettivo';

  @override
  String get addSaving => 'Aggiungi Risparmio';

  @override
  String get withdrawFunds => 'Preleva Fondi';

  @override
  String get savingAddedSuccess => 'Risparmio aggiunto con successo';

  @override
  String get insufficientFunds => 'Fondi insufficienti';

  @override
  String get withdrawalSuccess => 'Prelievo effettuato con successo';

  @override
  String get currentBalance => 'Saldo attuale';

  @override
  String get progress => 'Progresso';

  @override
  String get invite => 'Invita+';

  @override
  String get progressChartComingSoon =>
      'Grafico di progressione disponibile a breve!';

  @override
  String get contribution => 'Contributo';

  @override
  String get withdrawal => 'Prelievo';

  @override
  String get goalCreation => 'Creazione obiettivo';

  @override
  String get inviteCollaboratorTitle => 'Invita Collaboratore';

  @override
  String get inviteCollaboratorSubtitle =>
      'Condividi questo obiettivo con qualcun altro';

  @override
  String get invitationUserCode => 'Codice Utente';

  @override
  String get userCodeHint => 'es. JUAN-1234';

  @override
  String get enterValidCode => 'Inserisci un codice valido';

  @override
  String invitationSentTo(String code) {
    return 'Invito inviato a $code';
  }

  @override
  String get errorSendingInvitation => 'Errore nell\'invio dell\'invito';

  @override
  String get sendInvitation => 'Invia Invito';

  @override
  String errorGeneric(String error) {
    return 'Errore: $error';
  }

  @override
  String get aiThinking => 'L\'IA sta pensando...';

  @override
  String speechError(String error) {
    return 'Errore vocale: $error';
  }

  @override
  String get voiceRecognitionUnavailable =>
      'Riconoscimento vocale non disponibile';

  @override
  String get listening => 'Ascolto...';

  @override
  String get typeHere => 'Scrivi qui...';

  @override
  String get assistantGreeting => 'Ciao! Sono il tuo assistente finanziario.';

  @override
  String get assistantDescription =>
      'Posso aiutarti a registrare le spese, creare obiettivi e analizzare le tue finanze con l\'IA.';

  @override
  String get questionExamples => 'ESEMPI DI DOMANDE';

  @override
  String get fastExpense => 'Spesa Rapida';

  @override
  String get fastExpenseSubtitle => '\"Guadagnato 3000 e speso 50\"';

  @override
  String get newGoalSubtitle => '\"Risparmiare per un viaggio\"';

  @override
  String get iaAnalysis => 'Analisi IA';

  @override
  String get iaAnalysisSubtitle => '\"Proiezione a 6 mesi\"';

  @override
  String get exportSubtitle => '\"Scarica CSV\"';

  @override
  String get finanzasAi => 'FINANZA IA';

  @override
  String get history => 'CRONOLOGIA';

  @override
  String get newChat => 'Nuova Chat';

  @override
  String get noSavedConversations => 'Nessuna conversazione salvata.';

  @override
  String get untitledConversation => 'Conversazione senza titolo';

  @override
  String get transactionSavedSuccess => 'Movimento registrato correttamente';

  @override
  String get aiAssistant => 'ASSISTENTE IA';

  @override
  String get youLabel => 'TU';

  @override
  String get premiumAnalysis => 'Analisi Premium';

  @override
  String get exclusiveContent => 'Contenuto esclusivo sbloccabile.';

  @override
  String get deepAiAnalysis => 'Analisi approfondita con IA';

  @override
  String get aiGeneratedAnalysis => 'Analisi generata da Finanza IA';

  @override
  String get strategicReportInfo =>
      'Questo rapporto contiene informazioni strategiche di alto valore.';

  @override
  String get unlockVideo => 'Guarda il Video per Sbloccare';

  @override
  String get contentUnlocked => 'Contenuto sbloccato!';

  @override
  String adLoadError(String error) {
    return 'Impossibile caricare l\'annuncio. Riprova. ($error)';
  }

  @override
  String get csvReady => 'Report Excel/CSV pronto';

  @override
  String get reportLocked => 'Report bloccato';

  @override
  String get downloadAdPrompt => 'Guarda un annuncio per scaricare';

  @override
  String get shareCsv => 'Condividi / Salva CSV';

  @override
  String get shareCsvText => 'Ecco il mio rapporto finanziario.';

  @override
  String csvShareError(String error) {
    return 'Errore nella condivisione del CSV: $error';
  }

  @override
  String get transactionSummary => 'Riepilogo Movimenti';

  @override
  String get concept => 'Concetto';

  @override
  String get result => 'Risultato';

  @override
  String get impact => 'Impatto';

  @override
  String get resultingBalance => 'Saldo Risultante';

  @override
  String get noRecentData => 'Nessun dato recente';

  @override
  String multiTransactionTitle(int count) {
    return '$count Transazioni';
  }

  @override
  String saveAllTransactions(int count) {
    return 'Salva $count Transazioni';
  }

  @override
  String get allSaved => 'Tutto salvato';

  @override
  String transactionsSavedCount(int count) {
    return '$count transazioni salvate';
  }

  @override
  String get goalSuggestion => 'Suggerimento Obiettivo';

  @override
  String objective(String amount) {
    return 'Obiettivo: $amount';
  }

  @override
  String get createGoal => 'Crea Obiettivo';

  @override
  String get goalCreated => 'Obiettivo creato';

  @override
  String get analysisAvailable => 'Analisi disponibile';

  @override
  String get viewChartsPrompt =>
      'Vai alla scheda \'Movimenti\' per vedere i grafici.';

  @override
  String get ticketGenerated => 'Ticket Generato';

  @override
  String get confirmAndSave => 'Conferma e Salva';

  @override
  String get balanceActual => 'SALDO ATTUALE';

  @override
  String saveError(String error) {
    return 'Errore durante il salvataggio: $error';
  }

  @override
  String get total => 'Totale';

  @override
  String get transaction => 'Movimento';

  @override
  String get exportCSV => 'Esporta';

  @override
  String get amountLabel => 'Importo';

  @override
  String get fastExpenseSuggestion =>
      'Oggi ho guadagnato 3000 e speso 50 per il caffè';

  @override
  String get newGoalSuggestion => 'Voglio risparmiare per un viaggio';

  @override
  String get aiAnalysisSuggestion =>
      'Fammi un\'analisi strategica delle mie finanze per i prossimi 6 mesi';

  @override
  String get exportCsvSuggestion => 'Esporta i miei movimenti in CSV';

  @override
  String get transactionAi => 'Movimento IA';

  @override
  String get goalAiDescription => 'Obiettivo creato dall\'IA';

  @override
  String get shareLinkAndCode => 'Condividi link e codice';

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
