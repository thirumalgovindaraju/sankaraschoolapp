// lib/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../widgets/home/home_header.dart';
import '../widgets/home/compact_school_banner.dart'; // or school_banner.dart
import '../widgets/home/admission_banner.dart';
import '../widgets/home/about_section.dart';
import '../widgets/home/news_carousel.dart';
import '../widgets/common/custom_drawer.dart';
import '../widgets/home/website_style_banner.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      endDrawer: const CustomDrawer(),
      body: Column(
        children: [
          // Fixed Header at top
          const HomeHeader(),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // School Banner (NEW!)
                  //const CompactSchoolBanner(), // or use SchoolBanner()
                  //const WebsiteStyleBanner(),
                  //const SizedBox(height: 16),

                  // Admission Banner
                  const AdmissionBanner(),

                  const SizedBox(height: 16),

                  // News Carousel
                  const NewsCarousel(),

                  const SizedBox(height: 24),

                  // About Section
                  const AboutSection(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}