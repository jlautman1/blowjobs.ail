import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/auth_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final Widget child;

  const HomeScreen({super.key, required this.child});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
    
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/matches');
        break;
      case 2:
        context.go('/chat');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom app bar
            _buildAppBar(context, authState),
            
            // Content - properly constrained
            Expanded(
              child: ClipRect(
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(authState),
    );
  }

  Widget _buildAppBar(BuildContext context, AuthState authState) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.surfaceBright.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Logo - Vibrant gradient
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '🚀',
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Title and streak
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, ${authState.firstName}! 👋',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Iconsax.flash_15,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${authState.user?['swipe_streak'] ?? 0} day streak',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Notification bell
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Notifications coming soon! 🔔'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Iconsax.notification),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceLight,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Profile
          GestureDetector(
            onTap: () {
              _showProfileMenu(context);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  authState.firstName.isNotEmpty 
                    ? authState.firstName[0].toUpperCase()
                    : '?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    final authState = ref.read(authStateProvider);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).padding.bottom + 24,
          ),
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
            _ProfileMenuItem(
                  icon: Iconsax.user,
                  title: 'My Profile',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/profile');
                  },
                ),
                if (authState.userType == 'job_seeker')
                  _ProfileMenuItem(
                    icon: Iconsax.document_upload,
                    title: 'Upload CV',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/cv-upload');
                    },
                  ),
                if (authState.userType == 'recruiter')
                  _ProfileMenuItem(
                    icon: Iconsax.chart,
                    title: 'Dashboard',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/recruiter-dashboard');
                    },
                  ),
            _ProfileMenuItem(
              icon: Iconsax.setting_2,
              title: 'Settings',
              onTap: () {
                Navigator.pop(context);
                context.push('/settings');
              },
            ),
            _ProfileMenuItem(
              icon: Iconsax.medal_star,
              title: 'Achievements',
              onTap: () {
                Navigator.pop(context);
                context.push('/achievements');
              },
            ),
            _ProfileMenuItem(
              icon: Iconsax.heart,
              title: 'Swipe History',
              onTap: () {
                Navigator.pop(context);
                context.push('/swipe-history');
              },
            ),
            const Divider(height: 32),
            _ProfileMenuItem(
              icon: Iconsax.logout,
              title: 'Sign Out',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                ref.read(authStateProvider.notifier).logout();
                context.go('/');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(AuthState authState) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.surfaceBright.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Iconsax.home_2,
            activeIcon: Iconsax.home_15,
            label: 'Discover',
            isSelected: _currentIndex == 0,
            onTap: () => _onTabTapped(0),
          ),
          _NavItem(
            icon: Iconsax.heart,
            activeIcon: Iconsax.heart5,
            label: 'Hired!',
            isSelected: _currentIndex == 1,
            onTap: () => _onTabTapped(1),
            badgeCount: authState.matchCount, // Only show if > 0
          ),
          _NavItem(
            icon: Iconsax.message,
            activeIcon: Iconsax.message5,
            label: 'Chat',
            isSelected: _currentIndex == 2,
            onTap: () => _onTabTapped(2),
            badgeCount: authState.unreadMessages, // Only show if > 0
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? AppColors.primary.withOpacity(0.15)
                      : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    color: isSelected ? AppColors.primary : AppColors.textTertiary,
                    size: 24,
                  ),
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badgeCount > 9 ? '9+' : '$badgeCount',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDestructive 
            ? AppColors.error.withOpacity(0.1)
            : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Iconsax.arrow_right_3,
        color: isDestructive ? AppColors.error : AppColors.textTertiary,
        size: 20,
      ),
    );
  }
}

