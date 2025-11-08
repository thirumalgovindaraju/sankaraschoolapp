// lib/presentation/widgets/home/website_style_banner.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;

class WebsiteStyleBanner extends StatefulWidget {
  const WebsiteStyleBanner({super.key});

  @override
  State<WebsiteStyleBanner> createState() => _WebsiteStyleBannerState();
}

class _WebsiteStyleBannerState extends State<WebsiteStyleBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 12,
            vertical: isTablet ? 16 : 12,
          ),
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
          child: isTablet ? _buildTabletLayout() : _buildMobileLayout(),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildSchoolLogo(),
        const SizedBox(width: 12),
        Expanded(child: _buildSchoolInfo()),
        const SizedBox(width: 8),
        _buildPartnerLogosRow(),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildSchoolLogo(),
        const SizedBox(width: 20),
        Expanded(child: _buildSchoolInfo()),
        const SizedBox(width: 24),
        _buildPartnerLogosRow(),
      ],
    );
  }

  Widget _buildSchoolLogo() {
    return Hero(
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
    );
  }

  Widget _buildSchoolInfo() {
    return Column(
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
    );
  }

  Widget _buildPartnerLogosRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPartnerLogo(
          'assets/images/edexcel_logo.png',
          'Edexcel',
          width: 55,
          showSubtext: true,
          subtext: 'Centre\nNo.95990',
          info: 'Edexcel International Centre\nCentre Number: 95990\n\nWe are an authorized Edexcel examination center, offering international qualifications recognized worldwide.',
          delay: 200,
        ),
        const SizedBox(width: 6),
        _buildPartnerLogo(
          'assets/images/pearson_logo.png',
          'Pearson',
          width: 50,
          info: 'Pearson Partner School\n\nPartnered with Pearson, the world\'s learning company, to deliver quality education and assessments.',
          delay: 400,
        ),
        const SizedBox(width: 6),
        _buildPartnerLogo(
          'assets/images/kidzee_logo.png',
          'Kidzee',
          width: 48,
          info: 'Kidzee Preschool Program\n\nIntegrated early childhood education program from India\'s leading preschool brand.',
          delay: 600,
        ),
      ],
    );
  }

  Widget _buildPartnerLogo(
      String assetPath,
      String name, {
        required double width,
        bool showSubtext = false,
        String? subtext,
        required String info,
        required int delay,
      }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPartnerInfo(context, name, info),
          borderRadius: BorderRadius.circular(6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
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
              ),
              if (showSubtext && subtext != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtext,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 6.5,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showPartnerInfo(BuildContext context, String name, String info) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Colors.orange.shade50.withOpacity(0.3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.business,
                    color: Colors.orange.shade700,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                info,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Got it!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}