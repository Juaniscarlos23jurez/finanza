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
}
