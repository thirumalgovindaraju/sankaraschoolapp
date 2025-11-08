// lib/presentation/screen/home/widgets/home_header.dart

import 'package:flutter/material.dart';
import '/core/constants/app_colors.dart';
import '/core/constants/app_strings.dart';
import '/presentation/widgets/home/website_style_banner.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Top Contact Bar (Dark Gray)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFF3C3C3C),
              child: Row(
                children: [
                  // Phone
                  const Icon(Icons.phone, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    '+91-044-22475862',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(width: 20),
                  // Email
                  const Icon(Icons.email, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'admin@srisankaraglobal.com',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Website Style Banner with Menu Icon
            const SizedBox(height: 12),
            _buildBannerWithMenu(context),
            const SizedBox(height: 16),

            // Admission Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.shade600,
                    Colors.orange.shade400,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Graduation Cap Icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Admission Text
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🎓 Admissions Open!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Enroll now for Academic Year 2025-2026',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Apply Now Button
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Add navigation to admission form
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.orange.shade700,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Apply Now →',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerWithMenu(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.orange.shade50.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // School Logo
          Hero(
            tag: 'school_logo',
            child: Container(
              width: 50,
              height: 50,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.orange.shade700,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.school_rounded,
                      size: 28,
                      color: Colors.orange.shade700,
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // School Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sri Sankara Global Academy',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                    height: 1.2,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '(A unit of Hindu Seva Samajam Trust)',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Partner Logos
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPartnerLogo(context, 'assets/images/edexcel_logo.png', 'Edexcel', 55),
              const SizedBox(width: 6),
              _buildPartnerLogo(context, 'assets/images/pearson_logo.png', 'Pearson', 50),
              const SizedBox(width: 6),
              _buildPartnerLogo(context, 'assets/images/kidzee_logo.png', 'Kidzee', 48),
            ],
          ),
          const SizedBox(width: 12),

          // Menu Icon
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
                icon: Icon(
                  Icons.menu,
                  color: Colors.orange.shade700,
                  size: 28,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerLogo(BuildContext context, String assetPath, String name, double width) {
    return Container(
      width: width,
      height: 36,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          );
        },
      ),
    );
  }
}