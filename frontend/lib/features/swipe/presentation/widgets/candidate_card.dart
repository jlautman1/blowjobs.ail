import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_theme.dart';

class CandidateCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isTopCard;
  final double swipeProgress;

  const CandidateCard({
    super.key,
    required this.data,
    required this.isTopCard,
    required this.swipeProgress,
  });

  @override
  Widget build(BuildContext context) {
    final isLiking = swipeProgress > 0.15;
    final isPassing = swipeProgress < -0.15;
    final firstName = data['first_name'] ?? 'Candidate';
    
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
            // Main content
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar and name
                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              firstName[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                firstName,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data['headline'] ?? 'Job Seeker',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Info chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          icon: Iconsax.chart,
                          text: _formatExperience(data['experience_level'], data['years_of_experience']),
                        ),
                        if (data['work_preference'] != null)
                          _InfoChip(
                            icon: Iconsax.building,
                            text: _formatWorkPreference(data['work_preference']),
                          ),
                        if (data['preferred_location'] != null)
                          _InfoChip(
                            icon: Iconsax.location,
                            text: data['preferred_location'],
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Expected salary
                    if (data['expected_salary'] != null && data['expected_salary'].toString().isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Iconsax.dollar_circle,
                              size: 18,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Expects: ${data['expected_salary']}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 20),
                    
                    // Summary/Bio
                    if (data['summary'] != null && data['summary'].toString().isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          data['summary'],
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Skills
                    if (data['skills'] != null && (data['skills'] as List).isNotEmpty) ...[
                      const Text(
                        'Skills',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (data['skills'] as List<dynamic>)
                          .take(8)
                          .map((skill) => _SkillChip(text: skill.toString()))
                          .toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Languages
                    if (data['languages'] != null && (data['languages'] as List).isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Iconsax.global, size: 14, color: AppColors.textTertiary),
                          const SizedBox(width: 6),
                          const Text(
                            'Languages: ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              (data['languages'] as List).take(4).join(', '),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                    
                    // Certifications
                    if (data['certifications'] != null && (data['certifications'] as List).isNotEmpty) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Iconsax.award, size: 14, color: AppColors.textTertiary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Certifications',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ...(data['certifications'] as List).take(3).map((cert) => Text(
                                  '• $cert',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                    
                    // Open to relocation badge
                    if (data['open_to_relocation'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Iconsax.airplane, size: 12, color: AppColors.info),
                            SizedBox(width: 4),
                            Text(
                              'Open to relocation',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.info,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Bottom padding for scroll
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
            
            // Bottom hint
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
                        Text('Pass', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        const SizedBox(width: 12),
                        Text('•', style: TextStyle(color: AppColors.textTertiary)),
                        const SizedBox(width: 12),
                        Text('Interested', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
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
                      'Interested! ⭐',
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
                      'Pass',
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

  String _formatExperience(String? level, dynamic years) {
    final levelStr = _formatLevel(level);
    if (years != null && years > 0) {
      return '$levelStr • $years yrs';
    }
    return levelStr;
  }

  String _formatLevel(String? level) {
    switch (level) {
      case 'entry': return 'Entry Level';
      case 'junior': return 'Junior';
      case 'mid': return 'Mid-Level';
      case 'senior': return 'Senior';
      case 'lead': return 'Lead';
      case 'executive': return 'Executive';
      default: return 'Professional';
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
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

