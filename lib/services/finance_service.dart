import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'auth_service.dart';

class FinanceService {
  final Dio _dio = Dio();
  final AuthService _authService = AuthService();
  // Hardcoding for stability as .env seems to be having issues loading on some devices/builds immediately
  final String _baseUrl = 'https://laravel-pkpass-backend-development-pfaawl.laravel.cloud/api/client/auth/finance';

  // Stream controller to broadcast data updates to the app
  static final StreamController<void> _updateController = StreamController<void>.broadcast();
  Stream<void> get onDataUpdated => _updateController.stream;

  Future<Map<String, dynamic>> getFinanceData({
    String? type,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final queryParams = <String, dynamic>{};
      if (type != null) queryParams['type'] = type;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await _dio.get(
        _baseUrl,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      return response.data;
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? 'Error fetching finance data');
      }
      throw Exception('Error fetching finance data: $e');
    }
  }

  Future<Map<String, dynamic>> createRecord(Map<String, dynamic> data) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await _dio.post(
        _baseUrl,
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      _updateController.add(null); // Notify listeners
      return response.data;
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? 'Error creating record');
      }
      throw Exception('Error creating record: $e');
    }
  }

  Future<Map<String, dynamic>> updateRecord(int id, Map<String, dynamic> data) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await _dio.put(
        '$_baseUrl/$id',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      _updateController.add(null); // Notify listeners
      return response.data;
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? 'Error updating record');
      }
      throw Exception('Error updating record: $e');
    }
  }

  Future<void> deleteRecord(int id) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      await _dio.delete(
        '$_baseUrl/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      _updateController.add(null); // Notify listeners
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? 'Error deleting record');
      }
      throw Exception('Error deleting record: $e');
    }
  }

  // --- GOALS API ---

  Future<List<dynamic>> getGoals() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token found');

      debugPrint('DEBUG: Fetching goals from ${AuthService.baseUrl}/goals');
      final response = await _dio.get(
        '${AuthService.baseUrl}/goals',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint('DEBUG: Goals response status: ${response.statusCode}');
      debugPrint('DEBUG: Goals response data: ${response.data}');

      return response.data;
    } catch (e) {
      debugPrint('DEBUG: Error querying goals: $e');
      if (e is DioException) {
         debugPrint('DEBUG: API Error Data: ${e.response?.data}');
      }
      return [];
    }
  }

  Future<Map<String, dynamic>> createGoal(Map<String, dynamic> data) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token found');

      debugPrint('DEBUG: Creating goal with data: $data');
      // The _baseUrl already ends in /api/client/auth/finance
      // Verify if the goals endpoint is /api/client/auth/finance/goals or what.
      // Based on previous code it was $_baseUrl/goals.
      // If _baseUrl is .../finance, then this makes .../finance/goals.
      final response = await _dio.post(
        '${AuthService.baseUrl}/goals',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint('DEBUG: Create goal response: ${response.data}');
      _updateController.add(null); // Notify listeners
      return response.data;
    } catch (e) {
      debugPrint('DEBUG: Error creating goal: $e');
      if (e is DioException) {
        debugPrint('DEBUG: Create Goal API Error: ${e.response?.data}');
        throw Exception(e.response?.data['message'] ?? 'Error creating goal');
      }
      throw Exception('Error creating goal: $e');
    }
  }

  Future<Map<String, dynamic>> updateGoal(int id, Map<String, dynamic> data) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token found');

      debugPrint('DEBUG: Updating goal $id with data: $data');
      final response = await _dio.put(
        '${AuthService.baseUrl}/goals/$id',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint('DEBUG: Update goal response: ${response.data}');
      _updateController.add(null); // Notify listeners
      return response.data;
    } catch (e) {
      debugPrint('DEBUG: Error updating goal: $e');
      if (e is DioException) {
        debugPrint('DEBUG: Update Goal API Error: ${e.response?.data}');
        throw Exception(e.response?.data['message'] ?? 'Error updating goal');
      }
      throw Exception('Error updating goal: $e');
    }
  }

  /// Contribute/add funds to a goal using the dedicated endpoint
  Future<Map<String, dynamic>> contributeToGoal(int goalId, double amount) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token found');

      debugPrint('DEBUG: Contributing $amount to goal $goalId');
      final response = await _dio.post(
        '${AuthService.baseUrl}/goals/$goalId/contribute',
        data: {'amount': amount},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint('DEBUG: Contribute response: ${response.data}');
      _updateController.add(null); // Notify listeners
      return response.data;
    } catch (e) {
      debugPrint('DEBUG: Error contributing to goal: $e');
      if (e is DioException) {
        debugPrint('DEBUG: Contribute API Error: ${e.response?.data}');
        throw Exception(e.response?.data['message'] ?? 'Error contributing to goal');
      }
      throw Exception('Error contributing to goal: $e');
    }
  }

  Future<dynamic> getReportSettings() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await _dio.get(
        '${AuthService.baseUrl}/report-settings',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      return response.data;
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? 'Error al obtener configuración de reportes');
      }
      throw Exception('Error al obtener configuración de reportes: $e');
    }
  }

  Future<Map<String, dynamic>> saveReportSettings({
    required String email,
    required int frequencyDays,
    bool isActive = true,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await _dio.post(
        '${AuthService.baseUrl}/report-settings',
        data: {
          'email': email,
          'frequency_days': frequencyDays,
          'is_active': isActive,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      return response.data;
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? 'Error al guardar configuración de reportes');
      }
      throw Exception('Error al guardar configuración de reportes: $e');
    }
  }
}
