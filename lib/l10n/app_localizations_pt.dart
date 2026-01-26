// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get accountSection => 'CONTA';

  @override
  String get personalInfo => 'Informações Pessoais';

  @override
  String get scheduleReport => 'Agendar Relatório';

  @override
  String get otherSection => 'OUTRO';

  @override
  String get feedback => 'Feedback';

  @override
  String get termsConditions => 'Termos e Condições';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get logout => 'Sair';

  @override
  String get deleteAccount => 'Excluir minha conta permanentemente';

  @override
  String get deleteAccountTitle => 'Excluir conta?';

  @override
  String get deleteAccountContent => 'Esta ação encerrará sua sessão atual.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get feedbackTitle => 'Dê seu Feedback';

  @override
  String get feedbackSubtitle =>
      'Sua opinião nos ajuda a melhorar a experiência para todos.';

  @override
  String get feedbackTypeQuestion => 'Sobre o que é seu comentário?';

  @override
  String get typeSuggestion => 'Sugestão';

  @override
  String get typeError => 'Erro';

  @override
  String get typeCompliment => 'Elogio';

  @override
  String get feedbackHint =>
      'Conte-nos o que você gosta ou o que podemos melhorar...';

  @override
  String get sendFeedback => 'Enviar Comentários';

  @override
  String get feedbackSuccess => 'Obrigado pelo seu feedback!';

  @override
  String get fullName => 'Nome Completo';

  @override
  String get email => 'E-mail';

  @override
  String get userId => 'ID do Usuário';

  @override
  String get close => 'Fechar';

  @override
  String get scheduleReportTitle => 'Agendar Relatório';

  @override
  String get reportDescription =>
      'Você receberá um arquivo Excel com suas transações e uma análise financeira gerada por IA.';

  @override
  String get sendReportTo => 'Enviar relatório para:';

  @override
  String get frequencyQuestion => 'A cada quantos dias?';

  @override
  String daysLoop(int count) {
    return '$count dias';
  }

  @override
  String get confirmAndSchedule => 'Confirmar e Agendar';

  @override
  String get configSaved => 'Configuração salva com sucesso!';

  @override
  String get language => 'Idioma';
}
