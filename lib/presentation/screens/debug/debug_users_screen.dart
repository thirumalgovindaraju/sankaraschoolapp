// lib/presentation/screens/debug/debug_users_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/services/test_data_service.dart';
import '../../../data/models/user_model.dart';

class DebugUsersScreen extends StatefulWidget {
  const DebugUsersScreen({Key? key}) : super(key: key);

  @override
  State<DebugUsersScreen> createState() => _DebugUsersScreenState();
}

class _DebugUsersScreenState extends State<DebugUsersScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _testUsers = [];

  @override
  void initState() {
    super.initState();
    _loadTestUsers();
  }

  Future<void> _loadTestUsers() async {
    setState(() => _isLoading = true);

    await TestDataService.instance.loadTestData();

    // Get test users
    _testUsers = [
      {
        'email': 'admin@school.com',
        'password': 'password123',
        'role': 'Admin',
        'roleEnum': UserRole.admin,
        'name': 'Administrator',
        'color': Colors.red,
      },
      {
        'email': 'teacher@school.com',
        'password': 'password123',
        'role': 'Teacher',
        'roleEnum': UserRole.teacher,
        'name': 'Teacher User',
        'color': Colors.green,
      },
      {
        'email': 'student@school.com',
        'password': 'password123',
        'role': 'Student',
        'roleEnum': UserRole.student,
        'name': 'Student User',
        'color': Colors.blue,
      },
      {
        'email': 'parent@school.com',
        'password': 'password123',
        'role': 'Parent',
        'roleEnum': UserRole.parent,
        'name': 'Parent User',
        'color': Colors.purple,
      },
    ];

    setState(() => _isLoading = false);
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Users'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTestUsers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info Card
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Test User Credentials',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'These are test accounts for development. '
                        'Tap any credential to copy it.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // User Cards
          ..._testUsers.map((user) => _buildUserCard(user)).toList(),

          const SizedBox(height: 16),

          // Navigation Info
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.route, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Expected Navigation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildRouteInfo('Admin', '/admin-dashboard', Colors.red),
                  _buildRouteInfo('Teacher', '/teacher-dashboard', Colors.green),
                  _buildRouteInfo('Student', '/student-dashboard', Colors.blue),
                  _buildRouteInfo('Parent', '/parent-dashboard', Colors.purple),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Back to Login Button
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Login'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final color = user['color'] as Color;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color,
                    child: Text(
                      user['role'].toString()[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['role'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        Text(
                          user['name'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user['roleEnum'].toString().split('.').last.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Credentials
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCredentialRow(
                    'Email',
                    user['email'],
                    Icons.email,
                  ),
                  const SizedBox(height: 8),
                  _buildCredentialRow(
                    'Password',
                    user['password'],
                    Icons.lock,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCredentialRow(String label, String value, IconData icon) {
    return InkWell(
      onTap: () => _copyToClipboard(value, label),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.content_copy, size: 16, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteInfo(String role, String route, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.grey[800], fontSize: 13),
                children: [
                  TextSpan(
                    text: '$role: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: route,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}