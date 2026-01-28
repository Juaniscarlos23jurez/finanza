import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'auth_service.dart';

class NutritionService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
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
      // Logic for streak update could go here, but maybe better to keep it simple for now
    }
  }

  Future<void> toggleMealCompletion(String mealId, bool completed) async {
    final userId = await _authService.getUserId();
    if (userId == null) throw Exception('No user logged in');

    await _database.ref('users/$userId/daily_meals/$mealId/completed').set(completed);
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

  Future<void> updateStreak(int increment) async {
    final userId = await _authService.getUserId();
    if (userId == null) return;

    final ref = _database.ref('users/$userId/streak');
    final snapshot = await ref.get();
    int currentStreak = 0;
    if (snapshot.exists) {
      currentStreak = int.tryParse(snapshot.value.toString()) ?? 0;
    }
    await ref.set(currentStreak + increment);
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

  Future<void> syncUserRanking(String name, int streak) async {
    final userId = await _authService.getUserId();
    if (userId == null) return;

    await _database.ref('public_rankings/$userId').set({
      'name': name,
      'streak': streak,
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
      'status': 'active',
      'current_amount': goalData['current_amount'] ?? 0,
    });
  }

  Future<void> updateGoalProgress(String goalId, double amount, {bool isWithdrawal = false}) async {
    final userId = await _authService.getUserId();
    if (userId == null) throw Exception('No user logged in');

    final ref = _database.ref('users/$userId/goals/$goalId/current_amount');
    final snapshot = await ref.get();
    double current = double.tryParse(snapshot.value.toString()) ?? 0.0;
    
    double newAmount = isWithdrawal ? current - amount : current + amount;
    await ref.set(newAmount);
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
