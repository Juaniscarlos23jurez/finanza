import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart' as dio_api;
import '../models/message_model.dart';
import 'nutrition_service.dart';

class AiService {
  // Use dotenv to get the API Key
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  
  final GenerativeModel _model;
  final NutritionService _nutritionService = NutritionService();
  ChatSession? _chat;

  AiService() : _model = GenerativeModel(
    model: 'gemini-2.5-flash-image', 
    apiKey: _apiKey,
    systemInstruction: Content.system(
      'Eres el asistente nutricional de "Nutrición AI", un experto en dietética y salud con un tono motivacional, profesional y empático. '
      'TU OBJETIVO PRINCIPAL: Ayudar al usuario a transformar su vida a través de la alimentación personalizada y el seguimiento de hábitos. '
      'REGLAS ESTRICTAS (GUARDRAILS): '
      '1. SOLO responde temas de nutrición, alimentación, recetas, macros y uso de la app. '
      '2. Si preguntan temas ajenos, declina amablemente: "Soy un experto en nutrición, prefiero mantenernos en el camino de tu salud alimenticia." '
      '3. NO des diagnósticos médicos. Sugiere profesionales si detectas síntomas graves. '
      '4. USA EL CONTEXTO: Tienes acceso al perfil del usuario (objetivo, restricciones, etc.). NO vuelvas a preguntar cosas que ya están en el contexto. Personaliza SIEMPRE tus planes y sugerencias basándote en esto (ej: si es vegano, no sugieras carne). '
      'PLAN NUTRICIONAL / RECETAS: '
      '- Cuando el usuario pida una "receta" o "qué comer": '
      '  1. SIEMPRE incluye una explicación motivadora en el texto. '
      '  2. Genera el bloque JSON "meal" con la receta completa. '
      'GENUI (INTERFAZ PREMIUM): '
      'Genera bloques JSON SIEMPRE al final de tus respuestas. Las recetas deben ser de alta calidad. '
      'Formatos soportados: '
      '1. REGISTRAR COMIDA (meal): { "type": "meal", "name": "...", "category": "Desayuno|Comida|Cena|Snack", "calories": 500, "protein": 30, "carbs": 50, "fats": 20, "recipe": { "ingredients": ["1 taza de...", "200g de..."], "steps": ["Primer paso...", "Segundo paso..."], "tips": "Tip de chef..." }, "score": 9.5 } '
      '2. PLAN NUTRICIONAL (nutrition_plan): { "type": "nutrition_plan", "daily_calories": 2000, "macros": {"protein": 150, "carbs": 200, "fats": 70}, "days": [ { "day": "Lunes", "meals": [ { "name": "...", "category": "Desayuno", "calories": 400, "recipe": {...} }, ... ] } ] } '
      '3. LISTA DE COMPRAS (shopping_list): { "type": "shopping_list", "title": "Lista para la semana", "items": [ {"name": "Huevos", "quantity": "1 docena", "category": "Proteína"}, {"name": "Espinaca", "quantity": "1 bolsa", "category": "Verdura"} ] } '
      'REGLA CRÍTICA: La receta debe ser "completa" y fácil de seguir. Si el usuario dice "tengo hambre" o "ayúdame", ofrece una receta rápida basada en su perfil.'
    ),
    generationConfig: GenerationConfig(
      temperature: 0.7,
      topK: 40,
      topP: 0.95,
      maxOutputTokens: 8192,
    ),
    safetySettings: [
      // SafetySetting(HarmCategory.harassment, HarmBlockThreshold.mediumAndAbove),
      // SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.mediumAndAbove),
    ],
  );

  void startNewChat() {
    _chat = _model.startChat();
  }

