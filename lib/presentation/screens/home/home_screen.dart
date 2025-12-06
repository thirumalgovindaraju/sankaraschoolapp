// lib/presentation/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isAuthenticated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sri Sankara Global School'),
        actions: [
          if (!isLoggedIn)
            TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              icon: const Icon(Icons.login, color: Colors.white),
              label: const Text('Login', style: TextStyle(color: Colors.white)),
            ),
          if (isLoggedIn)
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
            ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Banner
            _buildHeroBanner(context),

            const SizedBox(height: 24),

            // Quick Links Grid
            _buildQuickLinksSection(context),

            const SizedBox(height: 24),

            // About Section
            _buildAboutSection(context),

            const SizedBox(height: 24),

            // News/Updates Section
            _buildNewsSection(context),

            const SizedBox(height: 24),

            // Contact Footer
            _buildContactFooter(context),
          ],
        ),
      ),
      floatingActionButton: isLoggedIn
          ? FloatingActionButton(
        onPressed: () {
          final role = authProvider.currentUser?.role ?? 'student';
          Navigator.pushNamed(context, '/$role-dashboard');
        },
        child: const Icon(Icons.dashboard),
      )
          : null,
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school,
            size: 80,
            color: Colors.white.withOpacity(0.9),
          ),
          const SizedBox(height: 16),
          const Text(
            'Welcome to',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white70,
              fontWeight: FontWeight.w300,
            ),
          ),
          const Text(
            'Sri Sankara Global School',
            style: TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Excellence in Education',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLinksSection(BuildContext context) {
    final quickLinks = [
      {'icon': Icons.info_outline, 'title': 'About Us', 'route': '/about'},
      {'icon': Icons.book, 'title': 'Curriculum', 'route': '/curriculum'},
      {'icon': Icons.person_add, 'title': 'Admissions', 'route': '/admissions'},
      {'icon': Icons.apartment, 'title': 'Facilities', 'route': '/facilities'},
      {'icon': Icons.people, 'title': 'Faculty', 'route': '/faculty'},
      {'icon': Icons.photo_library, 'title': 'Gallery', 'route': '/gallery'},
      {'icon': Icons.event, 'title': 'Events', 'route': '/events'},
      {'icon': Icons.article, 'title': 'News', 'route': '/news'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Links',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemCount: quickLinks.length,
            itemBuilder: (context, index) {
              final link = quickLinks[index];
              return _buildQuickLinkCard(
                context,
                link['icon'] as IconData,
                link['title'] as String,
                link['route'] as String,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLinkCard(
      BuildContext context,
      IconData icon,
      String title,
      String route,
      ) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 36,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.stars, size: 48, color: Colors.blue),
          const SizedBox(height: 16),
          const Text(
            'About Our School',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Sri Sankara Global School is committed to providing quality education '
                'that nurtures young minds and builds character. With state-of-the-art '
                'facilities and experienced faculty, we prepare students for a bright future.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/about'),
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Learn More'),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Latest News',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/news'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildNewsCard(
            'Annual Day Celebration',
            'Join us for our grand annual day celebration...',
            Icons.celebration,
          ),
          const SizedBox(height: 12),
          _buildNewsCard(
            'New Academic Session',
            'Admissions open for the new academic year...',
            Icons.school,
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(String title, String description, IconData icon) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Widget _buildContactFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: Colors.grey.shade200,
      child: Column(
        children: [
          const Text(
            'Get In Touch',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone, size: 20),
              const SizedBox(width: 8),
              const Text('+91 1234567890'),
              const SizedBox(width: 24),
              const Icon(Icons.email, size: 20),
              const SizedBox(width: 8),
              const Text('info@srisankara.edu'),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/contact'),
            icon: const Icon(Icons.contact_mail),
            label: const Text('Contact Us'),
          ),
        ],
      ),
    );
  }
}
