import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/gold_button.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Job Seeker fields
  final _headlineController = TextEditingController();
  final _summaryController = TextEditingController();
  final _skillsController = TextEditingController();
  String _experienceLevel = 'mid';
  String _workPreference = 'any';
  List<String> _skills = [];
  
  // Recruiter fields
  final _companyNameController = TextEditingController();
  final _companyWebsiteController = TextEditingController();
  final _positionController = TextEditingController();
  final _bioController = TextEditingController();
  String _companySize = 'medium';
  String _industry = 'Technology';

  @override
  void dispose() {
    _pageController.dispose();
    _headlineController.dispose();
    _summaryController.dispose();
    _skillsController.dispose();
    _companyNameController.dispose();
    _companyWebsiteController.dispose();
    _positionController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _addSkill(String skill) {
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillsController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeSetup() async {
    // TODO: Save profile via API
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isRecruiter = authState.userType == 'recruiter';
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      onPressed: _previousPage,
                      icon: const Icon(Iconsax.arrow_left),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surfaceLight,
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                  
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Complete Your Profile',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        // Progress indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            return Container(
                              width: index == _currentPage ? 24 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: index <= _currentPage 
                                  ? AppColors.primary 
                                  : AppColors.surfaceBright,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  
                  TextButton(
                    onPressed: () => context.go('/home'),
                    child: Text(
                      'Skip',
                      style: TextStyle(color: AppColors.textTertiary),
                    ),
                  ),
                ],
              ),
            ),
            
            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: isRecruiter
                  ? [
                      _buildRecruiterPage1(),
                      _buildRecruiterPage2(),
                      _buildCompletionPage(isRecruiter),
                    ]
                  : [
                      _buildJobSeekerPage1(),
                      _buildJobSeekerPage2(),
                      _buildCompletionPage(isRecruiter),
                    ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobSeekerPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell us about yourself',
            style: Theme.of(context).textTheme.headlineMedium,
          ).animate().fadeIn(duration: 400.ms),
          
          const SizedBox(height: 8),
          
          Text(
            'This helps recruiters understand your background',
            style: TextStyle(color: AppColors.textSecondary),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
          
          const SizedBox(height: 32),
          
          CustomTextField(
            controller: _headlineController,
            label: 'Professional Headline',
            hint: 'e.g., Senior Software Engineer',
            prefixIcon: Iconsax.briefcase,
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
          
          const SizedBox(height: 20),
          
          CustomTextField(
            controller: _summaryController,
            label: 'Summary',
            hint: 'Brief description of your experience and goals',
            prefixIcon: Iconsax.document_text,
            maxLines: 4,
          ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
          
          const SizedBox(height: 20),
          
          Text(
            'Experience Level',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
          
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SelectableChip(
                label: 'Entry',
                isSelected: _experienceLevel == 'entry',
                onTap: () => setState(() => _experienceLevel = 'entry'),
              ),
              _SelectableChip(
                label: 'Junior',
                isSelected: _experienceLevel == 'junior',
                onTap: () => setState(() => _experienceLevel = 'junior'),
              ),
              _SelectableChip(
                label: 'Mid-Level',
                isSelected: _experienceLevel == 'mid',
                onTap: () => setState(() => _experienceLevel = 'mid'),
              ),
              _SelectableChip(
                label: 'Senior',
                isSelected: _experienceLevel == 'senior',
                onTap: () => setState(() => _experienceLevel = 'senior'),
              ),
              _SelectableChip(
                label: 'Lead',
                isSelected: _experienceLevel == 'lead',
                onTap: () => setState(() => _experienceLevel = 'lead'),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
          
          const SizedBox(height: 40),
          
          GoldButton(
            text: 'Continue',
            onPressed: _nextPage,
          ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
        ],
      ),
    );
  }

  Widget _buildJobSeekerPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Skills & Preferences',
            style: Theme.of(context).textTheme.headlineMedium,
          ).animate().fadeIn(duration: 400.ms),
          
          const SizedBox(height: 8),
          
          Text(
            'Help us match you with the right opportunities',
            style: TextStyle(color: AppColors.textSecondary),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
          
          const SizedBox(height: 32),
          
          // Skills input
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _skillsController,
                  label: 'Add Skills',
                  hint: 'Type a skill and press add',
                  prefixIcon: Iconsax.code,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => _addSkill(_skillsController.text.trim()),
                icon: const Icon(Iconsax.add),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
          
          const SizedBox(height: 16),
          
          // Skills chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _skills.map((skill) => Chip(
              label: Text(skill),
              deleteIcon: const Icon(Iconsax.close_circle, size: 18),
              onDeleted: () => _removeSkill(skill),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
              labelStyle: const TextStyle(color: AppColors.primary),
            )).toList(),
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'Work Preference',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
          
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SelectableChip(
                label: '🏠 Remote',
                isSelected: _workPreference == 'remote',
                onTap: () => setState(() => _workPreference = 'remote'),
              ),
              _SelectableChip(
                label: '🏢 On-site',
                isSelected: _workPreference == 'onsite',
                onTap: () => setState(() => _workPreference = 'onsite'),
              ),
              _SelectableChip(
                label: '🔄 Hybrid',
                isSelected: _workPreference == 'hybrid',
                onTap: () => setState(() => _workPreference = 'hybrid'),
              ),
              _SelectableChip(
                label: '✨ Any',
                isSelected: _workPreference == 'any',
                onTap: () => setState(() => _workPreference = 'any'),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
          
          const SizedBox(height: 40),
          
          GoldButton(
            text: 'Continue',
            onPressed: _nextPage,
          ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
        ],
      ),
    );
  }

  Widget _buildRecruiterPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Company Information',
            style: Theme.of(context).textTheme.headlineMedium,
          ).animate().fadeIn(duration: 400.ms),
          
          const SizedBox(height: 8),
          
          Text(
            'Tell candidates about your company',
            style: TextStyle(color: AppColors.textSecondary),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
          
          const SizedBox(height: 32),
          
          CustomTextField(
            controller: _companyNameController,
            label: 'Company Name',
            hint: 'Enter your company name',
            prefixIcon: Iconsax.building,
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
          
          const SizedBox(height: 20),
          
          CustomTextField(
            controller: _companyWebsiteController,
            label: 'Company Website',
            hint: 'https://example.com',
            prefixIcon: Iconsax.global,
          ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
          
          const SizedBox(height: 20),
          
          Text(
            'Company Size',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
          
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SelectableChip(
                label: 'Startup (1-10)',
                isSelected: _companySize == 'startup',
                onTap: () => setState(() => _companySize = 'startup'),
              ),
              _SelectableChip(
                label: 'Small (11-50)',
                isSelected: _companySize == 'small',
                onTap: () => setState(() => _companySize = 'small'),
              ),
              _SelectableChip(
                label: 'Medium (51-200)',
                isSelected: _companySize == 'medium',
                onTap: () => setState(() => _companySize = 'medium'),
              ),
              _SelectableChip(
                label: 'Large (201-1000)',
                isSelected: _companySize == 'large',
                onTap: () => setState(() => _companySize = 'large'),
              ),
              _SelectableChip(
                label: 'Enterprise (1000+)',
                isSelected: _companySize == 'enterprise',
                onTap: () => setState(() => _companySize = 'enterprise'),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
          
          const SizedBox(height: 40),
          
          GoldButton(
            text: 'Continue',
            onPressed: _nextPage,
          ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
        ],
      ),
    );
  }

  Widget _buildRecruiterPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Role',
            style: Theme.of(context).textTheme.headlineMedium,
          ).animate().fadeIn(duration: 400.ms),
          
          const SizedBox(height: 8),
          
          Text(
            'Help candidates know who they\'ll be talking to',
            style: TextStyle(color: AppColors.textSecondary),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
          
          const SizedBox(height: 32),
          
          CustomTextField(
            controller: _positionController,
            label: 'Your Position',
            hint: 'e.g., Senior Recruiter, HR Manager',
            prefixIcon: Iconsax.user,
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
          
          const SizedBox(height: 20),
          
          CustomTextField(
            controller: _bioController,
            label: 'Bio',
            hint: 'Brief description about yourself',
            prefixIcon: Iconsax.document_text,
            maxLines: 4,
          ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
          
          const SizedBox(height: 40),
          
          GoldButton(
            text: 'Continue',
            onPressed: _nextPage,
          ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildCompletionPage(bool isRecruiter) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Iconsax.tick_circle5,
                size: 60,
                color: Colors.white,
              ),
            ),
          ).animate()
            .fadeIn(duration: 600.ms)
            .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut),
          
          const SizedBox(height: 40),
          
          Text(
            'You\'re All Set!',
            style: Theme.of(context).textTheme.displaySmall,
          ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
          
          const SizedBox(height: 16),
          
          Text(
            isRecruiter
              ? 'Start posting jobs and finding top talent!'
              : 'Start swiping and find your dream job!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
          
          const SizedBox(height: 48),
          
          GoldButton(
            text: 'Start Exploring',
            onPressed: _completeSetup,
          ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
        ],
      ),
    );
  }
}

class _SelectableChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
            ? AppColors.primary.withOpacity(0.15)
            : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

