import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/providers/auth_provider.dart';

class MatchesState {
  final List<Map<String, dynamic>> matches;
  final List<Map<String, dynamic>> newMatches;
  final bool isLoading;
  final String? error;

  MatchesState({
    this.matches = const [],
    this.newMatches = const [],
    this.isLoading = false,
    this.error,
  });

  MatchesState copyWith({
    List<Map<String, dynamic>>? matches,
    List<Map<String, dynamic>>? newMatches,
    bool? isLoading,
    String? error,
  }) {
    return MatchesState(
      matches: matches ?? this.matches,
      newMatches: newMatches ?? this.newMatches,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MatchesNotifier extends StateNotifier<MatchesState> {
  final ApiService _apiService;

  MatchesNotifier(this._apiService) : super(MatchesState());

  Future<void> loadMatches() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final matchesList = await _apiService.getMatches();
      final allMatches = matchesList
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
      
      // Split into new and all matches
      final now = DateTime.now();
      final newMatches = allMatches.where((m) {
        final matchedAt = m['matched_at'] != null 
          ? DateTime.tryParse(m['matched_at']) 
          : null;
        if (matchedAt == null) return false;
        return now.difference(matchedAt).inHours < 24;
      }).toList();
      
      state = state.copyWith(
        matches: allMatches,
        newMatches: newMatches,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final matchesProvider = StateNotifierProvider<MatchesNotifier, MatchesState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return MatchesNotifier(apiService);
});

