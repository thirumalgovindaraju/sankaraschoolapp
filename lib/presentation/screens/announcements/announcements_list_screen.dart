import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/announcement_provider.dart';
import '../../widgets/dashboard/announcement_card.dart';
import '../../../data/models/announcement_model.dart';

class AnnouncementsListScreen extends StatefulWidget {
  const AnnouncementsListScreen({Key? key}) : super(key: key);

  @override
  State<AnnouncementsListScreen> createState() => _AnnouncementsListScreenState();
}

class _AnnouncementsListScreenState extends State<AnnouncementsListScreen> {
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id;
    final userRole = authProvider.currentUser?.role?.name;

    await context.read<AnnouncementProvider>().fetchAnnouncements(
      userRole: userRole,
      userId: userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final announcementProvider = context.watch<AnnouncementProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isAdmin = authProvider.currentUser?.role?.name == 'admin';
    final isTeacher = authProvider.currentUser?.role?.name == 'teacher';

    List<AnnouncementModel> announcements = _selectedFilter == null
        ? announcementProvider.announcements
        : announcementProvider.announcements
        .where((a) => a.type == _selectedFilter)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          if (isAdmin || isTeacher)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(context, '/create-announcement')
                    .then((_) => _loadAnnouncements());
              },
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value == 'all' ? null : value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All')),
              const PopupMenuItem(value: 'academic', child: Text('Academic')),
              const PopupMenuItem(value: 'general', child: Text('General')),
              const PopupMenuItem(value: 'urgent', child: Text('Urgent')),
              const PopupMenuItem(value: 'event', child: Text('Events')),
              const PopupMenuItem(value: 'holiday', child: Text('Holidays')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAnnouncements,
        child: announcementProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : announcements.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.announcement_outlined,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'No announcements available',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: announcements.length,
          itemBuilder: (context, index) {
            final announcement = announcements[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AnnouncementCard(
                announcement: announcement,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/announcement-detail',
                    arguments: announcement,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}