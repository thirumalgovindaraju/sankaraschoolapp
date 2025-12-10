// lib/data/models/worksheet_submission_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// ========================================
// SUBMISSION MODELS
// ========================================

/// Student's submission of a worksheet
class StudentSubmissionModel {
  final String id;
  final String worksheetId;
  final String worksheetTitle;
  final String studentId;
  final String studentName;
  final String? studentClass;
  final DateTime submittedAt;
  final List<StudentAnswer> answers;
  final int totalMarks;
  final int? marksObtained;
  final double? percentage;
  final String? grade;
  final SubmissionStatus status;
  final String? teacherFeedback;
  final DateTime? gradedAt;
  final String? gradedBy;
  final int timeTakenSeconds;

  StudentSubmissionModel({
    required this.id,
    required this.worksheetId,
    required this.worksheetTitle,
    required this.studentId,
    required this.studentName,
    this.studentClass,
    required this.submittedAt,
    required this.answers,
    required this.totalMarks,
    this.marksObtained,
    this.percentage,
    this.grade,
    required this.status,
    this.teacherFeedback,
    this.gradedAt,
    this.gradedBy,
    required this.timeTakenSeconds,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'worksheetId': worksheetId,
    'worksheetTitle': worksheetTitle,
    'studentId': studentId,
    'studentName': studentName,
    'studentClass': studentClass,
    'submittedAt': Timestamp.fromDate(submittedAt),
    'answers': answers.map((a) => a.toMap()).toList(),
    'totalMarks': totalMarks,
    'marksObtained': marksObtained,
    'percentage': percentage,
    'grade': grade,
    'status': status.toString().split('.').last,
    'teacherFeedback': teacherFeedback,
    'gradedAt': gradedAt != null ? Timestamp.fromDate(gradedAt!) : null,
    'gradedBy': gradedBy,
    'timeTakenSeconds': timeTakenSeconds,
  };

  factory StudentSubmissionModel.fromMap(Map<String, dynamic> map) {
    return StudentSubmissionModel(
      id: map['id'] ?? '',
      worksheetId: map['worksheetId'] ?? '',
      worksheetTitle: map['worksheetTitle'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      studentClass: map['studentClass'],
      submittedAt: (map['submittedAt'] as Timestamp).toDate(),
      answers: (map['answers'] as List<dynamic>?)
          ?.map((a) => StudentAnswer.fromMap(a as Map<String, dynamic>))
          .toList() ??
          [],
      totalMarks: map['totalMarks'] ?? 0,
      marksObtained: map['marksObtained'],
      percentage: map['percentage']?.toDouble(),
      grade: map['grade'],
      status: _parseSubmissionStatus(map['status']),
      teacherFeedback: map['teacherFeedback'],
      gradedAt: map['gradedAt'] != null
          ? (map['gradedAt'] as Timestamp).toDate()
          : null,
      gradedBy: map['gradedBy'],
      timeTakenSeconds: map['timeTakenSeconds'] ?? 0,
    );
  }

  static SubmissionStatus _parseSubmissionStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'submitted':
        return SubmissionStatus.submitted;
      case 'graded':
        return SubmissionStatus.graded;
      case 'returned':
        return SubmissionStatus.returned;
      case 'draft':
      default:
        return SubmissionStatus.draft;
    }
  }

  // Helper method to calculate if passed
  bool get isPassed => percentage != null && percentage! >= 40;

  // Helper method to get status color
  String get statusColor {
    switch (status) {
      case SubmissionStatus.draft:
        return 'gray';
      case SubmissionStatus.submitted:
        return 'blue';
      case SubmissionStatus.graded:
        return 'green';
      case SubmissionStatus.returned:
        return 'purple';
    }
  }
}

/// Student's answer to a single question
class StudentAnswer {
  final String questionId;
  final int questionNumber;
  final String? answer;
  final List<String>? attachmentUrls; // For image uploads
  final int? marksAwarded;
  final bool? isCorrect;
  final String? feedback;

  StudentAnswer({
    required this.questionId,
    required this.questionNumber,
    this.answer,
    this.attachmentUrls,
    this.marksAwarded,
    this.isCorrect,
    this.feedback,
  });

  Map<String, dynamic> toMap() => {
    'questionId': questionId,
    'questionNumber': questionNumber,
    'answer': answer,
    'attachmentUrls': attachmentUrls,
    'marksAwarded': marksAwarded,
    'isCorrect': isCorrect,
    'feedback': feedback,
  };

  factory StudentAnswer.fromMap(Map<String, dynamic> map) {
    return StudentAnswer(
      questionId: map['questionId'] ?? '',
      questionNumber: map['questionNumber'] ?? 0,
      answer: map['answer'],
      attachmentUrls: map['attachmentUrls'] != null
          ? List<String>.from(map['attachmentUrls'])
          : null,
      marksAwarded: map['marksAwarded'],
      isCorrect: map['isCorrect'],
      feedback: map['feedback'],
    );
  }

  // Create a copy with updated values
  StudentAnswer copyWith({
    String? questionId,
    int? questionNumber,
    String? answer,
    List<String>? attachmentUrls,
    int? marksAwarded,
    bool? isCorrect,
    String? feedback,
  }) {
    return StudentAnswer(
      questionId: questionId ?? this.questionId,
      questionNumber: questionNumber ?? this.questionNumber,
      answer: answer ?? this.answer,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      marksAwarded: marksAwarded ?? this.marksAwarded,
      isCorrect: isCorrect ?? this.isCorrect,
      feedback: feedback ?? this.feedback,
    );
  }
}

/// Question model reference (if not already in your main model file)
class QuestionModel {
  final String id;
  final int questionNumber;
  final String type;
  final String questionText;
  final List<String>? options;
  final String? correctAnswer;
  final int marks;
  final String? hint;

  QuestionModel({
    required this.id,
    required this.questionNumber,
    required this.type,
    required this.questionText,
    this.options,
    this.correctAnswer,
    required this.marks,
    this.hint,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'questionNumber': questionNumber,
    'type': type,
    'questionText': questionText,
    'options': options,
    'correctAnswer': correctAnswer,
    'marks': marks,
    'hint': hint,
  };

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id'] ?? '',
      questionNumber: map['questionNumber'] ?? 0,
      type: map['type'] ?? 'mcq',
      questionText: map['questionText'] ?? '',
      options: map['options'] != null
          ? List<String>.from(map['options'])
          : null,
      correctAnswer: map['correctAnswer'],
      marks: map['marks'] ?? 0,
      hint: map['hint'],
    );
  }
}

// ========================================
// ENUMS
// ========================================

enum SubmissionStatus {
  draft,      // Student is still working on it
  submitted,  // Student has submitted
  graded,     // Teacher has graded it
  returned,   // Graded submission returned to student
}

// ========================================
// EXTENSIONS
// ========================================

extension SubmissionStatusExtension on SubmissionStatus {
  String get displayName {
    switch (this) {
      case SubmissionStatus.draft:
        return 'Draft';
      case SubmissionStatus.submitted:
        return 'Submitted';
      case SubmissionStatus.graded:
        return 'Graded';
      case SubmissionStatus.returned:
        return 'Returned';
    }
  }

  String get description {
    switch (this) {
      case SubmissionStatus.draft:
        return 'Work in progress';
      case SubmissionStatus.submitted:
        return 'Waiting for grading';
      case SubmissionStatus.graded:
        return 'Graded by teacher';
      case SubmissionStatus.returned:
        return 'Available to view';
    }
  }
}