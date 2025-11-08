// lib/presentation/widgets/home/compact_school_banner.dart

import 'package:flutter/material.dart';

class CompactSchoolBanner extends StatelessWidget {
  const CompactSchoolBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // School Logo, Name and Tagline
          Row(
            children: [
              // School Logo
              Container(
                width: 60,
                height: 60,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.orange.shade700,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.25),
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
                        size: 32,
                        color: Colors.orange.shade700,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // School Name and Tagline
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sri Sankara Global Academy',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                        height: 1.2,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '(A unit of Hindu Seva Samajam Trust)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey.shade300,
                  Colors.transparent,
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Partner Logos Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPartnerLogoCard(
                'assets/images/edexcel_logo.png',
                'Edexcel',
                showSubtext: true,
                subtext: 'Centre No.95990',
              ),
              _buildPartnerLogoCard(
                'assets/images/pearson_logo.png',
                'Pearson',
              ),
              _buildPartnerLogoCard(
                'assets/images/kidzee_logo.png',
                'Kidzee',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerLogoCard(
      String assetPath,
      String name, {
        bool showSubtext = false,
        String? subtext,
      }) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(
          minWidth: 85,
          minHeight: 60,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 35,
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  );
                },
              ),
            ),
            if (showSubtext && subtext != null) ...[
              const SizedBox(height: 6),
              Text(
                subtext,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 8.5,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}