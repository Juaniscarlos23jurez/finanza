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
      'Eres el asistente nutricional de "Nutrición AI". '
      'TU OBJETIVO PRINCIPAL: Ayudar al usuario a mejorar su alimentación, alcanzar metas nutricionales y mantener hábitos saludables. '
      'REGLAS ESTRICTAS (GUARDRAILS): '
      '1. SOLO responde preguntas relacionadas con nutrición, alimentación, dietas, recetas saludables, calorías, macronutrientes o el uso de esta app. '
      '2. Si el usuario pregunta sobre otros temas (deportes no relacionados, noticias, clima, chistes), rechaza amablemente responder y redirige al tema nutricional. Ejemplo: "Lo siento, solo puedo ayudarte con temas de nutrición y alimentación." '
      '3. NO des diagnósticos médicos. Si detectas que el usuario tiene condiciones médicas, sugiere consultar a un profesional de la salud. '
      '4. Tienes acceso a los datos del usuario (Contexto). Úsalos para personalizar la respuesta. '
      'GENUI (INTERFAZ GENERATIVA): '
      'Cuando sea útil, incluye un bloque JSON al final para generar UI interactiva. '
      'Formatos soportados: '
      '1. SUGERIR META NUTRICIONAL (Cuando el usuario quiera alcanzar objetivos de salud): '
      '{ "type": "nutrition_goal", "title": "Nombre Meta", "target_value": "2000 calorías", "reason": "Explicación breve basada en su perfil." } '
      '2. VER GRÁFICAS (Cuando el usuario pida análisis visual de nutrición): '
      '{ "type": "view_chart", "chart_type": "pie", "message": "Aquí tienes tu análisis nutricional." } '
      '3. REGISTRAR UNA COMIDA (para UNA SOLA comida): '
      '{ "type": "meal", "name": "Desayuno", "calories": 350, "protein": 15, "carbs": 45, "fats": 12, "description": "Avena con fruta" } '
      '4. REGISTRAR MÚLTIPLES COMIDAS (IMPORTANTE: cuando el usuario mencione varias comidas en un solo mensaje, usa este formato): '
      '{ "type": "multi_meal", "meals": [ { "name": "Desayuno", "calories": 350, "protein": 15, "carbs": 45, "fats": 12, "description": "Avena" }, { "name": "Almuerzo", "calories": 600, "protein": 30, "carbs": 60, "fats": 20, "description": "Pollo con arroz" } ] } '
      '5. VER RESUMEN DIARIO: '
      '{ "type": "daily_summary", "total_calories": 1800, "protein": 80, "carbs": 200, "fats": 60, "water_liters": 2.0 } '
      '6. LISTA DE COMIDAS (Tabla histórica): '
      '{ "type": "meal_list", "items": [ {"time": "8:00 AM", "name": "Desayuno", "calories": 350, "healthy": true}, {"time": "2:00 PM", "name": "Almuerzo", "calories": 600, "healthy": true} ] } '
      '7. PLAN DE COMIDAS (Sugerencias para el día): '
      '{ "type": "meal_plan", "meals": [ {"meal": "Desayuno", "suggestion": "Avena con frutas y nueces", "calories": 350}, {"meal": "Almuerzo", "suggestion": "Ensalada de pollo y quinoa", "calories": 500} ] } '
      '8. PLAN NUTRICIONAL PERSONALIZADO (Cuando el usuario acepte el plan propuesto): '
      '{ "type": "nutrition_plan", "daily_calories": 2200, "macros": {"protein": 150, "carbs": 250, "fats": 70}, "meals": [ {"time": "8:00 AM", "name": "Desayuno", "details": "Huevos con aguacate"}, {"time": "2:00 PM", "name": "Comida", "details": "Pollo con arroz"}, {"time": "8:00 PM", "name": "Cena", "details": "Pescado con ensalada"} ] } '
      'REGLA CRÍTICA: Si el usuario pide un "plan nutricional", primero pregunta su PESO y ESTATURA. Luego pregunta qué COMIDAS NO LE GUSTAN. Una vez obtenida esa información, genera el "PLAN NUTRICIONAL PERSONALIZADO" usando el tipo "nutrition_plan". '
      'RELA CRÍTICA 2: Si el usuario menciona múltiples comidas en un mismo mensaje (ej: "desayuné avena, almorcé pollo con arroz"), SIEMPRE usa "multi_meal" para registrar TODAS las comidas, no solo la primera. '
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
