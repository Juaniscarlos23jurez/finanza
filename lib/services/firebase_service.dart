import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  
  // Helper to make email safe for Firebase keys
  String _safeEmail(String email) {
    return email.replaceAll('.', ',');
  }

  /// Mappings a user email to a unique invitation code
  Future<void> registerUserCode(String email, String code) async {
    final String safeEmail = _safeEmail(email);
    // Map code -> email
    await _db.ref('user_codes/$code').set(email);
    // Map email -> code (for quick lookup)
    await _db.ref('emails_to_codes/$safeEmail').set(code);
  }

  /// Sends an invitation using a target user's code
  Future<Map<String, dynamic>> sendInvitationByCode({
    required String fromEmail,
    required String fromName,
    required String toCode,
    required int goalId,
    required String goalName,
  }) async {
    // 1. Look up email by code
    final DataSnapshot snapshot = await _db.ref('user_codes/$toCode').get();
    
    if (snapshot.value == null) {
      return {'success': false, 'message': 'Código no encontrado'};
    }

    final String targetEmail = snapshot.value.toString();
    final String safeToEmail = _safeEmail(targetEmail);
    
    // 2. Push invitation to that email's inbox
    final invitationRef = _db.ref('invitations/$safeToEmail').push();
    
    await invitationRef.set({
      'fromEmail': fromEmail,
      'fromName': fromName,
      'goalId': goalId,
      'goalName': goalName,
      'status': 'pending',
      'timestamp': ServerValue.timestamp,
    });

    return {'success': true};
  }

  /// Listens for incoming invitations for a specific user
  Stream<DatabaseEvent> listenToInvitations(String email) {
    final String safeEmail = _safeEmail(email);
    return _db.ref('invitations/$safeEmail').onValue;
  }

  /// Removes an invitation after it has been handled
  Future<void> removeInvitation(String email, String invitationKey) async {
    final String safeEmail = _safeEmail(email);
    await _db.ref('invitations/$safeEmail/$invitationKey').remove();
  }

  /// Notifies collaborators that a goal has been updated
  Future<void> notifyGoalUpdate(int goalId) async {
    await _db.ref('goals_sync/$goalId').set({
      'updatedAt': ServerValue.timestamp,
    });
  }

  /// Listens for updates on a specific goal
  Stream<DatabaseEvent> listenToGoalUpdates(int goalId) {
    return _db.ref('goals_sync/$goalId').onValue;
  }

  /// Saves general user configuration (budget, sources, debts, onboarding status)
  Future<void> saveUserConfig(String email, Map<String, dynamic> config) async {
    final String safeEmail = _safeEmail(email);
    await _db.ref('user_configs/$safeEmail').set({
      ...config,
      'updatedAt': ServerValue.timestamp,
    });
  }

  /// Retrieves user configuration
  Future<Map<String, dynamic>?> getUserConfig(String email) async {
    final String safeEmail = _safeEmail(email);
    final snapshot = await _db.ref('user_configs/$safeEmail').get();
    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return null;
  }
}
