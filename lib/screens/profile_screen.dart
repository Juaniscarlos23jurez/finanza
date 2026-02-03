import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/nutrition_service.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final NutritionService _nutritionService = NutritionService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  final DateTime _focusedDay = DateTime.now();
  String _userEmoji = '🦊'; // Default emoji
  int _streak = 0;
  Map<String, bool> _streakDays = {}; // Map of dates with streak

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _listenToStreak();
  }

  void _listenToStreak() {
    _nutritionService.getStreak().listen((event) {
      if (event.snapshot.value != null && mounted) {
        final newStreak = int.tryParse(event.snapshot.value.toString()) ?? 0;
        setState(() {
          _streak = newStreak;
          _calculateStreakDays();
        });
      }
    });
  }

  void _calculateStreakDays() {
    final Map<String, bool> days = {};
    final now = DateTime.now();
    
    // Mark the last N days as streak days (where N = current streak)
    for (int i = 0; i < _streak; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      days[dateKey] = true;
    }
    
    _streakDays = days;
  }

  Future<void> _fetchProfile() async {
    final result = await _authService.getProfile();
    final emoji = await _nutritionService.getUserEmoji();
    if (mounted) {
      setState(() {
        if (result['success']) {
          _userData = result['data'];
        }
        _userEmoji = emoji ?? '🦊';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 48),
                      _buildProfileHeader(),
                      const SizedBox(height: 32),
                      _buildNutritionalCalendar(),
                      const SizedBox(height: 48),
                      _buildMenuSection(l10n.account, [
                        _buildMenuItem(Icons.person_outline_rounded, l10n.personalInfo, onTap: () => _showPersonalInfoModal(context)),
                        _buildMenuItem(Icons.language_rounded, l10n.language, onTap: () => _showLanguageSelector(context)),
                        _buildMenuItem(Icons.auto_awesome_outlined, l10n.customizeNutrition, onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                          );
                        }),
                        _buildMenuItem(Icons.restart_alt_rounded, l10n.resetMemoryTitle, onTap: () => _showResetAIModal(context)),
                       ]),
                      const SizedBox(height: 32),
                      _buildMenuSection(l10n.transparency, [
                        _buildMenuItem(Icons.security_outlined, l10n.dataControl, onTap: () => _showPrivacyInfo(context)),
                       ]),
                      const SizedBox(height: 32),
                      _buildMenuSection(l10n.otherSection, [
                        _buildMenuItem(Icons.feedback_outlined, l10n.feedback, onTap: () => _showFeedbackModal(context)),
                        _buildMenuItem(
                          Icons.info_outline_rounded, 
                          l10n.termsConditions,
                          onTap: () async {
                            final uri = Uri.parse('https://fynlink.shop/terminos_y_privacidad_app_clientes_html.html#terminos');
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          },
                        ),
                        _buildMenuItem(
                          Icons.privacy_tip_outlined, 
                          l10n.privacyPolicy,
                          onTap: () async {
                            final uri = Uri.parse('https://fynlink.shop/terminos_y_privacidad_app_clientes_html.html#privacidad');
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          },
                        ),
                      ]),
                      const SizedBox(height: 48),
                      _buildLogoutButton(context),
                      const SizedBox(height: 12),
                      _buildDeleteAccountButton(context, l10n.deleteAccount),
                      const SizedBox(height: 48),
                    ],
                  ),
                );
              }
            ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final l10n = AppLocalizations.of(context)!;
    final name = _userData?['name'] ?? l10n.defaultUserName;
    final photoUrl = _userData?['photo_url'];

    return StreamBuilder<DatabaseEvent>(
      stream: _nutritionService.getGamificationStats(),
      builder: (context, snapshot) {
        int level = 1;
        int xp = 0;
        
        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final data = snapshot.data!.snapshot.value as Map;
          level = data['level'] ?? 1;
          xp = data['xp'] ?? 0;
        }

        // Calculate progress to next level
        // Level N starts at (N-1)*500 XP. Next level at N*500.
        // Current Level Progress = (XP - (Level-1)*500) / 500
        int xpForCurrentLevel = (level - 1) * 500;
        int xpToNextLevel = 500;
        double progress = ((xp - xpForCurrentLevel) / xpToNextLevel).clamp(0.0, 1.0);

        String rankTitle = l10n.rankNovice;
        if (level > 2) rankTitle = l10n.rankApprentice;
        if (level > 5) rankTitle = l10n.rankWarrior;
        if (level > 10) rankTitle = l10n.rankMaster;
        if (level > 20) rankTitle = l10n.rankLegend;

        return Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                GestureDetector(
                  onTap: () => _showEmojiSelector(context),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)],
                      border: Border.all(color: AppTheme.primary, width: 3),
                    ),
                    child: ClipOval(
                      child: photoUrl != null
                          ? Image.network(photoUrl, fit: BoxFit.cover)
                          : Center(child: Text(_userEmoji, style: const TextStyle(fontSize: 60))),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppTheme.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$level',
                    style: GoogleFonts.manrope(
                      color: Colors.white, 
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(name, style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.primary)),
            Text(rankTitle, style: GoogleFonts.manrope(fontSize: 14, color: AppTheme.accent, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
            const SizedBox(height: 8),
            // XP Bar
            Container(
              width: 200,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${xp - xpForCurrentLevel} / 500 XP',
              style: GoogleFonts.manrope(fontSize: 10, color: AppTheme.secondary, fontWeight: FontWeight.bold),
            ),
          ],
        );
      }
    );
  }

  Widget _buildNutritionalCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: TableCalendar(
        locale: Localizations.localeOf(context).languageCode,
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: CalendarFormat.month,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: AppTheme.primary),
        ),
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            final dateKey = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
            final hasStreak = _streakDays[dateKey] ?? false;
            
            if (hasStreak) {
              return Container(
                margin: const EdgeInsets.all(4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.red.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Positioned(
                      top: 2,
                      child: Text('🔥', style: TextStyle(fontSize: 10)),
                    ),
                    Positioned(
                      bottom: 4,
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return null;
          },
          todayBuilder: (context, day, focusedDay) {
            final dateKey = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
            final hasStreak = _streakDays[dateKey] ?? false;
            
            if (hasStreak) {
              // Today with streak - special design
              return Container(
                margin: const EdgeInsets.all(4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.red.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Positioned(
                      top: 2,
                      child: Text('🔥', style: TextStyle(fontSize: 10)),
                    ),
                    Positioned(
                      bottom: 4,
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            // Today without streak - default style
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: Text(title, style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.secondary, letterSpacing: 1.5)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.primary)),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.secondary, size: 20),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languages = [
      {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
      {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
      {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
      {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
      {'code': 'ja', 'name': '日本語', 'flag': '🇯🇵'},
      {'code': 'it', 'name': 'Italiano', 'flag': '🇮🇹'},
      {'code': 'pt', 'name': 'Português', 'flag': '🇧🇷'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.selectLanguage, style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.primary)),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final lang = languages[index];
                  final isSelected = LocaleSettings.instance.localeNotifier.value.languageCode == lang['code'];
                  
                  return ListTile(
                    leading: Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
                    title: Text(lang['name']!, style: GoogleFonts.manrope(fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600)),
                    trailing: isSelected ? const Icon(Icons.check_circle, color: AppTheme.primary) : null,
                    onTap: () {
                      LocaleSettings.instance.setLocale(Locale(lang['code']!));
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPersonalInfoModal(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.personalInfo, style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.primary)),
            const SizedBox(height: 24),
            Text('${l10n.nameLabelProfile}: ${_userData?['name'] ?? 'N/A'}', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
            Text('${l10n.emailLabelProfile}: ${_userData?['email'] ?? 'N/A'}', style: GoogleFonts.manrope(color: AppTheme.secondary)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, minimumSize: const Size(double.infinity, 50)),
              child: Text(l10n.closeBtn, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetAIModal(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetMemoryTitle, style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
        content: Text(l10n.resetMemoryDesc),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancelLabel)),
          ElevatedButton(
            onPressed: () async {
              await _nutritionService.resetAIMemory();
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.memoryResetSuccess)));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(l10n.confirmBtn, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.privacyDesc, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: Text(l10n.closeBtn)),
          ],
        ),
      ),
    );
  }

  void _showFeedbackModal(BuildContext context) {
     final l10n = AppLocalizations.of(context)!;
     // Simplifying for space
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.feedbackThanks)));
  }

  void _showEmojiSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final animalEmojis = [
      '🦊', '🐼', '🐨', '🦁', '🐯', '🐻', '🐰', '🐱', 
      '🐶', '🐺', '🦝', '🦌', '🐮', '🐷', '🐸', '🐵',
      '🦉', '🦅', '🦆', '🐧', '🦜', '🦩', '🐢', '🦎',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.chooseAnimalTitle,
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.emojiRankingHint,
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: AppTheme.secondary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: animalEmojis.length,
                itemBuilder: (context, index) {
                  final emoji = animalEmojis[index];
                  final isSelected = emoji == _userEmoji;
                  return GestureDetector(
                    onTap: () async {
                      setState(() {
                        _userEmoji = emoji;
                      });
                      await _nutritionService.saveUserEmoji(emoji);
                      
                      // Sync with ranking
                      final result = await _authService.getProfile();
                      if (result['success']) {
                        final name = result['data']['name'] ?? l10n.defaultUserName;
                        // Get current streak
                        final streakSnapshot = await _nutritionService.getStreak().first;
                        final streak = streakSnapshot.snapshot.value != null 
                            ? int.tryParse(streakSnapshot.snapshot.value.toString()) ?? 0 
                            : 0;
                        await _nutritionService.syncUserRanking(name, streak, emoji: emoji);
                      }
                      
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.emojiUpdated(emoji))),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppTheme.primary.withValues(alpha: 0.1) 
                            : AppTheme.background,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected 
                            ? Border.all(color: AppTheme.primary, width: 2) 
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () async {
          await _authService.logout();
          if (!context.mounted) return;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
        },
        child: Text(l10n.logout, style: GoogleFonts.manrope(color: Colors.redAccent, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context, String title) {
    return TextButton(
      onPressed: () => _buildLogoutButton(context), 
      child: Text(title, style: TextStyle(color: Colors.grey, fontSize: 12)),
    );
  }
}
