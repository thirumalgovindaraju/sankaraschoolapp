import 'package:flutter/material.dart';

// lib/data/models/event_model.dart
class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String imageUrl;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.imageUrl,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      imageUrl: json['imageUrl'],
    );
  }
}
