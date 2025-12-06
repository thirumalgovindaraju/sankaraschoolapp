// lib/presentation/screens/faculty/faculty_screen.dart

import 'package:flutter/material.dart';

class FacultyScreen extends StatelessWidget {
  const FacultyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Faculty'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.7),
                  ],
                ),
              ),
              child: const Column(
                children: [
                  Icon(Icons.people, size: 70, color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Meet Our Teachers',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Experienced & Dedicated Educators',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Stats Section
            _buildStatsSection(context),

            // Faculty by Department
            _buildFacultySection(context, 'Principal & Leadership',
                _getPrincipalTeam()),
            _buildFacultySection(
                context, 'Primary Teachers', _getPrimaryTeachers()),
            _buildFacultySection(
                context, 'Secondary Teachers', _getSecondaryTeachers()),
            _buildFacultySection(
                context, 'Subject Specialists', _getSpecialists()),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      color: Colors.blue.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('80+', 'Teachers', Icons.people),
          _buildStatItem('15+', 'Avg Experience', Icons.work),
          _buildStatItem('95%', 'Qualified', Icons.school),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildFacultySection(
      BuildContext context,
      String title,
      List<Map<String, String>> faculty,
      ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...faculty.map((member) => _buildFacultyCard(
            member['name']!,
            member['position']!,
            member['qualification']!,
            member['icon']!,
          )),
        ],
      ),
    );
  }

  Widget _buildFacultyCard(
      String name,
      String position,
      String qualification,
      String iconName,
      ) {
    final icon = _getIconFromName(iconName);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(position),
            Text(
              qualification,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  IconData _getIconFromName(String name) {
    switch (name) {
      case 'school':
        return Icons.school;
      case 'person':
        return Icons.person;
      case 'science':
        return Icons.science;
      case 'calculate':
        return Icons.calculate;
      case 'language':
        return Icons.language;
      case 'sports':
        return Icons.sports;
      default:
        return Icons.person;
    }
  }

  List<Map<String, String>> _getPrincipalTeam() {
    return [
      {
        'name': 'Dr. Rajesh Kumar',
        'position': 'Principal',
        'qualification': 'Ph.D. in Education, 25 years exp.',
        'icon': 'school',
      },
      {
        'name': 'Mrs. Priya Sharma',
        'position': 'Vice Principal',
        'qualification': 'M.Ed., 20 years exp.',
        'icon': 'person',
      },
    ];
  }

  List<Map<String, String>> _getPrimaryTeachers() {
    return [
      {
        'name': 'Ms. Anjali Verma',
        'position': 'Primary Coordinator',
        'qualification': 'B.Ed., 15 years exp.',
        'icon': 'person',
      },
      {
        'name': 'Mr. Suresh Patel',
        'position': 'Class Teacher - Grade 3',
        'qualification': 'B.Ed., 10 years exp.',
        'icon': 'person',
      },
    ];
  }

  List<Map<String, String>> _getSecondaryTeachers() {
    return [
      {
        'name': 'Dr. Meena Iyer',
        'position': 'Secondary Coordinator',
        'qualification': 'Ph.D., 18 years exp.',
        'icon': 'person',
      },
      {
        'name': 'Mr. Arun Reddy',
        'position': 'Class Teacher - Grade 9',
        'qualification': 'M.Sc., B.Ed., 12 years exp.',
        'icon': 'person',
      },
    ];
  }

  List<Map<String, String>> _getSpecialists() {
    return [
      {
        'name': 'Dr. Kavita Singh',
        'position': 'Physics Teacher',
        'qualification': 'Ph.D. in Physics',
        'icon': 'science',
      },
      {
        'name': 'Mr. Ramesh Joshi',
        'position': 'Mathematics Teacher',
        'qualification': 'M.Sc. Mathematics',
        'icon': 'calculate',
      },
      {
        'name': 'Mrs. Sunita Desai',
        'position': 'English Teacher',
        'qualification': 'M.A. English',
        'icon': 'language',
      },
      {
        'name': 'Mr. Vikram Rao',
        'position': 'Sports Coach',
        'qualification': 'B.P.Ed., National Coach',
        'icon': 'sports',
      },
    ];
  }
}