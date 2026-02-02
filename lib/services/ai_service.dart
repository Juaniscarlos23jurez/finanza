import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/message_model.dart';
import 'finance_service.dart';
import 'auth_service.dart';

class AiService {
  // Use dotenv to get the API Key
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  
  final GenerativeModel _model;
  final FinanceService _financeService = FinanceService();
  final AuthService _authService = AuthService();
  ChatSession? _chat;

  AiService() : _model = GenerativeModel(
    model: 'gemini-2.5-flash-lite',
    apiKey: _apiKey,
    systemInstruction: Content.system(
      'Eres el asistente financiero de "Finanzas AI". '
      'TU OBJETIVO PRINCIPAL: Ayudar al usuario a gestionar su dinero, ahorros y metas. '
      'REGLAS ESTRICTAS (GUARDRAILS): '
      '1. SOLO responde preguntas relacionadas con finanzas, economía personal, presupuesto, ahorros o el uso de esta app. '
      '2. Si el usuario pregunta sobre otros temas (deportes, noticias, clima, chistes), rechaza amablemente responder y redirige al tema financiero. Ejemplo: "Lo siento, solo puedo ayudarte con temas financieros." '
      '3. Tienes acceso a los datos del usuario (Contexto). Úsalos para personalizar la respuesta. '
      '4. FORMATO JSON ESTRICTO: USA SOLO COMILLAS DOBLES ESTÁNDAR ("). NO USES COMILLAS INTELIGENTES (“”). NO USES PARÉNTESIS () PARA ENVOLVER JSON. SOLO LLAVES {}. '
      'GENUI (INTERFAZ GENERATIVA): '
      'Cuando sea útil, incluye un bloque JSON al final para generar UI interactiva. '
      'Formatos soportados: '
      '1. SUGERIR META (Cuando el usuario quiera ahorrar para algo): '
      '{ "type": "goal_suggestion", "title": "Nombre Meta", "target_amount": 1000, "reason": "Explicación breve basada en sus finanzas." } '
      'IMPORTANTE: Solo usa META si el usuario dice "quiero ahorrar para..." o "meta de...". Si dice "tengo X ahorrado", es un INGRESO, no una meta. '
      '2. VER GRÁFICAS (Cuando el usuario pida análisis visual): '
      '{ "type": "view_chart", "chart_type": "pie", "message": "Aquí tienes tu análisis." } '
      '4. CREAR UNA TRANSACCIÓN (para UNA SOLA transacción): '
      '{ "type": "transaction", "amount": 100, "category": "Ahorro", "is_expense": false, "description": "Ahorro inicial", "date": "2024-01-01T12:00:00" } '
      '5. PAGAR DEUDA (Cuando el usuario mencione pagar una deuda): '
      '{ "type": "pay_debt", "amount": 500, "debt_name": "Nombre de la Deuda" } '
      'IMPORTANTE: Usa "pay_debt" solo para abonos a deudas registradas. Esto actualizará el saldo de la deuda además del balance. '
      'REGLA CRÍTICA: Si el usuario menciona "ayer", "el viernes", etc., calcula la fecha exacta basándote en la fecha actual y úsala en "date". Si no, usa la fecha actual. '
      'Si el usuario dice "tengo 3000 ahorrados" o "mi base es 3000", ESTO ES UN INGRESO (is_expense: false). Genera una transacción para registrarlo. '
      '6. CREAR MÚLTIPLES TRANSACCIONES (IMPORTANTE: cuando el usuario mencione varias transacciones en un solo mensaje, usa este formato): '
      '{ "type": "multi_transaction", "transactions": [ { "amount": 20, "category": "Ventas", "is_expense": false, "description": "Venta", "date": "2024-01-01T12:00:00" }, { "amount": 30, "category": "Comida", "is_expense": true, "description": "Comida", "date": "..." } ] } '
      '7. VER BALANCE: '
      '{ "type": "balance", "total": 1500, "income": 2000, "expenses": 500 } '
      'Solo usa esto si el usuario pregunta "¿cuánto tengo?" o "ver balance". SI EL USUARIO PIDE "AÑADIR" o "REGISTRAR" O "TENGO X", USA TRANSACTION, NO BALANCE. '
      '8. LISTA DE MOVIMIENTOS (Tabla histórica): '
      '{ "type": "transaction_list", "items": [ {"date": "Hoy", "description": "Uber", "amount": 15.50, "is_expense": true}, {"date": "Ayer", "description": "Sueldo", "amount": 2000, "is_expense": false} ] } '
      'REGLA CRÍTICA: Si el usuario menciona múltiples ingresos o gastos en un mismo mensaje (ej: "gané 20, gasté 30 en comida y 20 en pasaje"), SIEMPRE usa "multi_transaction" para generar TODAS las transacciones, no solo la primera. '
      '9. ANÁLISIS PREMIUM (CRÍTICO): Usa esto SIEMPRE que el usuario pida proyecciones, planes a futuro (ej: "en 6 meses", "el próximo año"), análisis detallados o consejos estratégicos. '
      'REGLA DE MONETIZACIÓN: No hagas preguntas aclaratorias primero. Genera el análisis de inmediato usando el bloque JSON. '
      'Si te falta información, incluye tus suposiciones o diversos escenarios dentro del campo "content" del JSON. '
      'Formato: { "type": "premium_analysis", "title": "Nombre", "summary": "Resumen", "metrics": [{"label": "Ahorro", "value": "15%", "icon": "trending_up"}], "content": "Markdown extenso" } '
      'REGLA DE FORMATO: En "content", usa tablas de Markdown para comparativas, negritas para números clave y secciones claras (Situación, Estrategia, Pasos).'
      '10. EXPORTAR CSV (NUEVO): Usa esto si el usuario pide "exportar", "descargar CSV", "excel" o "guardar tabla". '
      'REGLA CRÍTICA: USA ÚNICAMENTE los datos reales de "MOVIMIENTOS RECIENTES" proporcionados en el contexto para generar el CSV. NUNCA inventes datos o uses ejemplos si hay movimientos disponibles. '
      'Formato: { "type": "csv_export", "filename": "movimientos.csv", "data": "fecha,descripcion,monto,tipo\\n2024-01-01,Sueldo,2000,ingreso\\n..." }'
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
        _authService.getDebts(),
      ]);

