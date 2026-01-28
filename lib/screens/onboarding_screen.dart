import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'main_screen.dart';
import '../services/nutrition_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Quiz data
  String _goal = '';
  String _activityLevel = '';
  final List<String> _restrictions = [];
  String _cookingSkill = '';
  
  final List<Map<String, dynamic>> _steps = [
    {
      'title': '¿Cuál es tu objetivo principal?',
      'subtitle': 'Personalizaremos tu IA basado en esto.',
      'type': 'choice',
      'options': [
        {'label': 'Perder Peso', 'icon': Icons.trending_down, 'value': 'weight_loss'},
        {'label': 'Ganar Músculo', 'icon': Icons.fitness_center, 'value': 'muscle_gain'},
        {'label': 'Salud Mental', 'icon': Icons.psychology, 'value': 'mental_health'},
        {'label': 'Comer Sano', 'icon': Icons.apple, 'value': 'general_health'},
      ]
    },
    {
      'title': '¿Qué tan activo eres?',
      'subtitle': 'Esto ayuda a calcular tus calorías.',
      'type': 'choice',
      'options': [
        {'label': 'Sedentario', 'icon': Icons.chair, 'value': 'sedentary'},
        {'label': 'Ligero', 'icon': Icons.directions_walk, 'value': 'light'},
        {'label': 'Moderado', 'icon': Icons.directions_run, 'value': 'moderate'},
        {'label': 'Muy Activo', 'icon': Icons.bolt, 'value': 'very_active'},
      ]
    },
    {
      'title': 'Restricciones Médicas',
      'subtitle': '¿Algo que debamos evitar?',
      'type': 'multi',
      'options': [
        {'label': 'Keto', 'icon': Icons.egg, 'value': 'keto'},
        {'label': 'Vegano', 'icon': Icons.eco, 'value': 'vegan'},
        {'label': 'Sin Gluten', 'icon': Icons.no_food, 'value': 'gluten_free'},
        {'label': 'Sin Lactosa', 'icon': Icons.water_drop_outlined, 'value': 'lactose_free'},
      ]
    },
    {
      'title': 'Habilidad en Cocina',
      'subtitle': '¿Cuánto tiempo quieres dedicar?',
      'type': 'choice',
      'options': [
        {'label': 'Express (<15 min)', 'icon': Icons.timer, 'value': 'fast'},
        {'label': 'Intermedio', 'icon': Icons.restaurant, 'value': 'medium'},
        {'label': 'Chef (Me encanta)', 'icon': Icons.outdoor_grill, 'value': 'elaborate'},
      ]
    },
    {
      'title': '¡Todo listo!',
      'subtitle': 'Tu IA nutricional está lista para empezar.',
      'type': 'final',
      'icon': Icons.auto_awesome_rounded,
    }
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    await prefs.setString('user_goal', _goal);
    await prefs.setString('user_activity', _activityLevel);
    await prefs.setStringList('user_restrictions', _restrictions);
    await prefs.setString('user_cooking', _cookingSkill);
    
    // Save to Firebase
    try {
      final nutritionService = NutritionService();
      await nutritionService.saveUserProfile({
        'goal': _goal,
        'activity_level': _activityLevel,
        'restrictions': _restrictions,
        'cooking_skill': _cookingSkill,
      });
    } catch (e) {
      debugPrint('Error saving profile to Firebase: $e');
    }
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / _steps.length,
                backgroundColor: AppTheme.primary.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                borderRadius: BorderRadius.circular(10),
                minHeight: 6,
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _steps.length,
                itemBuilder: (context, index) => _buildStep(index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int index) {
    final step = _steps[index];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (step['type'] == 'final') ...[
             const Icon(Icons.auto_awesome, size: 80, color: AppTheme.accent),
             const SizedBox(height: 32),
          ],
          Text(
            step['title'],
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            step['subtitle'],
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 16,
              color: AppTheme.secondary,
            ),
          ),
          const SizedBox(height: 48),
          if (step['type'] == 'choice' || step['type'] == 'multi')
            _buildOptions(step),
          if (step['type'] == 'multi') ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text('CONTINUAR', 
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            ),
          ],
          if (step['type'] == 'final')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text('EMPEZAR AHORA', 
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptions(Map<String, dynamic> step) {
    final options = step['options'] as List;
    return Column(
      children: options.map((opt) {
        bool isSelected = false;
        if (step['type'] == 'choice') {
          if (_currentPage == 0) isSelected = _goal == opt['value'];
          if (_currentPage == 1) isSelected = _activityLevel == opt['value'];
          if (_currentPage == 3) isSelected = _cookingSkill == opt['value'];
        } else {
          isSelected = _restrictions.contains(opt['value']);
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: InkWell(
            onTap: () {
              setState(() {
                if (step['type'] == 'choice') {
                  if (_currentPage == 0) _goal = opt['value'];
                  if (_currentPage == 1) _activityLevel = opt['value'];
                  if (_currentPage == 3) _cookingSkill = opt['value'];
                  _nextPage();
                } else {
                  if (_restrictions.contains(opt['value'])) {
                    _restrictions.remove(opt['value']);
                  } else {
                    _restrictions.add(opt['value']);
                  }
                }
              });
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  Icon(opt['icon'], color: isSelected ? Colors.white : AppTheme.primary, size: 24),
                  const SizedBox(width: 16),
                  Text(
                    opt['label'],
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSelected ? Colors.white : AppTheme.primary,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected) 
                    const Icon(Icons.check_circle, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
