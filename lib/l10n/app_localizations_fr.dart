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

  @override
  String get fillAllFields => 'Veuillez remplir tous les champs';

  @override
  String googleError(String error) {
    return 'Erreur Google : $error';
  }

  @override
  String appleError(String error) {
    return 'Erreur Apple : $error';
  }

  @override
  String get welcomeBack => 'Bon\nretour.';

  @override
  String get password => 'Mot de passe';

  @override
  String get loggingIn => 'Connexion...';

  @override
  String get login => 'Se connecter';

  @override
  String get or => 'OU';

  @override
  String get loading => 'Chargement...';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get continueWithApple => 'Continuer avec Apple';

  @override
  String get dontHaveAccount => 'Vous n\'avez pas de compte ? ';

  @override
  String get register => 'S\'inscrire';

  @override
  String get createAccount => 'Créer un\nCompte.';

  @override
  String get name => 'Nom';

  @override
  String get registering => 'Inscription...';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get transactions => 'Transactions';

  @override
  String get filterByDate => 'Filtrer par Date';

  @override
  String get ready => 'Terminé';

  @override
  String get all => 'Tous';

  @override
  String get incomes => 'Revenus';

  @override
  String get expenses => 'Dépenses';

  @override
  String get clearDate => 'Effacer la Date';

  @override
  String get noDataChart => 'Pas de données à afficher';

  @override
  String get trend => 'Tendance (7 jours)';

  @override
  String get weeklyExpenses => 'Dépenses Hebdomadaires';

  @override
  String get weeklyIncome => 'Revenus Hebdomadaires';

  @override
  String get byCategory => 'Par Catégorie';

  @override
  String get seeFull => 'Voir Tout';

  @override
  String get noTransactions => 'Pas de transactions';

  @override
  String get opens => 'Ouv:';

  @override
  String get closes => 'Ferm:';

  @override
  String get noDescription => 'Sans description';

  @override
  String get editTransaction => 'Modifier Transaction';

  @override
  String get description => 'Description';

  @override
  String get amount => 'Montant';

  @override
  String get date => 'Date';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get deleteTransactionConfirm =>
      'Êtes-vous sûr de vouloir supprimer cette transaction ?';

  @override
  String get transactionDeleted => 'Transaction supprimée';

  @override
  String deleteError(String error) {
    return 'Erreur de suppression : $error';
  }

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get yesterday => 'Hier';

  @override
  String get general => 'Général';

  @override
  String get others => 'Autres';
}
