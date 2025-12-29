import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/environment_provider.dart';
import '../widgets/animated_background.dart';
import '../widgets/gold_button.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final environment = ref.watch(environmentProvider);
    final environmentNotifier = ref.read(environmentProvider.notifier);
    
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          const AnimatedBackground(),
          
          // Environment switcher
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _EnvironmentSwitcher(
                  currentEnvironment: environment,
                  onChanged: (env) => environmentNotifier.setEnvironment(env),
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  
                  // Logo and branding
                  _buildLogo().animate()
                    .fadeIn(duration: 800.ms, delay: 200.ms)
                    .slideY(begin: -0.2, end: 0),
                  
                  const SizedBox(height: 24),
                  
                  // Tagline
                  Text(
                    "Find Your Dream Job\nThe Fun Way",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      height: 1.2,
                    ),
                  ).animate()
                    .fadeIn(duration: 800.ms, delay: 400.ms)
                    .slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    'Job hunting shouldn\'t be stressful.\nSwipe right on opportunities that excite you!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ).animate()
                    .fadeIn(duration: 800.ms, delay: 600.ms),
                  
                  const Spacer(flex: 2),
                  
                  // Buttons
                  GoldButton(
                    text: 'Get Started',
                    onPressed: () => context.push('/register'),
                  ).animate()
                    .fadeIn(duration: 600.ms, delay: 800.ms)
                    .slideY(begin: 0.3, end: 0),
                  
                  const SizedBox(height: 16),
                  
                  TextButton(
                    onPressed: () => context.push('/login'),
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate()
                    .fadeIn(duration: 600.ms, delay: 1000.ms),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // App icon with glow effect - Briefcase/rocket style
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 25,
                spreadRadius: 3,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '🚀',
              style: TextStyle(
                fontSize: 50,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // App name with gradient text
        ShaderMask(
          shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
          child: const Text(
            'BlowJobs.ai',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Subtitle
        Text(
          'AI-Powered Job Matching',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _EnvironmentSwitcher extends ConsumerWidget {
  final Environment currentEnvironment;
  final Function(Environment) onChanged;

  const _EnvironmentSwitcher({
    required this.currentEnvironment,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBright),
      ),
      child: PopupMenuButton<Environment>(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                currentEnvironment == Environment.development
                    ? Iconsax.code
                    : Iconsax.global,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                currentEnvironment == Environment.development
                    ? 'Dev'
                    : 'Prod',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Iconsax.arrow_down_1,
                size: 12,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: Environment.development,
            child: Row(
              children: [
                const Icon(Iconsax.code, size: 18, color: AppColors.textPrimary),
                const SizedBox(width: 12),
                const Expanded(child: Text('Development')),
                if (currentEnvironment == Environment.development) ...[
                  const SizedBox(width: 8),
                  const Icon(Iconsax.tick_circle, size: 18, color: AppColors.primary),
                ],
              ],
            ),
          ),
          PopupMenuItem(
            value: Environment.production,
            child: Row(
              children: [
                const Icon(Iconsax.global, size: 18, color: AppColors.textPrimary),
                const SizedBox(width: 12),
                const Expanded(child: Text('Production')),
                if (currentEnvironment == Environment.production) ...[
                  const SizedBox(width: 8),
                  const Icon(Iconsax.tick_circle, size: 18, color: AppColors.primary),
                ],
              ],
            ),
          ),
        ],
        onSelected: onChanged,
      ),
    );
  }
}

