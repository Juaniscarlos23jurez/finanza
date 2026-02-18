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
  String get paymentMethod => 'Detalles del Pago';

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
  String get onboardingWelcome => 'Benvenuto in Finanze IA';

  @override
  String get onboardingSubtitle =>
      'Configuriamo il tuo profilo finanziario in pochi semplici passaggi.';

  @override
  String get stepBudgetTitle => '3. Il tuo budget';

  @override
  String get stepBudgetSubtitle =>
      'Quanto pensi di spendere mensilmente in totale?';

  @override
  String stepBudgetHint(String amount) {
    return 'es. $amount';
  }

  @override
  String get monthlyAvailableMoney => 'Soldi mensili disponibili';

  @override
  String get incomeMinusDebts => 'Il tuo reddito meno i tuoi debiti.';

  @override
  String get howMuchToAssign => 'Quanto assegnerai alle tue spese?';

  @override
  String get budgetLimitInfo =>
      'Questo sarà il tuo limite mensule per le spese al di fuori dei tuoi debiti.';

  @override
  String get stepSaleTitle => '2. Primera Venta';

  @override
  String get stepSaleSubtitle => 'Registra tu primera venta o ingreso del día.';

  @override
  String get stepSaleHint => 'Ej. Venta de producto';

  @override
  String get stepSourcesTitle => '1. Fonti di denaro';

  @override
  String get stepSourcesSubtitle =>
      'Aggiungi le tue fonti di reddito regolari.';

  @override
  String get addSource => 'Agregar Fuente';

  @override
  String get sourceName => 'Nombre de la fuente';

  @override
  String get sourceNameHint => 'Sueldo, Freelance, etc.';

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
  String get stepDebtTitle => '2. I tuoi debiti';

  @override
  String get stepDebtSubtitle =>
      'Registra i tuoi debiti attuali per aiutarci a pianificare.';

  @override
  String get debtsRequired =>
      'Per favore aggiungi almeno un debito o inserisci 0 se non ne hai.';

  @override
  String get addDebt => 'Agregar Deuda';

  @override
  String get debtName => 'Nombre de la deuda';

  @override
  String get debtNameHint => 'Tarjeta de crédito, Préstamo, etc.';

  @override
  String get debtAmount => 'Monto total';

  @override
  String get debtInterest => 'Interés (%)';

  @override
  String get debtDueDate => 'Fecha de pago';

  @override
  String get stepGoalTitle => '4. I tuoi obiettivi';

  @override
  String get stepGoalSubtitle => 'Per cosa stai risparmiando?';

  @override
  String get addGoal => 'Agregar Meta';

  @override
  String get goalName => 'Nombre de la meta';

  @override
  String get goalNameHintOnboarding => 'Viaje, Carro, Emergencias...';

  @override
  String get goalTarget => 'Monto objetivo';

  @override
  String get onboardingSummary => 'Riepilogo finanziario';

  @override
  String get onboardingSummarySubtitle =>
      'Ecco come appaiono le tue finanze configurate.';

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
  String get totalMonthlyIncome => 'Reddito mensile totale';

  @override
  String get monthlyBudgetLimit => 'Limite budget mensile';

  @override
  String savingCapacityFormula(Object balance, Object budget, Object income) {
    return 'Ingreso ($income) - Gastos ($budget) = $balance libres para metas y emergencias.';
  }

  @override
  String get savingCapacityTitle => 'Tu capacidad de ahorro mensual';

  @override
  String get debtPayment => 'Pago mensual';

  @override
  String debtPaymentSummary(String interest, String amount) {
    return '$interest% - Pagamenti: $amount';
  }

  @override
  String get debtPaymentHint => 'Ej. 500';

  @override
  String get monthlyDebtCommitment => 'Compromiso Mensual de Deuda';

  @override
  String get realSavingCapacity => 'Capacità di risparmio reale';

  @override
  String get advisorContext =>
      'Come tuo consulente finanziario, ti suggerisco...';

  @override
  String get financialHealthGood =>
      'La tua salute finanziaria sembra solida. Hai un surplus positivo per i tuoi obiettivi.';

  @override
  String get financialHealthWarning =>
      'Attenzione: i tuoi impegni mensili superano il tuo reddito. Devi aggiustare il tuo budget.';

  @override
  String get netCashFlow => 'Flujo de Caja Neto';

  @override
  String savingCapacityFormulaRefined(
    Object balance,
    Object budget,
    Object debt,
    Object income,
  ) {
    return 'Reddito ($income) - Spese ($budget) - Pagamenti debito ($debt) = $balance liberi.';
  }

  @override
  String get skip => 'Saltar';

  @override
  String get skipOnboardingTitle => '¿Saltar configuración?';

  @override
  String get skipOnboardingMessage =>
      'Si ya configuraste tu perfil anteriormente, puedes saltar este paso. De lo contrario, te recomendamos completarlo para que la IA pueda darte mejores consejos.';

  @override
  String get monthlyBudgetLabel => 'Monthly Budget';

  @override
  String get addDebtTitle => 'New Debt';

  @override
  String get debtMonthlyPayment => 'Monthly Payment';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get noBudgetSet => 'Aún no tienes un presupuesto configurado';

  @override
  String get noDebtsSet => 'No has registrado deudas';

  @override
  String get setupBudget => 'Configurar Presupuesto';

  @override
  String get setupDebts => 'Registrar Deudas';

  @override
  String messageTooLong(int maxLength) {
    return 'El mensaje es demasiado largo. Máximo $maxLength caracteres.';
  }

  @override
  String get aiErrorTitle => 'Error de Procesamiento';

  @override
  String get aiErrorMessage =>
      'La respuesta de la IA llegó con un formato incorrecto. Por favor intenta preguntar de nuevo.';

  @override
  String get updateAvailable => 'Actualización disponible';

  @override
  String get mandatoryUpdate => 'Actualización obligatoria';

  @override
  String updateMessageOptional(String version) {
    return 'Hay una nueva versión disponible ($version). ¿Deseas actualizar ahora?';
  }

  @override
  String updateMessageMandatory(String version) {
    return 'No puedes continuar utilizando la aplicación con esta versión. Debes actualizar a la versión $version.';
  }

  @override
  String get later => 'Más tarde';

  @override
  String get update => 'Actualizar';

  @override
  String get aiConsentTitle => 'Uso de inteligencia artificial';

  @override
  String get aiConsentDisclosure =>
      'Esta app envía el contenido que escribes a un servicio de inteligencia artificial de terceros (Google Gemini) para generar respuestas.\n\nLos datos enviados pueden incluir texto que ingreses en la app.\n\nGoogle procesa estos datos de acuerdo con su política de privacidad.\n\n¿Aceptas que tus datos sean enviados a este servicio?';

  @override
  String get aiConsentDeclineConfirmTitle => '¿Estás seguro?';

  @override
  String get aiConsentDeclineConfirmBody =>
      'Al rechazar, no podrás usar las funciones de inteligencia artificial para registrar gastos con voz o texto, ni recibir consejos personalizados.';

  @override
  String get aiConsentDeclineConfirmProceed => 'Continuar sin IA';

  @override
  String get aiConsentDeclineConfirmStay => 'Volver';

  @override
  String get manualEntryTitle => 'Registro Manual';

  @override
  String get manualEntrySubtitle =>
      'La IA está desactivada. Registra tus movimientos manualmente.';

  @override
  String get income => 'Ingreso';

  @override
  String get expense => 'Gasto';

  @override
  String get category => 'Categoría';

  @override
  String get reEnableAi => 'Activar Inteligencia Artificial';

  @override
  String get activateNow => 'Activar ahora';

  @override
  String get newCategory => 'Nueva Categoría';

  @override
  String get addNew => 'Agregar nueva...';

  @override
  String get categoryHint => 'Ej. Gimnasio, Mascotas...';

  @override
  String get descriptionHint => '¿En qué gastaste?';

  @override
  String get reEnableAiSubtitle => 'Usa tu voz y recibe consejos inteligentes.';

  @override
  String get catGeneral => 'General';

  @override
  String get catFood => 'Comida y Bebida';

  @override
  String get catTransport => 'Transporte';

  @override
  String get catHousing => 'Vivienda';

  @override
  String get catServices => 'Servicios (Luz, Internet)';

  @override
  String get catHealth => 'Salud y Bienestar';

  @override
  String get catEntertainment => 'Entretenimiento';

  @override
  String get catShopping => 'Compras';

  @override
  String get catEducation => 'Educación';

  @override
  String get catTravel => 'Viajes';

  @override
  String get catInvestment => 'Inversiones';

  @override
  String get catOthers => 'Otros';

  @override
  String get supportProject => 'Apoyar el proyecto (Ver anuncio)';

  @override
  String get supportThanks => '¡Gracias por tu apoyo!';
}
