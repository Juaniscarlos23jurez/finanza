import 'dart:async';
import 'package:dio/dio.dart';
import 'auth_service.dart';
import '../main.dart';
import '../screens/login_screen.dart';
import 'package:flutter/material.dart';

class FinanceService {
  final Dio _dio = Dio();
  final AuthService _authService = AuthService();
  // Hardcoding for stability as .env seems to be having issues loading on some devices/builds immediately
  final String _baseUrl = 'https://laravel-pkpass-backend-development-pfaawl.laravel.cloud/api/client/auth/finance';

  FinanceService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          debugPrint('FinanceService: 401 Unauthorized detected. Clearing session.');
          await _authService.logout();
          
          if (navigatorKey.currentState != null) {
            navigatorKey.currentState!.pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        }
        return handler.next(e);
      },
    ));
  }

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
    final token = await _authService.getToken();
    if (token == null) throw Exception('No authentication token found');

    Future<List<dynamic>> verifyAndParse(Response response) async {
      debugPrint('DEBUG: Goals response status: ${response.statusCode}');
      if (response.data is Map && response.data.containsKey('data')) {
        return response.data['data'] as List<dynamic>;
      } else if (response.data is List) {
        return response.data as List<dynamic>;
      }
      return [];
    }

    try {
      debugPrint('DEBUG: Fetching goals from $_baseUrl/goals');
      final response = await _dio.get(
        '$_baseUrl/goals',
        options: Options(headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'}),
      );
      return await verifyAndParse(response);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint('DEBUG: New URL 404, trying old URL: ${AuthService.baseUrl}/goals');
        try {
          final response = await _dio.get(
            '${AuthService.baseUrl}/goals',
            options: Options(headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'}),
          );
          return await verifyAndParse(response);
        } catch (e2) {
          debugPrint('DEBUG: Error querying old goals URL: $e2');
          return [];
        }
      }
      debugPrint('DEBUG: Error querying goals: $e');
      return [];
    } catch (e) {
      debugPrint('DEBUG: Error querying goals: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getGoal(int id) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No authentication token found');

    Future<Map<String, dynamic>> verifyAndParse(Response response) async {
      debugPrint('DEBUG: Goal detail response: ${response.data}');
      if (response.data is Map && response.data.containsKey('data')) {
        return response.data['data'];
      }
      return response.data;
    }

    try {
      debugPrint('DEBUG: Fetching goal details from $_baseUrl/goals/$id');
      final response = await _dio.get(
        '$_baseUrl/goals/$id',
        options: Options(headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'}),
      );
      return await verifyAndParse(response);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint('DEBUG: New URL 404, trying old URL: ${AuthService.baseUrl}/goals/$id');
        try {
          final response = await _dio.get(
            '${AuthService.baseUrl}/goals/$id',
            options: Options(headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'}),
          );
          return await verifyAndParse(response);
        } catch (e2) {
          debugPrint('DEBUG: Error fetching goal detail from old URL: $e2');
          throw Exception('Error fetching goal details');
        }
      }
      debugPrint('DEBUG: Error fetching goal detail: $e');
      debugPrint('DEBUG: API Error Data: ${e.response?.data}');
      throw Exception('Error fetching goal details');
    } catch (e) {
      debugPrint('DEBUG: Error fetching goal detail: $e');
      throw Exception('Error fetching goal details');
    }
  }

  Future<Map<String, dynamic>> createGoal(Map<String, dynamic> data) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token found');

      Future<Map<String, dynamic>> performRequest(String baseUrl) async {
        debugPrint('DEBUG: Creating goal at $baseUrl/goals with data: $data');
        final response = await _dio.post(
          '$baseUrl/goals',
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json', 'Accept': 'application/json'}),
        );
        debugPrint('DEBUG: Create goal response: ${response.data}');
        _updateController.add(null);
        return response.data;
      }

      try {
        return await performRequest(_baseUrl);
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          debugPrint('DEBUG: New URL 404, trying old URL for createGoal');
          try {
            return await performRequest(AuthService.baseUrl);
          } catch (e2) {
            throw e; // Throw original error if fallback fails or isn't 404
          }
        }
        debugPrint('DEBUG: Error creating goal: $e');
        debugPrint('DEBUG: Create Goal API Error: ${e.response?.data}');
        throw Exception(e.response?.data['message'] ?? 'Error creating goal');
      } catch (e) {
        throw Exception('Error creating goal: $e');
      }
    } catch (e) {
      throw Exception('Error creating goal: $e');
    }
  }

  Future<Map<String, dynamic>> updateGoal(int id, Map<String, dynamic> data) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token found');

      Future<Map<String, dynamic>> performRequest(String baseUrl) async {
        debugPrint('DEBUG: Updating goal $id at $baseUrl/goals/$id with data: $data');
        final response = await _dio.put(
          '$baseUrl/goals/$id',
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json', 'Accept': 'application/json'}),
        );
        debugPrint('DEBUG: Update goal response: ${response.data}');
        _updateController.add(null);
        return response.data;
      }

      try {
        return await performRequest(_baseUrl);
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          debugPrint('DEBUG: New URL 404, trying old URL for updateGoal');
          try {
            return await performRequest(AuthService.baseUrl);
          } catch (e2) {
            throw e;
          }
        }
        debugPrint('DEBUG: Error updating goal: $e');
        debugPrint('DEBUG: Update Goal API Error: ${e.response?.data}');
        throw Exception(e.response?.data['message'] ?? 'Error updating goal');
      }
    } catch (e) {
      throw Exception('Error updating goal: $e');
    }
  }

  /// Contribute/add funds to a goal using the dedicated endpoint
  Future<Map<String, dynamic>> contributeToGoal(int goalId, double amount) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token found');

      Future<Map<String, dynamic>> performRequest(String baseUrl) async {
        debugPrint('DEBUG: Contributing $amount to goal $goalId at $baseUrl');
        final response = await _dio.post(
          '$baseUrl/goals/$goalId/contribute',
          data: {'amount': amount},
          options: Options(headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json', 'Accept': 'application/json'}),
        );
        debugPrint('DEBUG: Contribute response: ${response.data}');
        _updateController.add(null);
        return response.data;
      }

      try {
        return await performRequest(_baseUrl);
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          debugPrint('DEBUG: New URL 404, trying old URL for contributeToGoal');
          try {
            return await performRequest(AuthService.baseUrl);
          } catch (e2) {
            throw e;
          }
        }
        debugPrint('DEBUG: Error contributing to goal: $e');
        debugPrint('DEBUG: Contribute API Error: ${e.response?.data}');
        throw Exception(e.response?.data['message'] ?? 'Error contributing to goal');
      } catch (e) {
        throw Exception('Error contributing to goal: $e');
      }
    } catch (e) {
      throw Exception('Error contributing to goal: $e');
    }
  }

  /// Delete a goal
  Future<void> deleteGoal(int id) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No authentication token found');

    Future<void> performRequest(String baseUrl) async {
      debugPrint('DEBUG: Deleting goal $id at $baseUrl/goals/$id');
      await _dio.delete(
        '$baseUrl/goals/$id',
        options: Options(headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'}),
      );
      debugPrint('DEBUG: Goal deleted successfully');
      _updateController.add(null);
    }

    try {
      await performRequest(_baseUrl);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint('DEBUG: New URL 404, trying old URL for deleteGoal');
        try {
          await performRequest(AuthService.baseUrl);
          return;
        } catch (e2) {
          throw e;
        }
      }
      debugPrint('DEBUG: Error deleting goal: $e');
      debugPrint('DEBUG: Delete Goal API Error: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Error deleting goal');
    } catch (e) {
      throw Exception('Error deleting goal: $e');
    }
  }

  /// Withdraw funds from a goal
  Future<Map<String, dynamic>> withdrawFromGoal(int goalId, double amount) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token found');

      Future<Map<String, dynamic>> performRequest(String baseUrl) async {
        debugPrint('DEBUG: Withdrawing $amount from goal $goalId at $baseUrl');
        final response = await _dio.post(
          '$baseUrl/goals/$goalId/withdraw',
          data: {'amount': amount},
          options: Options(headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json', 'Accept': 'application/json'}),
        );
        debugPrint('DEBUG: Withdraw response: ${response.data}');
        _updateController.add(null);
        return response.data;
      }

      try {
        return await performRequest(_baseUrl);
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          debugPrint('DEBUG: New URL 404, trying old URL for withdrawFromGoal');
          try {
            return await performRequest(AuthService.baseUrl);
          } catch (e2) {
            throw e;
          }
        }
        debugPrint('DEBUG: Error withdrawing from goal: $e');
        debugPrint('DEBUG: Withdraw API Error: ${e.response?.data}');
        throw Exception(e.response?.data['message'] ?? 'Error withdrawing from goal');
      } catch (e) {
        throw Exception('Error withdrawing from goal: $e');
      }
    } catch (e) {
      throw Exception('Error withdrawing from goal: $e');
    }
  }

  /// Join a shared goal (accept invitation)
  Future<Map<String, dynamic>> joinGoal(int goalId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No authentication token found');

      Future<Map<String, dynamic>> performRequest(String baseUrl) async {
        debugPrint('DEBUG: Joining goal $goalId at $baseUrl');
        final response = await _dio.post(
          '$baseUrl/goals/$goalId/join',
          options: Options(headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'}),
        );
        debugPrint('DEBUG: Join goal response: ${response.data}');
        _updateController.add(null);
        return response.data;
      }

      try {
        return await performRequest(_baseUrl);
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          debugPrint('DEBUG: New URL 404, trying old URL for joinGoal');
          try {
            return await performRequest(AuthService.baseUrl);
          } catch (e2) {
            throw e;
          }
        }
        debugPrint('DEBUG: Error joining goal: $e');
        debugPrint('DEBUG: Join Goal API Error: ${e.response?.data}');
        throw Exception(e.response?.data['message'] ?? 'Error joining goal');
      } catch (e) {
        throw Exception('Error joining goal: $e');
      }
    } catch (e) {
      throw Exception('Error joining goal: $e');
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