import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Environment {
  development,
  production,
}

class EnvironmentNotifier extends StateNotifier<Environment> {
  static const String _storageKey = 'app_environment';
  
  EnvironmentNotifier() : super(Environment.development) {
    _loadEnvironment();
  }

  Future<void> _loadEnvironment() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final envIndex = prefs.getInt(_storageKey);
      if (envIndex != null && envIndex < Environment.values.length) {
        state = Environment.values[envIndex];
      }
    } catch (e) {
      // Default to production if loading fails
      state = Environment.production;
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

