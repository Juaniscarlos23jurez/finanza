import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart';

class AuthService {
  final Dio _dio = Dio();
  final FirebaseService _firebaseService = FirebaseService();
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
          'app_name': 'Finanzas AI',
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
          'app_name': 'Finanzas AI',
          'device_platform': kIsWeb ? 'web' : (defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android'),
          'provider': 'email',
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
          'app_name': 'Finanzas AI',
          'device_platform': kIsWeb ? 'web' : (defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android'),
          'provider': 'email',
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
    if (user['email'] != null) {
      await prefs.setString('user_email', user['email']);
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

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('user_email');
    debugPrint('AuthService: Local user_email: $email');
    if (email == null) {
      debugPrint('AuthService: Email is null localy, fetching profile...');
      try {
        final profile = await getProfile();
        if (profile['success'] == true) {
          email = profile['data']['email'];
          debugPrint('AuthService: Email fetched from profile API: $email');
        } else {
          debugPrint('AuthService: Failed to fetch profile: ${profile['message']}');
        }
      } catch (e) {
        debugPrint('AuthService: Error fetching profile for email: $e');
      }
    }
    return email;
  }

  Future<String?> getOrCreateUserCode() async {
    final prefs = await SharedPreferences.getInstance();
    String? code = prefs.getString('user_invite_code');
    
    if (code == null) {
      final String? name = prefs.getString('user_name');
      final String? userId = prefs.getString('user_id');
      
      if (name != null && userId != null) {
        // Simple code generator: NAME-ID (shortened)
        final String prefix = name.split(' ')[0].toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
        final String suffix = userId.length > 4 ? userId.substring(userId.length - 4) : userId;
        code = '$prefix-$suffix';
        await prefs.setString('user_invite_code', code);
      }
    }
    return code;
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
          if (devicePlatform == null) 'device_platform': kIsWeb ? 'web' : (defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android'),
          'app_name': 'Finanzas AI',
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

  Future<bool> isOnboardingComplete() async {
    final email = await getUserEmail();
    debugPrint('AuthService: isOnboardingComplete check for: $email');
    
    // Fallback 1: Local preferences (Fastest)
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('onboarding_complete') ?? false) {
      debugPrint('AuthService: Result -> ONBOARDING COMPLETE (Local Flag)');
      return true;
    }

    if (email != null) {
      // Fallback 2: Firebase config
      final config = await _firebaseService.getUserConfig(email);
      if (config != null) {
        final bool hasBudget = config['user_monthly_budget'] != null;
        final bool hasSources = config['user_income_sources'] != null && (config['user_income_sources'] as List).isNotEmpty;
        final bool flagComplete = config['onboarding_complete'] ?? false;
        
        debugPrint('AuthService: Firebase data for $email: flag=$flagComplete, hasBudget=$hasBudget, hasSources=$hasSources');
        
        if (flagComplete || (hasBudget && hasSources)) {
          debugPrint('AuthService: Result -> ONBOARDING COMPLETE (Firebase Config)');
          // Cache it locally too
          await prefs.setBool('onboarding_complete', true);
          return true;
        }
      }

      // Fallback 3: Check if they have goals in the backend (Definitive indicator they are using the app)
      debugPrint('AuthService: Checking backend for existing goals...');
      try {
        final hasGoals = await checkIfUserHasGoals();
        if (hasGoals) {
          debugPrint('AuthService: Result -> ONBOARDING COMPLETE (Existing Goals found)');
          await prefs.setBool('onboarding_complete', true);
          return true;
        }
      } catch (e) {
        debugPrint('AuthService: Error checking goals fallback: $e');
      }
    }
    
    debugPrint('AuthService: Result -> ONBOARDING INCOMPLETE');
    return false;
  }

  Future<bool> checkIfUserHasGoals() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await _dio.get(
        'https://laravel-pkpass-backend-development-pfaawl.laravel.cloud/api/client/auth/finance/goals',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        if (data is List && data.isNotEmpty) {
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  Future<void> setOnboardingComplete(bool complete) async {
    final email = await getUserEmail();
    if (email != null) {
      final currentConfig = await _firebaseService.getUserConfig(email) ?? {};
      currentConfig['onboarding_complete'] = complete;
      await _firebaseService.saveUserConfig(email, currentConfig);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', complete);
  }

  Future<void> saveBudget(double budget) async {
    final email = await getUserEmail();
    if (email != null) {
      final currentConfig = await _firebaseService.getUserConfig(email) ?? {};
      currentConfig['user_monthly_budget'] = budget;
      await _firebaseService.saveUserConfig(email, currentConfig);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user_monthly_budget', budget);
  }

  Future<double?> getBudget() async {
    final email = await getUserEmail();
    if (email != null) {
      final config = await _firebaseService.getUserConfig(email);
      if (config != null && config['user_monthly_budget'] != null) {
        return (config['user_monthly_budget'] as num).toDouble();
      }
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('user_monthly_budget');
  }

  Future<void> saveIncomeSources(List<Map<String, dynamic>> sources) async {
    final email = await getUserEmail();
    if (email != null) {
      final currentConfig = await _firebaseService.getUserConfig(email) ?? {};
      currentConfig['user_income_sources'] = sources;
      await _firebaseService.saveUserConfig(email, currentConfig);
    }
    final prefs = await SharedPreferences.getInstance();
    final String sourcesJson = json.encode(sources);
    await prefs.setString('user_income_sources', sourcesJson);
  }

  Future<List<Map<String, dynamic>>> getIncomeSources() async {
    final email = await getUserEmail();
    if (email != null) {
      final config = await _firebaseService.getUserConfig(email);
      if (config != null && config['user_income_sources'] != null) {
        final List<dynamic> sources = config['user_income_sources'];
        return sources.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    }
    final prefs = await SharedPreferences.getInstance();
    final String? sourcesJson = prefs.getString('user_income_sources');
    if (sourcesJson == null) return [];
    final List<dynamic> decoded = json.decode(sourcesJson);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> saveDebts(List<Map<String, dynamic>> debts) async {
    final email = await getUserEmail();
    if (email != null) {
      final currentConfig = await _firebaseService.getUserConfig(email) ?? {};
      currentConfig['user_debts'] = debts;
      await _firebaseService.saveUserConfig(email, currentConfig);
    }
    final prefs = await SharedPreferences.getInstance();
    final String debtsJson = json.encode(debts);
    await prefs.setString('user_debts', debtsJson);
  }

  Future<List<Map<String, dynamic>>> getDebts() async {
    final email = await getUserEmail();
    if (email != null) {
      final config = await _firebaseService.getUserConfig(email);
      if (config != null && config['user_debts'] != null) {
        final List<dynamic> debts = config['user_debts'];
        return debts.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    }
    final prefs = await SharedPreferences.getInstance();
    final String? debtsJson = prefs.getString('user_debts');
    if (debtsJson == null) return [];
    final List<dynamic> decoded = json.decode(debtsJson);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> payDebt(String debtName, double amount) async {
    final List<Map<String, dynamic>> currentDebts = await getDebts();
    bool found = false;

    for (var debt in currentDebts) {
      if (debt['name'] == debtName) {
        double currentAmount = (double.tryParse(debt['amount'].toString()) ?? 0.0);
        debt['amount'] = currentAmount - amount;
        if (debt['amount'] < 0) debt['amount'] = 0.0;
        found = true;
        break;
      }
    }

    if (found) {
      await saveDebts(currentDebts);
    }
  }

  Future<void> saveFullOnboardingData({
    required double budget,
    required List<Map<String, dynamic>> incomeSources,
    required List<Map<String, dynamic>> debts,
  }) async {
    final email = await getUserEmail();
    if (email != null) {
      final config = {
        'user_monthly_budget': budget,
        'user_income_sources': incomeSources,
        'user_debts': debts,
        'onboarding_complete': true,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await _firebaseService.saveUserConfig(email, config);
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user_monthly_budget', budget);
    await prefs.setString('user_income_sources', json.encode(incomeSources));
    await prefs.setString('user_debts', json.encode(debts));
    await prefs.setBool('onboarding_complete', true);
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
