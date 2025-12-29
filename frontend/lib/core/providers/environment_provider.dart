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
    // Load from storage (don't force production on deployed web)
    // User can switch to dev mode on deployed web - it will use production URL
    // but send dev header for dev features
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
    // Check if API_URL was set from build (deployed web app)
    final buildApiUrl = apiUrlFromBuild;
    final isDeployedWeb = buildApiUrl != null && buildApiUrl.isNotEmpty && kIsWeb;
    
    // If deployed web, always use the production backend URL
    // (localhost won't work from deployed site)
    // But we'll send X-Dev-Mode header when user selects dev mode
    if (isDeployedWeb) {
      return buildApiUrl!;
    }
    
    // For local development, respect environment selection
    switch (state) {
      case Environment.development:
        return 'http://localhost:8080/api/v1';
      case Environment.production:
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

