import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_theme.dart';

class MatchPopup extends StatelessWidget {
  final Map<String, dynamic> match;
  final VoidCallback onDismiss;
  final VoidCallback onMessage;
  final bool isRecruiter;

  const MatchPopup({
    super.key,
    required this.match,
    required this.onDismiss,
    required this.onMessage,
    required this.isRecruiter,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Blur background
          Positioned.fill(
            child: GestureDetector(
              onTap: onDismiss,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: AppColors.background.withOpacity(0.7),
                ),
              ),
            ),
          ),
          
          // Content - Make it scrollable to ensure buttons are always visible
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                  // "It's a Match!" header
                  ShaderMask(
                    shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                    child: const Text(
                      "IT'S A MATCH!",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ).animate()
                    .fadeIn(duration: 500.ms)
                    .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),
                  
                  const SizedBox(height: 12),
                  
                  // Different content for recruiters vs job seekers
                  if (isRecruiter) ...[
                    // For recruiters: show candidate name
                    Text(
                      match['candidate_name'] ?? match['first_name'] ?? 'Great Candidate',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ).animate()
                      .fadeIn(duration: 500.ms, delay: 200.ms),
                    const SizedBox(height: 8),
                    Text(
                      match['headline'] ?? 'Perfect match for your role!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ).animate()
                      .fadeIn(duration: 500.ms, delay: 300.ms),
                  ] else ...[
                    // For job seekers: show job title and company (more compact)
                    Text(
                      match['job']?['title'] ?? 'New Opportunity',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ).animate()
                      .fadeIn(duration: 500.ms, delay: 200.ms),
                    const SizedBox(height: 6),
                    Text(
                      'at ${match['company_name'] ?? 'Company'}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ).animate()
                      .fadeIn(duration: 500.ms, delay: 300.ms),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Match illustration - smaller for job seekers
                  Container(
                    width: isRecruiter ? 160 : 120,
                    height: isRecruiter ? 160 : 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.matchGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Iconsax.heart5,
                        size: isRecruiter ? 80 : 60,
                        color: Colors.white,
                      ),
                    ),
                  ).animate()
                    .fadeIn(duration: 600.ms, delay: 100.ms)
                    .scale(
                      begin: const Offset(0.3, 0.3),
                      end: const Offset(1, 1),
                      curve: Curves.elasticOut,
                      duration: 800.ms,
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Message - different for recruiters vs job seekers (more compact for job seekers)
                  Text(
                    isRecruiter
                      ? 'This candidate is interested in your role!\nStart a conversation to learn more about them.'
                      : 'This company is interested in your profile!\nStart a conversation to learn more.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isRecruiter ? 15 : 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ).animate()
                    .fadeIn(duration: 500.ms, delay: 400.ms),
                  
                  const SizedBox(height: 24),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onDismiss,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.surfaceBright),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Keep Swiping',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: onMessage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Iconsax.message, size: 20, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Send Message', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ).animate()
                    .fadeIn(duration: 500.ms, delay: 500.ms)
                    .slideY(begin: 0.2),
                    // Add bottom padding to ensure buttons are visible
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

