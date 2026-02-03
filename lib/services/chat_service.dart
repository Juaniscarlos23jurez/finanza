import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import '../models/message_model.dart';
import 'ai_service.dart';
import 'auth_service.dart';

class ChatService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final AuthService _authService = AuthService();
  final AiService _aiService = AiService();

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
    debugPrint('Creating new conversation with ID: ${newConvRef.key}');

    await newConvRef.set({
      'title': initialMessage.length > 30 ? '${initialMessage.substring(0, 30)}...' : initialMessage,
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

    final conversationRef = _database.ref('users/$userId/conversations/$currentConversationId');
    final messagesRef = conversationRef.child('messages');

    // 1. Save User Message
    debugPrint('Saving user message to RTDB in conversation: $currentConversationId');
    await messagesRef.push().set({
      'text': text,
      'is_ai': false,
      'timestamp': ServerValue.timestamp,
    });

    // 2. Get AI Response
    try {
      debugPrint('Requesting AI response for text: $text');
      final aiMessage = await _aiService.sendMessage(text);
      
      // 3. Save AI Message
      debugPrint('Saving AI response to RTDB (isGenUI: ${aiMessage.isGenUI})');
      await messagesRef.push().set({
        'text': aiMessage.text,
        'is_ai': true,
        'is_gen_ui': aiMessage.isGenUI,
        'data': aiMessage.data, // Map<String, dynamic> leads to proper JSON in RTDB
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
  // Update a message's data in the database
  Future<void> updateMessageData({
    required String conversationId,
    required String messageId,
    required Map<String, dynamic> newData,
  }) async {
    final userId = await _authService.getUserId();
    if (userId == null) throw Exception('No user logged in');

    debugPrint('Updating message data for message: $messageId in conversation: $conversationId');
    await _database
        .ref('users/$userId/conversations/$conversationId/messages/$messageId')
        .update({
          'data': newData,
        });
  }
  
  // Create a message object from Realtime DB DataSnapshot value (Map)
  Message fromRealtimeDB(Map<dynamic, dynamic> data, [String? key]) {
    return Message(
      id: key,
      text: data['text']?.toString() ?? '',
      isAi: data['is_ai'] == true,
      timestamp: data['timestamp'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int) 
          : DateTime.now(),
      isGenUI: data['is_gen_ui'] == true,
      data: data['data'] != null ? Map<String, dynamic>.from(data['data'] as Map) : null,
    );
  }
}
