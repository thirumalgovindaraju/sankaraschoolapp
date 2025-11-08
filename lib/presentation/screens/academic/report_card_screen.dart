// lib/presentation/screens/academic/report_card_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/academic_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../../core/constants/app_colors.dart';

class ReportCardScreen extends StatefulWidget {
  const ReportCardScreen({super.key});

  @override
  State<ReportCardScreen> createState() => _ReportCardScreenState();
}

class _ReportCardScreenState extends State<ReportCardScreen> {
  String _selectedYear = '2024-2025';
  String _selectedTerm = 'Term 1';

  @override
  void initState() {
    super.initState();
    _loadReportCard();
  }

  void _loadReportCard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final academicProvider = context.read<AcademicProvider>();

      if (authProvider.currentUser != null) {
        academicProvider.fetchReportCard(
          authProvider.currentUser!.id,
          _selectedYear,
          _selectedTerm,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Card'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AcademicProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingReportCard) {
            return const LoadingIndicator();
          }

          if (provider.reportCardError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    provider.reportCardError!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadReportCard,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.reportCard == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('No report card available for selected period'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadReportCard,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          final reportCard = provider.reportCard!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedYear,
                                decoration: const InputDecoration(
                                  labelText: 'Academic Year',
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  '2024-2025',
                                  '2023-2024',
                                  '2022-2023',
                                ].map((year) {
                                  return DropdownMenuItem(
                                    value: year,
                                    child: Text(year),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _selectedYear = value);
                                    _loadReportCard();
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedTerm,
                                decoration: const InputDecoration(
                                  labelText: 'Term',
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  'Term 1',
                                  'Term 2',
                                  'Term 3',
                                  'Final',
                                ].map((term) {
                                  return DropdownMenuItem(
                                    value: term,
                                    child: Text(term),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _selectedTerm = value);
                                    _loadReportCard();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Overall Performance Card
                Card(
                  color: AppColors.primary,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'Overall Performance',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildOverallStat(
                              'Grade',
                              _getProperty(reportCard, 'overallGrade') ?? 'N/A',
                              Icons.grade,
                            ),
                            _buildOverallStat(
                              'Percentage',
                              '${_getNumericProperty(reportCard, 'overallPercentage', 0.0).toStringAsFixed(1)}%',
                              Icons.percent,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Subject Grades
                const Text(
                  'Subject-wise Performance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ..._getListProperty(reportCard, 'subjects').map((subject) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _getProperty(subject, 'subjectName') ??
                                      _getProperty(subject, 'subject') ??
                                      'Unknown Subject',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _getProperty(subject, 'grade') ?? 'N/A',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSubjectDetail(
                                'Marks',
                                '${_getNumericProperty(subject, 'marks', 0)}/${_getNumericProperty(subject, 'maxMarks', 0)}',
                              ),
                              _buildSubjectDetail(
                                'Percentage',
                                '${_getNumericProperty(subject, 'percentage', 0.0).toStringAsFixed(1)}%',
                              ),
                            ],
                          ),
                          if ((_getProperty(subject, 'remarks') ?? '').isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Remarks: ${_getProperty(subject, 'remarks')}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),

                // Teacher's Remarks
                if ((_getProperty(reportCard, 'remarks') ?? '').isNotEmpty) ...[
                  const Text(
                    "Teacher's Remarks",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _getProperty(reportCard, 'remarks') ?? '',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],

                // Additional Info
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Additional Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('Academic Year', _getProperty(reportCard, 'academicYear') ?? 'N/A'),
                        _buildInfoRow('Term', _getProperty(reportCard, 'term') ?? 'N/A'),
                        _buildInfoRow('Class', _getProperty(reportCard, 'className') ?? _getProperty(reportCard, 'class') ?? 'N/A'),
                        _buildInfoRow('Section', _getProperty(reportCard, 'section') ?? 'N/A'),
                        if ((_getProperty(reportCard, 'classTeacher') ?? '').isNotEmpty)
                          _buildInfoRow('Class Teacher', _getProperty(reportCard, 'classTeacher') ?? ''),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String? _getProperty(dynamic obj, String property) {
    try {
      if (obj is Map) {
        return obj[property]?.toString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  num _getNumericProperty(dynamic obj, String property, num defaultValue) {
    try {
      if (obj is Map) {
        final value = obj[property];
        if (value is num) return value;
        if (value is String) return num.tryParse(value) ?? defaultValue;
      }
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  List<dynamic> _getListProperty(dynamic obj, String property) {
    try {
      if (obj is Map) {
        final value = obj[property];
        if (value is List) return value;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Widget _buildOverallStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}