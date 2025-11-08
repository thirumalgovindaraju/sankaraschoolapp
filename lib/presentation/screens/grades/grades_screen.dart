// lib/presentation/screens/grades/grades_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/academic_provider.dart';
import '../../providers/auth_provider.dart';

class GradesScreen extends StatefulWidget {
  final String? studentId;

  const GradesScreen({super.key, this.studentId});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  String _selectedTerm = 'Term 1';
  final List<String> _terms = ['Term 1', 'Term 2', 'Term 3', 'Final'];

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    final authProvider = context.read<AuthProvider>();
    // Use the passed studentId or get from auth provider's currentUser
    final studentId = widget.studentId ?? authProvider.currentUser?.id ?? '';

    if (studentId.isNotEmpty) {
      await context.read<AcademicProvider>().fetchGrades(
        studentId,
        term: _selectedTerm,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grades'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGrades,
          ),
        ],
      ),
      body: Column(
        children: [
          // Term selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Row(
              children: [
                const Text(
                  'Select Term: ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedTerm,
                    isExpanded: true,
                    items: _terms.map((term) {
                      return DropdownMenuItem(
                        value: term,
                        child: Text(term),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedTerm = value);
                        _loadGrades();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Grades list
          Expanded(
            child: Consumer<AcademicProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingGrades) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.gradesError != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          provider.gradesError!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadGrades,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.grades.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.grade, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No grades available for this term',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                // Calculate overall statistics
                double totalMarks = 0;
                double totalMaxMarks = 0;
                for (var grade in provider.grades) {
                  totalMarks += grade.marks;
                  totalMaxMarks += grade.maxMarks;
                }
                final overallPercentage = totalMaxMarks > 0
                    ? (totalMarks / totalMaxMarks * 100)
                    : 0.0;

                return Column(
                  children: [
                    // Overall summary card
                    Card(
                      margin: const EdgeInsets.all(16),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              'Overall Performance',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  'Total Marks',
                                  '${totalMarks.toStringAsFixed(1)}/${totalMaxMarks.toStringAsFixed(1)}',
                                  Icons.format_list_numbered,
                                ),
                                _buildStatItem(
                                  'Percentage',
                                  '${overallPercentage.toStringAsFixed(1)}%',
                                  Icons.percent,
                                ),
                                _buildStatItem(
                                  'Subjects',
                                  '${provider.grades.length}',
                                  Icons.book,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Grades list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: provider.grades.length,
                        itemBuilder: (context, index) {
                          final grade = provider.grades[index];
                          final percentage = grade.maxMarks > 0
                              ? (grade.marks / grade.maxMarks * 100)
                              : 0.0;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getGradeColor(percentage),
                                child: Text(
                                  grade.grade,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                grade.subjectName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('Exam: ${grade.examType}'),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: percentage / 100,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _getGradeColor(percentage),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${grade.marks.toStringAsFixed(1)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '/ ${grade.maxMarks.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    '${percentage.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _getGradeColor(percentage),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getGradeColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 80) return Colors.lightGreen;
    if (percentage >= 70) return Colors.orange;
    if (percentage >= 60) return Colors.deepOrange;
    return Colors.red;
  }
}