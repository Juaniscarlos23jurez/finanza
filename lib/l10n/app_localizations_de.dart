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
}
