import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart';

class AuthService {
  final Dio _dio = Dio();
  final FirebaseService _firebaseService = FirebaseService();
  static const String baseUrl = 'https://laravel-pkpass-backend-development-pfaawl.laravel.cloud/api/client/auth';
  
  // Reactive consent state
  final ValueNotifier<bool?> aiConsentNotifier = ValueNotifier<bool?>(null);

  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal() {
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _initConsentNotifier();
  }

  Future<void> _initConsentNotifier() async {
    aiConsentNotifier.value = await getAiConsent();
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

  Future<void> setAiConsent(bool consent) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ai_consent', consent);
    aiConsentNotifier.value = consent; // Update reactive state
    
    final userId = await getUserId();
    if (userId != null) {
      await _firebaseService.updateUserConfigById(userId, {'ai_consent': consent});
    }
  }

  Future<bool?> getAiConsent() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if we have a local decision
    if (prefs.containsKey('ai_consent')) {
      return prefs.getBool('ai_consent');
    }
    
    // If not set locally, check Firebase as backup
    final userId = await getUserId();
    if (userId != null) {
      final config = await _firebaseService.getUserConfigById(userId);
      if (config != null && config['ai_consent'] != null) {
        bool consent = config['ai_consent'] == true;
        await prefs.setBool('ai_consent', consent);
        return consent;
      }
    }
    
    return null; // Not decided yet
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
    final String? email = await getUserEmail();
    final String? userId = await getUserId();
    debugPrint('AuthService: isOnboardingComplete check for: $email (ID: $userId)');
    
