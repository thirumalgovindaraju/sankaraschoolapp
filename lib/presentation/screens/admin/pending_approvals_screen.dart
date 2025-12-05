// lib/presentation/screens/admin/pending_approvals_screen.dart
// ✅ NEW FILE - Complete implementation

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/services/admin_service.dart';
import '../../../data/services/api_service.dart';
import '../../providers/auth_provider.dart';

class PendingApprovalsScreen extends StatefulWidget {
  const PendingApprovalsScreen({Key? key}) : super(key: key);

  @override
  State<PendingApprovalsScreen> createState() => _PendingApprovalsScreenState();
}

class _PendingApprovalsScreenState extends State<PendingApprovalsScreen> {
  final AdminService _adminService = AdminService(ApiService());
  List<Map<String, dynamic>> _pendingUsers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPendingApprovals();
  }

  Future<void> _loadPendingApprovals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final pendingUsers = await _adminService.getPendingApprovals();
      setState(() {
        _pendingUsers = pendingUsers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _approveUser(Map<String, dynamic> user) async {
    final authProvider = context.read<AuthProvider>();
    final adminId = authProvider.currentUser?.id ?? 'ADMIN';
    final adminName = authProvider.currentUser?.name ?? 'Administrator';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to approve this user?'),
            const SizedBox(height: 16),
            _buildUserInfoCard(user),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      final success = await _adminService.approveUser(
        userId: user['teacher_id'] ?? user['student_id'] ?? user['admin_id'],
        userType: user['user_type'] ?? 'student',
        approvedBy: adminName,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${user['name']} approved successfully'),
              backgroundColor: Colors.green,
            ),
          );
          await _loadPendingApprovals();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Failed to approve user'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _rejectUser(Map<String, dynamic> user) async {
    final authProvider = context.read<AuthProvider>();
    final adminName = authProvider.currentUser?.name ?? 'Administrator';
    String? rejectionReason;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to reject this user?'),
            const SizedBox(height: 16),
            _buildUserInfoCard(user),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Reason for rejection (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) => rejectionReason = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      final success = await _adminService.rejectUser(
        userId: user['teacher_id'] ?? user['student_id'] ?? user['admin_id'],
        userType: user['user_type'] ?? 'student',
        rejectedBy: adminName,
        reason: rejectionReason,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${user['name']} rejected'),
              backgroundColor: Colors.orange,
            ),
          );
          await _loadPendingApprovals();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Failed to reject user'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Widget _buildUserInfoCard(Map<String, dynamic> user) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getUserTypeIcon(user['user_type']),
                color: _getUserTypeColor(user['user_type']),
              ),
              const SizedBox(width: 8),
              Text(
                user['name'] ?? 'Unknown',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Email: ${user['email'] ?? 'N/A'}'),
          Text('Phone: ${user['phone'] ?? 'N/A'}'),
          Text(
            'Type: ${_getUserTypeLabel(user['user_type'])}',
            style: TextStyle(
              color: _getUserTypeColor(user['user_type']),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Approvals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingApprovals,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPendingApprovals,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : _pendingUsers.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.green.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No Pending Approvals',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'All registrations have been processed',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadPendingApprovals,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _pendingUsers.length,
          itemBuilder: (context, index) {
            final user = _pendingUsers[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getUserTypeColor(
                              user['user_type'],
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getUserTypeIcon(user['user_type']),
                            color: _getUserTypeColor(
                              user['user_type'],
                            ),
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['name'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getUserTypeColor(
                                    user['user_type'],
                                  ).withOpacity(0.1),
                                  borderRadius:
                                  BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _getUserTypeLabel(
                                    user['user_type'],
                                  ),
                                  style: TextStyle(
                                    color: _getUserTypeColor(
                                      user['user_type'],
                                    ),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.email,
                      'Email',
                      user['email'] ?? 'N/A',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.phone,
                      'Phone',
                      user['phone'] ?? 'N/A',
                    ),
                    if (user['user_type'] == 'teacher') ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.subject,
                        'Subject',
                        user['subject'] ?? 'N/A',
                      ),
                    ],
                    if (user['user_type'] == 'student') ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.class_,
                        'Class',
                        '${user['class'] ?? 'N/A'} - ${user['section'] ?? 'N/A'}',
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _rejectUser(user),
                            icon: const Icon(Icons.close),
                            label: const Text('Reject'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(
                                color: Colors.red,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _approveUser(user),
                            icon: const Icon(Icons.check),
                            label: const Text('Approve'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getUserTypeIcon(String? userType) {
    switch (userType) {
      case 'teacher':
        return Icons.school;
      case 'student':
        return Icons.person;
      case 'parent':
        return Icons.family_restroom;
      default:
        return Icons.person_outline;
    }
  }

  Color _getUserTypeColor(String? userType) {
    switch (userType) {
      case 'teacher':
        return Colors.green;
      case 'student':
        return Colors.blue;
      case 'parent':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getUserTypeLabel(String? userType) {
    switch (userType) {
      case 'teacher':
        return 'TEACHER';
      case 'student':
        return 'STUDENT';
      case 'parent':
        return 'PARENT';
      default:
        return 'UNKNOWN';
    }
  }
}