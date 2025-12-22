import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/messages_provider.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  final String matchId;

  const ConversationScreen({super.key, required this.matchId});

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(messagesProvider(widget.matchId).notifier).loadMessages();
      ref.read(messagesProvider(widget.matchId).notifier).markAsRead();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;
    
    setState(() => _isSending = true);
    _messageController.clear();
    
    await ref.read(messagesProvider(widget.matchId).notifier).sendMessage(content);
    
    setState(() => _isSending = false);
    
    // Scroll to bottom
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messagesProvider(widget.matchId));
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(state),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: state.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[state.messages.length - 1 - index];
                    final isMine = message['is_mine'] == true;
                    final isSystem = message['type'] == 'system' || 
                                    message['type'] == 'status' ||
                                    message['type'] == 'interview';
                    
                    if (isSystem) {
                      return _SystemMessage(message: message);
                    }
                    
                    return _MessageBubble(
                      message: message,
                      isMine: isMine,
                    ).animate()
                      .fadeIn(duration: 200.ms)
                      .slideY(begin: 0.1);
                  },
                ),
          ),
          
          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(MessagesState state) {
    return AppBar(
      backgroundColor: AppColors.surface,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Iconsax.arrow_left),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.matchDetails?['job']?['title'] ?? 'Chat',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            state.matchDetails?['company_name'] ?? '',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Show match details
          },
          icon: const Icon(Iconsax.more),
        ),
      ],
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Attachment button
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('File attachments coming soon! 📎'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Iconsax.attach_circle),
            color: AppColors.textTertiary,
          ),
          
          // Text input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: 4,
                minLines: 1,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: AppColors.textTertiary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Send button
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Iconsax.send_15,
                      color: Colors.white,
                      size: 22,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isMine;

  const _MessageBubble({
    required this.message,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    final content = message['content'] ?? '';
    final senderName = message['sender_name'] ?? '';
    final createdAt = message['created_at'] != null
      ? DateTime.tryParse(message['created_at'])
      : null;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  senderName.isNotEmpty ? senderName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMine ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMine ? 18 : 4),
                bottomRight: Radius.circular(isMine ? 4 : 18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 15,
                    color: isMine ? AppColors.background : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  createdAt != null 
                    ? '${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}'
                    : '',
                  style: TextStyle(
                    fontSize: 11,
                    color: isMine 
                      ? AppColors.background.withOpacity(0.7)
                      : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SystemMessage extends StatelessWidget {
  final Map<String, dynamic> message;

  const _SystemMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    final content = message['content'] ?? '';
    final type = message['type'] ?? 'system';
    
    IconData icon;
    Color color;
    
    switch (type) {
      case 'interview':
        icon = Iconsax.calendar;
        color = AppColors.accent;
        break;
      case 'status':
        icon = Iconsax.info_circle;
        color = AppColors.primary;
        break;
      default:
        icon = Iconsax.notification;
        color = AppColors.textSecondary;
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

