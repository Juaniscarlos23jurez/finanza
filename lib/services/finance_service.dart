import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';

class FinanceService {
  final Dio _dio = Dio();
  final AuthService _authService = AuthService();
  final String _baseUrl = '${dotenv.env['API_URL']}/api/client/auth/finance';

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

      final response = await _dio.get(
        '$_baseUrl/goals',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      return response.data;
    } catch (e) {
       // Return empty list on error to not break UI if endpoint is not ready
      return [];
    }
  }
