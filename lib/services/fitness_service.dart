import 'package:health/health.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class FitnessService {
  final Health _health = Health();
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Tipos de datos que queremos leer
  static final List<HealthDataType> _healthDataTypes = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WORKOUT,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.HEART_RATE,
  ];

  // Permisos necesarios
  static final List<HealthDataAccess> _permissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  /// Solicita permisos para acceder a datos de salud
  Future<bool> requestAuthorization() async {
    print('🔐 [FitnessService] Solicitando autorización...');
    print('🔐 [FitnessService] Tipos de datos: $_healthDataTypes');
    print('🔐 [FitnessService] Permisos: $_permissions');
    
    try {
      // Verificar si HealthKit está disponible en el dispositivo
      print('🔐 [FitnessService] Verificando disponibilidad de HealthKit...');
      final available = await _health.hasPermissions(_healthDataTypes, permissions: _permissions);
      print('🔐 [FitnessService] HealthKit disponible: $available');
      
      print('🔐 [FitnessService] Llamando a _health.requestAuthorization()...');
      bool? authorized = await _health.requestAuthorization(_healthDataTypes, permissions: _permissions);
      print('🔐 [FitnessService] Respuesta de autorización: $authorized');
      
      if (authorized == null) {
        print('⚠️ [FitnessService] Autorización retornó null');
        print('⚠️ [FitnessService] Esto puede significar:');
        print('   - iPad (no tiene Apple Health)');
        print('   - Android sin Google Fit instalado');
        print('   - Simulador sin soporte de Health');
        return false;
      }
      
      print('✅ [FitnessService] Autorización: ${authorized ? "CONCEDIDA" : "DENEGADA"}');
      return authorized;
    } catch (e, stackTrace) {
      print('❌ [FitnessService] Error requesting health authorization: $e');
      print('❌ [FitnessService] StackTrace: $stackTrace');
      print('❌ [FitnessService] Tipo de error: ${e.runtimeType}');
      return false;
    }
  }

  /// Obtiene los pasos del día actual
  Future<int> getTodaySteps() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      
      final steps = await _health.getTotalStepsInInterval(midnight, now);
      return steps ?? 0;
    } catch (e) {
      print('Error getting steps: $e');
      return 0;
    }
  }

  /// Obtiene las calorías quemadas hoy
  Future<double> getTodayCaloriesBurned() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      
      final healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: midnight,
        endTime: now,
      );

      double totalCalories = 0;
      for (var data in healthData) {
        if (data.value is NumericHealthValue) {
          totalCalories += (data.value as NumericHealthValue).numericValue;
        }
      }
      
      return totalCalories;
    } catch (e) {
      print('Error getting calories: $e');
      return 0;
    }
  }

  /// Obtiene la distancia recorrida hoy (en metros)
  Future<double> getTodayDistance() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      
      final healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.DISTANCE_WALKING_RUNNING],
        startTime: midnight,
        endTime: now,
      );

      double totalDistance = 0;
      for (var data in healthData) {
        if (data.value is NumericHealthValue) {
          totalDistance += (data.value as NumericHealthValue).numericValue;
        }
      }
      
      return totalDistance;
    } catch (e) {
      print('Error getting distance: $e');
      return 0;
    }
  }

  /// Obtiene minutos de ejercicio activo hoy
  Future<int> getTodayActiveMinutes() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      
      final healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.WORKOUT],
        startTime: midnight,
        endTime: now,
      );

      int totalMinutes = 0;
      for (var data in healthData) {
        if (data.value is WorkoutHealthValue) {
          final workout = data.value as WorkoutHealthValue;
          final duration = workout.totalEnergyBurned ?? 0;
          // Estimación aproximada basada en duración del workout
          totalMinutes += (duration / 60).round();
        }
      }
      
      return totalMinutes;
    } catch (e) {
      print('Error getting active minutes: $e');
      return 0;
    }
  }

  /// Obtiene todos los datos de fitness del día
  Future<Map<String, dynamic>> getTodayFitnessData() async {
    try {
      final steps = await getTodaySteps();
      final calories = await getTodayCaloriesBurned();
      final distance = await getTodayDistance();
      final activeMinutes = await getTodayActiveMinutes();

      return {
        'steps': steps,
        'calories': calories.round(),
        'distance': (distance / 1000).toStringAsFixed(2), // Convertir a km
        'activeMinutes': activeMinutes,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
    } catch (e) {
      print('Error getting fitness data: $e');
      return {
        'steps': 0,
        'calories': 0,
        'distance': '0.0',
        'activeMinutes': 0,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
    }
  }

  /// Guarda los datos de fitness en Firebase
  Future<void> saveFitnessData(Map<String, dynamic> data) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await _database
          .ref('users/$userId/fitness/$today')
          .set(data);
    } catch (e) {
      print('Error saving fitness data: $e');
    }
  }

  /// Sincroniza datos de fitness (obtiene y guarda)
  Future<Map<String, dynamic>> syncFitnessData() async {
    final data = await getTodayFitnessData();
    await saveFitnessData(data);
    return data;
  }

  /// Stream de datos de fitness históricos
  Stream<DatabaseEvent> getFitnessHistory() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return const Stream.empty();
    }
    return _database.ref('users/$userId/fitness').onValue;
  }

  /// Obtiene el historial de pasos para gráfico (últimos 7 días)
  Future<List<Map<String, dynamic>>> getStepsHistory({int days = 7}) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await _database.ref('users/$userId/fitness').get();
      if (!snapshot.exists) return [];

      final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      final List<Map<String, dynamic>> history = [];

      final now = DateTime.now();
      for (int i = days - 1; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dateKey = DateFormat('yyyy-MM-dd').format(date);
        
        if (data.containsKey(dateKey)) {
          final dayData = Map<String, dynamic>.from(data[dateKey] as Map);
          history.add({
            'date': dateKey,
            'steps': dayData['steps'] ?? 0,
            'calories': dayData['calories'] ?? 0,
          });
        } else {
          history.add({
            'date': dateKey,
            'steps': 0,
            'calories': 0,
          });
        }
      }

      return history;
    } catch (e) {
      print('Error getting steps history: $e');
      return [];
    }
  }

  /// Verifica si el usuario ha sido activo hoy (más de 5000 pasos o 20 min activos)
  Future<bool> isActiveToday() async {
    try {
      final steps = await getTodaySteps();
      final activeMinutes = await getTodayActiveMinutes();
      
      return steps >= 5000 || activeMinutes >= 20;
    } catch (e) {
      print('Error checking activity: $e');
      return false;
    }
  }
}
