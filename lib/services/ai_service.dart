import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/message_model.dart';

class AiService {
  // Use dotenv to get the API Key
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  
  final GenerativeModel _model;
  ChatSession? _chat;

  AiService() : _model = GenerativeModel(
    model: 'gemini-2.0-flash-lite-preview-02-05',
    apiKey: _apiKey,
    systemInstruction: Content.system(
      'Eres el asistente financiero de la aplicación "Finanzas AI". '
      'Ayuda al usuario a rastrear sus finanzas. '
      'Mantén un seguimiento aproximado del balance en esta conversación si es posible. '
      'Cuando el usuario registre una transacción (ingreso o gasto) O pida un balance/resumen, '
      'ADEMÁS de tu respuesta de texto normal, debes incluir un bloque JSON al final. '
      'El bloque JSON debe estar formateado así: '
      '```json { "type": "transaction", "amount": 100, "category": "comida", "is_expense": true, "description": "Gasto en cena" } ``` '
      'O para balance: '
      '```json { "type": "balance", "total": 1500, "monthly_savings": 200, "income": 2000, "expenses": 500 } ``` '
      'Asegúrate de que el JSON sea válido y esté al final del mensaje.',
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

  Future<Message> sendMessage(String text) async {
    _chat ??= _model.startChat();

    try {
      final response = await _chat!.sendMessage(Content.text(text));
      String responseText = response.text ?? 'No pude procesar tu solicitud.';
      debugPrint('AI Response Raw: $responseText');
      
      Map<String, dynamic>? genUiData;
      bool isGenUI = false;

      // Extract JSON block using Regex
      // 1. Try formatted Markdown code block
      RegExp jsonRegex = RegExp(r'```json\s*(\{.*?\})\s*```', dotAll: true);
      Match? jsonMatch = jsonRegex.firstMatch(responseText);

      // 2. If not found, try lax JSON block (just start/end braces)
      if (jsonMatch == null) {
        // Look for { "type": ... } pattern generally at the end
        jsonRegex = RegExp(r'(\{.*"type"\s*:\s*".*?\}.*?)', dotAll: true);
        final matches = jsonRegex.allMatches(responseText);
        if (matches.isNotEmpty) {
           jsonMatch = matches.last; // Take the last JSON candidates
        }
      }
      
      if (jsonMatch != null) {
        try {
          String jsonString = jsonMatch.group(1)!;
          // Sanitize if necessary (sometimes it might include non-json text)
          if (jsonString.startsWith('```json')) {
             jsonString = jsonString.replaceAll('```json', '').replaceAll('```', '');
          }
           
          // Decode JSON
          genUiData = json.decode(jsonString);
          isGenUI = true;
          debugPrint('GenUI Data Parsed: $genUiData');
          
          // Remove the JSON block from the visible text (using the full match range)
          responseText = responseText.replaceRange(jsonMatch.start, jsonMatch.end, '').trim();
        } catch (e) {
          debugPrint('Error parsing GenUI JSON: $e');
          // If parsing failed, maybe it wasn't our valid JSON. Keep text as is.
        }
      } else if (responseText.contains('[SHOW_GENUI_SUMMARY]')) {
         // Fallback for previous manual trigger if needed
         isGenUI = true;
         responseText = responseText.replaceAll('[SHOW_GENUI_SUMMARY]', '').trim();
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
