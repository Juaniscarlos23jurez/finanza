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

  @override
  String get fillAllFields => 'Por favor, preencha todos os campos';

  @override
  String googleError(String error) {
    return 'Erro no Google: $error';
  }

  @override
  String appleError(String error) {
    return 'Erro na Apple: $error';
  }

  @override
  String get welcomeBack => 'Bem-vindo\nde volta.';

  @override
  String get password => 'Senha';

  @override
  String get loggingIn => 'Entrando...';

  @override
  String get login => 'Entrar';

  @override
  String get or => 'OU';

  @override
  String get loading => 'Carregando...';

  @override
  String get continueWithGoogle => 'Continuar com Google';

  @override
  String get continueWithApple => 'Continuar com Apple';

  @override
  String get dontHaveAccount => 'Não tem uma conta? ';

  @override
  String get register => 'Cadastre-se';

  @override
  String get createAccount => 'Criar\nConta.';

  @override
  String get name => 'Nome';

  @override
  String get registering => 'Cadastrando...';

  @override
  String get signUp => 'Cadastrar';

  @override
  String get transactions => 'Transações';

  @override
  String get filterByDate => 'Filtrar por Data';

  @override
  String get ready => 'Pronto';

  @override
  String get all => 'Todos';

  @override
  String get incomes => 'Receitas';

  @override
  String get expenses => 'Despesas';

  @override
  String get clearDate => 'Limpar Data';

  @override
  String get noDataChart => 'Sem dados para gráfico';

  @override
  String get trend => 'Tendência (7 dias)';

  @override
  String get weeklyExpenses => 'Despesas Semanais';

  @override
  String get weeklyIncome => 'Receitas Semanais';

  @override
  String get byCategory => 'Por Categoria';

  @override
  String get seeFull => 'Ver Completo';

  @override
  String get noTransactions => 'Sem transações';

  @override
  String get opens => 'Abre:';

  @override
  String get closes => 'Fecha:';

  @override
  String get noDescription => 'Sem descrição';

  @override
  String get editTransaction => 'Editar Transação';

  @override
  String get description => 'Descrição';

  @override
  String get amount => 'Valor';

  @override
  String get date => 'Data';

  @override
  String get save => 'Salvar';

  @override
  String get delete => 'Excluir';

  @override
  String get deleteTransactionConfirm =>
      'Tem certeza que deseja excluir esta transação?';

  @override
  String get transactionDeleted => 'Transação excluída';

  @override
  String deleteError(String error) {
    return 'Erro ao excluir: $error';
  }

  @override
  String get today => 'Hoje';

  @override
  String get yesterday => 'Ontem';

  @override
  String get general => 'Geral';

  @override
  String get others => 'Outros';
}
