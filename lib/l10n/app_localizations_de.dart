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
