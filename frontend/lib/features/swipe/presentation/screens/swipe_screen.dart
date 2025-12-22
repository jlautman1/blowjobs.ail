import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:confetti/confetti.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/environment_provider.dart';
import '../../../../core/services/api_service.dart';
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
    final environment = ref.watch(environmentProvider);
    final isRecruiter = authState.userType == 'recruiter';
    final isDev = environment == Environment.development;
    
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
            
            // Dev reset button
            if (isDev)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ElevatedButton.icon(
                  onPressed: _resetSwipes,
                  icon: const Icon(Iconsax.refresh, size: 18),
                  label: const Text('Reset All Swipes (Dev Only)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            
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
                onInfo: () => _showCardDetails(swipeState.cards[_currentIndex], authState.userType == 'recruiter'),
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
              context.go('/chat');
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

  void _showCardDetails(Map<String, dynamic> card, bool isRecruiter) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBright,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (isRecruiter) ...[
                // Candidate details
                Text(
                  card['first_name'] ?? 'Candidate',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  card['headline'] ?? '',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (card['summary'] != null && card['summary'].toString().isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    card['summary'],
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                if (card['skills'] != null && (card['skills'] as List).isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Skills',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (card['skills'] as List).map<Widget>((skill) => Chip(
                      label: Text(skill.toString()),
                      backgroundColor: AppColors.surfaceLight,
                    )).toList(),
                  ),
                ],
              ] else ...[
                // Job details
                Text(
                  card['title'] ?? 'Job Title',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  card['company_name'] ?? 'Company',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (card['description'] != null && card['description'].toString().isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    card['description'],
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                if (card['skills'] != null && (card['skills'] as List).isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Required Skills',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (card['skills'] as List).map<Widget>((skill) => Chip(
                      label: Text(skill.toString()),
                      backgroundColor: AppColors.surfaceLight,
                    )).toList(),
                  ),
                ],
                if (card['location'] != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Iconsax.location, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        card['location'],
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
                if (card['work_preference'] != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Iconsax.briefcase, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        card['work_preference'].toString().replaceAll('_', ' ').toUpperCase(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ],
              SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resetSwipes() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text('Reset All Swipes?'),
        content: const Text(
          'This will delete all your swipe history and reset your stats. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.resetSwipes();
      
      // Reload the feed
      ref.read(swipeFeedProvider.notifier).loadFeed();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Swipes reset successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reset swipes: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
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

