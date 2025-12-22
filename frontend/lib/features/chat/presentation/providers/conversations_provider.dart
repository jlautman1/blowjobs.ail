import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/providers/auth_provider.dart';

class ConversationsState {
  final List<Map<String, dynamic>> conversations;
  final bool isLoading;
  final String? error;

  ConversationsState({
    this.conversations = const [],
    this.isLoading = false,
    this.error,
  });

  ConversationsState copyWith({
    List<Map<String, dynamic>>? conversations,
    bool? isLoading,
    String? error,
  }) {
    return ConversationsState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ConversationsNotifier extends StateNotifier<ConversationsState> {
  final ApiService _apiService;

  ConversationsNotifier(this._apiService) : super(ConversationsState());

  Future<void> loadConversations() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final list = await _apiService.getConversations();
      final conversations = list.map((c) => Map<String, dynamic>.from(c)).toList();
      
      state = state.copyWith(
        conversations: conversations,
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

final conversationsProvider = StateNotifierProvider<ConversationsNotifier, ConversationsState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ConversationsNotifier(apiService);
});

