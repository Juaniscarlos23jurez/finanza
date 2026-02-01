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
  String get categoryLabel => 'Categoría';

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
  String get aiThinking => 'AIが考えています...';

  @override
  String speechError(String error) {
    return '音声エラー: $error';
  }

  @override
  String get voiceRecognitionUnavailable => '音声認識は利用できません';

  @override
  String get listening => '聞き取り中...';

  @override
  String get typeHere => 'ここに入力...';

  @override
  String get assistantGreeting => 'こんにちは！私はあなたの財務アシスタントです。';

  @override
  String get assistantDescription => '支出の記録、目標の作成、AIによる財務分析のお手伝いをします。';

  @override
  String get questionExamples => '質問の例';

  @override
  String get fastExpense => 'クイック支出';

  @override
  String get fastExpenseSubtitle => '「3000円稼いで50円使った」';

  @override
  String get newGoalSubtitle => '「旅行のために貯金する」';

  @override
  String get iaAnalysis => 'AI分析';

  @override
  String get iaAnalysisSubtitle => '「6ヶ月の予測」';

  @override
  String get exportSubtitle => '「CSVをダウンロード」';

  @override
  String get finanzasAi => '財務AI';

  @override
  String get history => '履歴';

  @override
  String get newChat => '新しいチャット';

  @override
  String get noSavedConversations => '保存された会話はありません。';

  @override
  String get untitledConversation => '無題の会話';

  @override
  String get transactionSavedSuccess => '取引が正常に記録されました';

  @override
  String get aiAssistant => 'AIアシスタント';

  @override
  String get youLabel => 'あなた';

  @override
  String get premiumAnalysis => 'プレミアム分析';

  @override
  String get exclusiveContent => '独占的なアンロック可能コンテンツ。';

  @override
  String get deepAiAnalysis => 'AIによる詳細分析';

  @override
  String get aiGeneratedAnalysis => '財務AIによる分析';

  @override
  String get strategicReportInfo => 'このレポートには価値の高い戦略的情報が含まれています。';

  @override
  String get unlockVideo => '動画を見てアンロック';

  @override
  String get contentUnlocked => 'コンテンツがアンロックされました！';

  @override
  String adLoadError(String error) {
    return '広告を読み込めませんでした。もう一度お試しください。($error)';
  }

  @override
  String get csvReady => 'Excel/CSVレポートの準備完了';

  @override
  String get reportLocked => 'レポートはロックされています';

  @override
  String get downloadAdPrompt => '動画を見てダウンロード';

  @override
  String get shareCsv => 'CSVを共有 / 保存';

  @override
  String get shareCsvText => '私の財務レポートです。';

  @override
  String csvShareError(String error) {
    return 'CSVの共有中にエラーが発生しました: $error';
  }

  @override
  String get transactionSummary => '取引概要';

  @override
  String get concept => '項目';

  @override
  String get result => '結果';

  @override
  String get impact => '影響';

  @override
  String get resultingBalance => '最終残高';

  @override
  String get noRecentData => '最近のデータはありません';

  @override
  String multiTransactionTitle(int count) {
    return '$count件の取引';
  }

  @override
  String saveAllTransactions(int count) {
    return '$count件の取引を保存';
  }

  @override
  String get allSaved => 'すべて保存完了';

  @override
  String transactionsSavedCount(int count) {
    return '$count件の取引を保存しました';
  }

  @override
  String get goalSuggestion => '目標の提案';

  @override
  String objective(String amount) {
    return '目標: $amount';
  }

  @override
  String get createGoal => '目標を作成';

  @override
  String get goalCreated => '目標を作成しました';

  @override
  String get analysisAvailable => '分析が利用可能です';

  @override
  String get viewChartsPrompt => '「取引」タブでグラフを確認してください。';

  @override
  String get ticketGenerated => 'チケットが生成されました';

  @override
  String get confirmAndSave => '確認して保存';

  @override
  String get balanceActual => '現在の残高';

  @override
  String saveError(String error) {
    return '保存エラー: $error';
  }

  @override
  String get total => '合計';

  @override
  String get transaction => '取引';

  @override
  String get exportCSV => '書き出し';

  @override
  String get amountLabel => '金額';

  @override
  String get fastExpenseSuggestion => '今日は3000円稼いで、コーヒーに50円使いました';

  @override
  String get newGoalSuggestion => '旅行のために貯金したいです';

  @override
  String get aiAnalysisSuggestion => '今後6ヶ月間の財務状況を戦略的に分析してください';

  @override
  String get exportCsvSuggestion => '取引履歴をCSVで書き出してください';

  @override
  String get transactionAi => 'AI取引';

  @override
  String get goalAiDescription => 'AIによって作成された目標';

  @override
  String get shareLinkAndCode => 'リンクとコードを共有';

  @override
  String get onboardingWelcome => 'Bienvenido a Finanzas AI';

  @override
  String get onboardingSubtitle =>
      'Vamos a configurar tu perfil financiero en 3 simples pasos.';

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
  String get stepSourcesTitle => '3. Fuentes de Dinero';

  @override
  String get stepSourcesSubtitle => 'Agrega tus fuentes de ingresos regulares.';

  @override
  String get addSource => 'Agregar Fuente';

  @override
  String get sourceName => 'Nombre de la fuente';

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
  String get stepDebtTitle => '4. Tus Deudas';

  @override
  String get stepDebtSubtitle =>
      'Registra tus deudas actuales para ayudarte a planear.';

  @override
  String get addDebt => 'Agregar Deuda';

  @override
  String get debtName => 'Nombre de la deuda';

  @override
  String get debtAmount => 'Monto total';

  @override
  String get debtInterest => 'Interés (%)';

  @override
  String get debtDueDate => 'Fecha de pago';

  @override
  String get stepGoalTitle => '5. Tus Metas';

  @override
  String get stepGoalSubtitle => '¿Para qué estás ahorrando?';

  @override
  String get addGoal => 'Agregar Meta';

  @override
  String get goalName => 'Nombre de la meta';

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
}
