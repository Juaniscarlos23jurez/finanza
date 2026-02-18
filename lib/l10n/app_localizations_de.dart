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
  String get paymentMethod => 'Detalles del Pago';

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
  String get onboardingWelcome => 'Willkommen bei Finanzen KI';

  @override
  String get onboardingSubtitle =>
      'Lassen Sie uns Ihr Finanzprofil in wenigen einfachen Schritten einrichten.';

  @override
  String get stepBudgetTitle => '3. Ihr Budget';

  @override
  String get stepBudgetSubtitle =>
      'Wie viel planen Sie monatlich insgesamt auszugeben?';

  @override
  String stepBudgetHint(String amount) {
    return 'z.B. $amount';
  }

  @override
  String get monthlyAvailableMoney => 'Verfügbares monatliches Geld';

  @override
  String get incomeMinusDebts => 'Ihr Einkommen abzüglich Ihrer Schulden.';

  @override
  String get howMuchToAssign => 'Wie viel werden Sie Ihren Ausgaben zuweisen?';

  @override
  String get budgetLimitInfo =>
      'Dies wird Ihr monatliches Limit für Ausgaben außerhalb Ihrer Schulden sein.';

  @override
  String get stepSaleTitle => '2. Primera Venta';

  @override
  String get stepSaleSubtitle => 'Registra tu primera venta o ingreso del día.';

  @override
  String get stepSaleHint => 'Ej. Venta de producto';

  @override
  String get stepSourcesTitle => '1. Geldquellen';

  @override
  String get stepSourcesSubtitle =>
      'Fügen Sie Ihre regelmäßigen Einkommensquellen hinzu.';

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
  String get stepDebtTitle => '2. Ihre Schulden';

  @override
  String get stepDebtSubtitle =>
      'Erfassen Sie Ihre aktuellen Schulden, um uns bei der Planung zu helfen.';

  @override
  String get debtsRequired =>
      'Bitte fügen Sie mindestens eine Schuld hinzu oder geben Sie 0 ein, wenn Sie keine haben.';

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
  String get stepGoalTitle => '4. Ihre Ziele';

  @override
  String get stepGoalSubtitle => 'Wofür sparen Sie?';

  @override
  String get addGoal => 'Agregar Meta';

  @override
  String get goalName => 'Nombre de la meta';

  @override
  String get goalNameHintOnboarding => 'Viaje, Carro, Emergencias...';

  @override
  String get goalTarget => 'Monto objetivo';

  @override
  String get onboardingSummary => 'Finanzzusammenfassung';

  @override
  String get onboardingSummarySubtitle =>
      'So sehen Ihre konfigurierten Finanzen aus.';

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
  String get totalMonthlyIncome => 'Monatliches Gesamteinkommen';

  @override
  String get monthlyBudgetLimit => 'Monatliches Budgetlimit';

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
    return '$interest% - Zahlungen: $amount';
  }

  @override
  String get debtPaymentHint => 'Ej. 500';

  @override
  String get monthlyDebtCommitment => 'Compromiso Mensual de Deuda';

  @override
  String get realSavingCapacity => 'Tatsächliche Sparkapazität';

  @override
  String get advisorContext => 'Als Ihr Finanzberater schlage ich vor...';

  @override
  String get financialHealthGood =>
      'Ihre finanzielle Gesundheit sieht solide aus. Sie haben einen positiven Überschuss für Ihre Ziele.';

  @override
  String get financialHealthWarning =>
      'Achtung: Ihre monatlichen Verpflichtungen übersteigen Ihr Einkommen. Sie müssen Ihr Budget anpassen.';

  @override
  String get netCashFlow => 'Flujo de Caja Neto';

  @override
  String savingCapacityFormulaRefined(
    Object balance,
    Object budget,
    Object debt,
    Object income,
  ) {
    return 'Einkommen ($income) - Ausgaben ($budget) - Schuldenzahlungen ($debt) = $balance frei.';
  }

  @override
  String get skip => 'Überspringen';

  @override
  String get skipOnboardingTitle => 'Einrichtung überspringen?';

  @override
  String get skipOnboardingMessage =>
      'Wenn Sie Ihr Profil bereits konfiguriert haben, können Sie diesen Schritt überspringen. Andernfalls empfehlen wir den Abschluss, damit die KI Sie besser beraten kann.';

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
