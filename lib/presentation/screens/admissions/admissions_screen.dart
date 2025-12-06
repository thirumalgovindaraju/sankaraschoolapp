import 'package:flutter/material.dart';

// lib/presentation/screens/admissions/admissions_screen.dart

import 'package:flutter/material.dart';
import '../../widgets/common/custom_drawer.dart';

class AdmissionsScreen extends StatelessWidget {
  const AdmissionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admissions'),
        elevation: 0,
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.7),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(
                    Icons.how_to_reg,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Admissions Open',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Academic Year 2025-26',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Admission Process
                  _buildSectionTitle(context, 'Admission Process', Icons.trending_flat),
                  const SizedBox(height: 16),
                  _buildAdmissionSteps(context),
                  const SizedBox(height: 32),

                  // Eligibility
                  _buildSectionTitle(context, 'Eligibility Criteria', Icons.checklist),
                  const SizedBox(height: 16),
                  _buildEligibility(context),
                  const SizedBox(height: 32),

                  // Required Documents
                  _buildSectionTitle(context, 'Required Documents', Icons.folder_open),
                  const SizedBox(height: 16),
                  _buildDocuments(context),
                  const SizedBox(height: 32),

                  // Fee Structure
                  _buildSectionTitle(context, 'Fee Structure', Icons.currency_rupee),
                  const SizedBox(height: 16),
                  _buildFeeStructure(context),
                  const SizedBox(height: 32),

                  // Important Dates
                  _buildSectionTitle(context, 'Important Dates', Icons.calendar_today),
                  const SizedBox(height: 16),
                  _buildImportantDates(context),
                  const SizedBox(height: 32),

                  // Apply Now Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to application form
                        Navigator.pushNamed(context, '/application-form');
                      },
                      icon: const Icon(Icons.login, size: 24),
                      label: const Text(
                        'Apply Now',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Contact Info
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'For Admission Enquiries',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.phone, color: Theme.of(context).primaryColor),
                              const SizedBox(width: 8),
                              const Text('+91 98765 43210'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.email, color: Theme.of(context).primaryColor),
                              const SizedBox(width: 8),
                              const Text('admissions@srisankara.edu.in'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 28,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildAdmissionSteps(BuildContext context) {
    final steps = [
      {
        'number': '1',
        'title': 'Registration',
        'desc': 'Fill the online admission form with required details',
      },
      {
        'number': '2',
        'title': 'Document Verification',
        'desc': 'Submit all required documents for verification',
      },
      {
        'number': '3',
        'title': 'Interaction',
        'desc': 'Parent-student interaction with school management',
      },
      {
        'number': '4',
        'title': 'Admission',
        'desc': 'Complete fee payment and receive admission confirmation',
      },
    ];

    return Column(
      children: steps.map((step) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    step['number'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step['title'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step['desc'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEligibility(BuildContext context) {
    final eligibility = [
      'Age as per CBSE norms for respective classes',
      'Previous school leaving certificate (for new admissions)',
      'Transfer certificate from previous school',
      'Medical fitness certificate',
      'Good academic and conduct record',
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: eligibility.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDocuments(BuildContext context) {
    final documents = [
      'Birth Certificate (Original)',
      'Aadhar Card of Student',
      'Transfer Certificate from Previous School',
      'Previous Year Mark Sheets',
      'Passport Size Photographs (4 copies)',
      'Parent\'s ID Proof (Aadhar/Passport)',
      'Address Proof (Latest)',
      'Caste Certificate (if applicable)',
    ];

    return Column(
      children: documents.map((doc) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              Icons.description,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(doc),
            dense: true,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeeStructure(BuildContext context) {
    final fees = [
      {'class': 'Pre-Primary (Nursery - UKG)', 'fee': '₹45,000'},
      {'class': 'Primary (I - V)', 'fee': '₹55,000'},
      {'class': 'Middle School (VI - VIII)', 'fee': '₹65,000'},
      {'class': 'Secondary (IX - X)', 'fee': '₹75,000'},
      {'class': 'Senior Secondary (XI - XII)', 'fee': '₹85,000'},
    ];

    return Column(
      children: [
        Card(
          elevation: 2,
          child: Column(
            children: fees.map((fee) {
              return ListTile(
                title: Text(fee['class'] as String),
                trailing: Text(
                  fee['fee'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Note: Fees include tuition, books, and activities. Transport fees are separate.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImportantDates(BuildContext context) {
    final dates = [
      {'event': 'Admission Form Release', 'date': 'January 15, 2025'},
      {'event': 'Last Date for Application', 'date': 'March 31, 2025'},
      {'event': 'Admission Results', 'date': 'April 15, 2025'},
      {'event': 'Admission Confirmation', 'date': 'April 30, 2025'},
      {'event': 'Academic Session Starts', 'date': 'June 1, 2025'},
    ];

    return Card(
      elevation: 2,
      child: Column(
        children: dates.map((date) {
          return ListTile(
            leading: Icon(
              Icons.event,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(date['event'] as String),
            subtitle: Text(
              date['date'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        }).toList(),
      ),
    );
  }
}
