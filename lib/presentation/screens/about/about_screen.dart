// lib\presentation\screens\about\about_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/common/custom_drawer.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        elevation: 0,
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
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
                  Icon(
                    Icons.school,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sri Sankara Global School',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Nurturing Excellence Since 2005',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Vision Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, 'Our Vision', Icons.visibility),
                  const SizedBox(height: 12),
                  _buildCard(
                    context,
                    'To be a center of educational excellence that empowers students to become responsible global citizens and lifelong learners, equipped with knowledge, skills, and values to succeed in an ever-changing world.',
                  ),
                  const SizedBox(height: 32),

                  // Mission Section
                  _buildSectionTitle(context, 'Our Mission', Icons.flag),
                  const SizedBox(height: 12),
                  _buildCard(
                    context,
                    '• Provide quality education based on CBSE curriculum\n'
                        '• Foster holistic development of each student\n'
                        '• Create a safe, inclusive, and stimulating learning environment\n'
                        '• Encourage innovation, creativity, and critical thinking\n'
                        '• Build strong partnerships with parents and community\n'
                        '• Develop ethical values and social responsibility',
                  ),
                  const SizedBox(height: 32),

                  // Core Values
                  _buildSectionTitle(context, 'Core Values', Icons.favorite),
                  const SizedBox(height: 16),
                  _buildValuesList(context),
                  const SizedBox(height: 32),

                  // Statistics
                  _buildSectionTitle(context, 'At a Glance', Icons.analytics),
                  const SizedBox(height: 16),
                  _buildStatsGrid(context),
                  const SizedBox(height: 32),

                  // Why Choose Us
                  _buildSectionTitle(context, 'Why Choose Us', Icons.star),
                  const SizedBox(height: 16),
                  _buildWhyChooseUs(context),
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

  Widget _buildCard(BuildContext context, String content) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
          ),
        ),
      ),
    );
  }

  Widget _buildValuesList(BuildContext context) {
    final values = [
      {'icon': Icons.wb_incandescent, 'title': 'Excellence', 'desc': 'Striving for the highest standards in all endeavors'},
      {'icon': Icons.handshake, 'title': 'Integrity', 'desc': 'Upholding honesty and strong moral principles'},
      {'icon': Icons.volunteer_activism, 'title': 'Compassion', 'desc': 'Showing empathy and care for others'},
      {'icon': Icons.emoji_events, 'title': 'Innovation', 'desc': 'Encouraging creativity and new ideas'},
      {'icon': Icons.groups, 'title': 'Collaboration', 'desc': 'Working together towards common goals'},
      {'icon': Icons.local_library, 'title': 'Learning', 'desc': 'Fostering a lifelong love for knowledge'},
    ];

    return Column(
      children: values.map((value) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(
                value['icon'] as IconData,
                color: Theme.of(context).primaryColor,
              ),
            ),
            title: Text(
              value['title'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(value['desc'] as String),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final stats = [
      {'label': 'Students', 'value': '1200+', 'icon': Icons.people},
      {'label': 'Teachers', 'value': '80+', 'icon': Icons.school},
      {'label': 'Staff', 'value': '50+', 'icon': Icons.work},
      {'label': 'Years', 'value': '18+', 'icon': Icons.calendar_today},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  stat['icon'] as IconData,
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 8),
                Text(
                  stat['value'] as String,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat['label'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWhyChooseUs(BuildContext context) {
    final reasons = [
      'CBSE affiliated institution with proven track record',
      'Experienced and dedicated faculty members',
      'State-of-the-art infrastructure and facilities',
      'Focus on holistic development',
      'Strong emphasis on sports and extra-curricular activities',
      'Safe and secure campus environment',
      'Regular parent-teacher interaction',
      'Technology-enabled learning',
    ];

    return Column(
      children: reasons.map((reason) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    reason,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}