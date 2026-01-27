import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/message_model.dart';
import 'finance_service.dart';

class AiService {
  // Use dotenv to get the API Key
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  
  final GenerativeModel _model;
  final FinanceService _financeService = FinanceService();
  ChatSession? _chat;

  AiService() : _model = GenerativeModel(
    model: 'gemini-2.0-flash-lite-preview-02-05',
    apiKey: _apiKey,
    systemInstruction: Content.system(
      'Eres el asistente nutricional de "Nutrición AI", un experto en dietética y salud con un tono motivacional, profesional y empático. '
      'TU OBJETIVO PRINCIPAL: Ayudar al usuario a transformar su vida a través de la alimentación personalizada y el seguimiento de hábitos. '
      'REGLAS ESTRICTAS (GUARDRAILS): '
      '1. SOLO responde temas de nutrición, alimentación, recetas, macros y uso de la app. '
      '2. Si preguntan temas ajenos, declina amablemente: "Soy un experto en nutrición, prefiero mantenernos en el camino de tu salud alimenticia." '
      '3. NO des diagnósticos médicos. Sugiere profesionales si detectas síntomas graves. '
      'PLAN NUTRICIONAL SEMANAL / INGREDIENTES: '
      '- SI EL USUARIO PIDE UN "PLAN SEMANAL" o "DIETA DE LA SEMANA": '
      '  1. SIEMPRE pregunta: "¿Qué ingredientes tienes disponibles actualmente o prefieres que no usemos?" '
      '  2. Consulta si prefiere recetas rápidas o elaboradas. '
      '  3. Una vez respondido, genera el plan usando el tipo "nutrition_plan" con una estructura que cubra los días solicitados. '
      'GENUI (INTERFAZ PREMIUM): '
      'Genera bloques JSON SIEMPRE al final de tus respuestas cuando haya datos que visualizar. '
      'Formatos soportados: '
      '1. REGISTRAR COMIDA (meal): { "type": "meal", "name": "...", "calories": 500, "protein": 30, "carbs": 50, "fats": 20, "description": "...", "score": 9.5 } (Añade un score de 1-10 de qué tan saludable es). '
      '2. REGISTRAR MÚLTIPLES COMIDAS (multi_meal): { "type": "multi_meal", "meals": [...] } '
      '3. PLAN NUTRICIONAL (nutrition_plan): { "type": "nutrition_plan", "daily_calories": 2000, "macros": {"protein": 150, "carbs": 200, "fats": 60}, "days": [ {"day": "Lunes", "meals": [...]}, {"day": "Martes", "meals": [...]} ] } '
      '4. VER GRÁFICAS (view_chart): { "type": "view_chart", "chart_type": "pie", "message": "Tu distribución de macros actual." } '
      '5. SUGERIR META (nutrition_goal): { "type": "nutrition_goal", "title": "...", "target_value": "...", "reason": "..." } '
      'REGLA CRÍTICA: Nunca asumas ingredientes. Pregunta siempre por lo que el usuario tiene en su refrigerador para personalizar el plan al máximo.'
    ),
    generationConfig: GenerationConfig(
      temperature: 0.7,
      topK: 40,
      topP: 0.95,
      maxOutputTokens: 1024,
    ),
  );

  void startNewChat() {
    _chat = _model.startChat();
  }

  Future<String> _getNutritionContext() async {
    try {
      final futures = await Future.wait([
        _financeService.getFinanceData(),
        _financeService.getGoals(),
      ]);

      final data = futures[0] as Map<String, dynamic>;
      final goals = futures[1] as List<dynamic>;
      
      final summary = data['summary'];
      
      final goalsString = goals.map((g) => 
        "${g['title']}: \$${g['current_amount']}/\$${g['target_amount']}"
      ).join(', ');

      return '[CONTEXTO NUTRICIONAL ACTUAL: '
             'Calorías Totales: ${(summary['total_income'] - summary['total_expense']).toStringAsFixed(0)} kcal, '
             'Comidas Registradas: ${summary['total_income']}, '
             'Meta Calórica Diaria: ${summary['total_expense']}, '
             'Metas Activas: ${goalsString.isEmpty ? "Ninguna" : goalsString}]';
    } catch (e) {
      return '[No se pudo obtener el contexto nutricional actual]';
    }
  }

  Future<Message> sendMessage(String text) async {
    _chat ??= _model.startChat();

    try {
      // Inject context into the message
      final contextValues = await _getNutritionContext();
      final fullPrompt = '$contextValues\n\nUsuario: $text';
      debugPrint('Sending to AI: $fullPrompt');

      final response = await _chat!.sendMessage(Content.text(fullPrompt));
      String responseText = response.text ?? 'No pude procesar tu solicitud.';
      
      Map<String, dynamic>? genUiData;
      bool isGenUI = false;

      // Extract JSON block
      RegExp jsonRegex = RegExp(r'```json\s*(\{.*?\})\s*```', dotAll: true);
      Match? jsonMatch = jsonRegex.firstMatch(responseText);

      if (jsonMatch == null) {
        jsonRegex = RegExp(r'(\{.*"type"\s*:\s*".*?\}.*?)', dotAll: true);
        final matches = jsonRegex.allMatches(responseText);
        if (matches.isNotEmpty) {
           jsonMatch = matches.last;
        }
      }
      
      if (jsonMatch != null) {
        try {
          String jsonString = jsonMatch.group(1)!;
          if (jsonString.startsWith('```json')) {
             jsonString = jsonString.replaceAll('```json', '').replaceAll('```', '');
          }
           
          genUiData = json.decode(jsonString);
          isGenUI = true;
          
          responseText = responseText.replaceRange(jsonMatch.start, jsonMatch.end, '').trim();
        } catch (e) {
          debugPrint('Error parsing GenUI JSON: $e');
        }
      }

      return Message(
        text: responseText,
        isAi: true,
        timestamp: DateTime.now(),
        isGenUI: isGenUI,
        data: genUiData,
      );
    } catch (e) {
      return Message(
        text: 'Error al conectar con la IA: $e',
        isAi: true,
        timestamp: DateTime.now(),
      );
    }
  }
}