    // Fallback 1: Local preferences (Fastest)
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('onboarding_complete') ?? false) {
      debugPrint('AuthService: Result -> ONBOARDING COMPLETE (Local Flag)');
      return true;
    }

    // NEW: Check Backend Profile Data (Highest priority for remote truth)
    try {
      final profile = await getProfile();
      if (profile['success'] == true) {
        final userData = profile['data'];
        final bool serverFlag = userData['onboarding_complete'] == true || (userData['onboarding_complete'] is int && userData['onboarding_complete'] == 1);
        final bool hasBudget = userData['monthly_budget'] != null;

        if (serverFlag || hasBudget) {
          debugPrint('AuthService: Result -> ONBOARDING COMPLETE (Server Profile Flag)');
          await prefs.setBool('onboarding_complete', true);
          return true;
        }
      }
    } catch (e) {
      debugPrint('AuthService: Error checking server profile for onboarding: $e');
    }

    // Try ID-based check first (v2) - Priority for Cloud State (Firebase)
    if (userId != null) {
      final configId = await _firebaseService.getUserConfigById(userId);
      if (configId != null && (configId['onboarding_complete'] == true || configId['user_monthly_budget'] != null)) {
        debugPrint('AuthService: Result -> ONBOARDING COMPLETE (Firebase ID Config)');
        await prefs.setBool('onboarding_complete', true);
        return true;
      }
    }

    // Try Email-based check (v1) - Legacy compatibility
    if (email != null) {
      final config = await _firebaseService.getUserConfig(email);
      if (config != null) {
        final bool hasBudget = config['user_monthly_budget'] != null;
        final bool flagComplete = config['onboarding_complete'] ?? false;
        if (flagComplete || hasBudget) {
          debugPrint('AuthService: Result -> ONBOARDING COMPLETE (Firebase Email Config)');
          await prefs.setBool('onboarding_complete', true);
          return true;
        }
      }
    }

    // Fallback 3: CHECK BACKEND DATA (Definitive indicator)
    debugPrint('AuthService: Checking backend for ANY existing financial data/history...');
    try {
      final hasData = await checkUserFinanceData();
      if (hasData) {
        debugPrint('AuthService: Result -> ONBOARDING COMPLETE (Backend data found)');
        await prefs.setBool('onboarding_complete', true);
        // Sync to Firebase too so we have the flag there for next time
        if (userId != null) await _firebaseService.saveUserConfigById(userId, {'onboarding_complete': true});
        return true;
      }
    } catch (e) {
      debugPrint('AuthService: Error checking backend data fallback: $e');
    }
    
    debugPrint('AuthService: Result -> ONBOARDING INCOMPLETE');
    return false;
  }

  Future<bool> checkUserFinanceData() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      // 1. Check Goals
      final goalsResponse = await _dio.get(
        'https://laravel-pkpass-backend-development-pfaawl.laravel.cloud/api/client/auth/finance/goals',
        options: Options(headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'}),
      );
      if (goalsResponse.statusCode == 200) {
        final data = goalsResponse.data['data'] ?? goalsResponse.data;
        if (data is List && data.isNotEmpty) return true;
      }

      // 2. Check General Finance (Transactions/Summary)
      final financeResponse = await _dio.get(
        'https://laravel-pkpass-backend-development-pfaawl.laravel.cloud/api/client/auth/finance',
        options: Options(headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'}),
      );
      if (financeResponse.statusCode == 200) {
        final data = financeResponse.data;
        final List<dynamic> records = data['records'] ?? [];
        final Map<String, dynamic> summary = data['summary'] ?? {};
        final double totalIn = (summary['total_income'] ?? 0).toDouble();
        final double totalOut = (summary['total_expense'] ?? 0).toDouble();

        if (records.isNotEmpty || totalIn > 0 || totalOut > 0) {
          return true;
        }
      }
    } catch (e) {
      debugPrint('AuthService: checkUserFinanceData detail error: $e');
    }
    return false;
  }

  Future<void> setOnboardingComplete(bool complete) async {
    final email = await getUserEmail();
    final userId = await getUserId();
    debugPrint('AuthService: Manually setting onboarding as $complete for $email (ID: $userId)');
    
    // 1. Sync to Server (New Primary)
    if (complete) {
      await updateOnboardingOnServer(onboardingComplete: true);
    }

    // 2. Sync to Firebase (Redundancy)
    final config = {
      'onboarding_complete': complete,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    if (userId != null) {
      try {
        await _firebaseService.saveUserConfigById(userId, config);
      } catch (e) {
        debugPrint('AuthService: Error saving onboarding flag by ID: $e');
      }
    }

    // 3. Local Cache
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', complete);
  }

  Future<Map<String, dynamic>> updateOnboardingOnServer({
    required bool onboardingComplete,
    double? monthlyBudget,
    List<Map<String, dynamic>>? incomeSources,
    List<Map<String, dynamic>>? debts,
  }) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'No token'};

      debugPrint('AuthService: Syncing onboarding to server...');
      final response = await _dio.post(
        '$baseUrl/update-onboarding',
        data: {
          'onboarding_complete': onboardingComplete,
          if (monthlyBudget != null) 'monthly_budget': monthlyBudget,
          if (incomeSources != null) 'income_sources': incomeSources,
          if (debts != null) 'debts': debts,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint('AuthService: Server onboarding update status: ${response.statusCode}');
      return {'success': true, 'data': response.data};
    } catch (e) {
      debugPrint('AuthService: Error syncing onboarding to server: $e');
      return {'success': false, 'message': _handleError(e)};
    }
  }

  Future<void> saveBudget(double budget) async {
    final email = await getUserEmail();
    final userId = await getUserId();
    
    // 1. Server Sync
    await updateOnboardingOnServer(onboardingComplete: true, monthlyBudget: budget);

    // 2. Firebase Sync
    if (email != null) {
      final currentConfig = await _firebaseService.getUserConfig(email) ?? {};
      currentConfig['user_monthly_budget'] = budget;
      await _firebaseService.saveUserConfig(email, currentConfig);
    }
    if (userId != null) {
      await _firebaseService.saveUserConfigById(userId, {'user_monthly_budget': budget});
    }

    // 3. Local Sync
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
    final userId = await getUserId();

    // 1. Server Sync
    await updateOnboardingOnServer(onboardingComplete: true, debts: debts);

    // 2. Firebase Sync
    if (email != null) {
      final currentConfig = await _firebaseService.getUserConfig(email) ?? {};
      currentConfig['user_debts'] = debts;
      await _firebaseService.saveUserConfig(email, currentConfig);
    }
    if (userId != null) {
      await _firebaseService.saveUserConfigById(userId, {'user_debts': debts});
    }

    // 3. Local Sync
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
    final userId = await getUserId();
    
    debugPrint('AuthService: Saving full onboarding data for $email (ID: $userId)');
    
    // 1. Sync to Server (New Primary)
    await updateOnboardingOnServer(
      onboardingComplete: true,
      monthlyBudget: budget,
      incomeSources: incomeSources,
      debts: debts,
    );

    // 2. Sync to Firebase (Redundancy)
    final config = {
      'user_monthly_budget': budget,
      'user_income_sources': incomeSources,
      'user_debts': debts,
      'onboarding_complete': true,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    if (userId != null) {
      await _firebaseService.saveUserConfigById(userId, config);
    }
    if (email != null) {
      await _firebaseService.saveUserConfig(email, config);
    }
    
    // 3. Local Cache
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user_monthly_budget', budget);
    await prefs.setString('user_income_sources', json.encode(incomeSources));
    await prefs.setString('user_debts', json.encode(debts));
    await prefs.setBool('onboarding_complete', true);
    
    debugPrint('AuthService: Data saved successfully in server, cloud and local.');
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
