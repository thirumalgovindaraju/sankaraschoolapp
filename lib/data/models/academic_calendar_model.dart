// lib/data/models/academic_calendar_model.dart

class AcademicCalendarModel {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String type; // holiday, exam, event
  final String? location;

  AcademicCalendarModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.type,
    this.location,
  });

  factory AcademicCalendarModel.fromJson(Map<String, dynamic> json) {
    return AcademicCalendarModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      type: json['type'] ?? 'event',
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'type': type,
      'location': location,
    };
  }
}