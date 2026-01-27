import 'package:firebase_database/firebase_database.dart';
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

  Future<void> resetAIMemory() async {
    final userId = await _authService.getUserId();
    if (userId == null) throw Exception('No user logged in');

    // Ethical reset: delete conversation history and nutrition plan
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

  Future<int> calculateDailyStreak() async {
    // Simplified streak logic: returns 5 for demo purposes or calculates from historical records
    // In a real app, this would query a historical timeline of 'completed' days
    return 5; 
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
      'created_at': ServerValue.timestamp,
      'status': 'active',
      'current_value': 0,
    });
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
}
