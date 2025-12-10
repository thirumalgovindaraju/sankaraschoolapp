// lib/presentation/providers/worksheet_generator_provider.dart
// ✅ COMPLETE FIX - Changed difficulty from String to DifficultyLevel

import 'package:flutter/material.dart';
import '../../data/models/worksheet_generator_model.dart';
import '../../data/services/pdf_processor_service.dart';
import '../../data/services/worksheet_generator_service.dart';

class WorksheetGeneratorProvider extends ChangeNotifier {
  // State
  List<Textbook> _textbooks = [];
  List<WorksheetModel> _worksheets = [];
  Textbook? _selectedTextbook;
  List<Topic> _selectedTopics = [];
  bool _isLoading = false;
  String? _error;

  // Worksheet configuration
  int _mcqCount = 10;
  int _shortAnswerCount = 5;
  int _longAnswerCount = 2;
  DifficultyLevel _difficulty = DifficultyLevel.medium; // ✅ Changed from String to DifficultyLevel
  int _durationMinutes = 60;
  String _worksheetType = 'practice';

  // Getters
  List<Textbook> get textbooks => _textbooks;
  List<WorksheetModel> get worksheets => _worksheets;
  Textbook? get selectedTextbook => _selectedTextbook;
  List<Topic> get selectedTopics => _selectedTopics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get mcqCount => _mcqCount;
  int get shortAnswerCount => _shortAnswerCount;
  int get longAnswerCount => _longAnswerCount;
  DifficultyLevel get difficulty => _difficulty; // ✅ Returns DifficultyLevel instead of String
  int get durationMinutes => _durationMinutes;
  String get worksheetType => _worksheetType;

  int get totalQuestions => _mcqCount + _shortAnswerCount + _longAnswerCount;
  int get estimatedMarks =>
      (_mcqCount * 2) + (_shortAnswerCount * 4) + (_longAnswerCount * 8);

  // Initialize
  Future<void> init() async {
    await loadTextbooks();
    await loadWorksheets();
  }

  // Load all textbooks
  Future<void> loadTextbooks() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _textbooks = await PDFProcessorService.getTextbooks();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load textbooks: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Upload new textbook
  Future<bool> uploadTextbook({
    required String title,
    required String subject,
    required String board,
    required String grade,
    required String uploadedBy,
    String? publisher,
    String? edition,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final textbook = await PDFProcessorService.uploadTextbook(
        title: title,
        subject: subject,
        board: board,
        grade: grade,
        uploadedBy: uploadedBy,
        publisher: publisher,
        edition: edition,
      );

      if (textbook != null) {
        _textbooks.insert(0, textbook);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Failed to upload textbook';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Upload error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Select textbook
  void selectTextbook(Textbook textbook) {
    _selectedTextbook = textbook;
    _selectedTopics = []; // Reset topic selection
    notifyListeners();
  }

  // Get all topics from selected textbook
  List<Topic> getAllTopics() {
    if (_selectedTextbook == null) return [];

    List<Topic> allTopics = [];
    for (var chapter in _selectedTextbook!.chapters) {
      allTopics.addAll(chapter.topics);
    }
    return allTopics;
  }

  // Toggle topic selection
  void toggleTopic(Topic topic) {
    if (_selectedTopics.any((t) => t.id == topic.id)) {
      _selectedTopics.removeWhere((t) => t.id == topic.id);
    } else {
      _selectedTopics.add(topic);
    }
    notifyListeners();
  }

  // Select all topics in a chapter
  void selectChapterTopics(Chapter chapter, bool select) {
    if (select) {
      for (var topic in chapter.topics) {
        if (!_selectedTopics.any((t) => t.id == topic.id)) {
          _selectedTopics.add(topic);
        }
      }
    } else {
      _selectedTopics.removeWhere(
            (t) => chapter.topics.any((ct) => ct.id == t.id),
      );
    }
    notifyListeners();
  }

  // Set worksheet configuration
  void setMCQCount(int count) {
    _mcqCount = count;
    notifyListeners();
  }

  void setShortAnswerCount(int count) {
    _shortAnswerCount = count;
    notifyListeners();
  }

  void setLongAnswerCount(int count) {
    _longAnswerCount = count;
    notifyListeners();
  }

  void setDifficulty(DifficultyLevel difficulty) { // ✅ Changed parameter type from dynamic to DifficultyLevel
    _difficulty = difficulty;
    notifyListeners();
  }

  void setDuration(int minutes) {
    _durationMinutes = minutes;
    notifyListeners();
  }

  void setWorksheetType(dynamic type) {
    if (type is WorksheetType) {
      _worksheetType = type.name;
    } else if (type is String) {
      _worksheetType = type;
    }
    notifyListeners();
  }

  // Generate worksheet - calling the service directly
  Future<WorksheetModel?> generateWorksheet({
    required String title,
    required String createdBy,
    required String createdByName,
  }) async {
    if (_selectedTextbook == null || _selectedTopics.isEmpty) {
      _error = 'Please select textbook and topics';
      notifyListeners();
      return null;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Call the service method with all required parameters
      final worksheet = await WorksheetGeneratorService.generateWorksheet(
        title: title,
        textbook: _selectedTextbook!,
        selectedTopics: _selectedTopics,
        mcqCount: _mcqCount,
        shortAnswerCount: _shortAnswerCount,
        longAnswerCount: _longAnswerCount,
        difficulty: _difficulty.name, // ✅ Convert enum to string for service
        durationMinutes: _durationMinutes,
        createdBy: createdBy,
        createdByName: createdByName,
        type: _worksheetType,
      );

      if (worksheet != null) {
        _worksheets.insert(0, worksheet);
      }

      _isLoading = false;
      notifyListeners();
      return worksheet;
    } catch (e) {
      _error = 'Generation failed: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Load worksheets - using the service
  Future<void> loadWorksheets() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Call the service method
      _worksheets = await WorksheetGeneratorService.fetchWorksheets();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load worksheets: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Generate PDF - using the service
  Future<void> generatePDF(WorksheetModel worksheet) async {
    try {
      _isLoading = true;
      notifyListeners();

      await WorksheetGeneratorService.generateAndPrintPDF(worksheet);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'PDF generation failed: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Assign worksheet - using the service
  Future<bool> assignWorksheet({
    required String worksheetId,
    List<String>? studentIds,
    List<String>? classIds,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await WorksheetGeneratorService.assignWorksheet(
        worksheetId: worksheetId,
        studentIds: studentIds,
        classIds: classIds,
      );

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Assignment failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Submit worksheet
  Future<bool> submitWorksheet(
      String worksheetId,
      Map<String, dynamic> submission,
      ) async {
    try {
      final worksheetSubmission = WorksheetSubmission(
        studentId: submission['studentId'],
        studentName: submission['studentName'],
        submittedAt: submission['submittedAt'],
        score: submission['score'],
        totalMarks: submission['totalMarks'],
        answers: List<Map<String, dynamic>>.from(submission['answers']),
        timeTaken: submission['timeTaken'],
      );

      return await WorksheetGeneratorService.submitWorksheet(
        worksheetId,
        worksheetSubmission,
      );
    } catch (e) {
      _error = 'Submission failed: $e';
      notifyListeners();
      return false;
    }
  }

  // Reset configuration
  void resetConfiguration() {
    _selectedTextbook = null;
    _selectedTopics = [];
    _mcqCount = 10;
    _shortAnswerCount = 5;
    _longAnswerCount = 2;
    _difficulty = DifficultyLevel.medium; // ✅ Reset to enum instead of string
    _durationMinutes = 60;
    _worksheetType = 'practice';
    _error = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}