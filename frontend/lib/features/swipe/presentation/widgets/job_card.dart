import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_theme.dart';

class JobCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isTopCard;
  final double swipeProgress;

  const JobCard({
    super.key,
    required this.data,
    required this.isTopCard,
    required this.swipeProgress,
  });

  @override
  Widget build(BuildContext context) {
    final isLiking = swipeProgress > 0.15;
    final isPassing = swipeProgress < -0.15;
    final isSuperLiking = swipeProgress > 0.5;
    
    // Calculate rotation based on swipe progress
    final rotation = swipeProgress * 0.1;
    
    return Transform.rotate(
      angle: rotation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          gradient: isLiking
              ? AppColors.swipeRightGradient
              : isPassing
                  ? AppColors.swipeLeftGradient
                  : isSuperLiking
                      ? AppColors.swipeUpGradient
                      : AppColors.vibrantCardGradient,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isLiking 
                ? AppColors.swipeRight.withOpacity(0.6)
                : isPassing 
                    ? AppColors.swipeLeft.withOpacity(0.6)
                    : isSuperLiking
                        ? AppColors.swipeUp.withOpacity(0.6)
                        : AppColors.primary.withOpacity(0.2),
            width: isLiking || isPassing || isSuperLiking ? 4 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isLiking
                  ? AppColors.swipeRight.withOpacity(0.4)
                  : isPassing
                      ? AppColors.swipeLeft.withOpacity(0.4)
                      : isSuperLiking
                          ? AppColors.swipeUp.withOpacity(0.4)
                          : AppColors.primary.withOpacity(0.2),
              blurRadius: isLiking || isPassing || isSuperLiking ? 30 : 20,
              offset: const Offset(0, 12),
              spreadRadius: isLiking || isPassing || isSuperLiking ? 4 : 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(31),
          child: Stack(
            children: [
              // Vibrant animated background overlay when swiping
              if (isLiking || isPassing || isSuperLiking)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          (isLiking ? AppColors.swipeRight : isPassing ? AppColors.swipeLeft : AppColors.swipeUp)
                              .withOpacity(0.15),
                          Colors.transparent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              
              // Thick vibrant accent bar at top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 6,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: isLiking
                        ? AppColors.swipeRightGradient
                        : isPassing
                            ? AppColors.swipeLeftGradient
                            : isSuperLiking
                                ? AppColors.swipeUpGradient
                                : AppColors.primaryGradient,
                  ),
                ),
              ),
              
              // Main content - scrollable
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(32, 36, 32, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with company - EXTRA Large and prominent
                      Row(
                        children: [
                          // Company logo - HUGE with vibrant gradient
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                (data['company_name'] ?? 'C')[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['company_name'] ?? 'Company',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.5,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Iconsax.location,
                                        size: 18,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        data['location'] ?? 'Remote',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Job title - EXTRA Large, bold, prominent
                      Text(
                        data['title'] ?? 'Job Title',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          height: 1.1,
                          letterSpacing: -1.5,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Tags row - Vibrant, colorful chips
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _InfoChip(
                            text: _formatJobType(data['job_type']),
                            color: AppColors.primary,
                          ),
                          _InfoChip(
                            text: _formatWorkPreference(data['work_preference']),
                            color: AppColors.success,
                          ),
                          _InfoChip(
                            text: _formatExperienceLevel(data['experience_level']),
                            color: AppColors.superLike,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 28),
                      
                      // Salary - EXTRA Prominent, vibrant display
                      if (data['salary_range'] != null && data['salary_range'].toString().isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.success.withOpacity(0.2),
                                AppColors.success.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.success.withOpacity(0.4),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.success.withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: AppColors.swipeRightGradient,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Iconsax.dollar_circle,
                                  size: 22,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                data['salary_range'].toString(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 32),
                      
                      // Skills section - Ultra vibrant chips
                      if (data['skills'] != null && (data['skills'] as List).isNotEmpty) ...[
                        const Text(
                          'Required Skills',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: (data['skills'] as List<dynamic>)
                            .take(8)
                            .map((skill) => _SkillChip(text: skill.toString()))
                            .toList(),
                        ),
                      ],
                      
                      // Add bottom padding for scroll
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatJobType(String? type) {
    if (type == null) return 'Full Time';
    return type.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  String _formatWorkPreference(String? pref) {
    if (pref == null) return 'Any';
    return pref.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  String _formatExperienceLevel(String? level) {
    if (level == null) return 'Mid Level';
    return level.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }
}

class _InfoChip extends StatelessWidget {
  final String text;
  final Color color;

  const _InfoChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String text;

  const _SkillChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.2),
            AppColors.primary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
