import 'package:flutter/material.dart';

// lib/presentation/screens/curriculum/curriculum_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/common/custom_drawer.dart';

class CurriculumScreen extends StatelessWidget {
  const CurriculumScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Curriculum'),
        elevation: 0,
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.7),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(
                    Icons.menu_book,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'CBSE Curriculum',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Comprehensive Academic Programs',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CBSE Affiliation Info
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(
                            Icons.verified,
                            size: 48,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'CBSE Affiliated',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Affiliation No: 1234567',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const Text(
                                  'Classes: Pre-Primary to XII',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Grade Levels
                  _buildSectionTitle(context, 'Academic Programs', Icons.school),
                  const SizedBox(height: 16),
                  _buildGradeLevels(context),
                  const SizedBox(height: 32),

                  // Subjects Offered
                  _buildSectionTitle(context, 'Subjects Offered', Icons.book),
                  const SizedBox(height: 16),
                  _buildSubjectsGrid(context),
                  const SizedBox(height: 32),

                  // Special Programs
                  _buildSectionTitle(context, 'Special Programs', Icons.star),
                  const SizedBox(height: 16),
                  _buildSpecialPrograms(context),
                  const SizedBox(height: 32),

                  // Teaching Methodology
                  _buildSectionTitle(context, 'Teaching Methodology', Icons.psychology),
                  const SizedBox(height: 16),
                  _buildMethodology(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 28,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildGradeLevels(BuildContext context) {
    final grades = [
      {'name': 'Pre-Primary', 'classes': 'Nursery, LKG, UKG', 'icon': Icons.child_care},
      {'name': 'Primary', 'classes': 'Classes I - V', 'icon': Icons.school},
      {'name': 'Middle School', 'classes': 'Classes VI - VIII', 'icon': Icons.menu_book},
      {'name': 'Secondary', 'classes': 'Classes IX - X', 'icon': Icons.school},
      {'name': 'Senior Secondary', 'classes': 'Classes XI - XII', 'icon': Icons.workspace_premium},
    ];

    return Column(
      children: grades.map((grade) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(
                grade['icon'] as IconData,
                color: Theme.of(context).primaryColor,
                size: 28,
              ),
            ),
            title: Text(
              grade['name'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Text(
              grade['classes'] as String,
              style: const TextStyle(fontSize: 14),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubjectsGrid(BuildContext context) {
    final subjects = [
      {'name': 'English', 'icon': Icons.abc},
      {'name': 'Mathematics', 'icon': Icons.calculate},
      {'name': 'Science', 'icon': Icons.science},
      {'name': 'Social Studies', 'icon': Icons.public},
      {'name': 'Hindi', 'icon': Icons.language},
      {'name': 'Computer Science', 'icon': Icons.computer},
      {'name': 'Physical Education', 'icon': Icons.sports},
      {'name': 'Arts & Crafts', 'icon': Icons.palette},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  subject['icon'] as IconData,
                  size: 36,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 12),
                Text(
                  subject['name'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpecialPrograms(BuildContext context) {
    final programs = [
      {'title': 'Skill Development', 'desc': 'Focus on 21st century skills and practical learning'},
      {'title': 'Language Labs', 'desc': 'Advanced language learning with modern tools'},
      {'title': 'STEM Education', 'desc': 'Science, Technology, Engineering, and Mathematics'},
      {'title': 'Value Education', 'desc': 'Character building and moral development'},
      {'title': 'Sports Training', 'desc': 'Professional coaching in various sports'},
      {'title': 'Arts & Music', 'desc': 'Classical and contemporary arts education'},
    ];

    return Column(
      children: programs.map((program) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.star,
                color: Theme.of(context).primaryColor,
              ),
            ),
            title: Text(
              program['title'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(program['desc'] as String),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMethodology(BuildContext context) {
    final methods = [
      'Activity-based and experiential learning',
      'Student-centered interactive sessions',
      'Project-based collaborative work',
      'Technology-integrated classrooms',
      'Regular assessments and feedback',
      'Personalized attention to each student',
      'Practical application of concepts',
      'Critical thinking and problem-solving focus',
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: methods.map((method) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      method,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
