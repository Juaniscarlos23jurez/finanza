// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get accountSection => 'CUENTA';

  @override
  String get personalInfo => 'Información Personal';

  @override
  String get scheduleReport => 'Programar Envío de Reporte';

  @override
  String get otherSection => 'OTRO';

  @override
  String get feedback => 'Feedback';

  @override
  String get termsConditions => 'Términos y Condiciones';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get deleteAccount => 'Eliminar mi cuenta permanentemente';

  @override
  String get deleteAccountTitle => '¿Eliminar cuenta?';

  @override
  String get deleteAccountContent => 'Esta acción cerrará tu sesión actual.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get feedbackTitle => 'Danos tu Feedback';

  @override
  String get feedbackSubtitle =>
      'Tu opinión nos ayuda a mejorar la experiencia para todos.';

  @override
  String get feedbackTypeQuestion => '¿De qué trata tu comentario?';

  @override
  String get typeSuggestion => 'Sugerencia';

  @override
  String get typeError => 'Error';

  @override
  String get typeCompliment => 'Felicitación';

  @override
  String get feedbackHint => 'Cuéntanos qué te gusta o qué podemos mejorar...';

  @override
  String get sendFeedback => 'Enviar Comentarios';

  @override
  String get feedbackSuccess => '¡Gracias por tu feedback!';

  @override
  String get fullName => 'Nombre Completo';

  @override
  String get email => 'Correo Electrónico';

  @override
  String get userId => 'ID de Usuario';

  @override
  String get close => 'Cerrar';

  @override
  String get scheduleReportTitle => 'Programar Reporte';

  @override
  String get reportDescription =>
      'Recibirás un Excel con tus movimientos y un análisis financiero generado por IA.';

  @override
  String get sendReportTo => 'Enviar reporte a:';

  @override
  String get frequencyQuestion => '¿Cada cuántos días?';

  @override
  String daysLoop(int count) {
    return '$count días';
  }

  @override
  String get confirmAndSchedule => 'Confirmar y Programar';

  @override
  String get configSaved => '¡Configuración guardada con éxito!';

  @override
  String get language => 'Idioma';

  @override
  String get fillAllFields => 'Por favor llena todos los campos';

  @override
  String googleError(String error) {
    return 'Error con Google: $error';
  }

  @override
  String appleError(String error) {
    return 'Error con Apple: $error';
  }

  @override
  String get welcomeBack => 'Bienvenido\nde nuevo.';

  @override
  String get password => 'Contraseña';

  @override
  String get loggingIn => 'Iniciando sesión...';

  @override
  String get login => 'Iniciar Sesión';

  @override
  String get or => 'O';

  @override
  String get loading => 'Cargando...';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get continueWithApple => 'Continuar con Apple';

  @override
  String get dontHaveAccount => '¿No tienes cuenta? ';

  @override
  String get register => 'Regístrate';

  @override
  String get createAccount => 'Crear\nCuenta.';

  @override
  String get name => 'Nombre';

  @override
  String get registering => 'Registrando...';

  @override
  String get signUp => 'Registrarse';
}
