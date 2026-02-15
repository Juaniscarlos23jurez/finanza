import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

enum UpdateState {
  noUpdate,
  optionalUpdate,
  forceUpdate,
}

class AppUpdateStatus {
  final UpdateState state;
  final String? storeUrl;
  final String? latestVersion;
  final String? minVersion;

  AppUpdateStatus({
    this.state = UpdateState.noUpdate,
    this.storeUrl,
    this.latestVersion,
    this.minVersion,
  });
}

class AppVersionService {
  final Dio _dio = Dio();
  static const String baseUrl = 'https://laravel-pkpass-backend-development-pfaawl.laravel.cloud/api/public';

  Future<AppUpdateStatus> checkAppVersion() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersionStr = packageInfo.version;
      final Version? currentVersion = _tryParseVersion(currentVersionStr);
      
      debugPrint('AppVersionService: Current App Version: $currentVersionStr');

      if (currentVersion == null) {
        debugPrint('AppVersionService: Failed to parse current version');
        return AppUpdateStatus(state: UpdateState.noUpdate);
      }

      debugPrint('AppVersionService: Fetching remote version info...');
      final response = await _dio.get(
        '$baseUrl/app-versions',
        queryParameters: {
          'app': 'Finanzas AI',
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      debugPrint('AppVersionService: Response Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = response.data;
        debugPrint('AppVersionService: Raw Data: $data');
        
        String platformKey = Platform.isIOS ? 'ios' : 'android';
        debugPrint('AppVersionService: Filtering for platform: $platformKey');
        
        if (data != null && data[platformKey] != null) {
          final platformData = data[platformKey];
          final String minVersionStr = platformData['min'] ?? '0.0.0';
          final String latestVersionStr = platformData['latest'] ?? '0.0.0';
          final String? storeUrl = platformData['store_url'];

          final Version? minVersion = _tryParseVersion(minVersionStr);
          final Version? latestVersion = _tryParseVersion(latestVersionStr);

          debugPrint('AppVersionService: Parsed Remote Versions - Min: $minVersion, Latest: $latestVersion');
          debugPrint('AppVersionService: Comparing Current ($currentVersion) vs Min ($minVersion) and Latest ($latestVersion)');

          if (minVersion != null && currentVersion < minVersion) {
            debugPrint('AppVersionService: RESULT -> FORCE UPDATE REQUIRED');
            return AppUpdateStatus(
               state: UpdateState.forceUpdate, 
               storeUrl: storeUrl,
               latestVersion: latestVersionStr,
               minVersion: minVersionStr,
            );
          } else if (latestVersion != null && currentVersion < latestVersion) {
            debugPrint('AppVersionService: RESULT -> OPTIONAL UPDATE AVAILABLE');
            return AppUpdateStatus(
               state: UpdateState.optionalUpdate, 
               storeUrl: storeUrl,
               latestVersion: latestVersionStr,
               minVersion: minVersionStr,
            );
          } else {
            debugPrint('AppVersionService: RESULT -> UP TO DATE');
          }
        } else {
          debugPrint('AppVersionService: No data found for platform $platformKey in response');
        }
      } else {
        debugPrint('AppVersionService: Non-200 response from server');
      }
    } catch (e) {
      debugPrint('AppVersionService: ERROR in checkAppVersion: $e');
    }
    
    return AppUpdateStatus(state: UpdateState.noUpdate);
  }

  Version? _tryParseVersion(String v) {
    try {
      return Version.parse(v);
    } catch (e) {
      // Handle non-semver compliant versions (e.g. "1.2" -> "1.2.0")
      try {
        final parts = v.split('.');
        if (parts.length == 2) {
          return Version.parse('$v.0');
        } else if (parts.length == 1) {
          return Version.parse('$v.0.0');
        }
      } catch (_) {}
      debugPrint('AppVersionService: Could not parse version $v');
      return null;
    }
  }
}
