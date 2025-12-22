import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/providers/auth_provider.dart';

class SwipeFeedState {
  final List<Map<String, dynamic>> cards;
  final bool isLoading;
  final String? error;
  final int todayViews;
  final int todayLikes;
  final int todayMatches;

  SwipeFeedState({
    this.cards = const [],
    this.isLoading = false,
    this.error,
    this.todayViews = 0,
    this.todayLikes = 0,
    this.todayMatches = 0,
  });

  SwipeFeedState copyWith({
    List<Map<String, dynamic>>? cards,
    bool? isLoading,
    String? error,
    int? todayViews,
    int? todayLikes,
    int? todayMatches,
  }) {
    return SwipeFeedState(
      cards: cards ?? this.cards,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      todayViews: todayViews ?? this.todayViews,
      todayLikes: todayLikes ?? this.todayLikes,
      todayMatches: todayMatches ?? this.todayMatches,
    );
  }
}

class SwipeFeedNotifier extends StateNotifier<SwipeFeedState> {
  final ApiService _apiService;
  final String _userType;

  SwipeFeedNotifier(this._apiService, this._userType) : super(SwipeFeedState());

  Future<void> loadFeed() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      List<dynamic> feed;
      if (_userType == 'recruiter') {
        feed = await _apiService.getCandidateFeed(limit: 20);
      } else {
        feed = await _apiService.getJobFeed(limit: 20);
      }
      
      final cards = feed.map((item) => Map<String, dynamic>.from(item)).toList();
      
      state = state.copyWith(
        cards: cards,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> recordSwipe(
    String targetId,
    String direction, {
    void Function(Map<String, dynamic>)? onMatch,
  }) async {
    try {
      final response = await _apiService.recordSwipe(targetId, direction);
      
      // Update stats
      int newViews = state.todayViews + 1;
      int newLikes = state.todayLikes;
      int newMatches = state.todayMatches;
      
      if (direction == 'right' || direction == 'up') {
        newLikes++;
      }
      
      // Check if it's a match
      if (response['is_match'] == true && onMatch != null) {
        newMatches++;
        onMatch(response['match'] ?? {});
      }
      
      state = state.copyWith(
        todayViews: newViews,
        todayLikes: newLikes,
        todayMatches: newMatches,
      );
    } catch (e) {
      // Log error but don't interrupt UX
      print('Failed to record swipe: $e');
    }
  }

  void removeCard(int index) {
    if (index < state.cards.length) {
      final newCards = List<Map<String, dynamic>>.from(state.cards);
      newCards.removeAt(index);
      state = state.copyWith(cards: newCards);
    }
  }
}

final swipeFeedProvider = StateNotifierProvider<SwipeFeedNotifier, SwipeFeedState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final authState = ref.watch(authStateProvider);
  return SwipeFeedNotifier(apiService, authState.userType);
});

