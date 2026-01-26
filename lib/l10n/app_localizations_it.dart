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
