// lib/presentation/screens/worksheet/upload_textbook_dialog.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/worksheet_generator_model.dart';
import '../../providers/worksheet_generator_provider.dart';
import '../../providers/auth_provider.dart';

class UploadTextbookDialog extends StatefulWidget {
  const UploadTextbookDialog({super.key});

  @override
  State<UploadTextbookDialog> createState() => _UploadTextbookDialogState();
}

class _UploadTextbookDialogState extends State<UploadTextbookDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _publisherController = TextEditingController();
  final _editionController = TextEditingController();

  String _selectedSubject = 'Mathematics';
  String _selectedBoard = 'IGCSE';
  String _selectedGrade = 'Year 10';

  bool _isUploading = false;

  // Subjects list
  final List<String> _subjects = [
    'Mathematics',
    'English',
    'Science',
    'Physics',
    'Chemistry',
    'Biology',
    'Computer Science',
    'History',
    'Geography',
    'Economics',
    'Business Studies',
    'Accounting',
    'Art & Design',
    'Music',
    'Physical Education',
  ];

  // Boards list
  final List<String> _boards = [
    'IGCSE',
    'CBSE',
    'IB',
    'Cambridge',
    'Edexcel',
    'ICSE',
    'State Board',
  ];

  // Grades list
  final List<String> _grades = [
    'Pre-Primary',
    'KG 1',
    'KG 2',
    'Grade 1',
    'Grade 2',
    'Grade 3',
    'Grade 4',
    'Grade 5',
    'Grade 6',
    'Grade 7',
    'Grade 8',
    'Grade 9',
    'Grade 10',
    'Grade 11',
    'Grade 12',
    'Year 9',
    'Year 10',
    'Year 11',
    'Year 12',
    'Year 13',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _publisherController.dispose();
    _editionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Icon(Icons.upload_file, size: 32, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Upload Textbook PDF',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(
                              'AI will extract chapters and topics automatically',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Textbook Title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Textbook Title *',
                      hintText: 'e.g., IGCSE Mathematics - Edexcel',
                      prefixIcon: Icon(Icons.book),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter textbook title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Subject Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedSubject,
                    decoration: const InputDecoration(
                      labelText: 'Subject *',
                      prefixIcon: Icon(Icons.subject),
                      border: OutlineInputBorder(),
                    ),
                    items: _subjects.map((subject) {
                      return DropdownMenuItem(
                        value: subject,
                        child: Text(subject),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedSubject = value!);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Board and Grade Row
                  Row(
                    children: [
                      // Board Dropdown
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedBoard,
                          decoration: const InputDecoration(
                            labelText: 'Board *',
                            prefixIcon: Icon(Icons.school),
                            border: OutlineInputBorder(),
                          ),
                          items: _boards.map((board) {
                            return DropdownMenuItem(
                              value: board,
                              child: Text(board),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedBoard = value!);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Grade Dropdown
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedGrade,
                          decoration: const InputDecoration(
                            labelText: 'Grade/Year *',
                            prefixIcon: Icon(Icons.grade),
                            border: OutlineInputBorder(),
                          ),
                          items: _grades.map((grade) {
                            return DropdownMenuItem(
                              value: grade,
                              child: Text(grade),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedGrade = value!);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Publisher (Optional)
                  TextFormField(
                    controller: _publisherController,
                    decoration: const InputDecoration(
                      labelText: 'Publisher (Optional)',
                      hintText: 'e.g., Cambridge University Press',
                      prefixIcon: Icon(Icons.business),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Edition (Optional)
                  TextFormField(
                    controller: _editionController,
                    decoration: const InputDecoration(
                      labelText: 'Edition (Optional)',
                      hintText: 'e.g., 2024 Edition',
                      prefixIcon: Icon(Icons.new_releases),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Text(
                              'How it works',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildInfoItem('1', 'Upload your PDF textbook (up to 100MB)'),
                        _buildInfoItem('2', 'AI extracts text and identifies chapters'),
                        _buildInfoItem('3', 'Topics and keywords are analyzed automatically'),
                        _buildInfoItem('4', 'Takes 1-2 minutes for processing'),
                        const SizedBox(height: 8),
                        Text(
                          '💡 Tip: Works best with text-based PDFs. Scanned PDFs may require OCR.',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isUploading ? null : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _isUploading ? null : _handleUpload,
                        icon: _isUploading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Icon(Icons.upload_file),
                        label: Text(_isUploading ? 'Uploading...' : 'Select & Upload PDF'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Upload Progress
                  if (_isUploading) ...[
                    const SizedBox(height: 16),
                    const LinearProgressIndicator(),
                    const SizedBox(height: 8),
                    Text(
                      'Uploading and processing... This may take a few minutes.',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.blue[700],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleUpload() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isUploading = true);

    try {
      final provider = context.read<WorksheetGeneratorProvider>();
      final authProvider = context.read<AuthProvider>();

      final success = await provider.uploadTextbook(
        title: _titleController.text.trim(),
        subject: _selectedSubject,
        board: _selectedBoard,
        grade: _selectedGrade,
        uploadedBy: authProvider.user?.id ?? 'unknown',
        publisher: _publisherController.text.trim().isEmpty
            ? null
            : _publisherController.text.trim(),
        edition: _editionController.text.trim().isEmpty
            ? null
            : _editionController.text.trim(),
      );

      if (mounted) {
        setState(() => _isUploading = false);

        if (success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Textbook uploaded successfully! Processing in background...',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 5),
            ),
          );

          // Close dialog
          Navigator.pop(context, true);

          // Show processing info dialog
          _showProcessingInfoDialog();
        } else {
          // Show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.error ?? 'Upload failed. Please try again.',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showProcessingInfoDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.hourglass_empty, size: 48, color: Colors.blue),
        title: const Text('Processing Textbook'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your textbook is being processed in the background. This includes:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildProcessingStep(Icons.text_fields, 'Extracting text from PDF'),
            _buildProcessingStep(Icons.auto_awesome, 'AI analyzing chapters'),
            _buildProcessingStep(Icons.topic, 'Identifying topics & keywords'),
            _buildProcessingStep(Icons.done_all, 'Creating topic taxonomy'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: Colors.amber[900]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This usually takes 1-2 minutes. You\'ll be notified when ready.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Refresh the textbooks list
              context.read<WorksheetGeneratorProvider>().loadTextbooks();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh List'),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingStep(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper function to show the dialog from anywhere
Future<bool?> showUploadTextbookDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const UploadTextbookDialog(),
  );
}