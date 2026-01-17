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
      'Eres el asistente financiero de "Finanzas AI". '
      'TU OBJETIVO PRINCIPAL: Ayudar al usuario a gestionar su dinero, ahorros y metas. '
      'REGLAS ESTRICTAS (GUARDRAILS): '
      '1. SOLO responde preguntas relacionadas con finanzas, economía personal, presupuesto, ahorros o el uso de esta app. '
      '2. Si el usuario pregunta sobre otros temas (deportes, noticias, clima, chistes), rechaza amablemente responder y redirige al tema financiero. Ejemplo: "Lo siento, solo puedo ayudarte con temas financieros." '
      '3. Tienes acceso a los datos del usuario (Contexto). Úsalos para personalizar la respuesta. '
      'GENUI (INTERFAZ GENERATIVA): '
      'Cuando sea útil, incluye un bloque JSON al final para generar UI interactiva. '
      'Formatos soportados: '
      '1. SUGERIR META (Cuando el usuario quiera ahorrar para algo): '
      '{ "type": "goal_suggestion", "title": "Nombre Meta", "target_amount": 1000, "reason": "Explicación breve basada en sus finanzas." } '
      '2. VER GRÁFICAS (Cuando el usuario pida análisis visual): '
      '{ "type": "view_chart", "chart_type": "pie", "message": "Aquí tienes tu análisis." } '
      '3. CREAR TRANSACCIÓN (Ticket): '
      '{ "type": "transaction", "amount": 100, "category": "General", "is_expense": true, "description": "..." } '
      '4. VER BALANCE: '
      '{ "type": "balance", "total": 1500, "income": 2000, "expenses": 500 } '
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

  Future<String> _getFinancialContext() async {
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

      return '[CONTEXTO FINANCIERO ACTUAL: '
             'Balance Total: \$${(summary['total_income'] - summary['total_expense']).toStringAsFixed(2)}, '
             'Ingresos: \$${summary['total_income']}, '
             'Gastos: \$${summary['total_expense']}, '
             'Metas Activas: ${goalsString.isEmpty ? "Ninguna" : goalsString}]';
    } catch (e) {
      return '[No se pudo obtener el contexto financiero actual]';
    }
  }

  Future<Message> sendMessage(String text) async {
    _chat ??= _model.startChat();

    try {
      // Inject context into the message
      final contextValues = await _getFinancialContext();
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
