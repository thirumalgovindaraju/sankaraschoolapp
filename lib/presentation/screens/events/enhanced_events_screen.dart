// lib/presentation/screens/events/enhanced_events_screen.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class EnhancedEventsScreen extends StatefulWidget {
  const EnhancedEventsScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedEventsScreen> createState() => _EnhancedEventsScreenState();
}

class _EnhancedEventsScreenState extends State<EnhancedEventsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  final Map<DateTime, List<Event>> _events = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedDay = _focusedDay;
    _loadSampleEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadSampleEvents() {
    // Sample events
    final now = DateTime.now();
    _events[DateTime(now.year, now.month, now.day + 2)] = [
      Event(
        'Annual Sports Day',
        'Sports',
        const Color(0xFF4CAF50),
        '9:00 AM - 5:00 PM',
        'School Playground',
        'All students to participate in various sports activities',
      ),
    ];
    _events[DateTime(now.year, now.month, now.day + 5)] = [
      Event(
        'Science Exhibition',
        'Academic',
        const Color(0xFF2196F3),
        '10:00 AM - 3:00 PM',
        'Science Lab',
        'Students will showcase their science projects',
      ),
    ];
    _events[DateTime(now.year, now.month, now.day + 10)] = [
      Event(
        'Parent-Teacher Meeting',
        'Meeting',
        const Color(0xFFFF9800),
        '2:00 PM - 6:00 PM',
        'School Auditorium',
        'Discussion on student progress',
      ),
    ];
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Events & Calendar'),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Calendar', icon: Icon(Icons.calendar_today, size: 20)),
            Tab(text: 'Upcoming', icon: Icon(Icons.event_note, size: 20)),
            Tab(text: 'Past', icon: Icon(Icons.history, size: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCalendarView(),
          _buildUpcomingEventsView(),
          _buildPastEventsView(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateEventDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Event'),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildCalendarView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: _getEventsForDay,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: const Color(0xFF9C27B0).withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Color(0xFF9C27B0),
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          if (_selectedDay != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Events on ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._getEventsForDay(_selectedDay!).map((event) => _buildEventCard(event)),
                  if (_getEventsForDay(_selectedDay!).isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.event_busy, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'No events on this day',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventsView() {
    final upcomingEvents = [
      Event(
        'Annual Sports Day',
        'Sports',
        const Color(0xFF4CAF50),
        '9:00 AM - 5:00 PM',
        'School Playground',
        'All students to participate in various sports activities',
        date: DateTime.now().add(const Duration(days: 2)),
      ),
      Event(
        'Science Exhibition',
        'Academic',
        const Color(0xFF2196F3),
        '10:00 AM - 3:00 PM',
        'Science Lab',
        'Students will showcase their science projects',
        date: DateTime.now().add(const Duration(days: 5)),
      ),
      Event(
        'Parent-Teacher Meeting',
        'Meeting',
        const Color(0xFFFF9800),
        '2:00 PM - 6:00 PM',
        'School Auditorium',
        'Discussion on student progress',
        date: DateTime.now().add(const Duration(days: 10)),
      ),
      Event(
        'Cultural Program',
        'Cultural',
        const Color(0xFFE91E63),
        '4:00 PM - 7:00 PM',
        'School Auditorium',
        'Annual cultural performances by students',
        date: DateTime.now().add(const Duration(days: 15)),
      ),
      Event(
        'Inter-School Quiz Competition',
        'Academic',
        const Color(0xFF2196F3),
        '10:00 AM - 2:00 PM',
        'Conference Hall',
        'Quiz competition with neighboring schools',
        date: DateTime.now().add(const Duration(days: 20)),
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: upcomingEvents.length,
      itemBuilder: (context, index) {
        return _buildDetailedEventCard(upcomingEvents[index]);
      },
    );
  }

  Widget _buildPastEventsView() {
    final pastEvents = [
      Event(
        'Republic Day Celebration',
        'National',
        const Color(0xFFFF5722),
        'Full Day',
        'School Campus',
        'Flag hoisting and cultural programs',
        date: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Event(
        'Annual Day Function',
        'Cultural',
        const Color(0xFFE91E63),
        '6:00 PM - 9:00 PM',
        'School Auditorium',
        'Annual performances and prize distribution',
        date: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Event(
        'Winter Sports Meet',
        'Sports',
        const Color(0xFF4CAF50),
        '9:00 AM - 4:00 PM',
        'Sports Ground',
        'Inter-house sports competition',
        date: DateTime.now().subtract(const Duration(days: 45)),
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pastEvents.length,
      itemBuilder: (context, index) {
        return _buildDetailedEventCard(pastEvents[index], isPast: true);
      },
    );
  }

  Widget _buildEventCard(Event event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: event.color.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: event.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getEventIcon(event.category),
            color: event.color,
          ),
        ),
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(event.time, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(event.location, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedEventCard(Event event, {bool isPast = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: event.color.withOpacity(0.3), width: 2),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              event.color.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: event.color.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: event.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          event.date != null ? event.date!.day.toString() : '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          event.date != null ? _getMonthName(event.date!.month) : '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: event.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            event.category,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: event.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isPast)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(Icons.access_time, 'Time', event.time),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.location_on, 'Location', event.location),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.description, 'Description', event.description),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.share, size: 18, color: event.color),
                          label: Text('Share', style: TextStyle(color: event.color)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: event.color),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: const Text('Add to Calendar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: event.color,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getEventIcon(String category) {
    switch (category.toLowerCase()) {
      case 'sports':
        return Icons.sports;
      case 'academic':
        return Icons.school;
      case 'meeting':
        return Icons.people;
      case 'cultural':
        return Icons.theater_comedy;
      case 'national':
        return Icons.flag;
      default:
        return Icons.event;
    }
  }

  String _getMonthName(int month) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month];
  }

  void _showCreateEventDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Event'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Event Title',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Event created successfully!')),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Events'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Sports'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Academic'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Cultural'),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class Event {
  final String title;
  final String category;
  final Color color;
  final String time;
  final String location;
  final String description;
  final DateTime? date;

  Event(
      this.title,
      this.category,
      this.color,
      this.time,
      this.location,
      this.description, {
        this.date,
      });
}