// lib/presentation/widgets/home/school_banner.dart

import 'package:flutter/material.dart';

class SchoolBanner extends StatelessWidget {
  const SchoolBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main school branding row
          Row(
            children: [
              // School Logo
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.orange.shade700,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.school,
                        size: 35,
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
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '(A unit of Hindu Seva Samajam Trust)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Partner Logos Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Edexcel Logo
              _buildPartnerLogo(
                'assets/images/edexcel_logo.png',
                'Edexcel\nCentre No.95990',
                70,
              ),

              // Vertical Divider
              Container(
                height: 50,
                width: 1,
                color: Colors.grey.shade300,
              ),

              // Pearson Logo
              _buildPartnerLogo(
                'assets/images/pearson_logo.png',
                'Pearson',
                70,
              ),

              // Vertical Divider
              Container(
                height: 50,
                width: 1,
                color: Colors.grey.shade300,
              ),

              // Kidzee Logo
              _buildPartnerLogo(
                'assets/images/kidzee_logo.png',
                'Kidzee',
                70,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerLogo(String assetPath, String altText, double width) {
    return Column(
      children: [
        SizedBox(
          width: width,
          height: 40,
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    altText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (altText.contains('Centre'))
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Centre No.95990',
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey.shade600,
              ),
            ),
          ),
      ],
    );
  }
}