      final data = futures[0] as Map<String, dynamic>;
      final goals = futures[1] as List<dynamic>;
      final debts = futures[2] as List<Map<String, dynamic>>;
      
      final summary = data['summary'];
      final List<dynamic> records = data['records'] ?? [];
      
      // Limit to last 50 transactions to avoid huge prompts but provide enough for CSV
      final recentRecords = records.take(50).map((r) => 
        "{fecha: ${r['date']}, desc: ${r['description']}, monto: ${r['amount']}, tipo: ${r['type']}, cat: ${r['category']}}"
      ).join(', ');

      final goalsString = goals.map((g) => 
        "${g['title']}: \$${g['current_amount']}/\$${g['target_amount']}"
      ).join(', ');

      final debtsString = debts.map((d) => 
        "${d['name']}: \$${d['amount']} (Pago mensual: \$${d['monthly_payment']})"
      ).join(', ');

      return '[CONTEXTO FINANCIERO ACTUAL: '
             'Balance: \$${(summary['total_income'] - summary['total_expense']).toStringAsFixed(2)}, '
             'Ingresos: \$${summary['total_income']}, '
             'Gastos: \$${summary['total_expense']}, '
             'Metas: ${goalsString.isEmpty ? "Ninguna" : goalsString}, '
             'Deudas: ${debtsString.isEmpty ? "Ninguna" : debtsString}. '
             'MOVIMIENTOS RECIENTES: $recentRecords]';
    } catch (e) {
      return '[No se pudo obtener el contexto financiero actual]';
    }
  }

  Future<Message> sendMessage(String text, {String? languageCode}) async {
    _chat ??= _model.startChat();

    try {
      // Inject context and language instruction into the message
      final contextValues = await _getFinancialContext();
      final languageInstruction = languageCode != null 
          ? 'El usuario está usando la aplicación en el idioma con código: "$languageCode". Responde ÚNICAMENTE en ese idioma, pero mantén todas las reglas de personalidad y formato JSON.'
          : 'Responde en el mismo idioma en que el usuario te hable.';

      final fullPrompt = 'FECHA ACTUAL: ${DateTime.now().toIso8601String()}\n'
                         '$languageInstruction\n'
                         '$contextValues\n\n'
                         'Usuario: $text';
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
           
          // Clean up common JSON errors from LLM
          jsonString = jsonString
              .replaceAll('“', '"')
              .replaceAll('”', '"')
              .replaceAll('‘', "'")
              .replaceAll('’', "'")
              .replaceAll('multi_ transaction', 'multi_transaction')
              .trim();
          
          if (jsonString.startsWith('(') && jsonString.endsWith(')')) {
            jsonString = jsonString.substring(1, jsonString.length - 1);
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
