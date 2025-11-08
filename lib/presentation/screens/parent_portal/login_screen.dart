// lib/presentation/screens/parent_portal/login_screen.dart:

import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parent Portal')),
      body: const Center(child: Text('Login Screen')),
    );
  }
}