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

  Stream<DatabaseEvent> getPlan() async* {
    final userId = await _authService.getUserId();
    if (userId == null) yield* const Stream.empty();

    yield* _database.ref('users/$userId/nutrition_plan').onValue;
  }
}
