// lib/presentation/screens/about_screen.dart

import 'package:flutter/material.dart';
import 'dart:ui';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          _buildPremiumBackground(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildHeaderSection(),
                    const SizedBox(height: 24),
                    _buildVisionSection(),
                    const SizedBox(height: 20),
                    _buildMissionSection(),
                    const SizedBox(height: 20),
                    _buildFounderMessageSection(),
                    const SizedBox(height: 20),
                    _buildPrincipalMessageSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: const Text(
        'About Us',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 19,
          letterSpacing: 0.3,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildPremiumBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1a237e),
            const Color(0xFF283593),
            const Color(0xFF3949ab),
            const Color(0xFF5e35b1),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.white.withOpacity(0.1), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.white.withOpacity(0.95)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade600, Colors.deepOrange.shade700],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.school_rounded, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            'Sri Sankara Global Academy',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade900,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'SRI SANKARA GLOBAL School (SSGA) Chennai, is a selective, independent, co-educational day school. The trustees of Hindu Samajam, had intended to initiate an idea of introducing a foreign based curriculum with key competency in order to improve student academic achievement at par with International Education.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.7,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVisionSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade600, Colors.deepOrange.shade700],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.visibility_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'OUR VISION',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade100, width: 2),
            ),
            child: Text(
              'Our vision is to provide a stimulating learning environment with a technological orientation across the curriculum, which maximizes individual potential and ensures students ability levels at various spectrum are well equipped to meet the challenges of education, work and life.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade800,
                height: 1.7,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Our vision is that children of our Academy:',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 12),
          _buildVisionPoint('Comply with', 'A set of spiritual and moral values — honesty, integrity and good decision making skills.'),
          _buildVisionPoint('Acquire', 'A complement of basic skills — linguistic, mathematical, scientific, artistic, physical, social and emotional.'),
          _buildVisionPoint('Harness', 'Strong self-esteem, Tolerance, Respect and Regard for others.'),
        ],
      ),
    );
  }

  Widget _buildVisionPoint(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade600, Colors.deepOrange.shade700],
              ),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.6),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade600, Colors.indigo.shade800],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.flag_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'OUR MISSION',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade50, Colors.blue.shade50],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.indigo.shade100, width: 2),
            ),
            child: Text(
              'To provide quality education that enables students to become responsible global citizens with strong moral values, critical thinking abilities, and the skills necessary to succeed in an ever-changing world.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade800,
                height: 1.7,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFounderMessageSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade600, Colors.teal.shade800],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.record_voice_over_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'FOUNDER\'S MESSAGE',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SSGA School is the kingdom of education. We believe that quality based education is the benchmark for every child to go for higher education in better institutions elsewhere in the world for their bright future.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We fully acknowledge the importance of value based education with social responsibility linked with cultural integrity of our country.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Our aim is to develop the children to become leaders of modern India.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 100,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/images/correspondent.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.person, size: 40, color: Colors.grey.shade400);
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrincipalMessageSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade600, Colors.purple.shade800],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'PRINCIPAL\'S MESSAGE',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 100,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/images/principal.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.person, size: 40, color: Colors.grey.shade400);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"Shaping young, impressionable minds is one of the life\'s biggest challenges"',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple.shade800,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We provide a solid academic foundation and rich co-scholastic programmes to empower the students to discover their potentials.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'We follow Edexcel international curriculum, London, UK. The curriculum emphasizes the acquisition of knowledge, useful skills, understanding, critical thinking, and problem-solving abilities.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade50, Colors.pink.shade50],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.shade100, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mrs. Latha Vivekanandan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Principal',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.purple.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}