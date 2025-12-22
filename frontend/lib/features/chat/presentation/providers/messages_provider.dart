import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/providers/auth_provider.dart';

class MessagesState {
  final List<Map<String, dynamic>> messages;
  final Map<String, dynamic>? matchDetails;
  final bool isLoading;
  final String? error;

  MessagesState({
    this.messages = const [],
    this.matchDetails,
    this.isLoading = false,
    this.error,
  });

  MessagesState copyWith({
    List<Map<String, dynamic>>? messages,
    Map<String, dynamic>? matchDetails,
    bool? isLoading,
    String? error,
  }) {
    return MessagesState(
      messages: messages ?? this.messages,
      matchDetails: matchDetails ?? this.matchDetails,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MessagesNotifier extends StateNotifier<MessagesState> {
  final ApiService _apiService;
  final String matchId;

  MessagesNotifier(this._apiService, this.matchId) : super(MessagesState());

  Future<void> loadMessages() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Load messages and match details in parallel
      final results = await Future.wait([
        _apiService.getMessages(matchId),
        _apiService.getMatch(matchId),
      ]);
      
      final messagesList = results[0] as List<dynamic>;
      final matchDetails = results[1] as Map<String, dynamic>;
      
      final messages = messagesList.map((m) => Map<String, dynamic>.from(m)).toList();
      
      state = state.copyWith(
        messages: messages,
        matchDetails: matchDetails,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> sendMessage(String content) async {
    try {
      final response = await _apiService.sendMessage(matchId, content);
      final newMessage = Map<String, dynamic>.from(response);
      newMessage['is_mine'] = true;
      
      state = state.copyWith(
        messages: [...state.messages, newMessage],
      );
    } catch (e) {
      // Handle error silently or show toast
      print('Failed to send message: $e');
    }
  }

  Future<void> markAsRead() async {
    try {
      await _apiService.markMessagesRead(matchId);
    } catch (e) {
      // Silent failure for read receipts
    }
  }

  void addMessage(Map<String, dynamic> message) {
    state = state.copyWith(
      messages: [...state.messages, message],
    );
  }
}

final messagesProvider = StateNotifierProvider.family<MessagesNotifier, MessagesState, String>((ref, matchId) {
  final apiService = ref.watch(apiServiceProvider);
  return MessagesNotifier(apiService, matchId);
});

