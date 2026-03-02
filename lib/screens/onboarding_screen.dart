import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:pasteboard/pasteboard.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'main_screen.dart';
import '../services/nutrition_service.dart';
import '../services/ai_service.dart';
import '../l10n/app_localizations.dart';

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
  String _gender = '';
  final TextEditingController _weightController = TextEditingController(text: '70');
  final TextEditingController _heightController = TextEditingController(text: '170');
  final TextEditingController _ageController = TextEditingController(text: '25');
  final TextEditingController _waistController = TextEditingController(text: '80');
  
  // Motivation data
  File? _progressImage;
  String? _generatedGoalImageUrl;
  Uint8List? _generatedGoalImageBytes;
  String? _aiVisionDescription;
  bool _isAnalyzing = false;
  final TextEditingController _motivationController = TextEditingController();
  final NutritionService _nutritionService = NutritionService();
  final AiService _aiService = AiService();
  
  List<Map<String, dynamic>> get _steps {
    final l10n = AppLocalizations.of(context)!;
    return [
      {
        'title': l10n.onboardingGoalTitle,
        'subtitle': l10n.onboardingGoalSubtitle,
        'type': 'choice',
        'options': [
          {'label': l10n.onboardingGoalWeightLoss, 'icon': Icons.trending_down, 'value': 'weight_loss'},
          {'label': l10n.onboardingGoalMuscleGain, 'icon': Icons.fitness_center, 'value': 'muscle_gain'},
          {'label': l10n.onboardingGoalMentalHealth, 'icon': Icons.psychology, 'value': 'mental_health'},
          {'label': l10n.onboardingGoalGeneralHealth, 'icon': Icons.apple, 'value': 'general_health'},
        ]
      },
      {
        'title': l10n.onboardingGenderTitle,
        'subtitle': l10n.onboardingGenderSubtitle,
        'type': 'gender',
        'options': [
          {'label': l10n.onboardingGenderMale, 'icon': Icons.male, 'value': 'male'},
          {'label': l10n.onboardingGenderFemale, 'icon': Icons.female, 'value': 'female'},
        ]
      },
      {
        'title': l10n.onboardingPhysicalTitle,
        'subtitle': l10n.onboardingPhysicalSubtitle,
        'type': 'physical',
      },
      {
        'title': l10n.onboardingActivityTitle,
        'subtitle': l10n.onboardingActivitySubtitle,
        'type': 'choice',
        'options': [
          {'label': l10n.onboardingActivitySedentary, 'icon': Icons.chair, 'value': 'sedentary'},
          {'label': l10n.onboardingActivityLight, 'icon': Icons.directions_walk, 'value': 'light'},
          {'label': l10n.onboardingActivityModerate, 'icon': Icons.directions_run, 'value': 'moderate'},
          {'label': l10n.onboardingActivityVeryActive, 'icon': Icons.bolt, 'value': 'very_active'},
        ]
      },
      {
        'title': l10n.onboardingRestrictionsTitle,
        'subtitle': l10n.onboardingRestrictionsSubtitle,
        'type': 'multi',
        'options': [
          {'label': l10n.onboardingRestrictionKeto, 'icon': Icons.egg, 'value': 'keto'},
          {'label': l10n.onboardingRestrictionVegan, 'icon': Icons.eco, 'value': 'vegan'},
          {'label': l10n.onboardingRestrictionGlutenFree, 'icon': Icons.no_food, 'value': 'gluten_free'},
          {'label': l10n.onboardingRestrictionLactoseFree, 'icon': Icons.water_drop_outlined, 'value': 'lactose_free'},
        ]
      },
      {
        'title': l10n.onboardingCookingTitle,
        'subtitle': l10n.onboardingCookingSubtitle,
        'type': 'choice',
        'options': [
          {'label': l10n.onboardingCookingFast, 'icon': Icons.timer, 'value': 'fast'},
          {'label': l10n.onboardingCookingMedium, 'icon': Icons.restaurant, 'value': 'medium'},
          {'label': l10n.onboardingCookingElaborate, 'icon': Icons.outdoor_grill, 'value': 'elaborate'},
        ]
      },

      {
        'title': l10n.onboardingFinalTitle,
        'subtitle': l10n.onboardingFinalSubtitle,
        'type': 'final',
        'icon': Icons.auto_awesome_rounded,
      }
    ];
  }

  Future<void> _pickImage() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
      );
      
      if (image != null) {
        debugPrint('Image picked successfully: ${image.path}');
        setState(() {
          _progressImage = File(image.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.onboardingUploadTip),
            backgroundColor: Colors.orangeAccent,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
          ),
        );
      }
    }
  }

  Future<void> _pasteImage() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final bytes = await Pasteboard.image;
      if (bytes != null) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/pasted_image_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(bytes);
        
        setState(() {
          _progressImage = file;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.onboardingImagePasted)),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.onboardingNoImageClipboard)),
          );
        }
      }
    } catch (e) {
      debugPrint('Error pasting image: $e');
    }
  }

  List<String> _getSmartPrompts() {
    final l10n = AppLocalizations.of(context)!;
    final prompts = <String>[];
    final isFemale = _gender == 'female';
    
    if (_goal == 'weight_loss') {
      if (isFemale) {
        prompts.addAll([
          l10n.onboardingPromptWeightLossFemale1,
          l10n.onboardingPromptWeightLossFemale2,
          l10n.onboardingPromptWeightLossFemale3,
          l10n.onboardingPromptWeightLossFemale4,
        ]);
      } else {
        prompts.addAll([
          l10n.onboardingPromptWeightLossMale1,
          l10n.onboardingPromptWeightLossMale2,
          l10n.onboardingPromptWeightLossMale3,
          l10n.onboardingPromptWeightLossMale4,
        ]);
      }
    } else if (_goal == 'muscle_gain') {
      if (isFemale) {
        prompts.addAll([
          l10n.onboardingPromptMuscleGainFemale1,
          l10n.onboardingPromptMuscleGainFemale2,
          l10n.onboardingPromptMuscleGainFemale3,
          l10n.onboardingPromptMuscleGainFemale4,
        ]);
      } else {
        prompts.addAll([
          l10n.onboardingPromptMuscleGainMale1,
          l10n.onboardingPromptMuscleGainMale2,
          l10n.onboardingPromptMuscleGainMale3,
          l10n.onboardingPromptMuscleGainMale4,
        ]);
      }
    } else {
      prompts.addAll([
        l10n.onboardingPromptHealth1,
        l10n.onboardingPromptHealth2,
        l10n.onboardingPromptHealth3,
      ]);
    }

    if (_restrictions.contains('vegan')) {
      prompts.add(l10n.onboardingPromptPlantPowered);
    }
    
    return prompts;
  }

  Future<void> _processMotivation() async {
    final l10n = AppLocalizations.of(context)!;
    if (_progressImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.onboardingSelectPhotoError)),
      );
      return;
    }

    if (_motivationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.onboardingSelectGoalError)),
      );
      return;
    }

    // Check AI Consent for Onboarding
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    bool consent = prefs.getBool('ai_consent_accepted') ?? false;

    if (!consent) {
      final confirm = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            l10n.aiConsentTitle,
            style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: AppTheme.primary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.aiConsentOnboardingDesc,
                style: GoogleFonts.manrope(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.aiConsentFooter,
                style: GoogleFonts.manrope(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancelLabel, style: GoogleFonts.manrope(color: AppTheme.secondary)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l10n.confirmBtn, style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await prefs.setBool('ai_consent_accepted', true);
        consent = true;
      } else {
        return;
      }
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      debugPrint('Onboarding: Starting analysis...');
      final bytes = await _progressImage!.readAsBytes();
      
      // Enriquecer el prompt con TODO el contexto del onboarding
      final fullContextPrompt = '''
        Objetivo Visual: ${_motivationController.text}
        Género: ${_gender == 'female' ? 'Mujer' : 'Hombre'}
        Edad: ${_ageController.text} años
        Peso actual: ${_weightController.text}kg
        Altura: ${_heightController.text}cm
        Nivel de actividad: $_activityLevel
        Restricciones: ${_restrictions.join(', ')}
        
        IMPORTANTE: Genera una visión física que sea REALISTA para este perfil. 
      ''';

      debugPrint('Onboarding: Requesting Combined Vision and Image (Saving Quota)...');
      final combinedResult = await _aiService.generateVisionAndImage(fullContextPrompt, bytes);
      
      final vision = combinedResult?['description'] ?? l10n.everythingSaved; // Fallback
      final imageBytes = combinedResult?['imageBytes'] as Uint8List?;
      
      // Upload original image to Firebase Storage
      debugPrint('Onboarding: Uploading original image to Firebase...');
      final originalUrl = await _nutritionService.uploadProgressImage(_progressImage!);
      
      String? generatedUrl;
      if (imageBytes != null) {
        debugPrint('Onboarding: Uploading generated image bytes to Firebase...');
        generatedUrl = await _nutritionService.uploadImageBytes(imageBytes, 'generated_goal');
      }
      
      if (originalUrl != null) {
        // Save the visual goal with the TRULY generated image URL (or original as fallback)
        await _nutritionService.saveVisualGoal(
          originalImageUrl: originalUrl,
          aiGoalImageUrl: generatedUrl ?? originalUrl,
          prompt: vision,
        );
        
        setState(() {
          _generatedGoalImageUrl = generatedUrl ?? originalUrl;
          _generatedGoalImageBytes = imageBytes;
          _aiVisionDescription = vision;
        });
        
        if (imageBytes == null) {
          debugPrint('Onboarding: FALLBACK - No se recibió imagen de la IA, usando la original.');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.onboardingQuotaError),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } else {
          debugPrint('Onboarding: EXITO - Se recibió imagen de transformación de la IA.');
        }
      } else {
        debugPrint('Onboarding: Image URL is null, moving to next page');
        _nextPage();
      }
    } catch (e, stack) {
      debugPrint('Error processing motivation: $e');
      debugPrint('Stack trace: $stack');
      _nextPage(); // Continue anyway but log error
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    await prefs.setString('user_goal', _goal);
    await prefs.setString('user_activity', _activityLevel);
    await prefs.setStringList('user_restrictions', _restrictions);
    await prefs.setString('user_cooking', _cookingSkill);
    await prefs.setString('user_gender', _gender);
    await prefs.setDouble('user_weight', double.tryParse(_weightController.text) ?? 0.0);
    await prefs.setDouble('user_height', double.tryParse(_heightController.text) ?? 0.0);
    await prefs.setInt('user_age', int.tryParse(_ageController.text) ?? 25);
    await prefs.setDouble('user_waist', double.tryParse(_waistController.text) ?? 0.0);
    
    // Save to Firebase
    try {
      final nutritionService = NutritionService();
      await nutritionService.saveUserProfile({
        'goal': _goal,
        'activity_level': _activityLevel,
        'restrictions': _restrictions,
        'cooking_skill': _cookingSkill,
        'gender': _gender,
        'weight': double.tryParse(_weightController.text) ?? 0.0,
        'height': double.tryParse(_heightController.text) ?? 0.0,
        'age': int.tryParse(_ageController.text) ?? 25,
        'waist': double.tryParse(_waistController.text) ?? 0.0,
      });

      // Also log initial weight to history
      final weight = double.tryParse(_weightController.text);
      if (weight != null) {
        await nutritionService.saveWeight(weight);
      }
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
      body: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyV, control: true): _pasteImage,
          const SingleActivator(LogicalKeyboardKey.keyV, meta: true): _pasteImage,
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: (_currentPage + 1) / _steps.length,
                        backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                        borderRadius: BorderRadius.circular(10),
                        minHeight: 6,
                      ),
                    ),
                  ],
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
      ),
    ),
    );
  }

  Widget _buildStep(int index) {
    final l10n = AppLocalizations.of(context)!;
    final step = _steps[index];
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
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
          if (step['type'] == 'choice' || step['type'] == 'multi' || step['type'] == 'gender')
            _buildOptions(step),
          if (step['type'] == 'physical')
            _buildPhysicalStep(),
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
                child: Text(l10n.onboardingContinue.toUpperCase(), 
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
                child: Text(l10n.onboardingStartNow.toUpperCase(), 
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            ),
          if (step['type'] == 'motivation')
            _buildMotivationStep(),
        ],
      ),
      ),
    );
  }

  Widget _buildPhysicalStep() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                label: l10n.onboardingAgeLabel,
                controller: _ageController,
                icon: Icons.cake_outlined,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInputField(
                label: l10n.onboardingWeightLabel,
                controller: _weightController,
                icon: Icons.monitor_weight_outlined,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildInputField(
          label: l10n.onboardingHeightLabel,
          controller: _heightController,
          icon: Icons.height,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _buildInputField(
          label: l10n.onboardingWaistLabel,
          controller: _waistController,
          icon: Icons.straighten,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 24),
        // ⚕️ Medical Citation / Disclaimer (REQUERIDO POR APPLE)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline_rounded, color: AppTheme.secondary, size: 14),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.onboardingHealthDisclaimer,
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  color: AppTheme.secondary.withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
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
            child: Text(l10n.onboardingContinue.toUpperCase(), 
              style: GoogleFonts.manrope(fontWeight: FontWeight.w900, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: AppTheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primary,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.only(top: 8),
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationStep() {
    final l10n = AppLocalizations.of(context)!;
    debugPrint('Onboarding: Building motivation step. Generated Image URL: $_generatedGoalImageUrl');
    if (_generatedGoalImageUrl != null) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.remove_red_eye_outlined, color: AppTheme.accent, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.onboardingScanningTransformation.toUpperCase(),
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.accent,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Futuristic Comparison UI
          Row(
            children: [
              // Before Photo
              Expanded(
                child: Column(
                  children: [
                    Text(
                      l10n.onboardingCurrentState.toUpperCase(),
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        image: DecorationImage(
                          image: FileImage(_progressImage!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // AI Vision
              Expanded(
                child: Column(
                  children: [
                    Text(
                      l10n.onboardingAiAnalysis.toUpperCase(),
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.cyanAccent,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withValues(alpha: 0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (_generatedGoalImageBytes != null)
                              Image.memory(
                                _generatedGoalImageBytes!,
                                fit: BoxFit.cover,
                              )
                            else if (_generatedGoalImageUrl != null)
                              Image.network(
                                _generatedGoalImageUrl!,
                                fit: BoxFit.cover,
                              ),
                            // Advanced Scanning Animation
                            TweenAnimationBuilder<double>(
                              duration: const Duration(seconds: 3),
                              tween: Tween(begin: 0.0, end: 1.0),
                              curve: Curves.linear,
                              builder: (context, value, child) {
                                return Stack(
                                  children: [
                                    // Scanning Line
                                    Positioned(
                                      top: 250 * value,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        height: 2,
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.cyanAccent.withValues(alpha: 0.8),
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                            )
                                          ],
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              Colors.cyanAccent,
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Scanning Glow
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.cyanAccent.withValues(alpha: 0.1 * value),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                              onEnd: () {
                                // Repeat animation if needed or just let it be
                              },
                            ),
                            // Tech Grid Overlay
                            Opacity(
                              opacity: 0.1,
                              child: GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 10),
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: 100,
                                itemBuilder: (context, index) => Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.cyanAccent, width: 0.5),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Transcription from AI
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.purple.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.cyanAccent, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n.onboardingSuccessProjection.toUpperCase(),
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: Colors.cyanAccent,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _aiVisionDescription ?? l10n.onboardingCalculating,
                    style: GoogleFonts.manrope(
                      color: AppTheme.primary,
                      fontSize: 15,
                      height: 1.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: Text(
                l10n.onboardingAcceptTransformation.toUpperCase(),
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _nextPage,
            child: Text(
              l10n.onboardingSkip.toUpperCase(),
              style: GoogleFonts.manrope(
                color: AppTheme.secondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: _progressImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.file(_progressImage!, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_a_photo_outlined, size: 48, color: AppTheme.accent),
                      const SizedBox(height: 12),
                      Text(
                        l10n.onboardingTapUpload,
                        style: GoogleFonts.manrope(
                          color: AppTheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pasteImage,
                icon: const Icon(Icons.content_paste, size: 18),
                label: Text(l10n.onboardingPasteImage.toUpperCase()),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppTheme.accent),
                  foregroundColor: AppTheme.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          l10n.onboardingSelectVisualGoal,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.secondary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _getSmartPrompts().map((prompt) {
            bool isSelected = _motivationController.text == prompt;
            return ChoiceChip(
              label: Text(
                prompt,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                  color: isSelected ? Colors.white : AppTheme.primary,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _motivationController.text = selected ? prompt : '';
                });
              },
              selectedColor: AppTheme.primary,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? AppTheme.primary : AppTheme.primary.withValues(alpha: 0.1),
                ),
              ),
              showCheckmark: false,
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _motivationController,
          maxLines: 2,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _processMotivation(),
          decoration: InputDecoration(
            hintText: l10n.onboardingOwnGoalHint,
            hintStyle: GoogleFonts.manrope(color: AppTheme.secondary.withValues(alpha: 0.5)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(20),
          ),
          style: GoogleFonts.manrope(color: AppTheme.primary, fontSize: 14),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isAnalyzing ? null : _processMotivation,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: _isAnalyzing
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text(l10n.onboardingAiAnalyzing.toUpperCase(), style: const TextStyle(color: Colors.white)),
                    ],
                  )
                : Text(
                    l10n.onboardingGenerateVision.toUpperCase(),
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w900, color: Colors.white),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _nextPage,
          child: Text(
            l10n.onboardingSkip.toUpperCase(),
            style: GoogleFonts.manrope(
              color: AppTheme.secondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptions(Map<String, dynamic> step) {
    final options = step['options'] as List;
    return Column(
      children: options.map((opt) {
        bool isSelected = false;
        if (step['type'] == 'choice' || step['type'] == 'gender') {
          if (_currentPage == 0) isSelected = _goal == opt['value'];
          if (_currentPage == 1) isSelected = _gender == opt['value'];
          if (_currentPage == 3) isSelected = _activityLevel == opt['value'];
          if (_currentPage == 5) isSelected = _cookingSkill == opt['value'];
        } else {
          isSelected = _restrictions.contains(opt['value']);
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: InkWell(
            onTap: () {
              setState(() {
                if (step['type'] == 'choice' || step['type'] == 'gender') {
                  if (_currentPage == 0) _goal = opt['value'];
                  if (_currentPage == 1) _gender = opt['value'];
                  if (_currentPage == 3) _activityLevel = opt['value'];
                  if (_currentPage == 5) _cookingSkill = opt['value'];
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
                    color: Colors.black.withValues(alpha: 0.04),
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
