// lib/presentation/screens/faculty/faculty_screen.dart
import 'package:flutter/material.dart';

class FacultyScreen extends StatelessWidget {
  const FacultyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Faculty')),
      body: const Center(child: Text('Faculty Screen')),
    );
  }
}
