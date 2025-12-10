// lib/presentation/screens/worksheet/worksheet_generator_screen.dart
// ✅ FIXED VERSION with Upload Textbook functionality

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/worksheet_generator_provider.dart';
import '../../../data/models/worksheet_generator_model.dart';
import 'upload_textbook_dialog.dart';


class WorksheetGeneratorScreen extends StatefulWidget {
  const WorksheetGeneratorScreen({Key? key}) : super(key: key);

  @override
  State<WorksheetGeneratorScreen> createState() => _WorksheetGeneratorScreenState();
}

class _WorksheetGeneratorScreenState extends State<WorksheetGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _topicController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorksheetGeneratorProvider>().init();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Worksheet Generator'),
        backgroundColor: Colors.purple[700],
        actions: [
          // ✅ View My Worksheets Button
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'My Worksheets',
            onPressed: () => _showMyWorksheetsDialog(),
          ),
        ],
      ),
      body: Consumer<WorksheetGeneratorProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.textbooks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  _buildHeaderCard(),
                  const SizedBox(height: 24),

                  // ✅ Textbook Selection Section
                  _buildTextbookSection(provider),
                  const SizedBox(height: 24),

                  // Topic Selection
                  if (provider.selectedTextbook != null) ...[
                    _buildTopicSelection(provider),
                    const SizedBox(height: 24),
                  ],

                  // Configuration Section
                  if (provider.selectedTopics.isNotEmpty) ...[
                    _buildConfigurationSection(provider),
                    const SizedBox(height: 24),
                  ],

                  // Generate Button
                  if (provider.selectedTopics.isNotEmpty) ...[
                    _buildGenerateButton(provider),
                    const SizedBox(height: 16),
                  ],

                  // Info Card
                  _buildInfoCard(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.purple[700]!,
              Colors.purple[400]!,
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'AI-Powered Questions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Generate custom worksheets from your textbooks',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
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

  Widget _buildTextbookSection(WorksheetGeneratorProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Textbook',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            // ✅ Upload Textbook Button
            ElevatedButton.icon(
              onPressed: () async {
                final result = await showUploadTextbookDialog(context);
                if (result == true) {
                  provider.loadTextbooks();
                }
              },
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Textbook'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (provider.textbooks.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.book, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No textbooks uploaded yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload a PDF textbook to get started',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await showUploadTextbookDialog(context);
                      if (result == true) {
                        provider.loadTextbooks();
                      }
                    },
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Your First Textbook'),
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
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.textbooks.length,
            itemBuilder: (context, index) {
              final textbook = provider.textbooks[index];
              final isSelected = provider.selectedTextbook?.id == textbook.id;

              return Card(
                elevation: isSelected ? 4 : 1,
                color: isSelected ? Colors.purple[50] : null,
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.book,
                      color: Colors.purple[700],
                    ),
                  ),
                  title: Text(
                    textbook.title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    '${textbook.board} • ${textbook.grade} • ${textbook.chapters.length} chapters',
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: Colors.purple[700])
                      : const Icon(Icons.chevron_right),
                  onTap: () => provider.selectTextbook(textbook),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildTopicSelection(WorksheetGeneratorProvider provider) {
    final textbook = provider.selectedTextbook!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Topics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${provider.selectedTopics.length} topics selected',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: textbook.chapters.length,
          itemBuilder: (context, chapterIndex) {
            final chapter = textbook.chapters[chapterIndex];
            final allSelected = chapter.topics.every(
                  (t) => provider.selectedTopics.any((st) => st.id == t.id),
            );

            return Card(
              child: ExpansionTile(
                leading: Checkbox(
                  value: allSelected,
                  onChanged: (value) {
                    provider.selectChapterTopics(chapter, value ?? false);
                  },
                ),
                title: Text(
                  'Chapter ${chapter.chapterNumber}: ${chapter.title}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${chapter.topics.length} topics'),
                children: chapter.topics.map((topic) {
                  final isSelected = provider.selectedTopics.any((t) => t.id == topic.id);

                  return CheckboxListTile(
                    value: isSelected,
                    title: Text(topic.name),
                    subtitle: Text(
                      topic.description ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    secondary: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(topic.difficulty).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        topic.difficulty.name, // ✅ Changed from .toString().split('.').last
                        style: TextStyle(
                          fontSize: 10,
                          color: _getDifficultyColor(topic.difficulty),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      provider.toggleTopic(topic);
                    },
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildConfigurationSection(WorksheetGeneratorProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Worksheet Configuration',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Worksheet Title
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Worksheet Title',
            hintText: 'e.g., Chapter 5 Practice Test',
            prefixIcon: const Icon(Icons.title),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Question Types
        Row(
          children: [
            Expanded(
              child: _buildQuestionCounter(
                label: 'MCQ',
                value: provider.mcqCount,
                onChanged: (value) => provider.setMCQCount(value),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuestionCounter(
                label: 'Short Answer',
                value: provider.shortAnswerCount,
                onChanged: (value) => provider.setShortAnswerCount(value),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuestionCounter(
                label: 'Long Answer',
                value: provider.longAnswerCount,
                onChanged: (value) => provider.setLongAnswerCount(value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Difficulty and Duration
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<DifficultyLevel>(
                value: provider.difficulty,
                decoration: InputDecoration(
                  labelText: 'Difficulty',
                  prefixIcon: const Icon(Icons.bar_chart),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: DifficultyLevel.values.map((diff) {
                  return DropdownMenuItem(
                    value: diff,
                    child: Text(diff.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) provider.setDifficulty(value);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                initialValue: provider.durationMinutes.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Duration (min)',
                  prefixIcon: const Icon(Icons.timer),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  final duration = int.tryParse(value);
                  if (duration != null) provider.setDuration(duration);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Summary Card
        Card(
          color: Colors.blue[50],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Questions:'),
                    Text(
                      '${provider.totalQuestions}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Estimated Marks:'),
                    Text(
                      '${provider.estimatedMarks}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCounter({
    required String label,
    required int value,
    required Function(int) onChanged,
  }) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: value > 0 ? () => onChanged(value - 1) : null,
            ),
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => onChanged(value + 1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenerateButton(WorksheetGeneratorProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: provider.isLoading ? null : () => _generateWorksheet(provider),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: provider.isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Icon(Icons.auto_awesome),
        label: Text(
          provider.isLoading ? 'Generating...' : 'Generate Worksheet',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'AI will generate questions based on your selected topics and configuration',
                style: TextStyle(
                  color: Colors.blue[900],
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return Colors.green;
      case DifficultyLevel.medium:
        return Colors.orange;
      case DifficultyLevel.hard:
        return Colors.red;
    }
  }

  Future<void> _generateWorksheet(WorksheetGeneratorProvider provider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a worksheet title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    final worksheet = await provider.generateWorksheet(
      title: _titleController.text,
      createdBy: user?.id ?? 'unknown',
      createdByName: user?.name ?? 'Unknown',
    );

    if (worksheet != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Worksheet generated successfully!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () => _showWorksheetDetail(worksheet),
          ),
        ),
      );

      // Clear form
      _titleController.clear();
      provider.resetConfiguration();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to generate worksheet'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showWorksheetDetail(WorksheetModel worksheet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(worksheet.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Questions: ${worksheet.questions.length}'),
              Text('Total Marks: ${worksheet.totalMarks}'),
              Text('Duration: ${worksheet.durationMinutes} minutes'),
              const SizedBox(height: 16),
              const Text('Topics:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...worksheet.topicNames.map((name) => Text('• $name')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              context.read<WorksheetGeneratorProvider>().generatePDF(worksheet);
            },
            icon: const Icon(Icons.download),
            label: const Text('Download PDF'),
          ),
        ],
      ),
    );
  }

  void _showMyWorksheetsDialog() {
    final provider = context.read<WorksheetGeneratorProvider>();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
          child: Column(
            children: [
              AppBar(
                title: const Text('My Worksheets'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(
                child: provider.worksheets.isEmpty
                    ? const Center(
                  child: Text('No worksheets generated yet'),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.worksheets.length,
                  itemBuilder: (context, index) {
                    final worksheet = provider.worksheets[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.description),
                        title: Text(worksheet.title),
                        subtitle: Text(
                          '${worksheet.questions.length} questions • ${worksheet.totalMarks} marks',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () {
                            provider.generatePDF(worksheet);
                          },
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _showWorksheetDetail(worksheet);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}