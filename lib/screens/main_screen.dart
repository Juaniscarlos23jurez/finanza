import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';
import 'dashboard_screen.dart';
import 'pantry_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; // Start on Chat

  late final List<Widget> _screens = [
    DashboardScreen(onChallengeClick: () => setState(() => _selectedIndex = 2)),
    const ChatScreen(),
    const ProgressScreen(),
    const PantryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard),
                _buildNavItem(1, FontAwesomeIcons.commentDots, FontAwesomeIcons.solidCommentDots),
                _buildNavItem(2, Icons.local_fire_department_rounded, Icons.local_fire_department_rounded),
                _buildNavItem(3, Icons.shopping_basket_outlined, Icons.shopping_basket),
                _buildNavItem(4, Icons.person_outline_rounded, Icons.person),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon) {
    bool isSelected = _selectedIndex == index;
    Color iconColor = isSelected ? Colors.white : AppTheme.secondary;
    
    // Special color for the Fire icon (Progress/Streak)
    if (index == 2 && !isSelected) {
      iconColor = Colors.redAccent;
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? (index == 2 ? Colors.redAccent : AppTheme.primary) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          isSelected ? activeIcon : icon,
          color: iconColor,
          size: 24,
        ),
      ),
    );
  }
}
