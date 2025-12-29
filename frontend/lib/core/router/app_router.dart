import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/profile/presentation/screens/profile_setup_screen.dart';
import '../../features/profile/presentation/screens/cv_upload_screen.dart';
import '../../features/swipe/presentation/screens/swipe_screen.dart';
import '../../features/matches/presentation/screens/matches_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/chat/presentation/screens/conversation_screen.dart';
import '../../features/swipe/presentation/screens/swipe_history_screen.dart';
import '../../features/jobs/presentation/screens/job_creation_screen.dart';
import '../../features/recruiter/presentation/screens/recruiter_dashboard_screen.dart';
import '../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      final hasError = authState.error != null;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/';
      
      // Don't redirect while authentication is in progress
      if (isLoading) {
        return null;
      }
      
      // If there's an error on login/register page, stay on that page
      if (hasError && isLoggingIn) {
        return null;
      }
      
      if (!isLoggedIn && !isLoggingIn) {
        return '/';
      }
      
      // Only redirect to home if authenticated AND not currently on auth pages
      if (isLoggedIn && isLoggingIn) {
        return '/home';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const SwipeScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: '/matches',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const MatchesScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: '/chat',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const ChatScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/conversation/:matchId',
        builder: (context, state) {
          final matchId = state.pathParameters['matchId']!;
          return ConversationScreen(matchId: matchId);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const _PlaceholderScreen(title: 'My Profile', icon: Iconsax.user),
      ),
      GoRoute(
        path: '/cv-upload',
        builder: (context, state) => const CVUploadScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const _PlaceholderScreen(title: 'Settings', icon: Iconsax.setting_2),
      ),
      GoRoute(
        path: '/achievements',
        builder: (context, state) => const _PlaceholderScreen(title: 'Achievements', icon: Iconsax.medal_star),
      ),
      GoRoute(
        path: '/swipe-history',
        builder: (context, state) => const SwipeHistoryScreen(),
      ),
      GoRoute(
        path: '/job-creation',
        builder: (context, state) => const JobCreationScreen(),
      ),
      GoRoute(
        path: '/recruiter-dashboard',
        builder: (context, state) => const RecruiterDashboardScreen(),
      ),
    ],
  );
});

// Placeholder screens for unimplemented features
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderScreen({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Coming soon!',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

