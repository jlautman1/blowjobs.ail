import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Environment {
  development,
  production,
}

class EnvironmentNotifier extends StateNotifier<Environment> {
  static const String _storageKey = 'app_environment';
  
  // Get API URL from dart-define (set during build) or use default
  static String? get apiUrlFromBuild {
    try {
      return const String.fromEnvironment('API_URL', defaultValue: '');
    } catch (e) {
      return null;
    }
  }
  
  EnvironmentNotifier() : super(_determineInitialEnvironment()) {
    _loadEnvironment();
  }
  
  static Environment _determineInitialEnvironment() {
    // If API_URL is set from build (production), use production
    final buildApiUrl = apiUrlFromBuild;
    if (buildApiUrl != null && buildApiUrl.isNotEmpty) {
      return Environment.production;
    }
    
    // For web builds, default to production
    if (kIsWeb) {
      return Environment.production;
    }
    
    // Otherwise default to development
    return Environment.development;
  }

  Future<void> _loadEnvironment() async {
    // If API_URL is set from build, always use production
    final buildApiUrl = apiUrlFromBuild;
    if (buildApiUrl != null && buildApiUrl.isNotEmpty) {
      state = Environment.production;
      return;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final envIndex = prefs.getInt(_storageKey);
      if (envIndex != null && envIndex < Environment.values.length) {
        state = Environment.values[envIndex];
      }
    } catch (e) {
      // Default to production if loading fails (especially for web)
      if (kIsWeb) {
        state = Environment.production;
      }
    }
  }

  Future<void> setEnvironment(Environment env) async {
    // Don't allow changing environment if API_URL is set from build
    final buildApiUrl = apiUrlFromBuild;
    if (buildApiUrl != null && buildApiUrl.isNotEmpty) {
      return;
    }
    
    state = env;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_storageKey, env.index);
    } catch (e) {
      // Ignore storage errors
    }
  }

  String get apiUrl {
    // First check if API_URL was set from build
    final buildApiUrl = apiUrlFromBuild;
    if (buildApiUrl != null && buildApiUrl.isNotEmpty) {
      return buildApiUrl;
    }
    
    // Otherwise use environment-based URL
    switch (state) {
      case Environment.development:
        return 'http://localhost:8080/api/v1';
      case Environment.production:
        return 'https://blowjobs-backend-production.up.railway.app/api/v1';
    }
  }

  String get displayName {
    switch (state) {
      case Environment.development:
        return 'Development';
      case Environment.production:
        return 'Production';
    }
  }
}

final environmentProvider = StateNotifierProvider<EnvironmentNotifier, Environment>((ref) {
  return EnvironmentNotifier();
});

final apiUrlProvider = Provider<String>((ref) {
  return ref.watch(environmentProvider.notifier).apiUrl;
});

