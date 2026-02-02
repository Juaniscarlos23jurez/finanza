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
  String get categoryLabel => 'Categoría';

  @override
  String get paymentMethod => 'Detalles del Pago';

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

  @override
  String get dashboard => 'Painel';

  @override
  String get balanceTrend => 'Tendência do Saldo';

  @override
  String get yourGoals => 'Suas Metas';

  @override
  String get expensesByCategory => 'Despesas por Categoria';

  @override
  String get recentTransactions => 'Transações Recentes';

  @override
  String get noRecentActivity => 'Nenhuma atividade recente';

  @override
  String hello(String name) {
    return 'Olá, $name';
  }

  @override
  String get helloSimple => 'Olá';

  @override
  String get totalBalance => 'SALDO TOTAL';

  @override
  String get newGoal => 'Nova Meta';

  @override
  String get goalNameHint => 'Nome da Meta (ex. Viagem)';

  @override
  String get targetAmountHint => 'Valor Alvo (\$)';

  @override
  String get noActiveGoals => 'Menhuma meta ativa';

  @override
  String get goal => 'Meta';

  @override
  String get deposit => 'Depositar';

  @override
  String get withdraw => 'Sacar';

  @override
  String get add => 'Adicionar';

  @override
  String get withdrawFromGoal => 'Sacar da Meta';

  @override
  String get depositToGoal => 'Depositar na Meta';

  @override
  String get available => 'Disponível';

  @override
  String get saved => 'Guardado';

  @override
  String get remaining => 'Restante';

  @override
  String get amountToWithdraw => 'Valor a sacar';

  @override
  String get amountToDeposit => 'Valor a depositar';

  @override
  String get allAmount => 'Tudo';

  @override
  String get enterValidAmount => 'Insira um valor válido';

  @override
  String cannotWithdrawMore(String amount) {
    return 'Não pode sacar mais de \$$amount';
  }

  @override
  String withdrewAmount(String amount, String goal) {
    return 'Você sacou \$$amount de \"$goal\"';
  }

  @override
  String depositedAmount(String amount, String goal) {
    return 'Você depositou \$$amount em \"$goal\"!';
  }

  @override
  String get deleteGoal => 'Excluir Meta';

  @override
  String get deleteGoalConfirm => 'Tem certeza que deseja excluir esta meta?';

  @override
  String goalAlreadySavedWarning(String amount) {
    return 'Você já tem \$$amount guardados nesta meta.';
  }

  @override
  String goalDeleted(String goal) {
    return 'Meta \"$goal\" excluída';
  }

  @override
  String get distribution => 'Distribuição';

  @override
  String get noExpensesRegistered => 'Nenhuma despesa registrada';

  @override
  String get invitationTitle => 'Convite!';

  @override
  String invitationBody(String name, String goal) {
    return '$name convidou você para colaborar em: $goal';
  }

  @override
  String get invitationQuestion =>
      'Deseja aceitar este convite e compartilhar o progresso?';

  @override
  String get reject => 'Rejeitar';

  @override
  String get accept => 'Aceitar';

  @override
  String get invitationAccepted => 'Convite aceito';

  @override
  String get unknownUser => 'Alguém';

  @override
  String get defaultGoalName => 'uma meta';

  @override
  String get addSaving => 'Adicionar Economia';

  @override
  String get withdrawFunds => 'Retirar Fundos';

  @override
  String get savingAddedSuccess => 'Economia adicionada com sucesso';

  @override
  String get insufficientFunds => 'Fundos insuficientes';

  @override
  String get withdrawalSuccess => 'Retirada realizada com sucesso';

  @override
  String get currentBalance => 'Saldo atual';

  @override
  String get progress => 'Progresso';

  @override
  String get invite => 'Convidar+';

  @override
  String get progressChartComingSoon => 'Gráfico de progresso em breve!';

  @override
  String get contribution => 'Contribuição';

  @override
  String get withdrawal => 'Retirada';

  @override
  String get goalCreation => 'Criação da meta';

  @override
  String get inviteCollaboratorTitle => 'Convidar Colaborador';

  @override
  String get inviteCollaboratorSubtitle =>
      'Compartilhe esta meta com outra pessoa';

  @override
  String get invitationUserCode => 'Código do Usuário';

  @override
  String get userCodeHint => 'ex. JUAN-1234';

  @override
  String get enterValidCode => 'Insira un código válido';

  @override
  String invitationSentTo(String code) {
    return 'Convite enviado para $code';
  }

  @override
  String get errorSendingInvitation => 'Erro ao enviar convite';

  @override
  String get sendInvitation => 'Enviar Convite';

  @override
  String errorGeneric(String error) {
    return 'Erro: $error';
  }

  @override
  String get aiThinking => 'A IA está pensando...';

  @override
  String speechError(String error) {
    return 'Erro de voz: $error';
  }

  @override
  String get voiceRecognitionUnavailable =>
      'Reconhecimento de voz não disponível';

  @override
  String get listening => 'Ouvindo...';

  @override
  String get typeHere => 'Escreva aqui...';

  @override
  String get assistantGreeting => 'Olá! Sou seu assistente financeiro.';

  @override
  String get assistantDescription =>
      'Posso ajudar você a registrar gastos, criar metas e analisar suas finanças com IA.';

  @override
  String get questionExamples => 'EXEMPLOS DE PERGUNTAS';

  @override
  String get fastExpense => 'Gasto Rápido';

  @override
  String get fastExpenseSubtitle => '\"Ganhei 3000 e gastei 50\"';

  @override
  String get newGoalSubtitle => '\"Economizar para uma viagem\"';

  @override
  String get iaAnalysis => 'Análise IA';

  @override
  String get iaAnalysisSubtitle => '\"Projeção para 6 meses\"';

  @override
  String get exportSubtitle => '\"Baixar CSV\"';

  @override
  String get finanzasAi => 'FINANÇAS IA';

  @override
  String get history => 'HISTÓRICO';

  @override
  String get newChat => 'Novo Chat';

  @override
  String get noSavedConversations => 'Não há conversas salvas.';

  @override
  String get untitledConversation => 'Conversa sem título';

  @override
  String get transactionSavedSuccess => 'Movimento registrado corretamente';

  @override
  String get aiAssistant => 'ASSISTENTE IA';

  @override
  String get youLabel => 'VOCÊ';

  @override
  String get premiumAnalysis => 'Análise Premium';

  @override
  String get exclusiveContent => 'Conteúdo exclusivo desbloqueável.';

  @override
  String get deepAiAnalysis => 'Análise profunda com IA';

  @override
  String get aiGeneratedAnalysis => 'Análise gerada por Finanças IA';

  @override
  String get strategicReportInfo =>
      'Este relatório contém informações estratégicas de alto valor.';

  @override
  String get unlockVideo => 'Ver Vídeo para Desbloquear';

  @override
  String get contentUnlocked => 'Conteúdo desbloqueado!';

  @override
  String adLoadError(String error) {
    return 'Não foi possível carregar o anúncio. Tente novamente. ($error)';
  }

  @override
  String get csvReady => 'Relatório Excel/CSV Pronto';

  @override
  String get reportLocked => 'Relatório Bloqueado';

  @override
  String get downloadAdPrompt => 'Veja um anúncio para baixar';

  @override
  String get shareCsv => 'Compartilhar / Salvar CSV';

  @override
  String get shareCsvText => 'Aqui está meu relatório financeiro.';

  @override
  String csvShareError(String error) {
    return 'Erro ao compartilhar CSV: $error';
  }

  @override
  String get transactionSummary => 'Resumo de Movimentações';

  @override
  String get concept => 'Conceito';

  @override
  String get result => 'Resultado';

  @override
  String get impact => 'Impacto';

  @override
  String get resultingBalance => 'Saldo Resultante';

  @override
  String get noRecentData => 'Sem dados recentes';

  @override
  String multiTransactionTitle(int count) {
    return '$count Transações';
  }

  @override
  String saveAllTransactions(int count) {
    return 'Salvar $count Transações';
  }

  @override
  String get allSaved => 'Tudo Salvo';

  @override
  String transactionsSavedCount(int count) {
    return '$count transações salvas';
  }

  @override
  String get goalSuggestion => 'Sugestão de Meta';

  @override
  String objective(String amount) {
    return 'Objetivo: $amount';
  }

  @override
  String get createGoal => 'Criar Meta';

  @override
  String get goalCreated => 'Meta Criada';

  @override
  String get analysisAvailable => 'Análise Disponível';

  @override
  String get viewChartsPrompt =>
      'Vá para a aba \'Movimentações\' para ver os gráficos.';

  @override
  String get ticketGenerated => 'Ticket Gerado';

  @override
  String get confirmAndSave => 'Confirmar e Salvar';

  @override
  String get balanceActual => 'SALDO ATUAL';

  @override
  String saveError(String error) {
    return 'Erro ao salvar: $error';
  }

  @override
  String get total => 'Total';

  @override
  String get transaction => 'Transação';

  @override
  String get exportCSV => 'Exportar';

  @override
  String get amountLabel => 'Quantia';

  @override
  String get fastExpenseSuggestion => 'Hoje ganhei 3000 e gastei 50 em café';

  @override
  String get newGoalSuggestion => 'Quero economizar para uma viagem';

  @override
  String get aiAnalysisSuggestion =>
      'Faça uma análise estratégica das minhas finanças para os próximos 6 meses';

  @override
  String get exportCsvSuggestion => 'Exportar minhas movimentações para CSV';

  @override
  String get transactionAi => 'Transação IA';

  @override
  String get goalAiDescription => 'Meta criada por IA';

  @override
  String get shareLinkAndCode => 'Compartilhar Link e Código';

  @override
  String get onboardingWelcome => 'Bienvenido a Finanzas AI';

  @override
  String get onboardingSubtitle =>
      'Vamos a configurar tu perfil financiero en unos simples pasos.';

  @override
  String get stepBudgetTitle => '1. Tu Presupuesto';

  @override
  String get stepBudgetSubtitle =>
      '¿Cuánto planeas gastar mensualmente en total?';

  @override
  String get stepBudgetHint => 'Ej. 5000';

  @override
  String get stepSaleTitle => '2. Primera Venta';

  @override
  String get stepSaleSubtitle => 'Registra tu primera venta o ingreso del día.';

  @override
  String get stepSaleHint => 'Ej. Venta de producto';

  @override
  String get stepSourcesTitle => '2. Fuentes de Dinero';

  @override
  String get stepSourcesSubtitle => 'Agrega tus fuentes de ingresos regulares.';

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
  String get stepDebtTitle => '3. Tus Deudas';

  @override
  String get stepDebtSubtitle =>
      'Registra tus deudas actuales para ayudarte a planear.';

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
  String get stepGoalTitle => '4. Tus Metas';

  @override
  String get stepGoalSubtitle => '¿Para qué estás ahorrando?';

  @override
  String get addGoal => 'Agregar Meta';

  @override
  String get goalName => 'Nombre de la meta';

  @override
  String get goalNameHintOnboarding => 'Viaje, Carro, Emergencias...';

  @override
  String get goalTarget => 'Monto objetivo';

  @override
  String get onboardingSummary => 'Resumen Financiero';

  @override
  String get onboardingSummarySubtitle =>
      'Así se ven tus finanzas configuradas.';

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
  String get totalMonthlyIncome => 'Ingreso Mensual Total';

  @override
  String get monthlyBudgetLimit => 'Límite de Presupuesto';

  @override
  String savingCapacityFormula(Object balance, Object budget, Object income) {
    return 'Ingreso ($income) - Gastos ($budget) = $balance libres para metas y emergencias.';
  }

  @override
  String get savingCapacityTitle => 'Tu capacidad de ahorro mensual';

  @override
  String get debtPayment => 'Pago mensual';

  @override
  String get debtPaymentHint => 'Ej. 500';

  @override
  String get monthlyDebtCommitment => 'Compromiso Mensual de Deuda';

  @override
  String get realSavingCapacity => 'Capacidad de Ahorro Real';

  @override
  String get advisorContext => 'Como tu asesor financiero, te sugiero...';

  @override
  String get financialHealthGood =>
      'Tu salud financiera se ve sólida. Tienes un excedente positivo para tus metas.';

  @override
  String get financialHealthWarning =>
      'Atención: Tus compromisos mensuales superan tus ingresos. Necesitas ajustar tu presupuesto.';

  @override
  String get netCashFlow => 'Flujo de Caja Neto';

  @override
  String savingCapacityFormulaRefined(
    Object balance,
    Object budget,
    Object debt,
    Object income,
  ) {
    return 'Ingresos ($income) - Gastos ($budget) - Pagos Deuda ($debt) = $balance libres.';
  }
}
