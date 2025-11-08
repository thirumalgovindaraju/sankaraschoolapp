// lib/presentation/screens/admin/manage_users_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import 'add_student_screen.dart';
import 'add_teacher_screen.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({Key? key}) : super(key: key);

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAllUsers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.school), text: 'Students'),
            Tab(icon: Icon(Icons.person), text: 'Teachers'),
            Tab(icon: Icon(Icons.family_restroom), text: 'Parents'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStudentsList(),
                _buildTeachersList(),
                _buildParentsList(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddUserDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add User'),
      ),
    );
  }

  Widget _buildStudentsList() {
    return Consumer<AdminProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final students = provider.students.where((student) {
          if (_searchQuery.isEmpty) return true;
          final query = _searchQuery.toLowerCase();
          return student['name'].toString().toLowerCase().contains(query) ||
              student['email'].toString().toLowerCase().contains(query) ||
              student['class'].toString().toLowerCase().contains(query);
        }).toList();

        if (students.isEmpty) {
          return const Center(
            child: Text('No students found'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return _buildStudentCard(student);
          },
        );
      },
    );
  }

  Widget _buildTeachersList() {
    return Consumer<AdminProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final teachers = provider.teachers.where((teacher) {
          if (_searchQuery.isEmpty) return true;
          final query = _searchQuery.toLowerCase();
          return teacher['name'].toString().toLowerCase().contains(query) ||
              teacher['email'].toString().toLowerCase().contains(query) ||
              teacher['subject'].toString().toLowerCase().contains(query);
        }).toList();

        if (teachers.isEmpty) {
          return const Center(
            child: Text('No teachers found'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: teachers.length,
          itemBuilder: (context, index) {
            final teacher = teachers[index];
            return _buildTeacherCard(teacher);
          },
        );
      },
    );
  }

  Widget _buildParentsList() {
    return Consumer<AdminProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Extract parents from students
        final parents = <Map<String, dynamic>>[];
        for (var student in provider.students) {
          if (student['parent_details'] != null) {
            final parentDetails = student['parent_details'];
            parents.add({
              'name': parentDetails['father_name'],
              'email': parentDetails['father_email'],
              'phone': parentDetails['father_phone'],
              'student_name': student['name'],
              'student_class': '${student['class']} - ${student['section']}',
              'relation': 'Father',
            });
            if (parentDetails['mother_name'] != null) {
              parents.add({
                'name': parentDetails['mother_name'],
                'email': parentDetails['mother_email'],
                'phone': parentDetails['mother_phone'],
                'student_name': student['name'],
                'student_class': '${student['class']} - ${student['section']}',
                'relation': 'Mother',
              });
            }
          }
        }

        final filteredParents = parents.where((parent) {
          if (_searchQuery.isEmpty) return true;
          final query = _searchQuery.toLowerCase();
          return parent['name'].toString().toLowerCase().contains(query) ||
              parent['student_name'].toString().toLowerCase().contains(query);
        }).toList();

        if (filteredParents.isEmpty) {
          return const Center(
            child: Text('No parents found'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredParents.length,
          itemBuilder: (context, index) {
            final parent = filteredParents[index];
            return _buildParentCard(parent);
          },
        );
      },
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            student['name'].toString()[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          student['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${student['class']} - ${student['section']} | Roll: ${student['roll_number']}'),
            Text(student['email'], style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddStudentScreen(studentData: student),
                ),
              ).then((result) {
                if (result == true) {
                  context.read<AdminProvider>().loadAllUsers();
                }
              });
            } else if (value == 'delete') {
              _showDeleteConfirmation(
                'student',
                student['name'],
                student['student_id'],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildTeacherCard(Map<String, dynamic> teacher) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: Text(
            teacher['name'].toString()[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          teacher['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${teacher['subject']}'),
            Text(teacher['email'], style: const TextStyle(fontSize: 12)),
            if (teacher['classes_assigned'] != null)
              Text(
                'Classes: ${(teacher['classes_assigned'] as List).join(", ")}',
                style: const TextStyle(fontSize: 11),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTeacherScreen(teacherData: teacher),
                ),
              ).then((result) {
                if (result == true) {
                  context.read<AdminProvider>().loadAllUsers();
                }
              });
            } else if (value == 'delete') {
              _showDeleteConfirmation(
                'teacher',
                teacher['name'],
                teacher['teacher_id'],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildParentCard(Map<String, dynamic> parent) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple,
          child: Text(
            parent['name'].toString()[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          '${parent['name']} (${parent['relation']})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Child: ${parent['student_name']}'),
            Text('Class: ${parent['student_class']}'),
            Text(parent['email'] ?? 'No email', style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Add Student'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddStudentScreen(),
                  ),
                ).then((result) {
                  if (result == true) {
                    context.read<AdminProvider>().loadAllUsers();
                  }
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Add Teacher'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTeacherScreen(),
                  ),
                ).then((result) {
                  if (result == true) {
                    context.read<AdminProvider>().loadAllUsers();
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(String userType, String userName, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $userType?'),
        content: Text('Are you sure you want to delete $userName? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<AdminProvider>();
              bool success = false;

              if (userType == 'student') {
                success = await provider.deleteStudent(userId);
              } else if (userType == 'teacher') {
                success = await provider.deleteTeacher(userId);
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? '$userType deleted successfully'
                        : 'Failed to delete $userType'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
                if (success) {
                  provider.loadAllUsers();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}