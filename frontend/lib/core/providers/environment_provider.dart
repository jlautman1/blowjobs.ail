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
    // If API_URL is set from build (deployed web), default to production
    final buildApiUrl = apiUrlFromBuild;
    if (buildApiUrl != null && buildApiUrl.isNotEmpty && kIsWeb) {
      return Environment.production;
    }
    // Otherwise default to development (local development)
    return Environment.development;
  }

  Future<void> _loadEnvironment() async {
    // If API_URL is set from build (deployed web), use production
    final buildApiUrl = apiUrlFromBuild;
    if (buildApiUrl != null && buildApiUrl.isNotEmpty && kIsWeb) {
      state = Environment.production;
      // Save this preference
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_storageKey, Environment.production.index);
      } catch (e) {
        // Ignore storage errors
      }
      return;
    }
    
    // Otherwise load from storage
    try {
      final prefs = await SharedPreferences.getInstance();
      final envIndex = prefs.getInt(_storageKey);
      if (envIndex != null && envIndex < Environment.values.length) {
        state = Environment.values[envIndex];
      }
    } catch (e) {
      // Keep default
    }
  }

  Future<void> setEnvironment(Environment env) async {
    state = env;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_storageKey, env.index);
    } catch (e) {
      // Ignore storage errors
    }
  }

  String get apiUrl {
    // Always respect the user's environment selection
    // This allows switching between dev and prod on both local and deployed apps
    switch (state) {
      case Environment.development:
        return 'http://localhost:8080/api/v1';
      case Environment.production:
        // If API_URL was set from build, use it; otherwise use default production URL
        final buildApiUrl = apiUrlFromBuild;
        if (buildApiUrl != null && buildApiUrl.isNotEmpty) {
          return buildApiUrl;
        }
        return 'https://blowjobs-backend-production.up.railway.app/api/v1';
    }
  }
  
  // Check if currently in development mode
  bool get isDevelopment => state == Environment.development;

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

