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
}
