import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import '../models/message_model.dart';
import 'ai_service.dart';
import 'auth_service.dart';

class ChatService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final AuthService _authService = AuthService();
  late final AiService _aiService;

  ChatService() {
    _aiService = AiService();
  }

  // Get conversations stream for current user (Realtime DB)
  Stream<DatabaseEvent> getUserConversations() async* {
    final userId = await _authService.getUserId();
    if (userId == null) yield* const Stream.empty();

    yield* _database
        .ref('users/$userId/conversations')
        .orderByChild('last_activity')
        .onValue;
  }

  // Get messages stream for a specific conversation
  Stream<DatabaseEvent> getMessages(String conversationId) async* {
    final userId = await _authService.getUserId();
    if (userId == null) yield* const Stream.empty();

    yield* _database
        .ref('users/$userId/conversations/$conversationId/messages')
        .orderByChild('timestamp')
        .onValue;
  }

  // Create a new conversation
  Future<String> createConversation(String initialMessage) async {
    final userId = await _authService.getUserId();
    if (userId == null) throw Exception('No user logged in');

    final conversationsRef = _database.ref('users/$userId/conversations');
    final newConvRef = conversationsRef.push(); // Generate ID

    await newConvRef.set({
      'title': initialMessage.length > 30
          ? '${initialMessage.substring(0, 30)}...'
          : initialMessage,
      'createdAt': ServerValue.timestamp,
      'last_activity': ServerValue.timestamp,
      'last_message': initialMessage,
    });

    return newConvRef.key!;
  }

  // Send a message (User) and trigger AI response
  Future<void> sendMessage({
    required String? conversationId,
    required String text,
    String? languageCode,
    Function(String newConversationId)? onConversationCreated,
  }) async {
    final userId = await _authService.getUserId();
    if (userId == null) throw Exception('No user logged in');

    String currentConversationId = conversationId ?? '';

    // If no conversation ID, create one
    if (currentConversationId.isEmpty) {
      currentConversationId = await createConversation(text);
      if (onConversationCreated != null) {
        onConversationCreated(currentConversationId);
      }
    } else {
      // Update last message
      await _database
          .ref('users/$userId/conversations/$currentConversationId')
          .update({
            'last_activity': ServerValue.timestamp,
            'last_message': text,
          });
    }

    final conversationRef = _database.ref(
      'users/$userId/conversations/$currentConversationId',
    );
    final messagesRef = conversationRef.child('messages');

    // 1. Save User Message
    await messagesRef.push().set({
      'text': text,
      'is_ai': false,
      'timestamp': ServerValue.timestamp,
    });

    // 2. Get AI Response
    try {
      final aiMessage = await _aiService.sendMessage(
        text,
        languageCode: languageCode,
      );

      // 3. Save AI Message
      await messagesRef.push().set({
        'text': aiMessage.text,
        'is_ai': true,
        'is_gen_ui': aiMessage.isGenUI,
        'data':
            aiMessage.data, // Map<String, dynamic> leads to proper JSON in RTDB
        'timestamp': ServerValue.timestamp,
      });

      // Update last message with AI text
      await conversationRef.update({
        'last_activity': ServerValue.timestamp,
        'last_message': aiMessage.text,
      });
    } catch (e) {
      debugPrint('Error getting AI response: $e');
    }
  }

  // Update a message (e.g., mark as handled)
  Future<void> updateMessage(
    String conversationId,
    String messageKey,
    Map<String, dynamic> updates,
  ) async {
    final userId = await _authService.getUserId();
    if (userId == null) return;

    await _database
        .ref('users/$userId/conversations/$conversationId/messages/$messageKey')
        .update(updates);
  }

  // Create a message object from Realtime DB DataSnapshot value (Map)
  Message fromRealtimeDB(Map<dynamic, dynamic> data, {String? key}) {
    return Message(
      key: key,
      text: data['text']?.toString() ?? '',
      isAi: data['is_ai'] == true,
      timestamp: data['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int)
          : DateTime.now(),
      isGenUI: data['is_gen_ui'] == true,
      isHandled: data['is_handled'] == true,
      data: data['data'] != null
          ? Map<String, dynamic>.from(data['data'] as Map)
          : null,
    );
  }
}
