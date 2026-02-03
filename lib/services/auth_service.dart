import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio = Dio();
  static const String baseUrl = 'https://laravel-pkpass-backend-development-pfaawl.laravel.cloud/api/client/auth';

  AuthService() {
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.connectTimeout = const Duration(seconds: 15);
  }

  Future<Map<String, dynamic>> loginWithFirebaseIdToken({
    required String idToken,
    required String provider,
  }) async {
    try {
      debugPrint('AuthService: Requesting social login to $baseUrl/login');
      debugPrint('AuthService: Payload: idToken: ${idToken.substring(0, 20)}..., provider: $provider');
      
      final response = await _dio.post(
        '$baseUrl/login',
        data: {
          'idToken': idToken,
          'provider': provider,
          'device_platform': kIsWeb ? 'web' : (defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android'),
          'app_name': 'nutrigpt',
        },
      );
      
      debugPrint('AuthService: Response Status: ${response.statusCode}');
      debugPrint('AuthService: Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        final token = data['token'];
        final user = data['user'];
        if (token != null) {
          await _saveToken(token);
        }
        if (user != null) {
          await _saveUser(user);
        }
        return {'success': true, 'data': data};
      }
      return {'success': false, 'message': 'Fallo la autenticación social: ${response.data}'};
    } catch (e) {
      if (e is DioException) {
        debugPrint('AuthService: Dio Error Status: ${e.response?.statusCode}');
        debugPrint('AuthService: Dio Error Data: ${e.response?.data}');
      }
      return {'success': false, 'message': _handleError(e)};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/login',
        data: {
          'email': email,
          'password': password,
          'app_name': 'nutrigpt',
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final token = data['token'];
        final user = data['user'];
        if (token != null) {
          await _saveToken(token);
        }
        if (user != null) {
          await _saveUser(user);
        }
        return {'success': true, 'data': data};
      }
      return {'success': false, 'message': 'Fallo el inicio de sesión'};
    } catch (e) {
      return {'success': false, 'message': _handleError(e)};
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'app_name': 'nutrigpt',
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        final token = data['token'];
        final user = data['user'];
        if (token != null) {
          await _saveToken(token);
        }
        if (user != null) {
          await _saveUser(user);
        }
        return {'success': true, 'data': data};
      }
      return {'success': false, 'message': 'Fallo el registro'};
    } catch (e) {
      return {'success': false, 'message': _handleError(e)};
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user['id'] != null) {
      await prefs.setString('user_id', user['id'].toString());
    }
    if (user['name'] != null) {
      await prefs.setString('user_name', user['name']);
    }
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('user_id');
    // If no ID locally, try fetching profile (fallback)
    if (id == null) {
      try {
        final profile = await getProfile();
        if (profile['success'] == true) {
          final user = profile['data'];
          await _saveUser(user as Map<String, dynamic>); // Cast safely if possible
          return user['id'].toString();
        }
      } catch (_) {}
    }
    return id;
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No hay token de autenticación'};
      }

      final response = await _dio.get(
        '$baseUrl/profile',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint('AuthService: Profile response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        // Optionally update cache here too
        if (data != null) _saveUser(data);
        return {'success': true, 'data': data};
      }
      return {'success': false, 'message': 'Fallo al obtener el perfil'};
    } catch (e) {
      return {'success': false, 'message': _handleError(e)};
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final token = await getToken();
      if (token != null) {
        await _dio.post(
          '$baseUrl/delete',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ),
        );
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      return {'success': true};
    } catch (e) {
      // Even if API fails, we clear local session for safety
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      return {'success': false, 'message': _handleError(e)};
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await _dio.post(
          '$baseUrl/logout',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ),
        );
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear all (token, user_id, etc.)
      return {'success': true};
    } catch (e) {
      // Even if the API fails (e.g. token already expired), we clear local prefs
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      return {'success': true, 'warning': _handleError(e)};
    }
  }

  Future<Map<String, dynamic>> sendFeedback({
    required String type,
    String? subject,
    required String message,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        debugPrint('AuthService: Error sendFeedback - No hay token');
        return {'success': false, 'message': 'No hay token de autenticación'};
      }

      final formDataMap = {
        'type': type,
        if (subject != null) 'subject': subject,
        'message': message,
      };

      debugPrint('AuthService: Requesting feedback to $baseUrl/feedback');
      debugPrint('AuthService: Feedback Payload: $formDataMap');

      final formData = FormData.fromMap(formDataMap);

      final response = await _dio.post(
        '$baseUrl/feedback',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint('AuthService: Feedback Response Status: ${response.statusCode}');
      debugPrint('AuthService: Feedback Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': response.data['message'] ?? 'Feedback enviado correctamente'};
      }
      return {'success': false, 'message': 'Fallo al enviar el feedback'};
    } catch (e) {
      if (e is DioException) {
        debugPrint('AuthService: Feedback DioError Status: ${e.response?.statusCode}');
        debugPrint('AuthService: Feedback DioError Data: ${e.response?.data}');
      } else {
        debugPrint('AuthService: Feedback Generic Error: $e');
      }
      return {'success': false, 'message': _handleError(e)};
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    String? fcmToken,
    String? devicePlatform,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No hay token de autenticación'};
      }

      final response = await _dio.post(
        '$baseUrl/profile',
        data: {
          if (fcmToken != null) 'fcm_token': fcmToken,
          if (devicePlatform != null) 'device_platform': devicePlatform,
          'app_name': 'nutrigpt',
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        if (data != null) _saveUser(data);
        return {'success': true, 'data': data};
      }
      return {'success': false, 'message': 'Fallo al actualizar el perfil'};
    } catch (e) {
      return {'success': false, 'message': _handleError(e)};
    }
  }

  String _handleError(dynamic e) {
    if (e is DioException) {
      if (e.response != null) {
        final message = e.response?.data['message'];
        return message ?? 'Error del servidor: ${e.response?.statusCode}';
      }
      return 'Error de conexión';
    }
    return e.toString();
  }
}
