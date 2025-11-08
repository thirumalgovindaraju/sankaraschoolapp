// lib/presentation/screens/academic/curriculum_detail_screen.dart
import 'package:flutter/material.dart';
import '../../../data/models/curriculum_model.dart';

class CurriculumDetailScreen extends StatelessWidget {
  final CurriculumModel curriculum;

  const CurriculumDetailScreen({super.key, required this.curriculum});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(curriculum.title),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (curriculum.imageUrl != null)
              Image.network(
                curriculum.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 16),
            Text(
              curriculum.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Grade: ${curriculum.grade}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(curriculum.description),
            const SizedBox(height: 24),
            const Text(
              'Subjects',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...curriculum.subjects.map((subject) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(subject.name),
                subtitle: Text('${subject.code} - ${subject.credits} credits'),
                trailing: Text(subject.teacher ?? 'N/A'),
              ),
            )),
          ],
        ),
      ),
    );
  }
}