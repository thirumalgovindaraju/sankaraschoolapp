// lib/presentation/providers/worksheet_submission_provider.dart
// ✅ FIXED - All model imports and logic corrected

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../data/models/worksheet_generator_model.dart';
import '../../data/models/worksheet_submission_model.dart';

class WorksheetSubmissionProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<StudentSubmissionModel> _submissions = [];
  List<StudentSubmissionModel> _mySubmissions = [];
  bool _isLoading = false;
  String? _error;

  List<StudentSubmissionModel> get submissions => _submissions;
  List<StudentSubmissionModel> get mySubmissions => _mySubmissions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Upload image to Firebase Storage
  Future<String?> uploadImage(File imageFile) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'worksheet_images/$timestamp.jpg';

      final ref = _storage.ref().child(fileName);
      await ref.putFile(imageFile);

      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) print('❌ Error uploading image: $e');
      _error = 'Failed to upload image: $e';
      notifyListeners();
      return null;
    }
  }

  /// Submit worksheet
  Future<bool> submitWorksheet(StudentSubmissionModel submission) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore
          .collection('worksheet_submissions')
          .doc(submission.id)
          .set(submission.toMap());

      if (kDebugMode) print('✅ Worksheet submitted: ${submission.id}');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error submitting worksheet: $e');
      _error = 'Failed to submit: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Fetch student's own submissions
  Future<void> fetchMySubmissions(String studentId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('worksheet_submissions')
          .where('studentId', isEqualTo: studentId)
          .orderBy('submittedAt', descending: true)
          .get();

      _mySubmissions = snapshot.docs
          .map((doc) => StudentSubmissionModel.fromMap(doc.data()))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ Error fetching submissions: $e');
      _error = 'Failed to fetch submissions: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch all submissions for a worksheet (Teacher view)
  Future<void> fetchWorksheetSubmissions(String worksheetId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('worksheet_submissions')
          .where('worksheetId', isEqualTo: worksheetId)
          .orderBy('submittedAt', descending: true)
          .get();

      _submissions = snapshot.docs
          .map((doc) => StudentSubmissionModel.fromMap(doc.data()))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ Error fetching submissions: $e');
      _error = 'Failed to fetch submissions: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Grade a submission (Teacher)
  Future<bool> gradeSubmission({
    required String submissionId,
    required List<StudentAnswer> gradedAnswers,
    required int totalMarks,
    required int totalMarksAwarded,
    required String teacherFeedback,
    required String gradedBy,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Calculate percentage
      final percentage = totalMarks > 0
          ? (totalMarksAwarded / totalMarks) * 100
          : 0.0;

      // Determine grade based on percentage
      String grade = 'F';
      if (percentage >= 90) {
        grade = 'A*';
      } else if (percentage >= 80) {
        grade = 'A';
      } else if (percentage >= 70) {
        grade = 'B';
      } else if (percentage >= 60) {
        grade = 'C';
      } else if (percentage >= 50) {
        grade = 'D';
      } else if (percentage >= 40) {
        grade = 'E';
      }

      await _firestore
          .collection('worksheet_submissions')
          .doc(submissionId)
          .update({
        'answers': gradedAnswers.map((a) => a.toMap()).toList(),
        'marksObtained': totalMarksAwarded,
        'teacherFeedback': teacherFeedback,
        'gradedAt': Timestamp.fromDate(DateTime.now()),
        'gradedBy': gradedBy,
        'status': SubmissionStatus.graded.toString().split('.').last,
        'percentage': percentage,
        'grade': grade,
      });

      if (kDebugMode) print('✅ Submission graded: $submissionId');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error grading submission: $e');
      _error = 'Failed to grade: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Auto-grade MCQ questions
  List<StudentAnswer> autoGradeMCQs(
      List<StudentAnswer> answers,
      List<Question> questions,
      ) {
    List<StudentAnswer> gradedAnswers = [];

    for (var answer in answers) {
      try {
        // Find the corresponding question
        final question = questions.firstWhere(
              (q) => q.id == answer.questionId,
          orElse: () => questions.first,
        );

        // Check if it's an MCQ question
        if (question.type == QuestionType.mcq) {
          final isCorrect = answer.answer?.trim().toUpperCase() ==
              question.correctAnswer?.trim().toUpperCase();

          // Create graded answer
          gradedAnswers.add(answer.copyWith(
            marksAwarded: isCorrect ? question.marks : 0,
            isCorrect: isCorrect,
            feedback: isCorrect
                ? 'Correct!'
                : 'Incorrect. Correct answer: ${question.correctAnswer}',
          ));
        } else {
          // For non-MCQ questions, keep original answer without grading
          gradedAnswers.add(answer);
        }
      } catch (e) {
        if (kDebugMode) print('⚠️ Error auto-grading question ${answer.questionId}: $e');
        // If there's an error, keep the original answer
        gradedAnswers.add(answer);
      }
    }

    return gradedAnswers;
  }

  /// Create a new submission draft
  StudentSubmissionModel createSubmissionDraft({
    required String worksheetId,
    required String worksheetTitle,
    required String studentId,
    required String studentName,
    required int totalMarks,
    String? studentClass,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return StudentSubmissionModel(
      id: 'submission_$timestamp',
      worksheetId: worksheetId,
      worksheetTitle: worksheetTitle,
      studentId: studentId,
      studentName: studentName,
      studentClass: studentClass,
      submittedAt: DateTime.now(),
      answers: [],
      totalMarks: totalMarks,
      status: SubmissionStatus.draft,
      timeTakenSeconds: 0,
    );
  }

  /// Update answer in submission
  StudentSubmissionModel updateAnswer({
    required StudentSubmissionModel submission,
    required String questionId,
    required int questionNumber,
    String? answer,
    List<String>? attachmentUrls,
  }) {
    final List<StudentAnswer> updatedAnswers = List.from(submission.answers);

    // Find if answer already exists
    final existingIndex = updatedAnswers.indexWhere(
          (a) => a.questionId == questionId,
    );

    final newAnswer = StudentAnswer(
      questionId: questionId,
      questionNumber: questionNumber,
      answer: answer,
      attachmentUrls: attachmentUrls,
    );

    if (existingIndex != -1) {
      // Update existing answer
      updatedAnswers[existingIndex] = newAnswer;
    } else {
      // Add new answer
      updatedAnswers.add(newAnswer);
    }

    // Return updated submission (you'd need to add a copyWith method to StudentSubmissionModel)
    return StudentSubmissionModel(
      id: submission.id,
      worksheetId: submission.worksheetId,
      worksheetTitle: submission.worksheetTitle,
      studentId: submission.studentId,
      studentName: submission.studentName,
      studentClass: submission.studentClass,
      submittedAt: submission.submittedAt,
      answers: updatedAnswers,
      totalMarks: submission.totalMarks,
      marksObtained: submission.marksObtained,
      percentage: submission.percentage,
      grade: submission.grade,
      status: submission.status,
      teacherFeedback: submission.teacherFeedback,
      gradedAt: submission.gradedAt,
      gradedBy: submission.gradedBy,
      timeTakenSeconds: submission.timeTakenSeconds,
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}