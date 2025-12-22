import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:confetti/confetti.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/auth_provider.dart';
import '../widgets/job_card.dart';
import '../widgets/candidate_card.dart';
import '../widgets/swipe_action_buttons.dart';
import '../widgets/match_popup.dart';
import '../providers/swipe_provider.dart';

class SwipeScreen extends ConsumerStatefulWidget {
  const SwipeScreen({super.key});

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen> 
    with TickerProviderStateMixin {
  late CardSwiperController _cardController;
  late ConfettiController _confettiController;
  late AnimationController _pulseController;
  int _currentIndex = 0;
  bool _showMatch = false;
  Map<String, dynamic>? _matchedItem;

  @override
  void initState() {
    super.initState();
    _cardController = CardSwiperController();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    // Load initial feed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(swipeFeedProvider.notifier).loadFeed();
    });
  }

  @override
  void dispose() {
    _cardController.dispose();
    _confettiController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<bool> _onSwipe(int previousIndex, int? currentIndex, CardSwiperDirection direction) async {
    HapticFeedback.mediumImpact();
    
    final swipeState = ref.read(swipeFeedProvider);
    if (previousIndex < swipeState.cards.length) {
      final card = swipeState.cards[previousIndex];
      String swipeDirection = 'left';
      
      if (direction == CardSwiperDirection.right) {
        swipeDirection = 'right';
      } else if (direction == CardSwiperDirection.top) {
        swipeDirection = 'up';
      }
      
      ref.read(swipeFeedProvider.notifier).recordSwipe(
        card['id'],
        swipeDirection,
        onMatch: (match) {
          _handleMatch(match);
        },
      );
    }
    
    if (currentIndex != null) {
      setState(() => _currentIndex = currentIndex);
    }
    
    return true; // Allow the swipe
  }

  void _handleMatch(Map<String, dynamic> match) {
    HapticFeedback.heavyImpact();
    _confettiController.play();
    setState(() {
      _showMatch = true;
      _matchedItem = match;
    });
  }

  void _dismissMatch() {
    setState(() {
      _showMatch = false;
      _matchedItem = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final swipeState = ref.watch(swipeFeedProvider);
    final isRecruiter = authState.userType == 'recruiter';
    
    return Stack(
      children: [
        // Background - clean light theme
        Container(
          color: AppColors.background,
        ),
        
        // Main content
        Column(
          children: [
            // Stats row
            _buildStatsRow(swipeState),
            
            // Card stack
            Expanded(
              child: swipeState.isLoading
                ? _buildLoadingState()
                : swipeState.cards.isEmpty
                  ? _buildEmptyState(isRecruiter)
                  : _buildCardStack(swipeState.cards),
            ),
            
            // Action buttons
            if (swipeState.cards.isNotEmpty)
              SwipeActionButtons(
                onPass: () => _cardController.swipeLeft(),
                onLike: () => _cardController.swipeRight(),
                onSuperLike: () => _cardController.swipeTop(),
                onUndo: _currentIndex > 0 ? () => _cardController.undo() : null,
                pulseController: _pulseController,
              ).animate()
                .fadeIn(delay: 300.ms)
                .slideY(begin: 0.2),
            
            const SizedBox(height: 16),
          ],
        ),
        
        // Confetti overlay
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              AppColors.primary,
              AppColors.primaryLight,
              AppColors.superLike,
              AppColors.accent,
            ],
            numberOfParticles: 30,
            gravity: 0.2,
          ),
        ),
        
        // Match popup
        if (_showMatch && _matchedItem != null)
          MatchPopup(
            match: _matchedItem!,
            onDismiss: _dismissMatch,
            onMessage: () {
              _dismissMatch();
              // TODO: Navigate to chat
            },
          ),
      ],
    );
  }

  Widget _buildStatsRow(SwipeFeedState swipeState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Iconsax.eye,
            value: '${swipeState.todayViews}',
            label: 'Viewed Today',
          ),
          Container(
            width: 1,
            height: 30,
            color: AppColors.surfaceBright,
          ),
          _StatItem(
            icon: Iconsax.heart,
            value: '${swipeState.todayLikes}',
            label: 'Likes',
            valueColor: AppColors.success,
          ),
          Container(
            width: 1,
            height: 30,
            color: AppColors.surfaceBright,
          ),
          _StatItem(
            icon: Iconsax.magic_star,
            value: '${swipeState.todayMatches}',
            label: 'Matches',
            valueColor: AppColors.primary,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Finding opportunities...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isRecruiter) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Center(
                child: Icon(
                  Iconsax.search_status,
                  size: 56,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              isRecruiter 
                ? 'No more candidates'
                : 'No more jobs',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              isRecruiter
                ? 'Check back later for new talent!'
                : 'Check back later for new opportunities!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            TextButton.icon(
              onPressed: () {
                ref.read(swipeFeedProvider.notifier).loadFeed();
              },
              icon: const Icon(Iconsax.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardStack(List<Map<String, dynamic>> cards) {
    final authState = ref.watch(authStateProvider);
    final isRecruiter = authState.userType == 'recruiter';
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CardSwiper(
        controller: _cardController,
        cardsCount: cards.length,
        numberOfCardsDisplayed: cards.length.clamp(1, 3),
        padding: EdgeInsets.zero,
        onSwipe: _onSwipe,
        cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
          final card = cards[index];
          final isTopCard = index == _currentIndex;
          final swipeProgress = percentThresholdX.toDouble() / 100.0;
          
          // Use different card widget based on user type
          if (isRecruiter) {
            return CandidateCard(
              data: card,
              isTopCard: isTopCard,
              swipeProgress: swipeProgress,
            );
          } else {
            return JobCard(
              data: card,
              isTopCard: isTopCard,
              swipeProgress: swipeProgress,
            );
          }
        },
        allowedSwipeDirection: AllowedSwipeDirection.only(
          left: true,
          right: true,
          up: true,
        ),
        isLoop: false,
        backCardOffset: const Offset(0, 35),
        scale: 0.95,
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? valueColor;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: valueColor ?? AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

