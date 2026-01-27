import 'package:firebase_database/firebase_database.dart';
import 'auth_service.dart';

class NutritionService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final AuthService _authService = AuthService();

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
}
