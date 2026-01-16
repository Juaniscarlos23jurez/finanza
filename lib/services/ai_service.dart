import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/message_model.dart';

class AiService {
  // TODO: Replace with your actual API Key or use an environment variable
  static const String _apiKey = 'AIzaSyBCjF8_76HMNew-dLaBpi5vk1vh1k3Aw1s';
  
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
      
      Map<String, dynamic>? genUiData;
      bool isGenUI = false;

      // Extract JSON block using Regex
      final jsonMatch = RegExp(r'```json\s*(\{.*?\})\s*```', dotAll: true).firstMatch(responseText);
      
      if (jsonMatch != null) {
        try {
          final jsonString = jsonMatch.group(1)!;
          // Decode JSON (Need to import dart:convert)
          genUiData = json.decode(jsonString);
          isGenUI = true;
          
          // Remove the JSON block from the visible text
          responseText = responseText.replaceFirst(jsonMatch.group(0)!, '').trim();
        } catch (e) {
          debugPrint('Error parsing GenUI JSON: $e');
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
