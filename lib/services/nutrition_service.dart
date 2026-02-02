import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:typed_data';
import 'auth_service.dart';

class NutritionService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthService _authService = AuthService();
  
  static String sanitizeKey(String key) {
    return key.replaceAll(RegExp(r'[.#$\[\]]'), '_');
  }

  Future<void> savePlan(Map<String, dynamic> planData) async {
    final userId = await _authService.getUserId();
    if (userId == null) throw Exception('No user logged in');

    await _database.ref('users/$userId/nutrition_plan').set(planData);
  }

  Future<void> saveUserProfile(Map<String, dynamic> profileData) async {
    final userId = await _authService.getUserId();
    if (userId == null) throw Exception('No user logged in');

    await _database.ref('users/$userId/profile').set({
      ...profileData,
      'updated_at': ServerValue.timestamp,
    });
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final userId = await _authService.getUserId();
    if (userId == null) return null;

    final snapshot = await _database.ref('users/$userId/profile').get();
    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return null;
  }

  Future<String?> uploadProgressImage(File imageFile) async {
    final userId = await _authService.getUserId();
    if (userId == null) return null;

    final String fileName = 'progress_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final Reference ref = _storage.ref().child('users/$userId/progress_photos/$fileName');
    
    final UploadTask uploadTask = ref.putFile(imageFile);
    final TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<String?> uploadImageBytes(Uint8List bytes, String fileNamePrefix) async {
    final userId = await _authService.getUserId();
    if (userId == null) return null;

    final String fileName = '${fileNamePrefix}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final Reference ref = _storage.ref().child('users/$userId/progress_photos/$fileName');
    
    final UploadTask uploadTask = ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    final TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> saveVisualGoal({
    required String originalImageUrl,
    required String aiGoalImageUrl,
    required String prompt,
  }) async {
    final userId = await _authService.getUserId();
    if (userId == null) return;

    await _database.ref('users/$userId/profile/visual_goal').set({
      'original_image': originalImageUrl,
      'ai_goal_image': aiGoalImageUrl,
      'prompt': prompt,
      'created_at': ServerValue.timestamp,
    });
  }

  Future<void> saveUserEmoji(String emoji) async {
    final userId = await _authService.getUserId();
    if (userId == null) throw Exception('No user logged in');

    await _database.ref('users/$userId/profile/emoji').set(emoji);
  }

  Future<String?> getUserEmoji() async {
    final userId = await _authService.getUserId();
    if (userId == null) return null;

    final snapshot = await _database.ref('users/$userId/profile/emoji').get();
    if (snapshot.exists) {
      return snapshot.value.toString();
    }
    return null;
  }


  Future<void> resetAIMemory() async {
    final userId = await _authService.getUserId();
    if (userId == null) throw Exception('No user logged in');

    // Ethical reset: delete conversation history, nutrition plan, and daily meals
    await _database.ref('users/$userId/conversations').remove();
    await _database.ref('users/$userId/nutrition_plan').remove();
    await _database.ref('users/$userId/daily_meals').remove();
  }

  Future<void> saveDailyMeals(List<dynamic> meals) async {
    final userId = await _authService.getUserId();
    if (userId == null) throw Exception('No user logged in');

    // Convert meals to a map where keys are unique identifiers
    final Map<String, dynamic> mealsMap = {};
    for (var i = 0; i < meals.length; i++) {
      final meal = meals[i];
      final id = 'meal_$i';
      mealsMap[id] = {
        ...meal,
        'completed': false,
        'id': id,
        'timestamp': ServerValue.timestamp,
      };
    }

    await _database.ref('users/$userId/daily_meals').set(mealsMap);
  }

  Future<void> initializeTodayMeals(List<dynamic> planMeals, [int? completedIndex]) async {
    final userId = await _authService.getUserId();
    if (userId == null) throw Exception('No user logged in');

    final Map<String, dynamic> mealsMap = {};
    for (var i = 0; i < planMeals.length; i++) {
      final meal = planMeals[i];
      final id = 'meal_$i';
      mealsMap[id] = {
        ...meal,
        'completed': i == completedIndex, // Mark specific meal as completed if requested
        'id': id,
        'timestamp': ServerValue.timestamp,
      };
    }
    await _database.ref('users/$userId/daily_meals').set(mealsMap);
    
    // If we completed a meal during initialization, check streak update
    if (completedIndex != null) {
      await addXp(50);
    }
  }

  Future<void> toggleMealCompletion(String mealId, bool completed) async {
    final userId = await _authService.getUserId();
    if (userId == null) throw Exception('No user logged in');

    await _database.ref('users/$userId/daily_meals/$mealId/completed').set(completed);

    if (completed) {
      await addXp(50);
    }
  }

  Stream<DatabaseEvent> getPlan() async* {
    final userId = await _authService.getUserId();
    if (userId == null) yield* const Stream.empty();

    yield* _database.ref('users/$userId/nutrition_plan').onValue;
  }

  Stream<DatabaseEvent> getDailyMeals() async* {
    final userId = await _authService.getUserId();
    if (userId == null) yield* const Stream.empty();

    yield* _database.ref('users/$userId/daily_meals').onValue;
  }

  Stream<DatabaseEvent> getStreak() async* {
    final userId = await _authService.getUserId();
    if (userId == null) yield* const Stream.empty();

    yield* _database.ref('users/$userId/streak').onValue;
  }

  Future<bool> updateStreak(int increment) async {
    final userId = await _authService.getUserId();
    if (userId == null) return false;

    final ref = _database.ref('users/$userId/streak');
    final dateRef = _database.ref('users/$userId/last_streak_date');
    
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final dateSnapshot = await dateRef.get();
    
    if (dateSnapshot.exists && dateSnapshot.value.toString() == today && increment > 0) {
      // Already updated streak today
      return false;
    }

    final snapshot = await ref.get();
    int currentStreak = 0;
    if (snapshot.exists) {
      currentStreak = int.tryParse(snapshot.value.toString()) ?? 0;
    }
    
    int newStreak = (increment > 0) ? currentStreak + increment : 0;
    
    await ref.set(newStreak);
    if (increment > 0) {
      await dateRef.set(today);
    }
    
    // Sync with public ranking
    final profile = await getUserProfile();
    if (profile != null) {
      await syncUserRanking(profile['name'] ?? 'Usuario', newStreak, emoji: profile['emoji']);
    }
    return true;
  }

  Future<Map<String, dynamic>> validateAndSyncGamification() async {
    final userId = await _authService.getUserId();
    if (userId == null) return {};

    final statsRef = _database.ref('users/$userId/stats');
    final streakRef = _database.ref('users/$userId/streak');
    final lastDateRef = _database.ref('users/$userId/last_streak_date');

    final statsSnap = await statsRef.get();
    final streakSnap = await streakRef.get();
    final lastDateSnap = await lastDateRef.get();

    if (!statsSnap.exists) {
      await initializeGamificationStats();
      return {};
    }

    final stats = Map<String, dynamic>.from(statsSnap.value as Map);
    int lives = stats['lives'] ?? 5;
    int streak = int.tryParse(streakSnap.value?.toString() ?? '0') ?? 0;
    String lastDateStr = lastDateSnap.value?.toString() ?? '';

    if (lastDateStr.isEmpty || streak == 0) return stats;

    final DateTime lastDate = DateFormat('yyyy-MM-dd').parse(lastDateStr);
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    
    final int daysDiff = today.difference(lastDate).inDays;

    if (daysDiff > 1) {
      // Missed days!
      int missedDays = daysDiff - 1;
      int livesToConsume = missedDays;
      
      if (lives >= livesToConsume) {
        lives -= livesToConsume;
        // Streak remains (we "saved" it with lives)
      } else {
        // Not enough lives to cover the gap
        streak = 0;
        lives = 0;
      }

      await statsRef.update({'lives': lives});
      await streakRef.set(streak);
      
      // Update last_streak_date so we don't penalize again today
      final yesterday = today.subtract(const Duration(days: 1));
      await lastDateRef.set(DateFormat('yyyy-MM-dd').format(yesterday));
      lastDateStr = DateFormat('yyyy-MM-dd').format(yesterday);
    }

    // --- Life Regeneration Logic ---
    final int lastRegenTs = stats['last_regen'] ?? 0;
    if (lives < 5 && lastRegenTs > 0) {
      final lastRegen = DateTime.fromMillisecondsSinceEpoch(lastRegenTs);
      final int hoursDiff = now.difference(lastRegen).inHours;
      
      if (hoursDiff >= 24) {
        int livesToRegen = (hoursDiff / 24).floor();
        lives = (lives + livesToRegen).clamp(0, 5);
        await statsRef.update({
          'lives': lives,
          'last_regen': ServerValue.timestamp,
        });
      }
    }

    return {...stats, 'lives': lives, 'streak': streak, 'streak_lost': streak == 0 && streakSnap.value != null && int.parse(streakSnap.value.toString()) > 0};
  }

  Future<void> saveDailyTotal(double calories) async {
    final userId = await _authService.getUserId();
    if (userId == null) return;

    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await _database.ref('users/$userId/history/$date').set({
      'calories': calories,
      'timestamp': ServerValue.timestamp,
    });
  }

  Stream<DatabaseEvent> getHistory() async* {
    final userId = await _authService.getUserId();
    if (userId == null) yield* const Stream.empty();

    yield* _database.ref('users/$userId/history').onValue;
  }

  // ============ WEIGHT TRACKING ============

  Future<void> saveWeight(double weight) async {
    final userId = await _authService.getUserId();
    if (userId == null) return;

    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await _database.ref('users/$userId/weight_history/$date').set({
      'weight': weight,
      'timestamp': ServerValue.timestamp,
    });
  }

  Stream<DatabaseEvent> getWeightHistory() async* {
    final userId = await _authService.getUserId();
    if (userId == null) yield* const Stream.empty();

    yield* _database.ref('users/$userId/weight_history').onValue;
  }

  // ============ GLOBAL RANKING ============

  Stream<DatabaseEvent> getGlobalRanking() async* {
    // We query the top 10 users by streak
    // Note: In a real app, you'd want to sync streak to a public 'rankings' node 
    // to avoid reading all users, but for this demo/MVP we'll use a public node.
    yield* _database.ref('public_rankings').orderByChild('streak').limitToLast(10).onValue;
  }

  Future<void> syncUserRanking(String name, int streak, {String? emoji}) async {
    final userId = await _authService.getUserId();
    if (userId == null) return;

    await _database.ref('public_rankings/$userId').set({
      'name': name,
      'streak': streak,
      'emoji': emoji ?? '🦊', // Default emoji
      'last_update': ServerValue.timestamp,
    });
  }

  // ============ INVENTORY MANAGEMENT ============
  
  Stream<DatabaseEvent> getInventory() async* {
    final userId = await _authService.getUserId();
    if (userId == null) yield* const Stream.empty();

    yield* _database.ref('users/$userId/inventory').onValue;
  }

  Future<void> addToInventory(String itemName) async {
    final userId = await _authService.getUserId();
    if (userId == null) throw Exception('No user logged in');

    // Sanitizar nombre para usar como llave en Firebase
    final safeName = sanitizeKey(itemName);

    await _database.ref('users/$userId/inventory/$safeName').set({
      'added_at': ServerValue.timestamp,
      'name': itemName,
    });
  }

  Future<void> removeFromInventory(String itemName) async {
    final userId = await _authService.getUserId();
    if (userId == null) throw Exception('No user logged in');

    final safeName = sanitizeKey(itemName);
    await _database.ref('users/$userId/inventory/$safeName').remove();
  }

  Future<void> clearInventory() async {
    final userId = await _authService.getUserId();
    if (userId == null) throw Exception('No user logged in');

    await _database.ref('users/$userId/inventory').remove();
  }

  Future<void> addShoppingItem(String name, String quantity, String category) async {
    final userId = await _authService.getUserId();
    if (userId == null) throw Exception('No user logged in');

    final safeName = sanitizeKey(name);

    await _database.ref('users/$userId/shopping_list/$safeName').set({
      'name': name,
      'quantity': quantity,
      'category': category,
      'bought': false,
      'added_at': ServerValue.timestamp,
      'affiliate_url': 'https://www.amazon.com/s?k=${Uri.encodeComponent(name)}',
    });
  }

  Future<void> saveShoppingList(List<dynamic> items) async {
    final userId = await _authService.getUserId();
    if (userId == null) throw Exception('No user logged in');

    // Save each item to shopping_list node
    for (var item in items) {
      final String name = item['name'] ?? item.toString();
      final String quantity = item['quantity'] ?? '1 unidad';
      final String category = item['category'] ?? 'Otros';
      
      await addShoppingItem(name, quantity, category);
    }
  }

  Future<void> saveGoal(Map<String, dynamic> goalData) async {
    final userId = await _authService.getUserId();
    if (userId == null) throw Exception('No user logged in');

    // Use title as key (sanitizing it)
    final String title = goalData['title'] ?? 'goal_${DateTime.now().millisecondsSinceEpoch}';
    final safeKey = sanitizeKey(title);

    await _database.ref('users/$userId/goals/$safeKey').set({
      ...goalData,
      'id': safeKey,
      'created_at': ServerValue.timestamp,
      'last_update_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'status': 'active',
      'current_amount': goalData['current_amount'] ?? 0,
      'is_daily': goalData['is_daily'] ?? false,
    });
  }

  Future<void> resetDailyGoal(String goalId) async {
    final userId = await _authService.getUserId();
    if (userId == null) return;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await _database.ref('users/$userId/goals/$goalId').update({
      'current_amount': 0,
      'last_update_date': today,
    });
  }

  Future<void> updateGoalProgress(String goalId, double amount, {bool isWithdrawal = false}) async {
    final userId = await _authService.getUserId();
    if (userId == null) throw Exception('No user logged in');

    final ref = _database.ref('users/$userId/goals/$goalId');
    final snapshot = await ref.get();
    if (!snapshot.exists) return;

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    double current = double.tryParse(data['current_amount']?.toString() ?? '0') ?? 0.0;
    final String goalType = data['goal_type']?.toString() ?? '';
    
    // Check if it's a daily goal and needs reset before updating
    // Backward compatibility: exercise and distance are daily by default
    final bool isDaily = data['is_daily'] == true || 
                       (data['is_daily'] == null && (goalType == 'exercise_minutes' || goalType == 'distance_km'));

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (isDaily && data['last_update_date'] != today) {
      current = 0;
    }

    double newAmount = isWithdrawal ? current - amount : current + amount;
    
    await ref.update({
      'current_amount': newAmount,
      'last_update_date': today,
    });
  }

  Future<void> deleteGoal(String goalId) async {
    final userId = await _authService.getUserId();
    if (userId == null) throw Exception('No user logged in');

    await _database.ref('users/$userId/goals/$goalId').remove();
  }

  Stream<DatabaseEvent> getGoals() async* {
    final userId = await _authService.getUserId();
    if (userId == null) yield* const Stream.empty();

    yield* _database.ref('users/$userId/goals').onValue;
  }

  Future<void> clearShoppingList() async {
    final userId = await _authService.getUserId();
    if (userId == null) throw Exception('No user logged in');

    await _database.ref('users/$userId/shopping_list').remove();
  }

  Stream<DatabaseEvent> getShoppingList() async* {
    final userId = await _authService.getUserId();
    if (userId == null) yield* const Stream.empty();

    yield* _database.ref('users/$userId/shopping_list').onValue;
  }

  // ============ GAMIFICATION (LIVES & LEVELS) ============

  Stream<DatabaseEvent> getGamificationStats() async* {
    final userId = await _authService.getUserId();
    if (userId == null) yield* const Stream.empty();
    yield* _database.ref('users/$userId/stats').onValue;
  }

  Future<void> initializeGamificationStats() async {
    final userId = await _authService.getUserId();
    if (userId == null) return;

    final ref = _database.ref('users/$userId/stats');
    final snapshot = await ref.get();
    
    if (!snapshot.exists) {
      await ref.set({
        'lives': 5,
        'xp': 0,
        'level': 1,
        'last_regen': ServerValue.timestamp,
      });
    }
  }

  Future<void> addXp(int amount) async {
    final userId = await _authService.getUserId();
    if (userId == null) return;

    final ref = _database.ref('users/$userId/stats');
    final snapshot = await ref.get();
    
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      int currentXp = (data['xp'] ?? 0) + amount;
      int currentLevel = data['level'] ?? 1;
      
      // Simple Level Formula: Level = floor(sqrt(XP / 100)) + 1
      // Level 1: 0-99 XP
      // Level 2: 100-399 XP
      // Level 3: 400-899 XP
      int newLevel = (currentXp / 500).floor() + 1; // Simplified linear for demo: 500xp per level
      
      await ref.update({
        'xp': currentXp,
        'level': newLevel > currentLevel ? newLevel : currentLevel,
      });
    } else {
      await initializeGamificationStats();
      await addXp(amount);
    }
  }

  Future<bool> consumeLife() async {
    final userId = await _authService.getUserId();
    if (userId == null) return false;

    final ref = _database.ref('users/$userId/stats');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      int currentLives = data['lives'] ?? 5;
      
      if (currentLives > 0) {
        await ref.update({'lives': currentLives - 1});
        return true;
      }
    } else {
      await initializeGamificationStats();
    }
    return false;
  }

  Future<void> restoreLives() async {
    final userId = await _authService.getUserId();
    if (userId == null) return;
    await _database.ref('users/$userId/stats/lives').set(5);
  }
}
