import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/api_service.dart';

class JobCreationScreen extends ConsumerStatefulWidget {
  const JobCreationScreen({super.key});

  @override
  ConsumerState<JobCreationScreen> createState() => _JobCreationScreenState();
}

class _JobCreationScreenState extends ConsumerState<JobCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryMinController = TextEditingController();
  final _salaryMaxController = TextEditingController();
  
  String _jobType = 'full_time';
  String _workPreference = 'any';
  String _experienceLevel = 'mid';
  List<String> _skills = [];
  List<String> _requirements = [];
  List<String> _benefits = [];
  final _skillController = TextEditingController();
  final _requirementController = TextEditingController();
  final _benefitController = TextEditingController();
  
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _skillController.dispose();
    _requirementController.dispose();
    _benefitController.dispose();
    super.dispose();
  }

  void _addSkill() {
    if (_skillController.text.trim().isNotEmpty) {
      setState(() {
        _skills.add(_skillController.text.trim());
        _skillController.clear();
      });
    }
  }

  void _addRequirement() {
    if (_requirementController.text.trim().isNotEmpty) {
      setState(() {
        _requirements.add(_requirementController.text.trim());
        _requirementController.clear();
      });
    }
  }

  void _addBenefit() {
    if (_benefitController.text.trim().isNotEmpty) {
      setState(() {
        _benefits.add(_benefitController.text.trim());
        _benefitController.clear();
      });
    }
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final apiService = ref.read(apiServiceProvider);
      final jobData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'job_type': _jobType,
        'work_preference': _workPreference,
        'experience_level': _experienceLevel,
        'skills': _skills,
        'requirements': _requirements,
        'benefits': _benefits,
        'salary_min': _salaryMinController.text.isNotEmpty 
          ? int.tryParse(_salaryMinController.text) ?? 0 
          : 0,
        'salary_max': _salaryMaxController.text.isNotEmpty 
          ? int.tryParse(_salaryMaxController.text) ?? 0 
          : 0,
        'show_salary': true,
      };

      await apiService.createJob(jobData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Job created successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Job Posting'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Job Title *',
                  hintText: 'e.g., Senior Software Engineer',
                  prefixIcon: Icon(Iconsax.briefcase),
                ),
                validator: (value) => value?.isEmpty ?? true 
                  ? 'Please enter a job title' 
                  : null,
              ),
              const SizedBox(height: 20),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Job Description *',
                  hintText: 'Describe the role and responsibilities...',
                  prefixIcon: Icon(Iconsax.document_text),
                ),
                maxLines: 5,
                validator: (value) => value?.isEmpty ?? true 
                  ? 'Please enter a job description' 
                  : null,
              ),
              const SizedBox(height: 20),
              
              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'e.g., Remote, New York, NY',
                  prefixIcon: Icon(Iconsax.location),
                ),
              ),
              const SizedBox(height: 20),
              
              // Job Type
              DropdownButtonFormField<String>(
                value: _jobType,
                decoration: const InputDecoration(
                  labelText: 'Job Type *',
                  prefixIcon: Icon(Iconsax.clock),
                ),
                items: const [
                  DropdownMenuItem(value: 'full_time', child: Text('Full Time')),
                  DropdownMenuItem(value: 'part_time', child: Text('Part Time')),
                  DropdownMenuItem(value: 'contract', child: Text('Contract')),
                  DropdownMenuItem(value: 'internship', child: Text('Internship')),
                ],
                onChanged: (value) => setState(() => _jobType = value ?? 'full_time'),
              ),
              const SizedBox(height: 20),
              
              // Work Preference
              DropdownButtonFormField<String>(
                value: _workPreference,
                decoration: const InputDecoration(
                  labelText: 'Work Preference',
                  prefixIcon: Icon(Iconsax.home),
                ),
                items: const [
                  DropdownMenuItem(value: 'remote', child: Text('Remote')),
                  DropdownMenuItem(value: 'hybrid', child: Text('Hybrid')),
                  DropdownMenuItem(value: 'onsite', child: Text('On-site')),
                  DropdownMenuItem(value: 'any', child: Text('Any')),
                ],
                onChanged: (value) => setState(() => _workPreference = value ?? 'any'),
              ),
              const SizedBox(height: 20),
              
              // Experience Level
              DropdownButtonFormField<String>(
                value: _experienceLevel,
                decoration: const InputDecoration(
                  labelText: 'Experience Level',
                  prefixIcon: Icon(Iconsax.user),
                ),
                items: const [
                  DropdownMenuItem(value: 'entry', child: Text('Entry Level')),
                  DropdownMenuItem(value: 'junior', child: Text('Junior')),
                  DropdownMenuItem(value: 'mid', child: Text('Mid Level')),
                  DropdownMenuItem(value: 'senior', child: Text('Senior')),
                  DropdownMenuItem(value: 'lead', child: Text('Lead')),
                ],
                onChanged: (value) => setState(() => _experienceLevel = value ?? 'mid'),
              ),
              const SizedBox(height: 20),
              
              // Salary Range
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _salaryMinController,
                      decoration: const InputDecoration(
                        labelText: 'Min Salary',
                        prefixIcon: Icon(Iconsax.dollar_circle),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _salaryMaxController,
                      decoration: const InputDecoration(
                        labelText: 'Max Salary',
                        prefixIcon: Icon(Iconsax.dollar_circle),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Skills
              _buildListSection(
                title: 'Required Skills',
                items: _skills,
                controller: _skillController,
                onAdd: _addSkill,
                onRemove: (index) => setState(() => _skills.removeAt(index)),
                hint: 'Add a skill',
              ),
              
              const SizedBox(height: 24),
              
              // Requirements
              _buildListSection(
                title: 'Requirements',
                items: _requirements,
                controller: _requirementController,
                onAdd: _addRequirement,
                onRemove: (index) => setState(() => _requirements.removeAt(index)),
                hint: 'Add a requirement',
              ),
              
              const SizedBox(height: 24),
              
              // Benefits
              _buildListSection(
                title: 'Benefits',
                items: _benefits,
                controller: _benefitController,
                onAdd: _addBenefit,
                onRemove: (index) => setState(() => _benefits.removeAt(index)),
                hint: 'Add a benefit',
              ),
              
              const SizedBox(height: 32),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitJob,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Job Posting'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListSection({
    required String title,
    required List<String> items,
    required TextEditingController controller,
    required VoidCallback onAdd,
    required Function(int) onRemove,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                  prefixIcon: const Icon(Iconsax.add),
                ),
                onFieldSubmitted: (_) => onAdd(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onAdd,
              icon: const Icon(Iconsax.add_circle),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
        if (items.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(items.length, (index) => Chip(
              label: Text(items[index]),
              onDeleted: () => onRemove(index),
              deleteIcon: const Icon(Iconsax.close_circle, size: 18),
            )),
          ),
        ],
      ],
    );
  }
}

