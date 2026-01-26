// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get accountSection => 'アカウント';

  @override
  String get personalInfo => '個人情報';

  @override
  String get scheduleReport => 'レポートのスケジュール';

  @override
  String get otherSection => 'その他';

  @override
  String get feedback => 'フィードバック';

  @override
  String get termsConditions => '利用規約';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get logout => 'ログアウト';

  @override
  String get deleteAccount => 'アカウントを完全に削除する';

  @override
  String get deleteAccountTitle => 'アカウントを削除しますか？';

  @override
  String get deleteAccountContent => 'この操作を行うと、現在のセッションが終了します。';

  @override
  String get cancel => 'キャンセル';

  @override
  String get confirm => '確認';

  @override
  String get feedbackTitle => 'フィードバックを送る';

  @override
  String get feedbackSubtitle => 'あなたの意見は、すべての人のための体験を向上させるのに役立ちます。';

  @override
  String get feedbackTypeQuestion => 'コメントの内容は何ですか？';

  @override
  String get typeSuggestion => '提案';

  @override
  String get typeError => 'エラー';

  @override
  String get typeCompliment => '称賛';

  @override
  String get feedbackHint => '気に入った点や改善できる点を教えてください...';

  @override
  String get sendFeedback => '送信';

  @override
  String get feedbackSuccess => 'フィードバックありがとうございます！';

  @override
  String get fullName => '氏名';

  @override
  String get email => 'メールアドレス';

  @override
  String get userId => 'ユーザーID';

  @override
  String get close => '閉じる';

  @override
  String get scheduleReportTitle => 'レポートのスケジュール';

  @override
  String get reportDescription => '取引履歴とAI生成の財務分析を含むExcelファイルを受け取ります。';

  @override
  String get sendReportTo => 'レポートの送信先:';

  @override
  String get frequencyQuestion => '何日ごとの送信ですか？';

  @override
  String daysLoop(int count) {
    return '$count 日';
  }

  @override
  String get confirmAndSchedule => '確認してスケジュール';

  @override
  String get configSaved => '設定が正常に保存されました！';

  @override
  String get language => '言語';

  @override
  String get fillAllFields => 'すべての項目を入力してください';

  @override
  String googleError(String error) {
    return 'Googleエラー: $error';
  }

  @override
  String appleError(String error) {
    return 'Appleエラー: $error';
  }

  @override
  String get welcomeBack => 'おかえり\nなさい。';

  @override
  String get password => 'パスワード';

  @override
  String get loggingIn => 'ログイン中...';

  @override
  String get login => 'ログイン';

  @override
  String get or => 'または';

  @override
  String get loading => '読み込み中...';

  @override
  String get continueWithGoogle => 'Googleで続ける';

  @override
  String get continueWithApple => 'Appleで続ける';

  @override
  String get dontHaveAccount => 'アカウントをお持ちでないですか？ ';

  @override
  String get register => '登録する';

  @override
  String get createAccount => 'アカウント\n作成';

  @override
  String get name => '名前';

  @override
  String get registering => '登録中...';

  @override
  String get signUp => '登録する';

  @override
  String get transactions => '取引履歴';

  @override
  String get filterByDate => '日付で絞り込み';

  @override
  String get ready => '完了';

  @override
  String get all => 'すべて';

  @override
  String get incomes => '収入';

  @override
  String get expenses => '支出';

  @override
  String get clearDate => '日付をクリア';

  @override
  String get noDataChart => 'グラフデータがありません';

  @override
  String get trend => 'トレンド (7日間)';

  @override
  String get weeklyExpenses => '週間支出';

  @override
  String get weeklyIncome => '週間収入';

  @override
  String get byCategory => 'カテゴリー別';

  @override
  String get seeFull => 'すべて見る';

  @override
  String get noTransactions => '取引はありません';

  @override
  String get opens => '開始:';

  @override
  String get closes => '終了:';

  @override
  String get noDescription => '説明なし';

  @override
  String get editTransaction => '取引の編集';

  @override
  String get description => '説明';

  @override
  String get amount => '金額';

  @override
  String get date => '日付';

  @override
  String get save => '保存';

  @override
  String get delete => '削除';

  @override
  String get deleteTransactionConfirm => 'この取引を削除してもよろしいですか？';

  @override
  String get transactionDeleted => '取引が削除されました';

  @override
  String deleteError(String error) {
    return '削除エラー: $error';
  }

  @override
  String get today => '今日';

  @override
  String get yesterday => '昨日';

  @override
  String get general => '一般';

  @override
  String get others => 'その他';

  @override
  String get dashboard => 'ダッシュボード';

  @override
  String get balanceTrend => '残高推移';

  @override
  String get yourGoals => '目標';

  @override
  String get expensesByCategory => 'カテゴリー別支出';

  @override
  String get recentTransactions => '最近の取引';

  @override
  String get noRecentActivity => '最近の活動はありません';

  @override
  String hello(String name) {
    return 'こんにちは、$nameさん';
  }

  @override
  String get helloSimple => 'こんにちは';

  @override
  String get totalBalance => '総残高';

  @override
  String get newGoal => '新しい目標';

  @override
  String get goalNameHint => '目標名 (例: 旅行)';

  @override
  String get targetAmountHint => '目標金額 (\$)';

  @override
  String get noActiveGoals => 'アクティブな目標はありません';

  @override
  String get goal => '目標';

  @override
  String get deposit => '入金';

  @override
  String get withdraw => '出金';

  @override
  String get add => '追加';

  @override
  String get withdrawFromGoal => '目標から出金';

  @override
  String get depositToGoal => '目標に入金';

  @override
  String get available => '利用可能';

  @override
  String get saved => '貯蓄額';

  @override
  String get remaining => '残り';

  @override
  String get amountToWithdraw => '出金金額';

  @override
  String get amountToDeposit => '入金金額';

  @override
  String get allAmount => '全額';

  @override
  String get enterValidAmount => '有効な金額を入力してください';

  @override
  String cannotWithdrawMore(String amount) {
    return '\$$amount以上は出金できません';
  }

  @override
  String withdrewAmount(String amount, String goal) {
    return '\"$goal\"から\$$amountを出金しました';
  }

  @override
  String depositedAmount(String amount, String goal) {
    return '\"$goal\"に\$$amountを入金しました！';
  }

  @override
  String get deleteGoal => '目標を削除';

  @override
  String get deleteGoalConfirm => 'この目標を削除してもよろしいですか？';

  @override
  String goalAlreadySavedWarning(String amount) {
    return 'この目標にはすでに\$$amountの貯蓄があります。';
  }

  @override
  String goalDeleted(String goal) {
    return '目標\"$goal\"を削除しました';
  }

  @override
  String get distribution => '内訳';

  @override
  String get noExpensesRegistered => '支出の記録はありません';

  @override
  String get invitationTitle => '招待！';

  @override
  String invitationBody(String name, String goal) {
    return '$nameさんが目標「$goal」への協力を招待しています';
  }

  @override
  String get invitationQuestion => 'この招待を受け入れて進捗を共有しますか？';

  @override
  String get reject => '拒否';

  @override
  String get accept => '承諾';

  @override
  String get invitationAccepted => '招待を承諾しました';

  @override
  String get unknownUser => '誰か';

  @override
  String get defaultGoalName => '目標';

  @override
  String get addSaving => '貯蓄を追加';

  @override
  String get withdrawFunds => '資金を引き出す';

  @override
  String get savingAddedSuccess => '貯蓄が正常に追加されました';

  @override
  String get insufficientFunds => '残高不足です';

  @override
  String get withdrawalSuccess => '引き出しが正常に完了しました';

  @override
  String get currentBalance => '現在の残高';

  @override
  String get progress => '進捗';

  @override
  String get invite => '招待+';

  @override
  String get progressChartComingSoon => '進捗グラフは近日公開予定です！';

  @override
  String get contribution => '寄付';

  @override
  String get withdrawal => '引き出し';

  @override
  String get goalCreation => '目標作成';

  @override
  String get inviteCollaboratorTitle => '共同作業者を招待';

  @override
  String get inviteCollaboratorSubtitle => 'この目標を他の人と共有する';

  @override
  String get invitationUserCode => 'ユーザーコード';

  @override
  String get userCodeHint => '例: JUAN-1234';

  @override
  String get enterValidCode => '有効なコードを入力してください';

  @override
  String invitationSentTo(String code) {
    return '$code に招待を送信しました';
  }

  @override
  String get errorSendingInvitation => '招待の送信中にエラーが発生しました';

  @override
  String get sendInvitation => '招待を送信';

  @override
  String errorGeneric(String error) {
    return 'エラー: $error';
  }

  @override
  String get aiThinking => 'La IA está pensando...';

  @override
  String speechError(String error) {
    return 'Error de voz: $error';
  }

  @override
  String get voiceRecognitionUnavailable =>
      'Reconocimiento de voz no disponible';

  @override
  String get listening => 'Escuchando...';

  @override
  String get typeHere => 'Escribe aquí...';

  @override
  String get assistantGreeting => '¡Hola! Soy tu asistente financiero.';

  @override
  String get assistantDescription =>
      'Puedo ayudarte a registrar gastos, crear metas y analizar tus finanzas con IA.';

  @override
  String get questionExamples => 'EJEMPLOS DE PREGUNTAS';

  @override
  String get fastExpense => 'Gasto Rápido';

  @override
  String get fastExpenseSubtitle => '\"Gané 3000 y gasté 50\"';

  @override
  String get newGoalSubtitle => '\"Ahorrar para viaje\"';

  @override
  String get iaAnalysis => 'Análisis IA';

  @override
  String get iaAnalysisSubtitle => '\"Proyección 6 meses\"';

  @override
  String get exportSubtitle => '\"Descargar CSV\"';

  @override
  String get finanzasAi => 'FINANZAS AI';

  @override
  String get history => 'HISTORIAL';

  @override
  String get newChat => 'Nuevo Chat';

  @override
  String get noSavedConversations => 'No hay conversaciones guardadas.';

  @override
  String get untitledConversation => 'Conversación sin título';

  @override
  String get transactionSavedSuccess => 'Movimiento registrado correctamente';

  @override
  String get aiAssistant => 'ASISTENTE IA';

  @override
  String get youLabel => 'TÚ';

  @override
  String get premiumAnalysis => 'Análisis Premium';

  @override
  String get exclusiveContent => 'Contenido exclusivo desbloqueable.';

  @override
  String get deepAiAnalysis => 'Análisis Profundo con IA';

  @override
  String get aiGeneratedAnalysis => 'Análisis generado por Finanzas AI';

  @override
  String get strategicReportInfo =>
      'Este reporte contiene información estratégica de alto valor.';

  @override
  String get unlockVideo => 'Ver Video para Desbloquear';

  @override
  String get contentUnlocked => '¡Contenido desbloqueado!';

  @override
  String adLoadError(String error) {
    return 'No se pudo cargar el anuncio. Intenta de nuevo. ($error)';
  }

  @override
  String get csvReady => 'Reporte Excel/CSV Listo';

  @override
  String get reportLocked => 'Reporte Bloqueado';

  @override
  String get downloadAdPrompt => 'Ve un anuncio para descargar';

  @override
  String get shareCsv => 'Compartir / Guardar CSV';

  @override
  String get shareCsvText => 'Aquí tienes mi reporte financiero.';

  @override
  String csvShareError(String error) {
    return 'Error al compartir CSV: $error';
  }

  @override
  String get transactionSummary => 'Resumen de Movimientos';

  @override
  String get concept => 'Concepto';

  @override
  String get result => 'Resultó';

  @override
  String get impact => 'Impacto';

  @override
  String get resultingBalance => 'Balance Resultante';

  @override
  String get noRecentData => 'Sin datos recientes';

  @override
  String multiTransactionTitle(int count) {
    return '$count Transacciones';
  }

  @override
  String saveAllTransactions(int count) {
    return 'Guardar $count Transacciones';
  }

  @override
  String get allSaved => 'Todo Guardado';

  @override
  String transactionsSavedCount(int count) {
    return '$count transacciones guardadas';
  }

  @override
  String get goalSuggestion => 'Sugerencia de Meta';

  @override
  String objective(String amount) {
    return 'Objetivo: $amount';
  }

  @override
  String get createGoal => 'Crear Meta';

  @override
  String get goalCreated => 'Meta Creada';

  @override
  String get analysisAvailable => 'Análisis Disponible';

  @override
  String get viewChartsPrompt =>
      'Ve a la pestaña \"Movimientos\" para ver los gráficos.';

  @override
  String get ticketGenerated => 'Ticket Generado';

  @override
  String get confirmAndSave => 'Confirmar y Guardar';

  @override
  String get balanceActual => 'BALANCE ACTUAL';
}
