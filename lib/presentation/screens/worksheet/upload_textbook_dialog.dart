// lib/presentation/screens/worksheet/upload_textbook_dialog.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../data/models/worksheet_generator_model.dart';
import '../../../data/services/worksheet_generator_service.dart';
import '../../providers/worksheet_generator_provider.dart';
import '../../providers/auth_provider.dart';
import '/data/services/pdf_processor_service.dart';


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
  PlatformFile? _selectedFile; // ✅ ADDED

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

  // ✅ ADDED: File picker method
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true, // Important for web
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Selected: ${_selectedFile!.name}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error selecting file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

                  // ✅ ADDED: File selection card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _selectedFile != null ? Colors.green[50] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedFile != null ? Colors.green : Colors.grey[300]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _selectedFile != null ? Icons.check_circle : Icons.attach_file,
                          color: _selectedFile != null ? Colors.green : Colors.grey[600],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedFile != null ? _selectedFile!.name : 'No file selected',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _selectedFile != null ? Colors.green[900] : Colors.grey[700],
                                ),
                              ),
                              if (_selectedFile != null)
                                Text(
                                  '${(_selectedFile!.size / 1024 / 1024).toStringAsFixed(2)} MB',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _pickFile,
                          icon: const Icon(Icons.folder_open),
                          label: Text(_selectedFile != null ? 'Change' : 'Browse'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

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
                        label: Text(_isUploading ? 'Uploading...' : 'Upload PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[700],
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
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Please select a PDF file'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // Upload using the service
      // Get current user for uploadedBy
      final authProvider = context.read<AuthProvider>();
      final currentUserId = authProvider.currentUser?.id ?? 'unknown';

// Call PDFProcessorService directly - it will pick the file
      final textbook = await PDFProcessorService.uploadTextbookWithFile(
        file: _selectedFile!,
        title: _titleController.text.trim(),
        subject: _selectedSubject,
        board: _selectedBoard,
        grade: _selectedGrade,
        uploadedBy: currentUserId,
        publisher: _publisherController.text.trim().isEmpty
            ? null
            : _publisherController.text.trim(),
        edition: _editionController.text.trim().isEmpty
            ? null
            : _editionController.text.trim(),
      );

      if (!mounted) return;

      setState(() => _isUploading = false);

      if (textbook != null) {
        // Success!
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('✅ ${textbook.title} uploaded successfully!'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Close dialog and return textbook
        Navigator.pop(context, textbook);

        // Show processing info
        _showProcessingInfoDialog();
      } else {
        throw Exception('Upload returned null');
      }
    } on FirebaseException catch (e) {
      if (!mounted) return;

      setState(() => _isUploading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('❌ Firebase Error: ${e.code}'),
              if (e.message != null)
                Text(e.message!, style: const TextStyle(fontSize: 12)),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isUploading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Upload failed: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _handleUpload(),
          ),
        ),
      );
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