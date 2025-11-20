// lib/domain/models/activity.dart

class Activity {
  final String id;
  final String type;
  final String title;
  final String description;
  final DateTime timestamp;
  final String? userName;
  final String? userId;
  final Map<String, dynamic>? metadata; // ADD THIS LINE

  Activity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.userName,
    this.userId,
    this.metadata, // ADD THIS LINE
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      timestamp: json['timestamp'] != null
          ? (json['timestamp'] is DateTime
          ? json['timestamp']
          : DateTime.parse(json['timestamp']))
          : DateTime.now(),
      userName: json['userName'],
      userId: json['userId'],
      metadata: json['metadata'] as Map<String, dynamic>?, // ADD THIS LINE
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'userName': userName,
      'userId': userId,
      'metadata': metadata, // ADD THIS LINE
    };
  }

  Activity copyWith({
    String? id,
    String? type,
    String? title,
    String? description,
    DateTime? timestamp,
    String? userName,
    String? userId,
    Map<String, dynamic>? metadata, // ADD THIS LINE
  }) {
    return Activity(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      userName: userName ?? this.userName,
      userId: userId ?? this.userId,
      metadata: metadata ?? this.metadata, // ADD THIS LINE
    );
  }
}