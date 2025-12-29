import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/api_service.dart';

class CVUploadScreen extends ConsumerStatefulWidget {
  const CVUploadScreen({super.key});

  @override
  ConsumerState<CVUploadScreen> createState() => _CVUploadScreenState();
}

class _CVUploadScreenState extends ConsumerState<CVUploadScreen> {
  bool _isUploading = false;
  String? _uploadedCVUrl;
  Map<String, dynamic>? _analysis;

  @override
  void initState() {
    super.initState();
    _loadCVInfo();
  }

  Future<void> _loadCVInfo() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final profile = await apiService.getJobSeekerProfile();
      setState(() {
        _uploadedCVUrl = profile['cv_url'];
        _analysis = profile['cv_analysis'];
      });
    } catch (e) {
      // Profile might not exist yet
    }
  }

  Future<void> _pickAndUploadCV() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result == null || result.files.isEmpty) return;

      setState(() => _isUploading = true);

      final apiService = ref.read(apiServiceProvider);
      
      // file_picker provides bytes for all platforms
      final fileBytes = result.files.single.bytes;
      final fileName = result.files.single.name;
      
      if (fileBytes == null || fileName == null) {
        setState(() => _isUploading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to read file. Please try again.'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
      
      // Upload CV
      final uploadResult = await apiService.uploadCV(fileBytes, fileName);
      
      if (uploadResult != null) {
        setState(() {
          _uploadedCVUrl = uploadResult['cv_url'];
          _analysis = uploadResult['analysis'];
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('CV uploaded and analyzed successfully!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
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
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload CV'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Upload Your Resume',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Upload your CV and our AI will analyze it to help match you with the best opportunities.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            
            // Upload area
            GestureDetector(
              onTap: _isUploading ? null : _pickAndUploadCV,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _uploadedCVUrl != null 
                      ? AppColors.success.withOpacity(0.3)
                      : AppColors.surfaceBright,
                    width: 2,
                    style: _uploadedCVUrl != null 
                      ? BorderStyle.solid
                      : BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    if (_isUploading)
                      const CircularProgressIndicator()
                    else if (_uploadedCVUrl != null)
                      Icon(
                        Iconsax.document_download,
                        size: 48,
                        color: AppColors.success,
                      )
                    else
                      Icon(
                        Iconsax.document_upload,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    const SizedBox(height: 16),
                    Text(
                      _isUploading
                        ? 'Uploading...'
                        : _uploadedCVUrl != null
                          ? 'CV Uploaded'
                          : 'Tap to upload CV',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'PDF, DOC, or DOCX (Max 5MB)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // AI Analysis Results
            if (_analysis != null) ...[
              const SizedBox(height: 32),
              Text(
                'AI Analysis Results',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.surfaceBright,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_analysis!['skills'] != null) ...[
                      _AnalysisSection(
                        title: 'Skills Detected',
                        items: List<String>.from(_analysis!['skills'] ?? []),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_analysis!['experience_level'] != null) ...[
                      _AnalysisSection(
                        title: 'Experience Level',
                        items: [_analysis!['experience_level'].toString()],
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_analysis!['years_of_experience'] != null) ...[
                      _AnalysisSection(
                        title: 'Years of Experience',
                        items: ['${_analysis!['years_of_experience']} years'],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnalysisSection extends StatelessWidget {
  final String title;
  final List<String> items;

  const _AnalysisSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }
}

