// lib/presentation/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../../data/models/user_model.dart';
import '../debug/debug_users_screen.dart';
import 'package:flutter/foundation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  UserRole _selectedRole = UserRole.admin; // Changed default to admin

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    // Debug log before login
    debugPrint('=== LOGIN ATTEMPT ===');
    debugPrint('Email: ${_emailController.text.trim()}');
    debugPrint('Selected Role: ${_selectedRole.name}');

    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole,
    );

    if (!mounted) return;

    // Debug log after login
    debugPrint('=== LOGIN RESULT ===');
    debugPrint('Success: $success');
    debugPrint('Current User: ${authProvider.currentUser?.name}');
    debugPrint('Current User Role: ${authProvider.currentUser?.role}');
    debugPrint('Current User Role Name: ${authProvider.currentUser?.role.name}');

    if (success && authProvider.currentUser != null) {
      final userRole = authProvider.currentUser!.role;
      String targetRoute;

      // Determine route based on role
      switch (userRole) {
        case UserRole.admin:
          targetRoute = '/admin-dashboard';
          debugPrint('✅ Navigating to: $targetRoute');
          break;
        case UserRole.teacher:
          targetRoute = '/teacher-dashboard';
          debugPrint('✅ Navigating to: $targetRoute');
          break;
        case UserRole.student:
          targetRoute = '/student-dashboard';
          debugPrint('✅ Navigating to: $targetRoute');
          break;
        case UserRole.parent:
          targetRoute = '/parent-dashboard';
          debugPrint('✅ Navigating to: $targetRoute');
          break;
        default:
          debugPrint('❌ Unknown role: ${userRole.name}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unknown user role: ${userRole.name}'),
              backgroundColor: Colors.red,
            ),
          );
          return;
      }

      // Navigate to the determined route
      try {
        await Navigator.pushReplacementNamed(context, targetRoute);
        debugPrint('✅ Navigation successful to $targetRoute');
      } catch (e) {
        debugPrint('❌ Navigation error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigation error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      debugPrint('❌ Login failed: ${authProvider.errorMessage}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // School Logo
                  Image.asset(
                    'assets/images/school_logo.png',
                    height: 120,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.school,
                        size: 120,
                        color: Colors.blue,
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Sri Sankara Global School',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Role Selection
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Role',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: UserRole.values.map((role) {
                              final isSelected = _selectedRole == role;
                              return FilterChip(
                                label: Text(_getRoleLabel(role)),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedRole = role;
                                    });
                                    debugPrint('Selected role: ${role.name}');
                                  }
                                },
                                selectedColor: Theme.of(context).colorScheme.primary,
                                checkmarkColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgot-password');
                      },
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (kDebugMode) // Only show in debug mode
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/debug-users');
                        },
                        icon: const Icon(Icons.bug_report, size: 18),
                        label: const Text('🔧 Debug Users'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.purple,
                        ),
                      ),
                    ),

                  // Login Button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          'Login',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text('Register'),
                      ),
                    ],
                  ),

                  // Test Credentials Hint (Debug Mode Only)
                  if (kDebugMode)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Test Credentials',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Admin: admin@school.com / password123\n'
                                'Teacher: teacher@school.com / password123\n'
                                'Student: student@school.com / password123\n'
                                'Parent: parent@school.com / password123',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue.shade900,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.parent:
        return 'Parent';
      case UserRole.student:
        return 'Student';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.admin:
        return 'Admin';
    }
  }
}