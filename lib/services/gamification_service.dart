import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../theme/app_theme.dart';
import 'nutrition_service.dart';

enum PandaTrigger {
  mealLogged,
  goalMet,
  streakKeep,
  lifeUsed
}

class GamificationService {
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;
  GamificationService._internal();

  final Random _random = Random();
  final Set<String> _celebratedMacros = {};
  String _lastCelebrationDate = '';

  void _checkResetCelebrations() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    if (_lastCelebrationDate != today) {
      _celebratedMacros.clear();
      _lastCelebrationDate = today;
    }
  }

  void checkAndShowModal(BuildContext context, PandaTrigger trigger) {
    // We can add probability logic here if needed, e.g., if (_random.nextDouble() > 0.7) return;
    // For now, always show for immediate feedback/demo.
    _showPandaModal(context, trigger);
  }

  Future<void> checkAndTriggerMacroCelebrations(BuildContext context) async {
    _checkResetCelebrations();
    final nutritionService = NutritionService();
    // Get current plan to check targets
    final planSnapshot = await nutritionService.getPlan().first;
    if (!planSnapshot.snapshot.exists) return;
    
    final planData = Map<String, dynamic>.from(planSnapshot.snapshot.value as Map);
    final Map macroTargets = planData['macros'] ?? {};
    
    // Get all daily meals to calculate totals
    final mealsSnapshot = await nutritionService.getDailyMeals().first;
    if (!mealsSnapshot.snapshot.exists) return;
    
    final Map<dynamic, dynamic> mealsData = mealsSnapshot.snapshot.value as Map<dynamic, dynamic>;
    
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFats = 0;
    
    mealsData.forEach((key, value) {
      final mealData = Map<String, dynamic>.from(value as Map);
      if (mealData['completed'] == true) {
        totalProtein += double.tryParse(mealData['protein']?.toString() ?? '0') ?? 0;
        totalCarbs += double.tryParse(mealData['carbs']?.toString() ?? '0') ?? 0;
        totalFats += double.tryParse(mealData['fats']?.toString() ?? '0') ?? 0;
      }
    });

    final targetProtein = macroTargets['protein'] ?? 0;
    final targetCarbs = macroTargets['carbs'] ?? 0;
    final targetFats = macroTargets['fats'] ?? 0;

    bool triggered = false;
    
    if (totalProtein >= targetProtein && !_celebratedMacros.contains('protein')) {
      _celebratedMacros.add('protein');
      if (context.mounted) {
        checkAndShowModal(context, PandaTrigger.goalMet);
        triggered = true;
      }
    }
    
    if (!triggered && totalCarbs >= targetCarbs && !_celebratedMacros.contains('carbs')) {
      _celebratedMacros.add('carbs');
      if (context.mounted) {
        checkAndShowModal(context, PandaTrigger.goalMet);
        triggered = true;
      }
    }
    
    if (!triggered && totalFats >= targetFats && !_celebratedMacros.contains('fats')) {
      _celebratedMacros.add('fats');
      if (context.mounted) {
        checkAndShowModal(context, PandaTrigger.goalMet);
        triggered = true;
      }
    }
  }

  void _showPandaModal(BuildContext context, PandaTrigger trigger) {
    final content = _getRandomMessage(trigger);
    
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: _PandaDialog(content: content),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }
  
  Map<String, dynamic> _getRandomMessage(PandaTrigger trigger) {
     List<Map<String, dynamic>> options = [];
     
     switch(trigger) {
       case PandaTrigger.mealLogged:
         options = [
           {
             'persona': 'El Entusiasta', 
             'message': '¡BOOM! 💥 Comida registrada. Tu cuerpo te acaba de dar las gracias.', 
             'emoji': '🐼⚡️',
             'color': Colors.amber
           },
           {
             'persona': 'El Analítico', 
             'message': '✅ Combustible de calidad detectado. Tus niveles de energía subirán en 3... 2... 1...', 
             'emoji': '🧐📊',
             'color': Colors.blue
           },
           {
             'persona': 'El Panda Chef', 
             'message': '👨‍🍳 ¡Delicioso y nutritivo! Esa es la actitud.', 
             'emoji': '🥗🥬',
             'color': Colors.green
           },
         ];
         break;
       case PandaTrigger.goalMet:
         options = [
           {
             'persona': 'El Panda Musculoso', 
             'message': '💪 ¡Hulk estaría orgulloso! Meta de macros alcanzada.', 
             'emoji': '💪🐼',
             'color': Colors.redAccent
           },
           {
             'persona': 'El Científico', 
             'message': '🧪 Nutrición optimizada. Tus células están celebrando.', 
             'emoji': '🧬🔬',
             'color': Colors.teal
           },
           {
             'persona': 'El Rey de Proteína', 
             'message': '🥩 ¡BOOM! Proteína completada. Tus músculos te lo agradecerán mañana.', 
             'emoji': '👑🥩',
             'color': Colors.red
           },
           {
             'persona': 'El Maestro de Carbos', 
             'message': '🍞 Energía al 100%. Carbohidratos optimizados para el día.', 
             'emoji': '⚡🍝',
             'color': Colors.orange
           },
           {
             'persona': 'El Optimizador de Grasas', 
             'message': '🥑 Grasas saludables: ✅ Tu cerebro está feliz.', 
             'emoji': '🧠🥑',
             'color': Colors.green
           },
           {
             'persona': 'El Panda Atleta', 
             'message': '🏃‍♂️ ¡Meta de ejercicio cumplida! Tu cuerpo te lo agradece.', 
             'emoji': '🏅🐼',
             'color': Colors.blue
           },
           {
             'persona': 'El Panda Motivador', 
             'message': '🎯 ¡Objetivo completado! Esto es solo el comienzo.', 
             'emoji': '🚀✨',
             'color': Colors.purple
           },
           {
             'persona': 'El Panda Campeón', 
             'message': '🏆 ¡LO LOGRASTE! La disciplina vence al talento.', 
             'emoji': '👑🏆',
             'color': Colors.amber
           },
           {
             'persona': 'El Panda Corredor', 
             'message': '🏃 ¡Kilómetros completados! Cada paso cuenta.', 
             'emoji': '🏃‍♀️💨',
             'color': Colors.cyan
           },
           {
             'persona': 'El Panda Transformador', 
             'message': '⚖️ ¡Meta de peso alcanzada! Tu dedicación da frutos.', 
             'emoji': '🎉⚖️',
             'color': Colors.greenAccent
           },
         ];
         break;
       case PandaTrigger.streakKeep:
         options = [
           {
             'persona': 'El Panda de Fuego', 
             'message': '🔥 ¡Sigue así! Estás en llamas, nadie puede pararte hoy.', 
             'emoji': '🔥🏎️',
             'color': Colors.orangeAccent
           },
           {
             'persona': 'El Panda VIP', 
             'message': '🏆 Bienvenido al club del 1%. La mayoría se rinde al día 3, tú sigues aquí.', 
             'emoji': '👑🥂',
             'color': Colors.purpleAccent
           },
         ];
         break;
       case PandaTrigger.lifeUsed:
         options = [
           {
             'persona': 'El Panda Compasivo', 
             'message': '❤️ Tranquilo, para eso son las vidas. Disfruta ese cheat meal, mañana volvemos al plan.', 
             'emoji': '🧸❤️',
             'color': Colors.pinkAccent
           },
           {
             'persona': 'El Negociador', 
             'message': '🤝 Vale, hoy nos relajamos... pero mañana quiero ver verdes en ese tablero.', 
             'emoji': '🤝💼',
             'color': Colors.blueGrey
           },
         ];
         break;
     }
     
     if (options.isEmpty) {
       return {
         'persona': 'Panda Coach',
         'message': '¡Sigue así!',
         'emoji': '🐼',
         'color': AppTheme.primary
       };
     }
     
     return options[_random.nextInt(options.length)];
  }
}

class _PandaDialog extends StatelessWidget {
  final Map<String, dynamic> content;

  const _PandaDialog({required this.content});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: (content['color'] as Color).withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: (content['color'] as Color).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                content['emoji'],
                style: const TextStyle(fontSize: 48),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              (content['persona'] as String).toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: (content['color'] as Color),
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content['message'],
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: (content['color'] as Color),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  '¡Entendido!',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
