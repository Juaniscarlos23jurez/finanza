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
}
