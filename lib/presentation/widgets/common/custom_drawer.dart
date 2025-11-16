// lib/presentation/widgets/common/custom_drawer.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLoggedIn = authProvider.isAuthenticated;
    final userRole = authProvider.currentUser?.role?.toString().toLowerCase();
    final user = authProvider.currentUser;

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.shade700,
              Colors.orange.shade500,
            ],
          ),
        ),
        child: Column(
          children: [
            // Enhanced School Info Header
            _buildSchoolInfoHeader(context, isLoggedIn, user),

            // Scrollable Menu Items
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(height: 20),

                    // User Profile Section (if logged in)
                    if (isLoggedIn) _buildUserProfile(context, user, userRole),
                    if (isLoggedIn) const Divider(height: 30),

                    // Public Menu Section
                    _buildSectionHeader('General'),
                    _buildMenuItem(
                      context,
                      icon: Icons.home,
                      title: 'Home',
                      route: '/home',
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.info,
                      title: 'About Us',
                      route: '/about',
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.school,
                      title: 'Academics',
                      route: '/curriculum',
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.location_city,
                      title: 'Campus & Facilities',
                      route: '/facilities',
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.how_to_reg,
                      title: 'Admissions',
                      route: '/admissions',
                    ),

                    const Divider(height: 30),

                    // School Information Section
                    _buildSectionHeader('School Info'),
                    _buildMenuItem(
                      context,
                      icon: Icons.event,
                      title: 'Events & Calendar',
                      route: '/events',
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.announcement,
                      title: 'Announcements',
                      route: '/announcements',
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.people,
                      title: 'Faculty',
                      route: '/faculty',
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.photo_library,
                      title: 'Gallery',
                      route: '/gallery',
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.article,
                      title: 'News',
                      route: '/news',
                    ),

                    // Academic Portal Section (only for logged-in users)
                    if (isLoggedIn &&
                        (userRole == 'student' ||
                            userRole == 'parent' ||
                            userRole == 'teacher' ||
                            userRole == 'admin')) ...[
                      const Divider(height: 30),
                      _buildSectionHeader('Academic Portal'),

                      // Dashboard
                      _buildMenuItem(
                        context,
                        icon: Icons.dashboard,
                        title: 'Dashboard',
                        route: _getDashboardRoute(userRole),
                      ),

                      // Academic Features
                      if (userRole == 'student' || userRole == 'parent' || userRole == 'teacher')
                        _buildMenuItem(
                          context,
                          icon: Icons.calendar_today,
                          title: 'Attendance',
                          route: '/attendance',
                        ),

                      if (userRole == 'student' || userRole == 'parent')
                        _buildMenuItem(
                          context,
                          icon: Icons.assessment,
                          title: 'Report Cards',
                          route: '/report-card',
                        ),

                      if (userRole == 'student' || userRole == 'parent')
                        _buildMenuItem(
                          context,
                          icon: Icons.event_busy,
                          title: 'Leave Request',
                          route: '/leave-request',
                        ),

                      if (userRole == 'teacher')
                        _buildMenuItem(
                          context,
                          icon: Icons.edit_calendar,
                          title: 'Mark Attendance',
                          route: '/teacher-attendance',
                        ),

                      // Admin Features
                      if (userRole == 'admin') ...[
                        _buildMenuItem(
                          context,
                          icon: Icons.people_alt,
                          title: 'Manage Students',
                          route: '/manage-students',
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.supervised_user_circle,
                          title: 'Manage Teachers',
                          route: '/manage-teachers',
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.admin_panel_settings,
                          title: 'Manage Users',
                          route: '/manage-users',
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.campaign,
                          title: 'Create Announcement',
                          route: '/create-announcement',
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.newspaper,
                          title: 'News Management',
                          route: '/news-management',
                        ),
                      ],

                      // Common for all logged-in users
                      _buildMenuItem(
                        context,
                        icon: Icons.notifications,
                        title: 'Notifications',
                        route: '/notifications',
                      ),
                    ],

                    const Divider(height: 30),

                    // Contact & Support Section
                    _buildSectionHeader('Support'),
                    _buildMenuItem(
                      context,
                      icon: Icons.contact_mail,
                      title: 'Contact Us',
                      route: '/contact',
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.feedback,
                      title: 'Feedback',
                      route: '/feedback',
                    ),

                    if (isLoggedIn)
                      _buildMenuItem(
                        context,
                        icon: Icons.settings,
                        title: 'Settings',
                        route: '/settings',
                      ),

                    const Divider(height: 30),

                    // School Details Card
                    _buildSchoolDetailsCard(context),

                    const Divider(height: 30),

                    // Login/Logout Section
                    if (!isLoggedIn)
                      _buildMenuItem(
                        context,
                        icon: Icons.login,
                        title: 'Login',
                        route: '/login',
                        color: Colors.green,
                      )
                    else
                      ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: Colors.red,
                          size: 24,
                        ),
                        title: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Colors.grey.shade400,
                        ),
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              title: Row(
                                children: [
                                  Icon(Icons.logout, color: Colors.red.shade700),
                                  const SizedBox(width: 10),
                                  const Text('Confirm Logout'),
                                ],
                              ),
                              content: const Text(
                                'Are you sure you want to logout?',
                                style: TextStyle(fontSize: 15),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.grey.shade700),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Logout'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await authProvider.logout();
                            if (context.mounted) {
                              Navigator.pop(context);
                              Navigator.pushReplacementNamed(context, '/home');
                            }
                          }
                        },
                      ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDashboardRoute(String? role) {
    switch (role?.toLowerCase()) {
      case 'student':
        return '/student-dashboard';
      case 'parent':
        return '/parent-dashboard';
      case 'teacher':
        return '/teacher-dashboard';
      case 'admin':
        return '/admin-dashboard';
      default:
        return '/home';
    }
  }

  Widget _buildSchoolInfoHeader(BuildContext context, bool isLoggedIn, dynamic user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 25),
      child: Column(
        children: [
          // Close Button
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
            ),
          ),

          // School Logo
          Hero(
            tag: 'school_logo',
            child: Container(
              width: 90,
              height: 90,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.school_rounded,
                      size: 50,
                      color: Colors.orange.shade700,
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // School Name
          const Text(
            'Sri Sankara Global Academy',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 6),

          // Trust Info
          Text(
            'A unit of Hindu Seva Samajam Trust',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 15),

          // Partner Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPartnerBadge('Edexcel\n95990'),
              const SizedBox(width: 12),
              _buildPartnerBadge('Pearson'),
              const SizedBox(width: 12),
              _buildPartnerBadge('Kidzee'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 9,
          color: Colors.white,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, dynamic user, String? userRole) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade50,
            Colors.orange.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.orange.shade700,
            child: Text(
              user?.name?.substring(0, 1).toUpperCase() ?? 'U',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'User',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getRoleColor(userRole),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getRoleDisplayName(userRole),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
            icon: Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return Colors.red.shade700;
      case 'teacher':
        return Colors.blue.shade700;
      case 'student':
        return Colors.green.shade700;
      case 'parent':
        return Colors.purple.shade700;
      default:
        return Colors.orange.shade700;
    }
  }

  String _getRoleDisplayName(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return 'ADMINISTRATOR';
      case 'teacher':
        return 'TEACHER';
      case 'student':
        return 'STUDENT';
      case 'parent':
        return 'PARENT';
      default:
        return 'USER';
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String route,
        Color? color,
      }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? Colors.orange.shade700,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: color ?? Colors.grey.shade800,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey.shade400,
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }

  Widget _buildSchoolDetailsCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade50,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school, color: Colors.orange.shade700, size: 28),
              const SizedBox(width: 10),
              Text(
                'School Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildDetailRow(Icons.location_on, 'Kozhikode, Kerala, India'),
          _buildDetailRow(Icons.phone, '+91-495-XXX-XXXX'),
          _buildDetailRow(Icons.email, 'admin@srisankaraglobal.com'),
          _buildDetailRow(Icons.web, 'www.srisankaraacademy.edu'),
          const SizedBox(height: 15),
          Divider(color: Colors.orange.shade200),
          const SizedBox(height: 15),
          _buildAccreditationRow('Edexcel Centre', '95990'),
          _buildAccreditationRow('Pearson', 'Partner School'),
          _buildAccreditationRow('Kidzee', 'Preschool Program'),
          const SizedBox(height: 15),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/about');
              },
              icon: const Icon(Icons.info_outline, size: 20),
              label: const Text('Learn More About Us'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.orange.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccreditationRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.verified, size: 16, color: Colors.orange.shade700),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}