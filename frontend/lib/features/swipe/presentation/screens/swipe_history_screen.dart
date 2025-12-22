import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/providers/auth_provider.dart';

class SwipeHistoryScreen extends ConsumerStatefulWidget {
  const SwipeHistoryScreen({super.key});

  @override
  ConsumerState<SwipeHistoryScreen> createState() => _SwipeHistoryScreenState();
}

class _SwipeHistoryScreenState extends ConsumerState<SwipeHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _allSwipes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSwipeHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSwipeHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final swipes = await apiService.getSwipeHistory();
      setState(() {
        _allSwipes = swipes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _likedSwipes {
    return _allSwipes.where((swipe) => 
      swipe['direction'] == 'right' || swipe['direction'] == 'up'
    ).toList();
  }

  List<dynamic> get _viewedSwipes {
    return _allSwipes.where((swipe) => 
      swipe['direction'] == 'left'
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isRecruiter = authState.userType == 'recruiter';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Swipe History'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Iconsax.heart5),
              text: 'Liked',
            ),
            Tab(
              icon: Icon(Iconsax.eye),
              text: 'Viewed',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.warning_2,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load swipe history',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadSwipeHistory,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSwipeList(_likedSwipes, isRecruiter, true),
                    _buildSwipeList(_viewedSwipes, isRecruiter, false),
                  ],
                ),
    );
  }

  Widget _buildSwipeList(List<dynamic> swipes, bool isRecruiter, bool isLiked) {
    if (swipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLiked ? Iconsax.heart : Iconsax.eye,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              isLiked 
                ? 'No liked ${isRecruiter ? 'candidates' : 'jobs'} yet'
                : 'No viewed ${isRecruiter ? 'candidates' : 'jobs'} yet',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSwipeHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: swipes.length,
        itemBuilder: (context, index) {
          final swipe = swipes[index];
          return _buildSwipeCard(swipe, isRecruiter, isLiked);
        },
      ),
    );
  }

  Widget _buildSwipeCard(Map<String, dynamic> swipe, bool isRecruiter, bool isLiked) {
    final date = DateTime.parse(swipe['created_at']);
    final dateFormat = DateFormat('MMM d, y • h:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLiked 
            ? AppColors.success.withOpacity(0.3)
            : AppColors.surfaceBright,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isLiked
                ? AppColors.success.withOpacity(0.1)
                : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isLiked ? Iconsax.heart5 : Iconsax.eye,
              color: isLiked ? AppColors.success : AppColors.textTertiary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRecruiter ? 'Candidate Profile' : 'Job Listing',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormat.format(date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (swipe['direction'] == 'up')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'SUPER LIKE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

