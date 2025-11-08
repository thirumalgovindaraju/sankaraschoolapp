import 'package:flutter/material.dart';

// lib/data/models/news_model.dart

class NewsModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String? imageUrl;
  final String? category;

  NewsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.imageUrl,
    this.category,
  });

  // Create from JSON (for API data)
  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      imageUrl: json['imageUrl'],
      category: json['category'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'imageUrl': imageUrl,
      'category': category,
    };
  }

  // Create a copy with modified fields
  NewsModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? imageUrl,
    String? category,
  }) {
    return NewsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
    );
  }
}

