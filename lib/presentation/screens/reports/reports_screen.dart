// lib/presentation/screens/reports/reports_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final List<Map<String, dynamic>> _reportTypes = [
    {
      'title': 'Attendance Report',
      'description': 'View attendance statistics and trends',
      'icon': Icons.check_circle,
      'color': Colors.blue,
      'route': '/attendance-report',
    },
    {
      'title': 'Academic Performance',
      'description': 'Student grades and performance analysis',
      'icon': Icons.school,
      'color': Colors.purple,
      'route': '/academic-report',
    },
    {
      'title': 'Fee Collection',
      'description': 'Financial reports and fee status',
      'icon': Icons.payment,
      'color': Colors.green,
      'route': '/fee-report',
    },
    {
      'title': 'Teacher Performance',
      'description': 'Teaching staff evaluation reports',
      'icon': Icons.person,
      'color': Colors.orange,
      'route': '/teacher-report',
    },
    {
      'title': 'Class-wise Analysis',
      'description': 'Detailed class performance metrics',
      'icon': Icons.class_,
      'color': Colors.teal,
      'route': '/class-report',
    },
    {
      'title': 'Exam Results',
      'description': 'Examination results and analytics',
      'icon': Icons.quiz,
      'color': Colors.red,
      'route': '/exam-report',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(child: _buildSummaryCard('Total Reports', '142', Icons.assessment, Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildSummaryCard('This Month', '28', Icons.calendar_today, Colors.green)),
              ],
            ),
            const SizedBox(height: 24),

            // Report Types
            Text(
              'Available Reports',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _reportTypes.length,
              itemBuilder: (context, index) {
                return _buildReportCard(_reportTypes[index]);
              },
            ),
            const SizedBox(height: 24),

            // Recent Reports
            Text(
              'Recent Reports',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildRecentReport('Monthly Attendance - October 2024', DateTime.now().subtract(const Duration(days: 2))),
            _buildRecentReport('Academic Performance Q2', DateTime.now().subtract(const Duration(days: 5))),
            _buildRecentReport('Fee Collection Report', DateTime.now().subtract(const Duration(days: 7))),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${report['title']} - Coming Soon')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: report['color'].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(report['icon'], color: report['color'], size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                report['title'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                report['description'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentReport(String title, DateTime date) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.description, color: Colors.blue, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          DateFormat('MMM dd, yyyy').format(date),
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.download, size: 20),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Downloading $title...')),
            );
          },
        ),
      ),
    );
  }
}