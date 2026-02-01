// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get accountSection => 'KONTO';

  @override
  String get personalInfo => 'Persönliche Informationen';

  @override
  String get scheduleReport => 'Bericht Planen';

  @override
  String get otherSection => 'ANDERE';

  @override
  String get feedback => 'Feedback';

  @override
  String get termsConditions => 'Allgemeine Geschäftsbedingungen';

  @override
  String get privacyPolicy => 'Datenschutzerklärung';

  @override
  String get logout => 'Abmelden';

  @override
  String get deleteAccount => 'Mein Konto dauerhaft löschen';

  @override
  String get deleteAccountTitle => 'Konto löschen?';

  @override
  String get deleteAccountContent =>
      'Diese Aktion beendet Ihre aktuelle Sitzung.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get feedbackTitle => 'Geben Sie uns Ihr Feedback';

  @override
  String get feedbackSubtitle =>
      'Ihre Meinung hilft uns, das Erlebnis für alle zu verbessern.';

  @override
  String get feedbackTypeQuestion => 'Worum geht es in Ihrem Kommentar?';

  @override
  String get typeSuggestion => 'Vorschlag';

  @override
  String get typeError => 'Fehler';

  @override
  String get typeCompliment => 'Kompliment';

  @override
  String get feedbackHint =>
      'Erzählen Sie uns, was Ihnen gefällt oder was wir verbessern können...';

  @override
  String get sendFeedback => 'Senden';

  @override
  String get feedbackSuccess => 'Danke für Ihr Feedback!';

  @override
  String get fullName => 'Vollständiger Name';

  @override
  String get email => 'E-Mail';

  @override
  String get userId => 'Benutzer-ID';

  @override
  String get close => 'Schließen';

  @override
  String get scheduleReportTitle => 'Bericht Planen';

  @override
  String get reportDescription =>
      'Sie erhalten eine Excel-Datei mit Ihren Transaktionen und einer KI-generierten Finanzanalyse.';

  @override
  String get sendReportTo => 'Bericht senden an:';

  @override
  String get frequencyQuestion => 'Alle wie viele Tage?';

  @override
  String daysLoop(int count) {
    return '$count Tage';
  }

  @override
  String get confirmAndSchedule => 'Bestätigen und Planen';

  @override
  String get configSaved => 'Konfiguration erfolgreich gespeichert!';

  @override
  String get language => 'Sprache';

  @override
  String get fillAllFields => 'Bitte füllen Sie alle Felder aus';

  @override
  String googleError(String error) {
    return 'Google-Fehler: $error';
  }

  @override
  String appleError(String error) {
    return 'Apple-Fehler: $error';
  }

  @override
  String get welcomeBack => 'Willkommen\nzurück.';

  @override
  String get password => 'Passwort';

  @override
  String get loggingIn => 'Anmelden...';

  @override
  String get login => 'Anmelden';

  @override
  String get or => 'ODER';

  @override
  String get loading => 'Laden...';

  @override
  String get continueWithGoogle => 'Weiter mit Google';

  @override
  String get continueWithApple => 'Weiter mit Apple';

  @override
  String get dontHaveAccount => 'Haben Sie kein Konto? ';

  @override
  String get register => 'Registrieren';

  @override
  String get createAccount => 'Konto\nerstellen.';

  @override
  String get name => 'Name';

  @override
  String get registering => 'Registrieren...';

  @override
  String get signUp => 'Registrieren';

  @override
  String get transactions => 'Transaktionen';

  @override
  String get filterByDate => 'Nach Datum filtern';

  @override
  String get ready => 'Fertig';

  @override
  String get all => 'Alle';

  @override
  String get incomes => 'Einnahmen';

  @override
  String get expenses => 'Ausgaben';

  @override
  String get clearDate => 'Datum löschen';

  @override
  String get noDataChart => 'Keine Daten für Diagramm';

  @override
  String get trend => 'Trend (7 Tage)';

  @override
  String get weeklyExpenses => 'Wöchentliche Ausgaben';

  @override
  String get weeklyIncome => 'Wöchentliche Einnahmen';

  @override
  String get byCategory => 'Nach Kategorie';

  @override
  String get seeFull => 'Vollständig anzeigen';

  @override
  String get noTransactions => 'Keine Transaktionen';

  @override
  String get opens => 'Öffnen:';

  @override
  String get closes => 'Schließen:';

  @override
  String get noDescription => 'Keine Beschreibung';

  @override
  String get editTransaction => 'Transaktion bearbeiten';

  @override
  String get description => 'Beschreibung';

  @override
  String get amount => 'Betrag';

  @override
  String get date => 'Datum';

  @override
  String get save => 'Speichern';

  @override
  String get categoryLabel => 'Categoría';

  @override
  String get delete => 'Löschen';

  @override
  String get deleteTransactionConfirm =>
      'Möchten Sie diese Transaktion wirklich löschen?';

  @override
  String get transactionDeleted => 'Transaktion gelöscht';

  @override
  String deleteError(String error) {
    return 'Fehler beim Löschen: $error';
  }

  @override
  String get today => 'Heute';

  @override
  String get yesterday => 'Gestern';

  @override
  String get general => 'Allgemein';

  @override
  String get others => 'Andere';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get balanceTrend => 'Saldo-Trend';

  @override
  String get yourGoals => 'Deine Ziele';

  @override
  String get expensesByCategory => 'Ausgaben nach Kategorie';

  @override
  String get recentTransactions => 'Aktuelle Transaktionen';

  @override
  String get noRecentActivity => 'Keine aktuellen Aktivitäten';

  @override
  String hello(String name) {
    return 'Hallo, $name';
  }

  @override
  String get helloSimple => 'Hallo';

  @override
  String get totalBalance => 'Guthaben';

  @override
  String get newGoal => 'Neues Ziel';

  @override
  String get goalNameHint => 'Zielname (z.B. Reise)';

  @override
  String get targetAmountHint => 'Zielbetrag (\$)';

  @override
  String get noActiveGoals => 'Keine aktiven Ziele';

  @override
  String get goal => 'Ziel';

  @override
  String get deposit => 'Einzahlen';

  @override
  String get withdraw => 'Abheben';

  @override
  String get add => 'Hinzufügen';

  @override
  String get withdrawFromGoal => 'Vom Ziel abheben';

  @override
  String get depositToGoal => 'Auf Ziel einzahlen';

  @override
  String get available => 'Verfügbar';

  @override
  String get saved => 'Gespart';

  @override
  String get remaining => 'Verbleibend';

  @override
  String get amountToWithdraw => 'Betrag zum Abheben';

  @override
  String get amountToDeposit => 'Betrag zum Einzahlen';

  @override
  String get allAmount => 'Alles';

  @override
  String get enterValidAmount => 'Bitte geben Sie einen gültigen Betrag ein';

  @override
  String cannotWithdrawMore(String amount) {
    return 'Sie können nicht mehr als \$$amount abheben';
  }

  @override
  String withdrewAmount(String amount, String goal) {
    return 'Sie haben \$$amount von \"$goal\" abgehoben';
  }

  @override
  String depositedAmount(String amount, String goal) {
    return 'Sie haben \$$amount auf \"$goal\" eingezahlt!';
  }

  @override
  String get deleteGoal => 'Ziel löschen';

  @override
  String get deleteGoalConfirm => 'Möchten Sie dieses Ziel wirklich löschen?';

  @override
  String goalAlreadySavedWarning(String amount) {
    return 'Sie haben bereits \$$amount für dieses Ziel gespart.';
  }

  @override
  String goalDeleted(String goal) {
    return 'Ziel \"$goal\" gelöscht';
  }

  @override
  String get distribution => 'Verteilung';

  @override
  String get noExpensesRegistered => 'Keine Ausgaben registriert';

  @override
  String get invitationTitle => 'Einladung!';

  @override
  String invitationBody(String name, String goal) {
    return '$name hat Sie eingeladen, an folgendem Ziel mitzuarbeiten: $goal';
  }

  @override
  String get invitationQuestion =>
      'Möchten Sie diese Einladung annehmen und den Fortschritt teilen?';

  @override
  String get reject => 'Ablehnen';

  @override
  String get accept => 'Annehmen';

  @override
  String get invitationAccepted => 'Einladung angenommen';

  @override
  String get unknownUser => 'Jemand';

  @override
  String get defaultGoalName => 'ein Ziel';

  @override
  String get addSaving => 'Ersparnis hinzufügen';

  @override
  String get withdrawFunds => 'Guthaben abheben';

  @override
  String get savingAddedSuccess => 'Ersparnis erfolgreich hinzugefügt';

  @override
  String get insufficientFunds => 'Unzureichendes Guthaben';

  @override
  String get withdrawalSuccess => 'Abhebung erfolgreich';

  @override
  String get currentBalance => 'Aktueller Kontostand';

  @override
  String get progress => 'Fortschritt';

  @override
  String get invite => 'Einladen+';

  @override
  String get progressChartComingSoon => 'Fortschrittsdiagramm bald verfügbar!';

  @override
  String get contribution => 'Beitrag';

  @override
  String get withdrawal => 'Abhebung';

  @override
  String get goalCreation => 'Zielerstellung';

  @override
  String get inviteCollaboratorTitle => 'Mitarbeiter einladen';

  @override
  String get inviteCollaboratorSubtitle =>
      'Teilen Sie dieses Ziel mit jemand anderem';

  @override
  String get invitationUserCode => 'Benutzercode';

  @override
  String get userCodeHint => 'z.B. JUAN-1234';

  @override
  String get enterValidCode => 'Geben Sie einen gültigen Code ein';

  @override
  String invitationSentTo(String code) {
    return 'Einladung an $code gesendet';
  }

  @override
  String get errorSendingInvitation => 'Fehler beim Senden der Einladung';

  @override
  String get sendInvitation => 'Einladung senden';

  @override
  String errorGeneric(String error) {
    return 'Fehler: $error';
  }

  @override
  String get aiThinking => 'Die KI denkt nach...';

  @override
  String speechError(String error) {
    return 'Sprachfehler: $error';
  }

  @override
  String get voiceRecognitionUnavailable => 'Spracherkennung nicht verfügbar';

  @override
  String get listening => 'Hören...';

  @override
  String get typeHere => 'Hier eingeben...';

  @override
  String get assistantGreeting => 'Hallo! Ich bin Ihr Finanzassistent.';

  @override
  String get assistantDescription =>
      'Ich kann Ihnen helfen, Ausgaben zu registrieren, Ziele zu erstellen und Ihre Finanzen mit KI zu analysieren.';

  @override
  String get questionExamples => 'BEISPIELFRAGEN';

  @override
  String get fastExpense => 'Schnelle Ausgabe';

  @override
  String get fastExpenseSubtitle => '\"3000 verdient und 50 ausgegeben\"';

  @override
  String get newGoalSubtitle => '\"Für Reise sparen\"';

  @override
  String get iaAnalysis => 'KI-Analyse';

  @override
  String get iaAnalysisSubtitle => '\"6-Monats-Projektion\"';

  @override
  String get exportSubtitle => '\"CSV herunterladen\"';

  @override
  String get finanzasAi => 'FINANZEN KI';

  @override
  String get history => 'VERLAUF';

  @override
  String get newChat => 'Neuer Chat';

  @override
  String get noSavedConversations => 'Keine gespeicherten Unterhaltungen.';

  @override
  String get untitledConversation => 'Unbenannte Unterhaltung';

  @override
  String get transactionSavedSuccess => 'Transaktion korrekt aufgezeichnet';

  @override
  String get aiAssistant => 'KI-ASSISTENT';

  @override
  String get youLabel => 'DU';

  @override
  String get premiumAnalysis => 'Premium-Analyse';

  @override
  String get exclusiveContent => 'Exklusiver freischaltbarer Inhalt.';

  @override
  String get deepAiAnalysis => 'Tiefe KI-Analyse';

  @override
  String get aiGeneratedAnalysis => 'Von Finanzen KI generierte Analyse';

  @override
  String get strategicReportInfo =>
      'Dieser Bericht enthält strategische Informationen von hohem Wert.';

  @override
  String get unlockVideo => 'Video ansehen zum Freischalten';

  @override
  String get contentUnlocked => 'Inhalt freigeschaltet!';

  @override
  String adLoadError(String error) {
    return 'Anzeige konnte nicht geladen werden. Versuchen Sie es erneut. ($error)';
  }

  @override
  String get csvReady => 'Excel/CSV-Bericht bereit';

  @override
  String get reportLocked => 'Bericht gesperrt';

  @override
  String get downloadAdPrompt => 'Anzeige ansehen zum Herunterladen';

  @override
  String get shareCsv => 'CSV teilen / speichern';

  @override
  String get shareCsvText => 'Hier ist mein Finanzbericht.';

  @override
  String csvShareError(String error) {
    return 'Fehler beim Teilen der CSV: $error';
  }

  @override
  String get transactionSummary => 'Transaktionszusammenfassung';

  @override
  String get concept => 'Konzept';

  @override
  String get result => 'Ergebnis';

  @override
  String get impact => 'Auswirkung';

  @override
  String get resultingBalance => 'Resultierender Kontostand';

  @override
  String get noRecentData => 'Keine aktuellen Daten';

  @override
  String multiTransactionTitle(int count) {
    return '$count Transaktionen';
  }

  @override
  String saveAllTransactions(int count) {
    return '$count Transaktionen speichern';
  }

  @override
  String get allSaved => 'Alle gespeichert';

  @override
  String transactionsSavedCount(int count) {
    return '$count Transaktionen gespeichert';
  }

  @override
  String get goalSuggestion => 'Zielvorschlag';

  @override
  String objective(String amount) {
    return 'Ziel: $amount';
  }

  @override
  String get createGoal => 'Ziel erstellen';

  @override
  String get goalCreated => 'Ziel erstellt';

  @override
  String get analysisAvailable => 'Analyse verfügbar';

  @override
  String get viewChartsPrompt =>
      'Gehen Sie zum Reiter \'Transaktionen\', um die Diagramme zu sehen.';

  @override
  String get ticketGenerated => 'Ticket generiert';

  @override
  String get confirmAndSave => 'Bestätigen und speichern';

  @override
  String get balanceActual => 'AKTUELLER STAND';

  @override
  String saveError(String error) {
    return 'Fehler beim Speichern: $error';
  }

  @override
  String get total => 'Gesamt';

  @override
  String get transaction => 'Transaktion';

  @override
  String get exportCSV => 'Exportieren';

  @override
  String get amountLabel => 'Betrag';

  @override
  String get fastExpenseSuggestion =>
      'Heute habe ich 3000 verdient und 50 für Kaffee ausgegeben';

  @override
  String get newGoalSuggestion => 'Ich möchte für eine Reise sparen';

  @override
  String get aiAnalysisSuggestion =>
      'Gib mir eine strategische Analyse meiner Finanzen für die nächsten 6 Monate';

  @override
  String get exportCsvSuggestion => 'Exportiere meine Transaktionen nach CSV';

  @override
  String get transactionAi => 'KI-Transaktion';

  @override
  String get goalAiDescription => 'Von KI erstelltes Ziel';

  @override
  String get shareLinkAndCode => 'Link und Code teilen';

  @override
  String get onboardingWelcome => 'Bienvenido a Finanzas AI';

  @override
  String get onboardingSubtitle =>
      'Vamos a configurar tu perfil financiero en 3 simples pasos.';

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
  String get stepSourcesTitle => '3. Fuentes de Dinero';

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
  String get stepDebtTitle => '4. Tus Deudas';

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
  String get stepGoalTitle => '5. Tus Metas';

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
}
