// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get accountSection => 'ACCOUNT';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get scheduleReport => 'Schedule Report';

  @override
  String get otherSection => 'OTHER';

  @override
  String get feedback => 'Feedback';

  @override
  String get termsConditions => 'Terms and Conditions';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get logout => 'Log Out';

  @override
  String get deleteAccount => 'Delete my account permanently';

  @override
  String get deleteAccountTitle => 'Delete account?';

  @override
  String get deleteAccountContent =>
      'This action will close your current session.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get feedbackTitle => 'Give us your Feedback';

  @override
  String get feedbackSubtitle =>
      'Your opinion helps us improve the experience for everyone.';

  @override
  String get feedbackTypeQuestion => 'What is your comment about?';

  @override
  String get typeSuggestion => 'Suggestion';

  @override
  String get typeError => 'Error';

  @override
  String get typeCompliment => 'Compliment';

  @override
  String get feedbackHint => 'Tell us what you like or what we can improve...';

  @override
  String get sendFeedback => 'Send Comments';

  @override
  String get feedbackSuccess => 'Thanks for your feedback!';

  @override
  String get fullName => 'Full Name';

  @override
  String get email => 'Email';

  @override
  String get userId => 'User ID';

  @override
  String get close => 'Close';

  @override
  String get scheduleReportTitle => 'Schedule Report';

  @override
  String get reportDescription =>
      'You will receive an Excel file with your transactions and an AI-generated financial analysis.';

  @override
  String get sendReportTo => 'Send report to:';

  @override
  String get frequencyQuestion => 'Every how many days?';

  @override
  String daysLoop(int count) {
    return '$count days';
  }

  @override
  String get confirmAndSchedule => 'Confirm and Schedule';

  @override
  String get configSaved => 'Configuration saved successfully!';

  @override
  String get language => 'Language';

  @override
  String get fillAllFields => 'Please fill all fields';

  @override
  String googleError(String error) {
    return 'Google Error: $error';
  }

  @override
  String appleError(String error) {
    return 'Apple Error: $error';
  }

  @override
  String get welcomeBack => 'Welcome\nback.';

  @override
  String get password => 'Password';

  @override
  String get loggingIn => 'Logging in...';

  @override
  String get login => 'Log In';

  @override
  String get or => 'OR';

  @override
  String get loading => 'Loading...';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get register => 'Sign Up';

  @override
  String get createAccount => 'Create\nAccount.';

  @override
  String get name => 'Name';

  @override
  String get registering => 'Registering...';

  @override
  String get signUp => 'Sign Up';
}
