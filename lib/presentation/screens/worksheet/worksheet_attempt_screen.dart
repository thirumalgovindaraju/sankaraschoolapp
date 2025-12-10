// lib/presentation/screens/worksheets/worksheet_attempt_screen.dart
// ✅ Student Worksheet Attempt Screen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/worksheet_generator_model.dart';
import '../../providers/worksheet_generator_provider.dart';
import '../../providers/auth_provider.dart';
import 'dart:async';

class WorksheetAttemptScreen extends StatefulWidget {
  final WorksheetModel worksheet;

  const WorksheetAttemptScreen({Key? key, required this.worksheet}) : super(key: key);

  @override
  State<WorksheetAttemptScreen> createState() => _WorksheetAttemptScreenState();
}

class _WorksheetAttemptScreenState extends State<WorksheetAttemptScreen> {
  final Map<String, dynamic> _answers = {};
  int _currentQuestionIndex = 0;
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.worksheet.durationMinutes * 60;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        _autoSubmit();
      }
    });
  }

  void _autoSubmit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⏰ Time is up! Submitting your answers...'),
        backgroundColor: Colors.orange,
      ),
    );
    _submitWorksheet();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _submitWorksheet() async {
    if (_isSubmitting) return;

    final unansweredCount = widget.worksheet.questions.length - _answers.length;

    if (unansweredCount > 0) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('⚠️ Incomplete Submission'),
          content: Text(
            'You have $unansweredCount unanswered question${unansweredCount > 1 ? 's' : ''}. Do you want to submit anyway?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Submit Anyway'),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final studentId = authProvider.currentUser?.id ?? '';
      final studentName = authProvider.currentUser?.name ?? 'Unknown';

      // Calculate score
      int score = 0;
      final List<Map<String, dynamic>> detailedAnswers = [];

      for (var i = 0; i < widget.worksheet.questions.length; i++) {
        final question = widget.worksheet.questions[i];
        final studentAnswer = _answers['q_$i'];
        final isCorrect = _checkAnswer(question, studentAnswer);

        if (isCorrect) {
          score += question.marks;
        }

        detailedAnswers.add({
          'questionIndex': i,
          'studentAnswer': studentAnswer,
          'correctAnswer': question.correctAnswer,
          'isCorrect': isCorrect,
          'marks': isCorrect ? question.marks : 0,
        });
      }

      // Create submission
      final submission = {
        'studentId': studentId,
        'studentName': studentName,
        'submittedAt': DateTime.now(),
        'score': score,
        'totalMarks': widget.worksheet.totalMarks,
        'answers': detailedAnswers,
        'timeTaken': (widget.worksheet.durationMinutes * 60) - _remainingSeconds,
      };

      // Save submission
      await context.read<WorksheetGeneratorProvider>().submitWorksheet(
        widget.worksheet.id,
        submission,
      );

      _timer?.cancel();

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/worksheet-result',
          arguments: {
            'worksheet': widget.worksheet,
            'submission': submission,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting worksheet: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _checkAnswer(Question question, dynamic studentAnswer) {
    if (studentAnswer == null) return false;

    switch (question.type) {
      case QuestionType.mcq:
        return studentAnswer == question.correctAnswer;
      case QuestionType.trueFalse:
        return studentAnswer.toString().toLowerCase() ==
            question.correctAnswer.toString().toLowerCase();
      case QuestionType.fillInTheBlank:
        return studentAnswer.toString().trim().toLowerCase() ==
            question.correctAnswer.toString().trim().toLowerCase();
      case QuestionType.shortAnswer:
      // For short answers, accept if any key phrase matches
        final studentText = studentAnswer.toString().toLowerCase();
        final correctText = question.correctAnswer.toString().toLowerCase();
        return studentText.contains(correctText) || correctText.contains(studentText);
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.worksheet.questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / widget.worksheet.questions.length;

    return WillPopScope(
      onWillPop: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('⚠️ Exit Worksheet?'),
            content: const Text(
              'Are you sure you want to exit? Your progress will be lost.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        return confirm ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.worksheet.title),
          backgroundColor: Colors.purple[700],
          actions: [
            // Timer Display
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _remainingSeconds < 300 ? Colors.red : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer,
                    color: _remainingSeconds < 300 ? Colors.white : Colors.purple[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(_remainingSeconds),
                    style: TextStyle(
                      color: _remainingSeconds < 300 ? Colors.white : Colors.purple[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[700]!),
              minHeight: 6,
            ),

            // Question Counter
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.purple[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${_currentQuestionIndex + 1} of ${widget.worksheet.questions.length}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[700],
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${currentQuestion.marks} marks',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Question Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Text
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.purple[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    _getQuestionIcon(currentQuestion.type),
                                    color: Colors.purple[700],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _getQuestionTypeName(currentQuestion.type),
                                    style: TextStyle(
                                      color: Colors.purple[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              currentQuestion.questionText,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Answer Options
                    _buildAnswerSection(currentQuestion),
                  ],
                ),
              ),
            ),

            // Navigation Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_currentQuestionIndex > 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _currentQuestionIndex--;
                          });
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Previous'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  if (_currentQuestionIndex > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting
                          ? null
                          : () {
                        if (_currentQuestionIndex < widget.worksheet.questions.length - 1) {
                          setState(() {
                            _currentQuestionIndex++;
                          });
                        } else {
                          _submitWorksheet();
                        }
                      },
                      icon: Icon(
                        _currentQuestionIndex < widget.worksheet.questions.length - 1
                            ? Icons.arrow_forward
                            : Icons.check_circle,
                      ),
                      label: Text(
                        _currentQuestionIndex < widget.worksheet.questions.length - 1
                            ? 'Next'
                            : _isSubmitting
                            ? 'Submitting...'
                            : 'Submit',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[700],
                        padding: const EdgeInsets.symmetric(vertical: 16),
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

  Widget _buildAnswerSection(Question question) {
    final answerId = 'q_$_currentQuestionIndex';

    switch (question.type) {
      case QuestionType.mcq:
        return Column(
          children: (question.options ?? []).map((option) {
            final isSelected = _answers[answerId] == option;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: isSelected ? Colors.purple[50] : null,
              child: RadioListTile<String>(
                value: option,
                groupValue: _answers[answerId],
                onChanged: (value) {
                  setState(() {
                    _answers[answerId] = value;
                  });
                },
                title: Text(
                  option,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                activeColor: Colors.purple[700],
              ),
            );
          }).toList(),
        );

      case QuestionType.trueFalse:
        return Column(
          children: ['True', 'False'].map((option) {
            final isSelected = _answers[answerId] == option;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: isSelected ? Colors.purple[50] : null,
              child: RadioListTile<String>(
                value: option,
                groupValue: _answers[answerId],
                onChanged: (value) {
                  setState(() {
                    _answers[answerId] = value;
                  });
                },
                title: Text(
                  option,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
                activeColor: Colors.purple[700],
              ),
            );
          }).toList(),
        );

      case QuestionType.fillInTheBlank:
      case QuestionType.shortAnswer:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: TextEditingController(text: _answers[answerId] ?? ''),
              onChanged: (value) {
                _answers[answerId] = value;
              },
              maxLines: question.type == QuestionType.shortAnswer ? 5 : 1,
              decoration: InputDecoration(
                hintText: question.type == QuestionType.fillInTheBlank
                    ? 'Type your answer here...'
                    : 'Write your answer here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.purple[700]!, width: 2),
                ),
              ),
            ),
          ),
        );

      default:
        return const Text('Unsupported question type');
    }
  }

  IconData _getQuestionIcon(QuestionType type) {
    switch (type) {
      case QuestionType.mcq:
        return Icons.radio_button_checked;
      case QuestionType.trueFalse:
        return Icons.check_circle;
      case QuestionType.fillInTheBlank:
        return Icons.text_fields;
      case QuestionType.shortAnswer:
        return Icons.notes;
      default:
        return Icons.help;
    }
  }

  String _getQuestionTypeName(QuestionType type) {
    switch (type) {
      case QuestionType.mcq:
        return 'Multiple Choice';
      case QuestionType.trueFalse:
        return 'True/False';
      case QuestionType.fillInTheBlank:
        return 'Fill in the Blank';
      case QuestionType.shortAnswer:
        return 'Short Answer';
      default:
        return 'Question';
    }
  }
}