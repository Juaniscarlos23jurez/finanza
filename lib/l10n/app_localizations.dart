import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('pt'),
    Locale('zh'),
  ];

  /// No description provided for @accountSection.
  ///
  /// In es, this message translates to:
  /// **'CUENTA'**
  String get accountSection;

  /// No description provided for @personalInfo.
  ///
  /// In es, this message translates to:
  /// **'Información Personal'**
  String get personalInfo;

  /// No description provided for @scheduleReport.
  ///
  /// In es, this message translates to:
  /// **'Programar Envío de Reporte'**
  String get scheduleReport;

  /// No description provided for @otherSection.
  ///
  /// In es, this message translates to:
  /// **'OTRO'**
  String get otherSection;

  /// No description provided for @feedback.
  ///
  /// In es, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @termsConditions.
  ///
  /// In es, this message translates to:
  /// **'Términos y Condiciones'**
  String get termsConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In es, this message translates to:
  /// **'Política de Privacidad'**
  String get privacyPolicy;

  /// No description provided for @logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar Sesión'**
  String get logout;

  /// No description provided for @deleteAccount.
  ///
  /// In es, this message translates to:
  /// **'Eliminar mi cuenta permanentemente'**
  String get deleteAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar cuenta?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountContent.
  ///
  /// In es, this message translates to:
  /// **'Esta acción cerrará tu sesión actual.'**
  String get deleteAccountContent;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @feedbackTitle.
  ///
  /// In es, this message translates to:
  /// **'Danos tu Feedback'**
  String get feedbackTitle;

  /// No description provided for @feedbackSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tu opinión nos ayuda a mejorar la experiencia para todos.'**
  String get feedbackSubtitle;

  /// No description provided for @feedbackTypeQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿De qué trata tu comentario?'**
  String get feedbackTypeQuestion;

  /// No description provided for @typeSuggestion.
  ///
  /// In es, this message translates to:
  /// **'Sugerencia'**
  String get typeSuggestion;

  /// No description provided for @typeError.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get typeError;

  /// No description provided for @typeCompliment.
  ///
  /// In es, this message translates to:
  /// **'Felicitación'**
  String get typeCompliment;

  /// No description provided for @feedbackHint.
  ///
  /// In es, this message translates to:
  /// **'Cuéntanos qué te gusta o qué podemos mejorar...'**
  String get feedbackHint;

  /// No description provided for @sendFeedback.
  ///
  /// In es, this message translates to:
  /// **'Enviar Comentarios'**
  String get sendFeedback;

  /// No description provided for @feedbackSuccess.
  ///
  /// In es, this message translates to:
  /// **'¡Gracias por tu feedback!'**
  String get feedbackSuccess;

  /// No description provided for @fullName.
  ///
  /// In es, this message translates to:
  /// **'Nombre Completo'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In es, this message translates to:
  /// **'Correo Electrónico'**
  String get email;

  /// No description provided for @userId.
  ///
  /// In es, this message translates to:
  /// **'ID de Usuario'**
  String get userId;

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// No description provided for @scheduleReportTitle.
  ///
  /// In es, this message translates to:
  /// **'Programar Reporte'**
  String get scheduleReportTitle;

  /// No description provided for @reportDescription.
  ///
  /// In es, this message translates to:
  /// **'Recibirás un Excel con tus movimientos y un análisis financiero generado por IA.'**
  String get reportDescription;

  /// No description provided for @sendReportTo.
  ///
  /// In es, this message translates to:
  /// **'Enviar reporte a:'**
  String get sendReportTo;

  /// No description provided for @frequencyQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Cada cuántos días?'**
  String get frequencyQuestion;

  /// No description provided for @daysLoop.
  ///
  /// In es, this message translates to:
  /// **'{count} días'**
  String daysLoop(int count);

  /// No description provided for @confirmAndSchedule.
  ///
  /// In es, this message translates to:
  /// **'Confirmar y Programar'**
  String get confirmAndSchedule;

  /// No description provided for @configSaved.
  ///
  /// In es, this message translates to:
  /// **'¡Configuración guardada con éxito!'**
  String get configSaved;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @fillAllFields.
  ///
  /// In es, this message translates to:
  /// **'Por favor llena todos los campos'**
  String get fillAllFields;

  /// No description provided for @googleError.
  ///
  /// In es, this message translates to:
  /// **'Error con Google:'**
  String googleError(String error);

  /// No description provided for @appleError.
  ///
  /// In es, this message translates to:
  /// **'Error con Apple:'**
  String appleError(String error);

  /// No description provided for @welcomeBack.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido\nde nuevo.'**
  String get welcomeBack;

  /// No description provided for @password.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// No description provided for @loggingIn.
  ///
  /// In es, this message translates to:
  /// **'Iniciando sesión...'**
  String get loggingIn;

  /// No description provided for @login.
  ///
  /// In es, this message translates to:
  /// **'Iniciar Sesión'**
  String get login;

  /// No description provided for @or.
  ///
  /// In es, this message translates to:
  /// **'O'**
  String get or;

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get loading;

  /// No description provided for @continueWithGoogle.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Apple'**
  String get continueWithApple;

  /// No description provided for @dontHaveAccount.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta? '**
  String get dontHaveAccount;

  /// No description provided for @register.
  ///
  /// In es, this message translates to:
  /// **'Regístrate'**
  String get register;

  /// No description provided for @createAccount.
  ///
  /// In es, this message translates to:
  /// **'Crear\nCuenta.'**
  String get createAccount;

  /// No description provided for @name.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get name;

  /// No description provided for @registering.
  ///
  /// In es, this message translates to:
  /// **'Registrando...'**
  String get registering;

  /// No description provided for @signUp.
  ///
  /// In es, this message translates to:
  /// **'Registrarse'**
  String get signUp;

  /// No description provided for @transactions.
  ///
  /// In es, this message translates to:
  /// **'Movimientos'**
  String get transactions;

  /// No description provided for @filterByDate.
  ///
  /// In es, this message translates to:
  /// **'Filtrar por Fecha'**
  String get filterByDate;

  /// No description provided for @ready.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get ready;

  /// No description provided for @all.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get all;

  /// No description provided for @incomes.
  ///
  /// In es, this message translates to:
  /// **'Ingresos'**
  String get incomes;

  /// No description provided for @expenses.
  ///
  /// In es, this message translates to:
  /// **'Gastos'**
  String get expenses;

  /// No description provided for @clearDate.
  ///
  /// In es, this message translates to:
  /// **'Limpiar Fecha'**
  String get clearDate;

  /// No description provided for @noDataChart.
  ///
  /// In es, this message translates to:
  /// **'No hay datos para graficar'**
  String get noDataChart;

  /// No description provided for @trend.
  ///
  /// In es, this message translates to:
  /// **'Tendencia (7 días)'**
  String get trend;

  /// No description provided for @weeklyExpenses.
  ///
  /// In es, this message translates to:
  /// **'Gastos Semanales'**
  String get weeklyExpenses;

  /// No description provided for @weeklyIncome.
  ///
  /// In es, this message translates to:
  /// **'Ingresos Semanales'**
  String get weeklyIncome;

  /// No description provided for @byCategory.
  ///
  /// In es, this message translates to:
  /// **'Por Categoría'**
  String get byCategory;

  /// No description provided for @seeFull.
  ///
  /// In es, this message translates to:
  /// **'Ver completo'**
  String get seeFull;

  /// No description provided for @noTransactions.
  ///
  /// In es, this message translates to:
  /// **'No hay movimientos'**
  String get noTransactions;

  /// No description provided for @opens.
  ///
  /// In es, this message translates to:
  /// **'Abre:'**
  String get opens;

  /// No description provided for @closes.
  ///
  /// In es, this message translates to:
  /// **'Cierra:'**
  String get closes;

  /// No description provided for @noDescription.
  ///
  /// In es, this message translates to:
  /// **'Sin descripción'**
  String get noDescription;

  /// No description provided for @editTransaction.
  ///
  /// In es, this message translates to:
  /// **'Editar Movimiento'**
  String get editTransaction;

  /// No description provided for @description.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get description;

  /// No description provided for @amount.
  ///
  /// In es, this message translates to:
  /// **'Monto'**
  String get amount;

  /// No description provided for @date.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get date;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @categoryLabel.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get categoryLabel;

  /// No description provided for @paymentMethod.
  ///
  /// In es, this message translates to:
  /// **'Detalles del Pago'**
  String get paymentMethod;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @deleteTransactionConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de eliminar este movimiento?'**
  String get deleteTransactionConfirm;

  /// No description provided for @transactionDeleted.
  ///
  /// In es, this message translates to:
  /// **'Movimiento eliminado'**
  String get transactionDeleted;

  /// No description provided for @deleteError.
  ///
  /// In es, this message translates to:
  /// **'Error al eliminar:'**
  String deleteError(String error);

  /// No description provided for @today.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In es, this message translates to:
  /// **'Ayer'**
  String get yesterday;

  /// No description provided for @general.
  ///
  /// In es, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @others.
  ///
  /// In es, this message translates to:
  /// **'Otros'**
  String get others;

  /// No description provided for @dashboard.
  ///
  /// In es, this message translates to:
  /// **'Panel de Control'**
  String get dashboard;

  /// No description provided for @balanceTrend.
  ///
  /// In es, this message translates to:
  /// **'Movimiento de Balance'**
  String get balanceTrend;

  /// No description provided for @yourGoals.
  ///
  /// In es, this message translates to:
  /// **'Tus Metas'**
  String get yourGoals;

  /// No description provided for @expensesByCategory.
  ///
  /// In es, this message translates to:
  /// **'Gastos por Categoría'**
  String get expensesByCategory;

  /// No description provided for @recentTransactions.
  ///
  /// In es, this message translates to:
  /// **'Movimientos Recientes'**
  String get recentTransactions;

  /// No description provided for @noRecentActivity.
  ///
  /// In es, this message translates to:
  /// **'Sin actividad reciente'**
  String get noRecentActivity;

  /// No description provided for @hello.
  ///
  /// In es, this message translates to:
  /// **'Hola, {name}'**
  String hello(String name);

  /// No description provided for @helloSimple.
  ///
  /// In es, this message translates to:
  /// **'Hola'**
  String get helloSimple;

  /// No description provided for @totalBalance.
  ///
  /// In es, this message translates to:
  /// **'SALDO TOTAL'**
  String get totalBalance;

  /// No description provided for @newGoal.
  ///
  /// In es, this message translates to:
  /// **'Nueva Meta'**
  String get newGoal;

  /// No description provided for @goalNameHint.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la meta (ej. Viaje)'**
  String get goalNameHint;

  /// No description provided for @targetAmountHint.
  ///
  /// In es, this message translates to:
  /// **'Monto objetivo (\$)'**
  String get targetAmountHint;

  /// No description provided for @noActiveGoals.
  ///
  /// In es, this message translates to:
  /// **'No tienes metas activas'**
  String get noActiveGoals;

  /// No description provided for @goal.
  ///
  /// In es, this message translates to:
  /// **'Meta'**
  String get goal;

  /// No description provided for @deposit.
  ///
  /// In es, this message translates to:
  /// **'Abonar'**
  String get deposit;

  /// No description provided for @withdraw.
  ///
  /// In es, this message translates to:
  /// **'Retirar'**
  String get withdraw;

  /// No description provided for @add.
  ///
  /// In es, this message translates to:
  /// **'Añadir'**
  String get add;

  /// No description provided for @withdrawFromGoal.
  ///
  /// In es, this message translates to:
  /// **'Retirar de Meta'**
  String get withdrawFromGoal;

  /// No description provided for @depositToGoal.
  ///
  /// In es, this message translates to:
  /// **'Abonar a Meta'**
  String get depositToGoal;

  /// No description provided for @available.
  ///
  /// In es, this message translates to:
  /// **'Disponible'**
  String get available;

  /// No description provided for @saved.
  ///
  /// In es, this message translates to:
  /// **'Ahorrado'**
  String get saved;

  /// No description provided for @remaining.
  ///
  /// In es, this message translates to:
  /// **'Restante'**
  String get remaining;

  /// No description provided for @amountToWithdraw.
  ///
  /// In es, this message translates to:
  /// **'Monto a retirar'**
  String get amountToWithdraw;

  /// No description provided for @amountToDeposit.
  ///
  /// In es, this message translates to:
  /// **'Monto a abonar'**
  String get amountToDeposit;

  /// No description provided for @allAmount.
  ///
  /// In es, this message translates to:
  /// **'Todo'**
  String get allAmount;

  /// No description provided for @enterValidAmount.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un monto válido'**
  String get enterValidAmount;

  /// No description provided for @cannotWithdrawMore.
  ///
  /// In es, this message translates to:
  /// **'No puedes retirar más de \${amount}'**
  String cannotWithdrawMore(String amount);

  /// No description provided for @withdrewAmount.
  ///
  /// In es, this message translates to:
  /// **'Retiraste \${amount} de \"{goal}\"'**
  String withdrewAmount(String amount, String goal);

  /// No description provided for @depositedAmount.
  ///
  /// In es, this message translates to:
  /// **'¡Abonaste \${amount} a \"{goal}\"!'**
  String depositedAmount(String amount, String goal);

  /// No description provided for @deleteGoal.
  ///
  /// In es, this message translates to:
  /// **'Eliminar Meta'**
  String get deleteGoal;

  /// No description provided for @deleteGoalConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de eliminar esta meta?'**
  String get deleteGoalConfirm;

  /// No description provided for @goalAlreadySavedWarning.
  ///
  /// In es, this message translates to:
  /// **'Ya tienes \${amount} ahorrados en esta meta.'**
  String goalAlreadySavedWarning(String amount);

  /// No description provided for @goalDeleted.
  ///
  /// In es, this message translates to:
  /// **'Meta \"{goal}\" eliminada'**
  String goalDeleted(String goal);

  /// No description provided for @distribution.
  ///
  /// In es, this message translates to:
  /// **'Distribución'**
  String get distribution;

  /// No description provided for @noExpensesRegistered.
  ///
  /// In es, this message translates to:
  /// **'No hay gastos registrados'**
  String get noExpensesRegistered;

  /// No description provided for @invitationTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Invitación!'**
  String get invitationTitle;

  /// No description provided for @invitationBody.
  ///
  /// In es, this message translates to:
  /// **'{name} te ha invitado a colaborar en la meta: {goal}'**
  String invitationBody(String name, String goal);

  /// No description provided for @invitationQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Deseas aceptar esta invitación y compartir el progreso?'**
  String get invitationQuestion;

  /// No description provided for @reject.
  ///
  /// In es, this message translates to:
  /// **'Rechazar'**
  String get reject;

  /// No description provided for @accept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get accept;

  /// No description provided for @invitationAccepted.
  ///
  /// In es, this message translates to:
  /// **'Invitación aceptada'**
  String get invitationAccepted;

  /// No description provided for @unknownUser.
  ///
  /// In es, this message translates to:
  /// **'Alguien'**
  String get unknownUser;

  /// No description provided for @defaultGoalName.
  ///
  /// In es, this message translates to:
  /// **'una meta'**
  String get defaultGoalName;

  /// No description provided for @addSaving.
  ///
  /// In es, this message translates to:
  /// **'Añadir Ahorro'**
  String get addSaving;

  /// No description provided for @withdrawFunds.
  ///
  /// In es, this message translates to:
  /// **'Retirar Fondos'**
  String get withdrawFunds;

  /// No description provided for @savingAddedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Ahorro añadido exitosamente'**
  String get savingAddedSuccess;

  /// No description provided for @insufficientFunds.
  ///
  /// In es, this message translates to:
  /// **'Fondos insuficientes'**
  String get insufficientFunds;

  /// No description provided for @withdrawalSuccess.
  ///
  /// In es, this message translates to:
  /// **'Retiro realizado exitosamente'**
  String get withdrawalSuccess;

  /// No description provided for @currentBalance.
  ///
  /// In es, this message translates to:
  /// **'Saldo actual'**
  String get currentBalance;

  /// No description provided for @progress.
  ///
  /// In es, this message translates to:
  /// **'Progreso'**
  String get progress;

  /// No description provided for @invite.
  ///
  /// In es, this message translates to:
  /// **'Invitar+'**
  String get invite;

  /// No description provided for @progressChartComingSoon.
  ///
  /// In es, this message translates to:
  /// **'¡Gráfica de progreso próximamente!'**
  String get progressChartComingSoon;

  /// No description provided for @contribution.
  ///
  /// In es, this message translates to:
  /// **'Contribución'**
  String get contribution;

  /// No description provided for @withdrawal.
  ///
  /// In es, this message translates to:
  /// **'Retiro'**
  String get withdrawal;

  /// No description provided for @goalCreation.
  ///
  /// In es, this message translates to:
  /// **'Creación de meta'**
  String get goalCreation;

  /// No description provided for @inviteCollaboratorTitle.
  ///
  /// In es, this message translates to:
  /// **'Invitar Colaborador'**
  String get inviteCollaboratorTitle;

  /// No description provided for @inviteCollaboratorSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Comparte esta meta con alguien más'**
  String get inviteCollaboratorSubtitle;

  /// No description provided for @invitationUserCode.
  ///
  /// In es, this message translates to:
  /// **'Código de Usuario'**
  String get invitationUserCode;

  /// No description provided for @userCodeHint.
  ///
  /// In es, this message translates to:
  /// **'ej. JUAN-1234'**
  String get userCodeHint;

  /// No description provided for @enterValidCode.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un código válido'**
  String get enterValidCode;

  /// No description provided for @invitationSentTo.
  ///
  /// In es, this message translates to:
  /// **'Invitación enviada a {code}'**
  String invitationSentTo(String code);

  /// No description provided for @errorSendingInvitation.
  ///
  /// In es, this message translates to:
  /// **'Error al enviar invitación'**
  String get errorSendingInvitation;

  /// No description provided for @sendInvitation.
  ///
  /// In es, this message translates to:
  /// **'Enviar Invitación'**
  String get sendInvitation;

  /// No description provided for @errorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Error:'**
  String errorGeneric(String error);

  /// No description provided for @aiThinking.
  ///
  /// In es, this message translates to:
  /// **'La IA está pensando...'**
  String get aiThinking;

  /// No description provided for @speechError.
  ///
  /// In es, this message translates to:
  /// **'Error de voz:'**
  String speechError(String error);

  /// No description provided for @voiceRecognitionUnavailable.
  ///
  /// In es, this message translates to:
  /// **'Reconocimiento de voz no disponible'**
  String get voiceRecognitionUnavailable;

  /// No description provided for @listening.
  ///
  /// In es, this message translates to:
  /// **'Escuchando...'**
  String get listening;

  /// No description provided for @typeHere.
  ///
  /// In es, this message translates to:
  /// **'Escribe aquí...'**
  String get typeHere;

  /// No description provided for @assistantGreeting.
  ///
  /// In es, this message translates to:
  /// **'¡Hola! Soy tu asistente financiero.'**
  String get assistantGreeting;

  /// No description provided for @assistantDescription.
  ///
  /// In es, this message translates to:
  /// **'Puedo ayudarte a registrar gastos, crear metas y analizar tus finanzas con IA.'**
  String get assistantDescription;

  /// No description provided for @questionExamples.
  ///
  /// In es, this message translates to:
  /// **'EJEMPLOS DE PREGUNTAS'**
  String get questionExamples;

  /// No description provided for @fastExpense.
  ///
  /// In es, this message translates to:
  /// **'Gasto Rápido'**
  String get fastExpense;

  /// No description provided for @fastExpenseSubtitle.
  ///
  /// In es, this message translates to:
  /// **'\"Gané 3000 y gasté 50\"'**
  String get fastExpenseSubtitle;

  /// No description provided for @newGoalSubtitle.
  ///
  /// In es, this message translates to:
  /// **'\"Ahorrar para viaje\"'**
  String get newGoalSubtitle;

  /// No description provided for @iaAnalysis.
  ///
  /// In es, this message translates to:
  /// **'Análisis IA'**
  String get iaAnalysis;

  /// No description provided for @iaAnalysisSubtitle.
  ///
  /// In es, this message translates to:
  /// **'\"Proyección 6 meses\"'**
  String get iaAnalysisSubtitle;

  /// No description provided for @exportSubtitle.
  ///
  /// In es, this message translates to:
  /// **'\"Descargar CSV\"'**
  String get exportSubtitle;

  /// No description provided for @finanzasAi.
  ///
  /// In es, this message translates to:
  /// **'FINANZAS AI'**
  String get finanzasAi;

  /// No description provided for @history.
  ///
  /// In es, this message translates to:
  /// **'HISTORIAL'**
  String get history;

  /// No description provided for @newChat.
  ///
  /// In es, this message translates to:
  /// **'Nuevo Chat'**
  String get newChat;

  /// No description provided for @noSavedConversations.
  ///
  /// In es, this message translates to:
  /// **'No hay conversaciones guardadas.'**
  String get noSavedConversations;

  /// No description provided for @untitledConversation.
  ///
  /// In es, this message translates to:
  /// **'Conversación sin título'**
  String get untitledConversation;

  /// No description provided for @transactionSavedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Movimiento registrado correctamente'**
  String get transactionSavedSuccess;

  /// No description provided for @aiAssistant.
  ///
  /// In es, this message translates to:
  /// **'ASISTENTE IA'**
  String get aiAssistant;

  /// No description provided for @youLabel.
  ///
  /// In es, this message translates to:
  /// **'TÚ'**
  String get youLabel;

  /// No description provided for @premiumAnalysis.
  ///
  /// In es, this message translates to:
  /// **'Análisis Premium'**
  String get premiumAnalysis;

  /// No description provided for @exclusiveContent.
  ///
  /// In es, this message translates to:
  /// **'Contenido exclusivo desbloqueable.'**
  String get exclusiveContent;

  /// No description provided for @deepAiAnalysis.
  ///
  /// In es, this message translates to:
  /// **'Análisis Profundo con IA'**
  String get deepAiAnalysis;

  /// No description provided for @aiGeneratedAnalysis.
  ///
  /// In es, this message translates to:
  /// **'Análisis generado por Finanzas AI'**
  String get aiGeneratedAnalysis;

  /// No description provided for @strategicReportInfo.
  ///
  /// In es, this message translates to:
  /// **'Este reporte contiene información estratégica de alto valor.'**
  String get strategicReportInfo;

  /// No description provided for @unlockVideo.
  ///
  /// In es, this message translates to:
  /// **'Ver Video para Desbloquear'**
  String get unlockVideo;

  /// No description provided for @contentUnlocked.
  ///
  /// In es, this message translates to:
  /// **'¡Contenido desbloqueado!'**
  String get contentUnlocked;

  /// No description provided for @adLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar el anuncio. Intenta de nuevo. ({error})'**
  String adLoadError(String error);

  /// No description provided for @csvReady.
  ///
  /// In es, this message translates to:
  /// **'Reporte Excel/CSV Listo'**
  String get csvReady;

  /// No description provided for @reportLocked.
  ///
  /// In es, this message translates to:
  /// **'Reporte Bloqueado'**
  String get reportLocked;

  /// No description provided for @downloadAdPrompt.
  ///
  /// In es, this message translates to:
  /// **'Ve un anuncio para descargar'**
  String get downloadAdPrompt;

  /// No description provided for @shareCsv.
  ///
  /// In es, this message translates to:
  /// **'Compartir / Guardar CSV'**
  String get shareCsv;

  /// No description provided for @shareCsvText.
  ///
  /// In es, this message translates to:
  /// **'Aquí tienes mi reporte financiero.'**
  String get shareCsvText;

  /// No description provided for @csvShareError.
  ///
  /// In es, this message translates to:
  /// **'Error al compartir CSV:'**
  String csvShareError(String error);

  /// No description provided for @transactionSummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen de Movimientos'**
  String get transactionSummary;

  /// No description provided for @concept.
  ///
  /// In es, this message translates to:
  /// **'Concepto'**
  String get concept;

  /// No description provided for @result.
  ///
  /// In es, this message translates to:
  /// **'Resultó'**
  String get result;

  /// No description provided for @impact.
  ///
  /// In es, this message translates to:
  /// **'Impacto'**
  String get impact;

  /// No description provided for @resultingBalance.
  ///
  /// In es, this message translates to:
  /// **'Balance Resultante'**
  String get resultingBalance;

  /// No description provided for @noRecentData.
  ///
  /// In es, this message translates to:
  /// **'Sin datos recientes'**
  String get noRecentData;

  /// No description provided for @multiTransactionTitle.
  ///
  /// In es, this message translates to:
  /// **'{count} Transacciones'**
  String multiTransactionTitle(int count);

  /// No description provided for @saveAllTransactions.
  ///
  /// In es, this message translates to:
  /// **'Guardar {count} Transacciones'**
  String saveAllTransactions(int count);

  /// No description provided for @allSaved.
  ///
  /// In es, this message translates to:
  /// **'Todo Guardado'**
  String get allSaved;

  /// No description provided for @transactionsSavedCount.
  ///
  /// In es, this message translates to:
  /// **'{count} transacciones guardadas'**
  String transactionsSavedCount(int count);

  /// No description provided for @goalSuggestion.
  ///
  /// In es, this message translates to:
  /// **'Sugerencia de Meta'**
  String get goalSuggestion;

  /// No description provided for @objective.
  ///
  /// In es, this message translates to:
  /// **'Objetivo: {amount}'**
  String objective(String amount);

  /// No description provided for @createGoal.
  ///
  /// In es, this message translates to:
  /// **'Crear Meta'**
  String get createGoal;

  /// No description provided for @goalCreated.
  ///
  /// In es, this message translates to:
  /// **'Meta Creada'**
  String get goalCreated;

  /// No description provided for @analysisAvailable.
  ///
  /// In es, this message translates to:
  /// **'Análisis Disponible'**
  String get analysisAvailable;

  /// No description provided for @viewChartsPrompt.
  ///
  /// In es, this message translates to:
  /// **'Ve a la pestaña \"Movimientos\" para ver los gráficos.'**
  String get viewChartsPrompt;

  /// No description provided for @ticketGenerated.
  ///
  /// In es, this message translates to:
  /// **'Ticket Generado'**
  String get ticketGenerated;

  /// No description provided for @confirmAndSave.
  ///
  /// In es, this message translates to:
  /// **'Confirmar y Guardar'**
  String get confirmAndSave;

  /// No description provided for @balanceActual.
  ///
  /// In es, this message translates to:
  /// **'SALDO ACTUAL'**
  String get balanceActual;

  /// No description provided for @saveError.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar:'**
  String saveError(String error);

  /// No description provided for @total.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @transaction.
  ///
  /// In es, this message translates to:
  /// **'Transacción'**
  String get transaction;

  /// No description provided for @exportCSV.
  ///
  /// In es, this message translates to:
  /// **'Exportar'**
  String get exportCSV;

  /// No description provided for @amountLabel.
  ///
  /// In es, this message translates to:
  /// **'Monto'**
  String get amountLabel;

  /// No description provided for @fastExpenseSuggestion.
  ///
  /// In es, this message translates to:
  /// **'Hoy gané 3000 y gasté 50 en café'**
  String get fastExpenseSuggestion;

  /// No description provided for @newGoalSuggestion.
  ///
  /// In es, this message translates to:
  /// **'Quiero ahorrar para un viaje'**
  String get newGoalSuggestion;

  /// No description provided for @aiAnalysisSuggestion.
  ///
  /// In es, this message translates to:
  /// **'Hazme un análisis estratégico de mis finanzas para los próximos 6 meses'**
  String get aiAnalysisSuggestion;

  /// No description provided for @exportCsvSuggestion.
  ///
  /// In es, this message translates to:
  /// **'Exportar mis movimientos a CSV'**
  String get exportCsvSuggestion;

  /// No description provided for @transactionAi.
  ///
  /// In es, this message translates to:
  /// **'Transacción AI'**
  String get transactionAi;

  /// No description provided for @goalAiDescription.
  ///
  /// In es, this message translates to:
  /// **'Meta creada por AI'**
  String get goalAiDescription;

  /// No description provided for @shareLinkAndCode.
  ///
  /// In es, this message translates to:
  /// **'Compartir Enlace y Código'**
  String get shareLinkAndCode;

  /// No description provided for @onboardingWelcome.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a Finanzas AI'**
  String get onboardingWelcome;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Vamos a configurar tu perfil financiero en unos simples pasos.'**
  String get onboardingSubtitle;

  /// No description provided for @stepBudgetTitle.
  ///
  /// In es, this message translates to:
  /// **'3. Tu Presupuesto'**
  String get stepBudgetTitle;

  /// No description provided for @stepBudgetSubtitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cuánto planeas gastar mensualmente en total?'**
  String get stepBudgetSubtitle;

  /// No description provided for @stepBudgetHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. {amount}'**
  String stepBudgetHint(String amount);

  /// No description provided for @monthlyAvailableMoney.
  ///
  /// In es, this message translates to:
  /// **'Dinero disponible mensual'**
  String get monthlyAvailableMoney;

  /// No description provided for @incomeMinusDebts.
  ///
  /// In es, this message translates to:
  /// **'Tus ingresos menos tus deudas.'**
  String get incomeMinusDebts;

  /// No description provided for @howMuchToAssign.
  ///
  /// In es, this message translates to:
  /// **'¿Cuánto asignarás a tus gastos?'**
  String get howMuchToAssign;

  /// No description provided for @budgetLimitInfo.
  ///
  /// In es, this message translates to:
  /// **'Este será tu límite mensual para gastos fuera de tus deudas.'**
  String get budgetLimitInfo;

  /// No description provided for @stepSaleTitle.
  ///
  /// In es, this message translates to:
  /// **'2. Primera Venta'**
  String get stepSaleTitle;

  /// No description provided for @stepSaleSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Registra tu primera venta o ingreso del día.'**
  String get stepSaleSubtitle;

  /// No description provided for @stepSaleHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Venta de producto'**
  String get stepSaleHint;

  /// No description provided for @stepSourcesTitle.
  ///
  /// In es, this message translates to:
  /// **'1. Fuentes de Dinero'**
  String get stepSourcesTitle;

  /// No description provided for @stepSourcesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Agrega tus fuentes de ingresos regulares.'**
  String get stepSourcesSubtitle;

  /// No description provided for @addSource.
  ///
  /// In es, this message translates to:
  /// **'Agregar Fuente'**
  String get addSource;

  /// No description provided for @sourceName.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la fuente'**
  String get sourceName;

  /// No description provided for @sourceNameHint.
  ///
  /// In es, this message translates to:
  /// **'Sueldo, Freelance, etc.'**
  String get sourceNameHint;

  /// No description provided for @sourceAmount.
  ///
  /// In es, this message translates to:
  /// **'Monto'**
  String get sourceAmount;

  /// No description provided for @sourceFrequency.
  ///
  /// In es, this message translates to:
  /// **'Frecuencia'**
  String get sourceFrequency;

  /// No description provided for @frequencyWeekly.
  ///
  /// In es, this message translates to:
  /// **'Semanal'**
  String get frequencyWeekly;

  /// No description provided for @frequencyMonthly.
  ///
  /// In es, this message translates to:
  /// **'Mensual'**
  String get frequencyMonthly;

  /// No description provided for @finish.
  ///
  /// In es, this message translates to:
  /// **'Finalizar'**
  String get finish;

  /// No description provided for @next.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get next;

  /// No description provided for @back.
  ///
  /// In es, this message translates to:
  /// **'Atrás'**
  String get back;

  /// No description provided for @onboardingComplete.
  ///
  /// In es, this message translates to:
  /// **'¡Configuración completada!'**
  String get onboardingComplete;

  /// No description provided for @budgetRequired.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa un presupuesto válido'**
  String get budgetRequired;

  /// No description provided for @saleRequired.
  ///
  /// In es, this message translates to:
  /// **'Por favor registra tu primera venta'**
  String get saleRequired;

  /// No description provided for @sourcesRequired.
  ///
  /// In es, this message translates to:
  /// **'Por favor agrega al menos una fuente de ingresos'**
  String get sourcesRequired;

  /// No description provided for @stepDebtTitle.
  ///
  /// In es, this message translates to:
  /// **'2. Tus Deudas'**
  String get stepDebtTitle;

  /// No description provided for @stepDebtSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Registra tus deudas actuales para ayudarte a planear.'**
  String get stepDebtSubtitle;

  /// No description provided for @debtsRequired.
  ///
  /// In es, this message translates to:
  /// **'Por favor agrega al menos una deuda o ingresa 0 si no tienes.'**
  String get debtsRequired;

  /// No description provided for @addDebt.
  ///
  /// In es, this message translates to:
  /// **'Agregar Deuda'**
  String get addDebt;

  /// No description provided for @debtName.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la deuda'**
  String get debtName;

  /// No description provided for @debtNameHint.
  ///
  /// In es, this message translates to:
  /// **'Tarjeta de crédito, Préstamo, etc.'**
  String get debtNameHint;

  /// No description provided for @debtAmount.
  ///
  /// In es, this message translates to:
  /// **'Monto total'**
  String get debtAmount;

  /// No description provided for @debtInterest.
  ///
  /// In es, this message translates to:
  /// **'Interés (%)'**
  String get debtInterest;

  /// No description provided for @debtDueDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de pago'**
  String get debtDueDate;

  /// No description provided for @stepGoalTitle.
  ///
  /// In es, this message translates to:
  /// **'4. Tus Metas'**
  String get stepGoalTitle;

  /// No description provided for @stepGoalSubtitle.
  ///
  /// In es, this message translates to:
  /// **'¿Para qué estás ahorrando?'**
  String get stepGoalSubtitle;

  /// No description provided for @addGoal.
  ///
  /// In es, this message translates to:
  /// **'Agregar Meta'**
  String get addGoal;

  /// No description provided for @goalName.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la meta'**
  String get goalName;

  /// No description provided for @goalNameHintOnboarding.
  ///
  /// In es, this message translates to:
  /// **'Viaje, Carro, Emergencias...'**
  String get goalNameHintOnboarding;

  /// No description provided for @goalTarget.
  ///
  /// In es, this message translates to:
  /// **'Monto objetivo'**
  String get goalTarget;

  /// No description provided for @onboardingSummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen Financiero'**
  String get onboardingSummary;

  /// No description provided for @onboardingSummarySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Así se ven tus finanzas configuradas.'**
  String get onboardingSummarySubtitle;

  /// No description provided for @estimatedMonthlyBalance.
  ///
  /// In es, this message translates to:
  /// **'Balance Mensual Estimado'**
  String get estimatedMonthlyBalance;

  /// No description provided for @totalDebts.
  ///
  /// In es, this message translates to:
  /// **'Deudas Totales'**
  String get totalDebts;

  /// No description provided for @totalGoals.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto para Metas'**
  String get totalGoals;

  /// No description provided for @myBudget.
  ///
  /// In es, this message translates to:
  /// **'Mi Presupuesto'**
  String get myBudget;

  /// No description provided for @budgetUsed.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto Usado'**
  String get budgetUsed;

  /// No description provided for @remainingBudget.
  ///
  /// In es, this message translates to:
  /// **'Restante'**
  String get remainingBudget;

  /// No description provided for @debtsTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis Deudas'**
  String get debtsTitle;

  /// No description provided for @chartBudget.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto'**
  String get chartBudget;

  /// No description provided for @chartSavings.
  ///
  /// In es, this message translates to:
  /// **'Ahorros'**
  String get chartSavings;

  /// No description provided for @chartDebt.
  ///
  /// In es, this message translates to:
  /// **'Deuda'**
  String get chartDebt;

  /// No description provided for @onboardingSummaryExplanation.
  ///
  /// In es, this message translates to:
  /// **'Este resumen muestra la relación entre tus ingresos, gastos mensuales presupuestados y deudas. El \'Balance Mensual\' es el dinero disponible que tienes cada mes para ahorrar o invertir.'**
  String get onboardingSummaryExplanation;

  /// No description provided for @totalMonthlyIncome.
  ///
  /// In es, this message translates to:
  /// **'Ingreso Mensual Total'**
  String get totalMonthlyIncome;

  /// No description provided for @monthlyBudgetLimit.
  ///
  /// In es, this message translates to:
  /// **'Límite de Presupuesto'**
  String get monthlyBudgetLimit;

  /// No description provided for @savingCapacityFormula.
  ///
  /// In es, this message translates to:
  /// **'Ingreso ({income}) - Gastos ({budget}) = {balance} libres para metas y emergencias.'**
  String savingCapacityFormula(Object balance, Object budget, Object income);

  /// No description provided for @savingCapacityTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu capacidad de ahorro mensual'**
  String get savingCapacityTitle;

  /// No description provided for @debtPayment.
  ///
  /// In es, this message translates to:
  /// **'Pago mensual'**
  String get debtPayment;

  /// No description provided for @debtPaymentSummary.
  ///
  /// In es, this message translates to:
  /// **'{interest}% - Pagos: {amount}'**
  String debtPaymentSummary(String interest, String amount);

  /// No description provided for @debtPaymentHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. 500'**
  String get debtPaymentHint;

  /// No description provided for @monthlyDebtCommitment.
  ///
  /// In es, this message translates to:
  /// **'Compromiso Mensual de Deuda'**
  String get monthlyDebtCommitment;

  /// No description provided for @realSavingCapacity.
  ///
  /// In es, this message translates to:
  /// **'Capacidad de Ahorro Real'**
  String get realSavingCapacity;

  /// No description provided for @advisorContext.
  ///
  /// In es, this message translates to:
  /// **'Como tu asesor financiero, te sugiero...'**
  String get advisorContext;

  /// No description provided for @financialHealthGood.
  ///
  /// In es, this message translates to:
  /// **'Tu salud financiera se ve sólida. Tienes un excedente positivo para tus metas.'**
  String get financialHealthGood;

  /// No description provided for @financialHealthWarning.
  ///
  /// In es, this message translates to:
  /// **'Atención: Tus compromisos mensuales superan tus ingresos. Necesitas ajustar tu presupuesto.'**
  String get financialHealthWarning;

  /// No description provided for @netCashFlow.
  ///
  /// In es, this message translates to:
  /// **'Flujo de Caja Neto'**
  String get netCashFlow;

  /// No description provided for @savingCapacityFormulaRefined.
  ///
  /// In es, this message translates to:
  /// **'Ingresos ({income}) - Gastos ({budget}) - Pagos Deuda ({debt}) = {balance} libres.'**
  String savingCapacityFormulaRefined(
    Object balance,
    Object budget,
    Object debt,
    Object income,
  );

  /// No description provided for @skip.
  ///
  /// In es, this message translates to:
  /// **'Saltar'**
  String get skip;

  /// No description provided for @skipOnboardingTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Saltar configuración?'**
  String get skipOnboardingTitle;

  /// No description provided for @skipOnboardingMessage.
  ///
  /// In es, this message translates to:
  /// **'Si ya configuraste tu perfil anteriormente, puedes saltar este paso. De lo contrario, te recomendamos completarlo para que la IA pueda darte mejores consejos.'**
  String get skipOnboardingMessage;

  /// No description provided for @monthlyBudgetLabel.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto Mensual'**
  String get monthlyBudgetLabel;

  /// No description provided for @addDebtTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva Deuda'**
  String get addDebtTitle;

  /// No description provided for @debtMonthlyPayment.
  ///
  /// In es, this message translates to:
  /// **'Pago Mensual'**
  String get debtMonthlyPayment;

  /// No description provided for @saveChanges.
  ///
  /// In es, this message translates to:
  /// **'Guardar Cambios'**
  String get saveChanges;

  /// No description provided for @noBudgetSet.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes un presupuesto configurado'**
  String get noBudgetSet;

  /// No description provided for @noDebtsSet.
  ///
  /// In es, this message translates to:
  /// **'No has registrado deudas'**
  String get noDebtsSet;

  /// No description provided for @setupBudget.
  ///
  /// In es, this message translates to:
  /// **'Configurar Presupuesto'**
  String get setupBudget;

  /// No description provided for @setupDebts.
  ///
  /// In es, this message translates to:
  /// **'Registrar Deudas'**
  String get setupDebts;

  /// No description provided for @messageTooLong.
  ///
  /// In es, this message translates to:
  /// **'El mensaje es demasiado largo. Máximo {maxLength} caracteres.'**
  String messageTooLong(int maxLength);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'pt',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
