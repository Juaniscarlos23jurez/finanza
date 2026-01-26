// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get accountSection => 'COMPTE';

  @override
  String get personalInfo => 'Informations Personnelles';

  @override
  String get scheduleReport => 'Programmer le Rapport';

  @override
  String get otherSection => 'AUTRE';

  @override
  String get feedback => 'Commentaires';

  @override
  String get termsConditions => 'Termes et Conditions';

  @override
  String get privacyPolicy => 'Politique de Confidentialité';

  @override
  String get logout => 'Se Déconnecter';

  @override
  String get deleteAccount => 'Supprimer mon compte définitivement';

  @override
  String get deleteAccountTitle => 'Supprimer le compte ?';

  @override
  String get deleteAccountContent =>
      'Cette action fermera votre session actuelle.';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get feedbackTitle => 'Donnez-nous votre avis';

  @override
  String get feedbackSubtitle =>
      'Votre avis nous aide à améliorer l\'expérience pour tous.';

  @override
  String get feedbackTypeQuestion => 'De quoi parle votre commentaire ?';

  @override
  String get typeSuggestion => 'Suggestion';

  @override
  String get typeError => 'Erreur';

  @override
  String get typeCompliment => 'Compliment';

  @override
  String get feedbackHint =>
      'Dites-nous ce que vous aimez ou ce que nous pouvons améliorer...';

  @override
  String get sendFeedback => 'Envoyer';

  @override
  String get feedbackSuccess => 'Merci pour vos commentaires !';

  @override
  String get fullName => 'Nom Complet';

  @override
  String get email => 'E-mail';

  @override
  String get userId => 'ID Utilisateur';

  @override
  String get close => 'Fermer';

  @override
  String get scheduleReportTitle => 'Programmer le Rapport';

  @override
  String get reportDescription =>
      'Vous recevrez un fichier Excel avec vos transactions et une analyse financière générée par IA.';

  @override
  String get sendReportTo => 'Envoyer le rapport à :';

  @override
  String get frequencyQuestion => 'Tous les combien de jours ?';

  @override
  String daysLoop(int count) {
    return '$count jours';
  }

  @override
  String get confirmAndSchedule => 'Confirmer et Programmer';

  @override
  String get configSaved => 'Configuration enregistrée avec succès !';

  @override
  String get language => 'Langue';
}