  Future<String> _getNutritionContext() async {
    try {
      final profile = await _nutritionService.getUserProfile();
      String profileContext = '';
      if (profile != null) {
        profileContext = 'PERFIL DEL USUARIO: '
            'Objetivo: ${profile['goal']}, '
            'Actividad: ${profile['activity_level']}, '
            'Restricciones: ${profile['restrictions'] is List ? (profile['restrictions'] as List).join(', ') : profile['restrictions']}, '
            'Habilidad Cocina: ${profile['cooking_skill']}. ';
      }

      // We can add more context here like current plan, streak, etc. if needed
      return '[CONTEXTO NUTRICIONAL RELEVANTE: $profileContext]';
    } catch (e) {
      debugPrint('Error getting nutrition context: $e');
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
      debugPrint('AI Raw Response: $responseText');
      
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
          debugPrint('Successfully parsed GenUI JSON: $genUiData');
          
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
      debugPrint('CRITICAL ERROR in AiService.sendMessage: $e');
      return Message(
        text: 'Error al conectar con la IA: $e',
        isAi: true,
        timestamp: DateTime.now(),
      );
    }
  }

  Future<Map<String, dynamic>?> _generateRestMultimodal(String prompt, Uint8List imageBytes, {bool includeImageOutput = false}) async {
    final String apiKey = _apiKey;
    final String baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent?key=$apiKey';

    final dio = dio_api.Dio();
    final String base64Image = base64Encode(imageBytes);

    final Map<String, dynamic> requestBody = {
      "contents": [
        {
          "parts": [
            {"text": prompt},
            {
              "inlineData": {
                "mimeType": "image/jpeg",
                "data": base64Image
              }
            }
          ]
        }
      ],
      "generationConfig": <String, dynamic>{
        "temperature": 0.7,
        "topK": 40,
        "topP": 0.95,
        "maxOutputTokens": 8192,
      },
      "safetySettings": [
        {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_NONE"},
        {"category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_NONE"},
        {"category": "HARM_CATEGORY_SEXUALLY_EXPLICIT", "threshold": "BLOCK_NONE"},
        {"category": "HARM_CATEGORY_DANGEROUS_CONTENT", "threshold": "BLOCK_NONE"},
        {"category": "HARM_CATEGORY_CIVIC_INTEGRITY", "threshold": "BLOCK_NONE"}
      ]
    };

    if (includeImageOutput) {
      requestBody["generationConfig"]["responseModalities"] = ["TEXT", "IMAGE"];
    }

    try {
      debugPrint('AI_SERVICE: Sending REST request to Gemini ($baseUrl)...');
      debugPrint('AI_SERVICE: Prompt: ${prompt.substring(0, prompt.length > 100 ? 100 : prompt.length)}...');
      
      final response = await dio.post(
        baseUrl,
        data: requestBody,
        options: dio_api.Options(headers: {'Content-Type': 'application/json'}),
      );

      debugPrint('AI_SERVICE: REST Response Status: ${response.statusCode}');
      debugPrint('AI_SERVICE: REST Response Data: ${jsonEncode(response.data)}');
      if (response.statusCode == 200) {
        return response.data;
      }
      debugPrint('AI_SERVICE: REST Error Data: ${response.data}');
      return null;
    } catch (e) {
      if (e is dio_api.DioException) {
        debugPrint('AI_SERVICE: REST DioError - Status: ${e.response?.statusCode}');
        debugPrint('AI_SERVICE: REST DioError - Data: ${e.response?.data}');
      }
      debugPrint('AI_SERVICE: REST CRITICAL ERROR: $e');
      return null;
    }
  }

  Future<String> generateGoalVision(String textGoal, Uint8List imageBytes) async {
    debugPrint('AI_SERVICE: Generating Goal Vision (REST) for objective: "$textGoal"');
    
    final prompt = 'El usuario tiene este objetivo: "$textGoal". '
        'Basado en su foto actual, describe de manera muy detallada y MOTIVADORA '
        'cómo se vería su cuerpo después de alcanzar este objetivo con éxito. '
        'Enfócate en la definición muscular, postura, brillo en la piel y energía. '
        'Tu respuesta debe ser un párrafo corto pero extremadamente inspirador.';

    final data = await _generateRestMultimodal(prompt, imageBytes);
    
    if (data != null && data['candidates'] != null) {
      final candidates = data['candidates'] as List;
      if (candidates.isNotEmpty) {
        final content = candidates[0]['content'];
        if (content != null && content['parts'] != null) {
          final parts = content['parts'] as List;
          for (var part in parts) {
            if (part['text'] != null) {
              return part['text'];
            }
          }
        }
      }
    }
    
    return '¡Te verás increíble alcanzando tu meta!';
  }

  Future<Uint8List?> generateGoalImageBytes(String textGoal, Uint8List imageBytes) async {
    debugPrint('AI_SERVICE: Requesting True Image-to-Image Generation (REST)...');
    
    final enhancedPrompt = '''
      Genera una foto fotorrealista de la persona en la imagen adjunta en su mejor versión física.
      El sujeto debe tener un físico atlético y en forma, con definición muscular saludable.
      MANTÉN la identidad facial exacta y los rasgos faciales de la persona original.
      Iluminación de estudio profesional, alta resolución.
      Instrucción del usuario: $textGoal
    ''';

    final data = await _generateRestMultimodal(enhancedPrompt, imageBytes, includeImageOutput: true);
    
    if (data != null && data['candidates'] != null) {
      final candidates = data['candidates'] as List;
      if (candidates.isNotEmpty) {
        final candidate = candidates[0];
        final finishReason = candidate['finishReason'];
        debugPrint('AI_SERVICE: Candidate Finish Reason: $finishReason');
        
        if (candidate['safetyRatings'] != null) {
           debugPrint('AI_SERVICE: Safety Ratings: ${jsonEncode(candidate['safetyRatings'])}');
        }

        final content = candidate['content'];
        if (content != null && content['parts'] != null) {
          final parts = content['parts'] as List;
          for (var part in parts) {
            if (part['inlineData'] != null) {
              final inlineData = part['inlineData'];
              if (inlineData['data'] != null) {
                debugPrint('AI_SERVICE: Image bytes found in REST response (inlineData)!');
                return base64Decode(inlineData['data']);
              }
            }
            // Fallback for different response versions
            if (part['inline_data'] != null) {
              final inlineData = part['inline_data'];
              if (inlineData['data'] != null) {
                debugPrint('AI_SERVICE: Image bytes found in REST response (inline_data)!');
                return base64Decode(inlineData['data']);
              }
            }
            // Some versions might return 'image' or 'blob' directly
            if (part['image'] != null && part['image']['data'] != null) {
              debugPrint('AI_SERVICE: Image bytes found in REST response (image.data)!');
              return base64Decode(part['image']['data']);
            }
          }
        }
      }
    }
    
    debugPrint('AI_SERVICE: No image found in REST response candidates.');
    return null;
  }
  Future<Map<String, dynamic>?> generateVisionAndImage(String textGoal, Uint8List imageBytes) async {
    debugPrint('AI_SERVICE: Combining Vision and Image Generation in one request...');
    
    final prompt = '''
      El usuario tiene este perfil y objetivo: $textGoal
      
      ACTÚA COMO UN EXPERTO:
     Genera una foto fotorrealista de la persona en la imagen adjunta en su mejor versión física, manteniendo su identidad facial exacta.
    ''';

    final data = await _generateRestMultimodal(prompt, imageBytes, includeImageOutput: true);
    
    if (data != null && data['candidates'] != null) {
      final candidates = data['candidates'] as List;
      if (candidates.isNotEmpty) {
        final candidate = candidates[0];
        String? vision;
        Uint8List? image;

        final content = candidate['content'];
        if (content != null && content['parts'] != null) {
          final parts = content['parts'] as List;
          for (var part in parts) {
            if (part['text'] != null) {
              vision = part['text'];
            }
            if (part['inlineData'] != null && part['inlineData']['data'] != null) {
              image = base64Decode(part['inlineData']['data']);
            } else if (part['inline_data'] != null && part['inline_data']['data'] != null) {
              image = base64Decode(part['inline_data']['data']);
            }
          }
        }
        
        if (vision != null || image != null) {
          return {
            'description': vision ?? '¡Te verás increíble alcanzando tu meta!',
            'imageBytes': image,
          };
        }
      }
    }
    
    debugPrint('AI_SERVICE: No vision or image found in combined request.');
    return null;
  }
}
