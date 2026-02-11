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
  String get categoryLabel => 'Categoría';

  @override
  String get paymentMethod => 'Detalles del Pago';

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

  @override
  String get dashboard => 'Tableau de Bord';

  @override
  String get balanceTrend => 'Tendance du Solde';

  @override
  String get yourGoals => 'Vos Objectifs';

  @override
  String get expensesByCategory => 'Dépenses par Catégorie';

  @override
  String get recentTransactions => 'Transactions Récentes';

  @override
  String get noRecentActivity => 'Aucune activité récente';

  @override
  String hello(String name) {
    return 'Bonjour, $name';
  }

  @override
  String get helloSimple => 'Bonjour';

  @override
  String get totalBalance => 'SOLDE TOTAL';

  @override
  String get newGoal => 'Nouvel Objectif';

  @override
  String get goalNameHint => 'Nom de l\'objectif (ex. Voyage)';

  @override
  String get targetAmountHint => 'Montant cible (\$)';

  @override
  String get noActiveGoals => 'Aucun objectif actif';

  @override
  String get goal => 'Objectif';

  @override
  String get deposit => 'Déposer';

  @override
  String get withdraw => 'Retirer';

  @override
  String get add => 'Ajouter';

  @override
  String get withdrawFromGoal => 'Retirer de l\'objectif';

  @override
  String get depositToGoal => 'Déposer sur l\'objectif';

  @override
  String get available => 'Disponible';

  @override
  String get saved => 'Économisé';

  @override
  String get remaining => 'Restant';

  @override
  String get amountToWithdraw => 'Montant à retirer';

  @override
  String get amountToDeposit => 'Montant à déposer';

  @override
  String get allAmount => 'Tout';

  @override
  String get enterValidAmount => 'Entrez un montant valide';

  @override
  String cannotWithdrawMore(String amount) {
    return 'Impossible de retirer plus de \$$amount';
  }

  @override
  String withdrewAmount(String amount, String goal) {
    return 'Vous avez retiré \$$amount de \"$goal\"';
  }

  @override
  String depositedAmount(String amount, String goal) {
    return 'Vous avez déposé \$$amount sur \"$goal\" !';
  }

  @override
  String get deleteGoal => 'Supprimer l\'objectif';

  @override
  String get deleteGoalConfirm =>
      'Êtes-vous sûr de vouloir supprimer cet objectif ?';

  @override
  String goalAlreadySavedWarning(String amount) {
    return 'Vous avez déjà économisé \$$amount pour cet objectif.';
  }

  @override
  String goalDeleted(String goal) {
    return 'Objectif \"$goal\" supprimé';
  }

  @override
  String get distribution => 'Distribution';

  @override
  String get noExpensesRegistered => 'Aucune dépense enregistrée';

  @override
  String get invitationTitle => 'Invitation !';

  @override
  String invitationBody(String name, String goal) {
    return '$name vous a invité à collaborer sur : $goal';
  }

  @override
  String get invitationQuestion =>
      'Voulez-vous accepter cette invitation et partager la progression ?';

  @override
  String get reject => 'Refuser';

  @override
  String get accept => 'Accepter';

  @override
  String get invitationAccepted => 'Invitation acceptée';

  @override
  String get unknownUser => 'Quelqu\'un';

  @override
  String get defaultGoalName => 'un objectif';

  @override
  String get addSaving => 'Ajouter de l\'épargne';

  @override
  String get withdrawFunds => 'Retirer des fonds';

  @override
  String get savingAddedSuccess => 'Épargne ajoutée avec succès';

  @override
  String get insufficientFunds => 'Fonds insuffisants';

  @override
  String get withdrawalSuccess => 'Retrait réussi';

  @override
  String get currentBalance => 'Solde actuel';

  @override
  String get progress => 'Progrès';

  @override
  String get invite => 'Inviter+';

  @override
  String get progressChartComingSoon =>
      'Graphique de progression bientôt disponible !';

  @override
  String get contribution => 'Contribution';

  @override
  String get withdrawal => 'Retrait';

  @override
  String get goalCreation => 'Création de l\'objectif';

  @override
  String get inviteCollaboratorTitle => 'Inviter un collaborateur';

  @override
  String get inviteCollaboratorSubtitle =>
      'Partagez cet objectif avec quelqu\'un d\'autre';

  @override
  String get invitationUserCode => 'Code utilisateur';

  @override
  String get userCodeHint => 'ex. JUAN-1234';

  @override
  String get enterValidCode => 'Entrez un code valide';

  @override
  String invitationSentTo(String code) {
    return 'Invitation envoyée à $code';
  }

  @override
  String get errorSendingInvitation =>
      'Erreur lors de l\'envoi de l\'invitation';

  @override
  String get sendInvitation => 'Envoyer l\'invitation';

  @override
  String errorGeneric(String error) {
    return 'Erreur : $error';
  }

  @override
  String get aiThinking => 'L\'IA réfléchit...';

  @override
  String speechError(String error) {
    return 'Erreur vocale : $error';
  }

  @override
  String get voiceRecognitionUnavailable =>
      'Reconnaissance vocale non disponible';

  @override
  String get listening => 'Écoute...';

  @override
  String get typeHere => 'Écrivez ici...';

  @override
  String get assistantGreeting => 'Salut ! Je suis votre assistant financier.';

  @override
  String get assistantDescription =>
      'Je peux vous aider à enregistrer des dépenses, créer des objectifs et analyser vos finances avec l\'IA.';

  @override
  String get questionExamples => 'EXEMPLES DE QUESTIONS';

  @override
  String get fastExpense => 'Dépense Rapide';

  @override
  String get fastExpenseSubtitle => '\"Gagné 3000 et dépensé 50\"';

  @override
  String get newGoalSubtitle => '\"Économiser pour un voyage\"';

  @override
  String get iaAnalysis => 'Analyse IA';

  @override
  String get iaAnalysisSubtitle => '\"Projection sur 6 mois\"';

  @override
  String get exportSubtitle => '\"Télécharger CSV\"';

  @override
  String get finanzasAi => 'FINANCES IA';

  @override
  String get history => 'HISTORIQUE';

  @override
  String get newChat => 'Nouveau Chat';

  @override
  String get noSavedConversations => 'Aucune conversation enregistrée.';

  @override
  String get untitledConversation => 'Conversation sans titre';

  @override
  String get transactionSavedSuccess => 'Transaction enregistrée correctement';

  @override
  String get aiAssistant => 'ASSISTANT IA';

  @override
  String get youLabel => 'VOUS';

  @override
  String get premiumAnalysis => 'Analyse Premium';

  @override
  String get exclusiveContent => 'Contenu exclusif déverrouillable.';

  @override
  String get deepAiAnalysis => 'Analyse approfondie par IA';

  @override
  String get aiGeneratedAnalysis => 'Analyse générée par Finance IA';

  @override
  String get strategicReportInfo =>
      'Ce rapport contient des informations stratégiques de grande valeur.';

  @override
  String get unlockVideo => 'Regarder une vidéo pour déverrouiller';

  @override
  String get contentUnlocked => 'Contenu déverrouillé !';

  @override
  String adLoadError(String error) {
    return 'Impossible de charger l\'annonce. Réessayez. ($error)';
  }

  @override
  String get csvReady => 'Rapport Excel/CSV prêt';

  @override
  String get reportLocked => 'Rapport verrouillé';

  @override
  String get downloadAdPrompt => 'Regardez une annonce pour télécharger';

  @override
  String get shareCsv => 'Partager / Enregistrer CSV';

  @override
  String get shareCsvText => 'Voici mon rapport financier.';

  @override
  String csvShareError(String error) {
    return 'Erreur lors du partage du CSV : $error';
  }

  @override
  String get transactionSummary => 'Résumé des transactions';

  @override
  String get concept => 'Concept';

  @override
  String get result => 'Résultat';

  @override
  String get impact => 'Impact';

  @override
  String get resultingBalance => 'Solde résultant';

  @override
  String get noRecentData => 'Pas de données récentes';

  @override
  String multiTransactionTitle(int count) {
    return '$count Transactions';
  }

  @override
  String saveAllTransactions(int count) {
    return 'Enregistrer $count transactions';
  }

  @override
  String get allSaved => 'Tout enregistré';

  @override
  String transactionsSavedCount(int count) {
    return '$count transactions enregistrées';
  }

  @override
  String get goalSuggestion => 'Suggestion d\'objectif';

  @override
  String objective(String amount) {
    return 'Objectif : $amount';
  }

  @override
  String get createGoal => 'Créer un objectif';

  @override
  String get goalCreated => 'Objectif créé';

  @override
  String get analysisAvailable => 'Analyse disponible';

  @override
  String get viewChartsPrompt =>
      'Allez dans l\'onglet \'Transactions\' pour voir les graphiques.';

  @override
  String get ticketGenerated => 'Ticket généré';

  @override
  String get confirmAndSave => 'Confirmer et enregistrer';

  @override
  String get balanceActual => 'SOLDE ACTUEL';

  @override
  String saveError(String error) {
    return 'Erreur lors de l\'enregistrement : $error';
  }

  @override
  String get total => 'Total';

  @override
  String get transaction => 'Transaction';

  @override
  String get exportCSV => 'Exporter';

  @override
  String get amountLabel => 'Montant';

  @override
  String get fastExpenseSuggestion =>
      'Aujourd\'hui j\'ai gagné 3000 et dépensé 50 en café';

  @override
  String get newGoalSuggestion => 'Je veux économiser pour un voyage';

  @override
  String get aiAnalysisSuggestion =>
      'Donnez-moi une analyse stratégique de mes finances pour les 6 prochains mois';

  @override
  String get exportCsvSuggestion => 'Exporter mes transactions vers CSV';

  @override
  String get transactionAi => 'Transaction IA';

  @override
  String get goalAiDescription => 'Objectif créé par l\'IA';

  @override
  String get shareLinkAndCode => 'Partager le lien et le code';

  @override
  String get onboardingWelcome => 'Bienvenue sur Finances IA';

  @override
  String get onboardingSubtitle =>
      'Configuons votre profil financier en quelques étapes simples.';

  @override
  String get stepBudgetTitle => '3. Votre budget';

  @override
  String get stepBudgetSubtitle =>
      'Combien prévoyez-vous dépenser par mois au total ?';

  @override
  String stepBudgetHint(String amount) {
    return 'ex. $amount';
  }

  @override
  String get monthlyAvailableMoney => 'Argent disponible mensuel';

  @override
  String get incomeMinusDebts => 'Vos revenus moins vos dettes.';

  @override
  String get howMuchToAssign => 'Combien allez-vous allouer à vos dépenses ?';

  @override
  String get budgetLimitInfo =>
      'Ce sera votre limite mensuelle pour les dépenses en dehors de vos dettes.';

  @override
  String get stepSaleTitle => '2. Primera Venta';

  @override
  String get stepSaleSubtitle => 'Registra tu primera venta o ingreso del día.';

  @override
  String get stepSaleHint => 'Ej. Venta de producto';

  @override
  String get stepSourcesTitle => '1. Sources d\'argent';

  @override
  String get stepSourcesSubtitle =>
      'Ajoutez vos sources de revenus régulières.';

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
  String get stepDebtTitle => '2. Vos dettes';

  @override
  String get stepDebtSubtitle =>
      'Enregistrez vos dettes actuelles pour nous aider à planifier.';

  @override
  String get debtsRequired =>
      'Veuillez ajouter au moins une dette ou entrez 0 si vous n\'en avez pas.';

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
  String get stepGoalTitle => '4. Vos objectifs';

  @override
  String get stepGoalSubtitle => 'Pour quoi épargnez-vous ?';

  @override
  String get addGoal => 'Agregar Meta';

  @override
  String get goalName => 'Nombre de la meta';

  @override
  String get goalNameHintOnboarding => 'Viaje, Carro, Emergencias...';

  @override
  String get goalTarget => 'Monto objetivo';

  @override
  String get onboardingSummary => 'Résumé financier';

  @override
  String get onboardingSummarySubtitle =>
      'Voici à quoi ressemblent vos finances configurées.';

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
  String get totalMonthlyIncome => 'Revenu mensuel total';

  @override
  String get monthlyBudgetLimit => 'Limite du budget mensuel';

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
    return '$interest% - Paiements : $amount';
  }

  @override
  String get debtPaymentHint => 'Ej. 500';

  @override
  String get monthlyDebtCommitment => 'Compromiso Mensual de Deuda';

  @override
  String get realSavingCapacity => 'Capacité d\'épargne réelle';

  @override
  String get advisorContext =>
      'En tant que votre conseiller financier, je suggère...';

  @override
  String get financialHealthGood =>
      'Votre santé financière semble solide. Vous avez un surplus positif pour vos objectifs.';

  @override
  String get financialHealthWarning =>
      'Attention : Vos engagements mensuels dépassent vos revenus. Vous devez ajuster votre budget.';

  @override
  String get netCashFlow => 'Flujo de Caja Neto';

  @override
  String savingCapacityFormulaRefined(
    Object balance,
    Object budget,
    Object debt,
    Object income,
  ) {
    return 'Revenus ($income) - Dépenses ($budget) - Paiements de dette ($debt) = $balance libres.';
  }

  @override
  String get skip => 'Passer';

  @override
  String get skipOnboardingTitle => 'Passer la configuration ?';

  @override
  String get skipOnboardingMessage =>
      'Si vous avez déjà configuré votre profil, vous pouvez passer cette étape. Sinon, nous vous recommandons de la terminer pour que l\'IA puisse vous donner de meilleurs conseils.';

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
}
