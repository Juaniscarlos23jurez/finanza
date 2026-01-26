// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get accountSection => '账户';

  @override
  String get personalInfo => '个人信息';

  @override
  String get scheduleReport => '安排报告';

  @override
  String get otherSection => '其他';

  @override
  String get feedback => '反馈';

  @override
  String get termsConditions => '条款和条件';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get logout => '退出登录';

  @override
  String get deleteAccount => '永久删除我的账户';

  @override
  String get deleteAccountTitle => '删除账户？';

  @override
  String get deleteAccountContent => '此操作将结束您当前的会话。';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确认';

  @override
  String get feedbackTitle => '给我们反馈';

  @override
  String get feedbackSubtitle => '您的意见有助于我们改善所有人的体验。';

  @override
  String get feedbackTypeQuestion => '您的评论关于什么？';

  @override
  String get typeSuggestion => '建议';

  @override
  String get typeError => '错误';

  @override
  String get typeCompliment => '赞扬';

  @override
  String get feedbackHint => '告诉我们您喜欢什么或我们可以改进什么...';

  @override
  String get sendFeedback => '发送评论';

  @override
  String get feedbackSuccess => '感谢您的反馈！';

  @override
  String get fullName => '全名';

  @override
  String get email => '电子邮件';

  @override
  String get userId => '用户ID';

  @override
  String get close => '关闭';

  @override
  String get scheduleReportTitle => '安排报告';

  @override
  String get reportDescription => '您将收到包含您的交易和AI生成的财务分析的Excel文件。';

  @override
  String get sendReportTo => '发送报告至：';

  @override
  String get frequencyQuestion => '每多少天？';

  @override
  String daysLoop(int count) {
    return '$count 天';
  }

  @override
  String get confirmAndSchedule => '确认并安排';

  @override
  String get configSaved => '配置已成功保存！';

  @override
  String get language => '语言';
}
