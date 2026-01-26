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
