import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

class GamificationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final AuthService _authService = AuthService();

  // Helper to ensure Firebase is ready and get the correct ID
  Future<String?> _getUserId() async {
    // 1. Ensure Firebase Auth is signed in (anonymously if needed for access)
    if (_firebaseAuth.currentUser == null) {
      try {
        await _firebaseAuth.signInAnonymously();
      } catch (e) {
        debugPrint("Error signing in anonymously to Firebase: $e");
        return null;
      }
    }

    // 2. Try to get the Laravel User ID (Persistent ID)
    final laravelId = await _authService.getUserId();
    if (laravelId != null) return laravelId;

    // 3. Fallback to Firebase UID if no Laravel ID (e.g. offline first run?)
    return _firebaseAuth.currentUser?.uid;
  }

  // Stream to listen to gamification data changes
  Stream<Map<String, dynamic>> get gamificationStream async* {
    final userId = await _getUserId();
    
    if (userId == null) {
      yield {'streak': 0, 'lives': 3, 'last_check_in': null};
      return;
    }

    final ref = _db.ref('users/$userId/gamification');
    
    yield* ref.onValue.map((event) {
      if (event.snapshot.value == null) {
        return {'streak': 0, 'lives': 3, 'last_check_in': null};
      }
      try {
         final data = Map<String, dynamic>.from(event.snapshot.value as Map);
         return data;
      } catch (e) {
         return {'streak': 0, 'lives': 3, 'last_check_in': null};
      }
    });
  }

  // Helper for StreamBuilder (since streams can't be async*)
  Stream<Map<String, dynamic>> getGamificationStream() {
    // Since we need to await the user ID, we can return a Stream that starts with default
    // and then switches. However, easier pattern is a StreamController or just FutureBuilder in UI.
    // But let's try to return a valid stream.
    
    return Stream.fromFuture(_getUserId()).asyncExpand((userId) {
       if (userId == null) {
         return Stream.value({'streak': 0, 'lives': 3, 'last_check_in': null});
       }
       final ref = _db.ref('users/$userId/gamification');
       return ref.onValue.map((event) {
        if (event.snapshot.value == null) {
          return {'streak': 0, 'lives': 3, 'last_check_in': null};
        }
        try {
          // Firebase returns LinkedHashMap, cast carefully
          final val = event.snapshot.value;
          if (val is Map) {
             return Map<String, dynamic>.from(val);
          }
          return {'streak': 0, 'lives': 3, 'last_check_in': null};
        } catch (e) {
          debugPrint("Error parsing gamification data: $e");
          return {'streak': 0, 'lives': 3, 'last_check_in': null};
        }
      });
    });
  }

  Future<void> checkIn() async {
    final userId = await _getUserId();
    if (userId == null) return;

    final ref = _db.ref('users/$userId/gamification');
    final snapshot = await ref.get();

    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month}-${now.day}";
    
    // Default state
    int streak = 0;
    int lives = 3;
    String? lastCheckIn;

    if (snapshot.exists) {
      final val = snapshot.value;
      if (val is Map) {
          final data = Map<String, dynamic>.from(val);
          streak = data['streak'] ?? 0;
          lives = data['lives'] ?? 3;
          lastCheckIn = data['last_check_in'];
      }
    }

    // Attempt to parse last check-in
    DateTime? lastDate;
    if (lastCheckIn != null) {
      try {
        final parts = lastCheckIn.split('-');
        if (parts.length == 3) {
            lastDate = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        }
      } catch (e) {
        debugPrint("Error parsing date: $e");
      }
    }

    if (lastDate != null) {
      final todayDate = DateTime(now.year, now.month, now.day);
      final difference = todayDate.difference(lastDate).inDays;

      if (difference == 0) {
        // Already checked in today
        debugPrint("Already checked in today.");
        return; 
      } else if (difference == 1) {
        // Consecutive day
        streak++;
        debugPrint("Streak increased to $streak!");
      } else {
        // Missed a day (or more)
        if (lives > 0) {
             // Simple logic: If missed, reset for now.
             // Improve later: Lose life instead of full reset if < 2 days missed?
             // Prompt says: "Lose life... avoids 'what the hell' effect"
             // Let's implement losing a life if diff > 1 but lives > 0
             /*
             lives--;
             if (lives < 0) lives = 0;
             // Keep streak? Or reset? Usually streak preserves if life used.
             // Let's preserve streak but consume life.
             */
            lives--; // Consume life
            streak++; // Keep the streak going and count today!
            debugPrint("Life consumed! Lives left: $lives. Streak saved and incremented to $streak.");
            if (lives == 0) {
               // If we just used the last life, do we warn? 
               // For now, we allowed the save. Next time it will reset.
            }
        } else {
            streak = 1;
             lives = 3; // Reset lives on full reset? Or keep 0? usually refresh lives on new streak
        }
      }
    } else {
        // First ever check-in
        streak = 1;
        lives = 3; 
    }

    // Update Firebase
    await ref.update({
      'streak': streak,
      'lives': lives,
      'last_check_in': todayStr,
      'last_updated': now.toIso8601String(),
    });
  }
}
