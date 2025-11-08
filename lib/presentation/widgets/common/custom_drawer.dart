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

    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Drawer Header
            _buildDrawerHeader(),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
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
                    title: 'Campus',
                    route: '/infrastructure',
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.how_to_reg,
                    title: 'Admission',
                    route: '/admissions',
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.work,
                    title: 'Careers',
                    route: '/careers',
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.event,
                    title: 'Events',
                    route: '/events',
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.photo_library,
                    title: 'Gallery',
                    route: '/gallery',
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.feedback,
                    title: 'Feedback',
                    route: '/feedback',
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.contact_mail,
                    title: 'Contact Us',
                    route: '/contact',
                  ),

                  // Academic Section (only for logged-in students/parents/teachers)
                  if (isLoggedIn &&
                      (userRole == 'student' ||
                          userRole == 'parent' ||
                          userRole == 'teacher')) ...[
                    const Divider(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'ACADEMIC PORTAL',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.calendar_today,
                      title: 'Attendance',
                      route: '/attendance',
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.assessment,
                      title: 'Report Cards',
                      route: '/report-cards',
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.book,
                      title: 'Curriculum',
                      route: '/curriculum',
                    ),
                    if (userRole == 'student' || userRole == 'parent')
                      _buildMenuItem(
                        context,
                        icon: Icons.event_busy,
                        title: 'Leave Request',
                        route: '/leave-request',
                      ),
                  ],

                  const Divider(height: 32),

                  // Login/Dashboard
                  if (!isLoggedIn)
                    _buildMenuItem(
                      context,
                      icon: Icons.login,
                      title: 'Parent/Student Login',
                      route: '/login',
                    )
                  else ...[
                    _buildMenuItem(
                      context,
                      icon: Icons.dashboard,
                      title: 'Dashboard',
                      route: _getDashboardRoute(authProvider.currentUser?.role),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.person,
                      title: 'Profile',
                      route: '/profile',
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.logout,
                        color: Colors.red,
                        size: 24,
                      ),
                      title: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        await authProvider.logout();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),

            // Footer
            _buildDrawerFooter(),
          ],
        ),
      ),
    );
  }

  String _getDashboardRoute(dynamic role) {
    final roleStr = role?.toString().toLowerCase();
    switch (roleStr) {
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

  Widget _buildDrawerHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.school,
              color: AppColors.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),

          // School Name
          const Text(
            AppStrings.appName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Empowering Minds, Shaping Futures',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String route,
      }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.textSecondary,
      ),
      onTap: () {
        Navigator.pop(context); // Close drawer
        Navigator.pushNamed(context, route);
      },
    );
  }

  Widget _buildDrawerFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: const Column(
        children: [
          // Contact Info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Text(
                '+91-044-22475862',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Text(
                'admin@srisankaraglobal.com',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}