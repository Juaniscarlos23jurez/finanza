import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For debuPrint
import '../models/message_model.dart';
import 'ai_service.dart';
import 'auth_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final AiService _aiService = AiService();

  // Get conversations stream for current user
  Stream<QuerySnapshot> getUserConversations() async* {
    final userId = await _authService.getUserId();
    if (userId == null) yield* const Stream.empty();
    
    yield* _firestore
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .orderBy('last_activity', descending: true)
        .snapshots();
  }

  // Get messages stream for a specific conversation
  Stream<QuerySnapshot> getMessages(String conversationId) async* {
    final userId = await _authService.getUserId();
    if (userId == null) yield* const Stream.empty();

    yield* _firestore
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Create a new conversation
  Future<String> createConversation(String initialMessage) async {
    final userId = await _authService.getUserId();
    if (userId == null) throw Exception('No user logged in');

    final docRef = await _firestore
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .add({
      'title': initialMessage.length > 30 ? '${initialMessage.substring(0, 30)}...' : initialMessage,
      'createdAt': FieldValue.serverTimestamp(),
      'last_activity': FieldValue.serverTimestamp(),
      'last_message': initialMessage,
    });

    return docRef.id;
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
       await _firestore
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .doc(currentConversationId)
          .update({
             'last_activity': FieldValue.serverTimestamp(),
             'last_message': text,
          });
    }

    final conversationRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .doc(currentConversationId);

    // 1. Save User Message
    await conversationRef.collection('messages').add({
      'text': text,
      'is_ai': false,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 2. Get AI Response
    try {
      final aiMessage = await _aiService.sendMessage(text);
      
      // 3. Save AI Message
      await conversationRef.collection('messages').add({
        'text': aiMessage.text,
        'is_ai': true,
        'is_gen_ui': aiMessage.isGenUI,
        'data': aiMessage.data,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      // Update last message with AI text
      await conversationRef.update({
        'last_activity': FieldValue.serverTimestamp(),
        'last_message': aiMessage.text,
      });

    } catch (e) {
      debugPrint('Error getting AI response: $e');
      // Optionally save an error message as AI response
    }
  }
  
  // Create a message object from Firestore doc
  Message fromFirestore(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      text: data['text'] ?? '',
      isAi: data['is_ai'] ?? false,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isGenUI: data['is_gen_ui'] ?? false,
      data: data['data'],
    );
  }
}
