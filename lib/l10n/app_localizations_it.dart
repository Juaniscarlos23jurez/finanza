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
  String errorGeneric(String error) {
    return 'Errore: $error';
  }
}
