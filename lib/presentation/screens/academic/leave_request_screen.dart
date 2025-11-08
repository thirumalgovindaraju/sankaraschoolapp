
// lib/presentation/screens/academic/leave_request_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/academic_provider.dart';
import '../../providers/auth_provider.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({Key? key}) : super(key: key);

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId != null) {
      context.read<AcademicProvider>().fetchLeaveRequests(userId);
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _startDate = date;
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;

    final success = await context.read<AcademicProvider>().submitLeaveRequest(
      studentId: userId,
      startDate: _startDate!,
      endDate: _endDate!,
      reason: _reasonController.text,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Leave request submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit leave request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Request'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'New Leave Request',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ListTile(
                              leading: const Icon(Icons.calendar_today),
                              title: const Text('Start Date'),
                              subtitle: Text(
                                _startDate != null
                                    ? _formatDate(_startDate!)
                                    : 'Select date',
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: _selectStartDate,
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.calendar_today),
                              title: const Text('End Date'),
                              subtitle: Text(
                                _endDate != null
                                    ? _formatDate(_endDate!)
                                    : 'Select date',
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: _selectEndDate,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _reasonController,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                labelText: 'Reason',
                                hintText: 'Enter reason for leave',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a reason';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _submitRequest,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6366F1),
                                ),
                                child: _isSubmitting
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text('Submit Request'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildLeaveHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveHistory() {
    return Consumer<AcademicProvider>(
      builder: (context, provider, child) {
        if (provider.leaveRequests.isEmpty) {
          return const SizedBox();
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Previous Requests',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...provider.leaveRequests.map((request) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      '${_formatDate(request.startDate)} - ${_formatDate(request.endDate)}',
                    ),
                    subtitle: Text(request.reason),
                    trailing: Chip(
                      label: Text(
                        request.status.toUpperCase(),
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: _getStatusColor(request.status),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green.withValues(alpha: 0.2);
      case 'rejected':
        return Colors.red.withValues(alpha: 0.2);
      default:
        return Colors.orange.withValues(alpha: 0.2);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}