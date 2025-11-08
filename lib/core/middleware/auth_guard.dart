// lib/core/middleware/auth_guard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/user_model.dart';
import '../../presentation/providers/auth_provider.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  final List<UserRole>? allowedRoles;
  final String redirectRoute;

  const AuthGuard({
    Key? key,
    required this.child,
    this.allowedRoles,
    this.redirectRoute = '/login',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Check if user is authenticated
        if (!authProvider.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, redirectRoute);
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Check if user has required role
        if (allowedRoles != null && authProvider.currentUser != null) {
          if (!allowedRoles!.contains(authProvider.currentUser!.role)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showUnauthorizedDialog(context);
            });
            return const Scaffold(
              body: Center(
                child: Text('Unauthorized Access'),
              ),
            );
          }
        }

        return child;
      },
    );
  }

  void _showUnauthorizedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Unauthorized'),
        content: const Text(
          'You do not have permission to access this page.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/home',
                    (route) => false,
              );
            },
            child: const Text('Go to Home'),
          ),
        ],
      ),
    );
  }
}

// Example usage with AuthGuard:

class ProtectedScreen extends StatelessWidget {
  const ProtectedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      allowedRoles: [UserRole.admin, UserRole.teacher],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Protected Screen'),
        ),
        body: const Center(
          child: Text('This is a protected screen'),
        ),
      ),
    );
  }
}

// Placeholder dashboards (same as before)
class ParentDashboard extends StatelessWidget {
  const ParentDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      allowedRoles: [UserRole.parent],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Parent Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
          ],
        ),
        drawer: const AppDrawer(),
        body: const Center(child: Text('Welcome to Parent Portal')),
      ),
    );
  }
}

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      allowedRoles: [UserRole.student],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Student Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
          ],
        ),
        drawer: const AppDrawer(),
        body: const Center(child: Text('Welcome Student')),
      ),
    );
  }
}

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      allowedRoles: [UserRole.teacher],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Teacher Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
          ],
        ),
        drawer: const AppDrawer(),
        body: const Center(child: Text('Welcome Teacher')),
      ),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      allowedRoles: [UserRole.admin],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
          ],
        ),
        drawer: const AppDrawer(),
        body: const Center(child: Text('Welcome Admin')),
      ),
    );
  }
}

// App Drawer with role-based menu
class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(user?.name ?? 'Guest'),
                accountEmail: Text(user?.email ?? ''),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: user?.profileImage != null
                      ? NetworkImage(user!.profileImage!)
                      : null,
                  child: user?.profileImage == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () => Navigator.pushNamed(context, '/home'),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () => Navigator.pushNamed(context, '/profile'),
              ),
              const Divider(),
              // Add more menu items based on user role
              if (user?.role == UserRole.admin) ...[
                ListTile(
                  leading: const Icon(Icons.dashboard),
                  title: const Text('Admin Panel'),
                  onTap: () {},
                ),
              ],
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}