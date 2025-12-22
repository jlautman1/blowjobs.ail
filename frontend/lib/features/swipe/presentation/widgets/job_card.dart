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
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isLiking 
            ? AppColors.success.withOpacity(0.5)
            : isPassing 
              ? AppColors.error.withOpacity(0.5)
              : AppColors.surfaceBright,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Main content - scrollable
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with company
                    Row(
                      children: [
                        // Company logo
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              (data['company_name'] ?? 'C')[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['company_name'] ?? 'Company',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(
                                    Iconsax.location,
                                    size: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      data['location'] ?? 'Remote',
                                      style: const TextStyle(
                                        fontSize: 12,
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
                    
                    const SizedBox(height: 16),
                    
                    // Job title
                    Text(
                      data['title'] ?? 'Job Title',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Tags row - compact
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _InfoChip(text: _formatJobType(data['job_type'])),
                        _InfoChip(text: _formatWorkPreference(data['work_preference'])),
                        _InfoChip(text: _formatExperienceLevel(data['experience_level'])),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Salary
                    if (data['salary_range'] != null && data['salary_range'].toString().isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Iconsax.dollar_circle,
                              size: 16,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              data['salary_range'].toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Skills section
                    if (data['skills'] != null && (data['skills'] as List).isNotEmpty) ...[
                      const Text(
                        'Skills',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: (data['skills'] as List<dynamic>)
                          .take(5)
                          .map((skill) => _SkillChip(text: skill.toString()))
                          .toList(),
                      ),
                    ],
                    
                    // Add some bottom padding for scroll
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
            
            // Bottom hint overlay
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.surface.withOpacity(0),
                      AppColors.surface,
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Iconsax.arrow_left_2, size: 12, color: AppColors.error),
                        const SizedBox(width: 4),
                        Text('Skip', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        const SizedBox(width: 12),
                        Text('•', style: TextStyle(color: AppColors.textTertiary)),
                        const SizedBox(width: 12),
                        Text('Like', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        const SizedBox(width: 4),
                        Icon(Iconsax.arrow_right_3, size: 12, color: AppColors.success),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Swipe feedback overlay
            if (isLiking || isPassing)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: isLiking
                      ? AppColors.success.withOpacity(0.08)
                      : AppColors.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
            
            // Like/Pass stamp
            if (isLiking)
              Positioned(
                top: 40,
                left: 20,
                child: Transform.rotate(
                  angle: -0.2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.15),
                      border: Border.all(color: AppColors.success, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Looks good! 👍',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ),
              ),
            
            if (isPassing)
              Positioned(
                top: 40,
                right: 20,
                child: Transform.rotate(
                  angle: 0.2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.15),
                      border: Border.all(color: AppColors.error, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatJobType(String? type) {
    switch (type) {
      case 'full_time': return 'Full Time';
      case 'part_time': return 'Part Time';
      case 'contract': return 'Contract';
      case 'freelance': return 'Freelance';
      case 'internship': return 'Internship';
      default: return 'Full Time';
    }
  }

  String _formatWorkPreference(String? pref) {
    switch (pref) {
      case 'remote': return 'Remote';
      case 'hybrid': return 'Hybrid';
      case 'onsite': return 'On-site';
      default: return 'Flexible';
    }
  }

  String _formatExperienceLevel(String? level) {
    switch (level) {
      case 'entry': return 'Entry';
      case 'junior': return 'Junior';
      case 'mid': return 'Mid';
      case 'senior': return 'Senior';
      case 'lead': return 'Lead';
      case 'executive': return 'Exec';
      default: return 'Any';
    }
  }
}

class _InfoChip extends StatelessWidget {
  final String text;

  const _InfoChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
