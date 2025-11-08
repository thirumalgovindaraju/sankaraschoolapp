// lib/presentation/screens/academic/curriculum_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/academic_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../../data/models/curriculum_model.dart';
import '../../../core/constants/app_colors.dart';

class CurriculumScreen extends StatefulWidget {
  const CurriculumScreen({super.key});

  @override
  State<CurriculumScreen> createState() => _CurriculumScreenState();
}

class _CurriculumScreenState extends State<CurriculumScreen> {
  @override
  void initState() {
    super.initState();
    _loadCurriculum();
  }

  void _loadCurriculum() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final academicProvider = context.read<AcademicProvider>();

      if (authProvider.currentUser != null) {
        // You can add classId and subject filters if needed
        academicProvider.fetchCurriculum();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Curriculum'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AcademicProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingCurriculum) {
            return const LoadingIndicator();
          }

          if (provider.curriculumError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    provider.curriculumError!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCurriculum,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.curriculumList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('No curriculum available'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCurriculum,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadCurriculum(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.curriculumList.length,
              itemBuilder: (context, index) {
                final curriculum = provider.curriculumList[index];
                return _buildCurriculumCard(curriculum);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurriculumCard(dynamic curriculum) {
    // Extract data safely from the curriculum object
    final subjectName = _getProperty(curriculum, 'subject') ??
        _getProperty(curriculum, 'subjectName') ??
        _getProperty(curriculum, 'title') ??
        'Unknown Subject';

    final className = _getProperty(curriculum, 'class') ??
        _getProperty(curriculum, 'className') ??
        _getProperty(curriculum, 'grade') ??
        'N/A';

    final sectionName = _getProperty(curriculum, 'section') ??
        _getProperty(curriculum, 'sectionName') ??
        'N/A';

    final description = _getProperty(curriculum, 'description') ?? '';

    final year = _getProperty(curriculum, 'academicYear') ??
        _getProperty(curriculum, 'year') ??
        'N/A';

    final term = _getProperty(curriculum, 'term') ??
        _getProperty(curriculum, 'semester') ??
        'N/A';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/curriculum-detail',
            arguments: curriculum,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.book,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subjectName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$className - $sectionName',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.calendar_today,
                    year,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.schedule,
                    term,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _getProperty(dynamic obj, String property) {
    try {
      if (obj is Map) {
        return obj[property]?.toString();
      }
      // Try to access as object property using reflection would go here
      // For now, return null if not a Map
      return null;
    } catch (e) {
      return null;
    }
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}