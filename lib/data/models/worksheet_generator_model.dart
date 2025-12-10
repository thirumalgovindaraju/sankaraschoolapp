// lib/data/models/worksheet_generator_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// ========================================
// TEXTBOOK MODELS
// ========================================

class Textbook {
  final String id;
  final String title;
  final String subject;
  final String board;
  final String grade;
  final String? publisher;
  final String? edition;
  final String? pdfUrl;
  final DateTime uploadedAt;
  final String status; // 'processing', 'ready', 'failed'
  final List<Chapter> chapters;
  final String? errorMessage;

  Textbook({
    required this.id,
    required this.title,
    required this.subject,
    required this.board,
    required this.grade,
    this.publisher,
    this.edition,
    this.pdfUrl,
    required this.uploadedAt,
    required this.status,
    required this.chapters,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subject': subject,
    'board': board,
    'grade': grade,
    'publisher': publisher,
    'edition': edition,
    'pdfUrl': pdfUrl,
    'uploadedAt': Timestamp.fromDate(uploadedAt),
    'status': status,
    'chapters': chapters.map((c) => c.toJson()).toList(),
    'errorMessage': errorMessage,
  };

  factory Textbook.fromJson(Map<String, dynamic> json) => Textbook(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    subject: json['subject'] ?? '',
    board: json['board'] ?? '',
    grade: json['grade'] ?? '',
    publisher: json['publisher'],
    edition: json['edition'],
    pdfUrl: json['pdfUrl'],
    uploadedAt: (json['uploadedAt'] as Timestamp).toDate(),
    status: json['status'] ?? 'processing',
    chapters: json['chapters'] != null
        ? (json['chapters'] as List).map((c) => Chapter.fromJson(c)).toList()
        : [],
    errorMessage: json['errorMessage'],
  );
}

class Chapter {
  final String id;
  final String title;
  final int chapterNumber;
  final List<Topic> topics;
  final String? summary;

  Chapter({
    required this.id,
    required this.title,
    required this.chapterNumber,
    required this.topics,
    this.summary,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'chapterNumber': chapterNumber,
    'topics': topics.map((t) => t.toJson()).toList(),
    'summary': summary,
  };

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    chapterNumber: json['chapterNumber'] ?? 0,
    topics: json['topics'] != null
        ? (json['topics'] as List).map((t) => Topic.fromJson(t)).toList()
        : [],
    summary: json['summary'],
  );
}

// Fixed Topic class with correct fromJson constructor

class Topic {
  final String id;
  final String name;
  final String title;
  final List<String> keywords;
  final String? description;
  final DifficultyLevel difficulty;

  Topic({
    required this.id,
    required this.title,
    required this.keywords,
    required this.name,
    required this.description,
    required this.difficulty,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,  // ✅ Added
    'title': title,
    'keywords': keywords,
    'description': description,
    'difficulty': difficulty.toString().split('.').last,  // ✅ Added
  };

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? json['title'] as String? ?? '',  // ✅ Fallback to title if name is missing
      title: json['title'] as String? ?? '',  // ✅ Added title parameter
      keywords: json['keywords'] != null
          ? List<String>.from(json['keywords'] as List)
          : [],  // ✅ Added keywords parameter
      description: json['description'] as String?,
      difficulty: json['difficulty'] != null
          ? DifficultyLevel.values.firstWhere(
            (e) => e.toString().split('.').last == json['difficulty'],
        orElse: () => DifficultyLevel.medium,
      )
          : DifficultyLevel.medium,
    );
  }
}

// ========================================
// WORKSHEET MODELS
// ========================================

class WorksheetModel {
  final String id;
  final String title;
  final String textbookId;
  final String? textbookTitle;
  final List<String> topicIds;
  final List<String> topicNames;
  final List<Question> questions;
  final int totalMarks;
  final int durationMinutes;
  final DateTime createdAt;
  final String createdBy;
  final String? createdByName;
  final List<String> assignedToStudents;
  final List<String> assignedToClasses;
  final String status; // 'draft', 'published', 'archived'
  final List<WorksheetSubmission>? submissions;
  final String overallDifficulty; // ✅ ADDED

  WorksheetModel({
    required this.id,
    required this.title,
    required this.textbookId,
    this.textbookTitle,
    required this.topicIds,
    required this.topicNames,
    required this.questions,
    required this.totalMarks,
    required this.durationMinutes,
    required this.createdAt,
    required this.createdBy,
    this.createdByName,
    this.assignedToStudents = const [],
    this.assignedToClasses = const [],
    this.status = 'draft',
    this.submissions,
    this.overallDifficulty = 'medium', // ✅ ADDED
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'textbookId': textbookId,
    'textbookTitle': textbookTitle,
    'topicIds': topicIds,
    'topicNames': topicNames,
    'questions': questions.map((q) => q.toJson()).toList(),
    'totalMarks': totalMarks,
    'durationMinutes': durationMinutes,
    'createdAt': Timestamp.fromDate(createdAt),
    'createdBy': createdBy,
    'createdByName': createdByName,
    'assignedToStudents': assignedToStudents,
    'assignedToClasses': assignedToClasses,
    'status': status,
    'submissions': submissions?.map((s) => s.toJson()).toList(),
    'overallDifficulty': overallDifficulty,
  };

  factory WorksheetModel.fromJson(Map<String, dynamic> json) => WorksheetModel(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    textbookId: json['textbookId'] ?? '',
    textbookTitle: json['textbookTitle'],
    topicIds: List<String>.from(json['topicIds'] ?? []),
    topicNames: List<String>.from(json['topicNames'] ?? []),
    questions: json['questions'] != null
        ? (json['questions'] as List).map((q) => Question.fromJson(q)).toList()
        : [],
    totalMarks: json['totalMarks'] ?? 0,
    durationMinutes: json['durationMinutes'] ?? 0,
    createdAt: (json['createdAt'] as Timestamp).toDate(),
    createdBy: json['createdBy'] ?? '',
    createdByName: json['createdByName'],
    assignedToStudents: List<String>.from(json['assignedToStudents'] ?? []),
    assignedToClasses: List<String>.from(json['assignedToClasses'] ?? []),
    status: json['status'] ?? 'draft',
    submissions: json['submissions'] != null
        ? (json['submissions'] as List)
        .map((s) => WorksheetSubmission.fromJson(s))
        .toList()
        : null,
    overallDifficulty: json['overallDifficulty'] ?? 'medium',
  );
}

class Question {
  final String id;
  final int questionNumber;
  final QuestionType type;
  final String questionText;
  final List<String>? options; // For MCQ
  final String? correctAnswer;
  final int marks;
  final String? hint;

  Question({
    required this.id,
    required this.questionNumber,
    required this.type,
    required this.questionText,
    this.options,
    this.correctAnswer,
    required this.marks,
    this.hint,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'questionNumber': questionNumber,
    'type': type.name,
    'questionText': questionText,
    'options': options,
    'correctAnswer': correctAnswer,
    'marks': marks,
    'hint': hint,
  };

  factory Question.fromJson(Map<String, dynamic> json) => Question(
    id: json['id'] ?? '',
    questionNumber: json['questionNumber'] ?? 0,
    type: QuestionType.values.firstWhere(
          (e) => e.name == json['type'],
      orElse: () => QuestionType.mcq,
    ),
    questionText: json['questionText'] ?? '',
    options: json['options'] != null ? List<String>.from(json['options']) : null,
    correctAnswer: json['correctAnswer'],
    marks: json['marks'] ?? 0,
    hint: json['hint'],
  );
}

class WorksheetSubmission {
  final String studentId;
  final String studentName;
  final DateTime submittedAt;
  final int score;
  final int totalMarks;
  final List<Map<String, dynamic>> answers;
  final int timeTaken; // in seconds

  WorksheetSubmission({
    required this.studentId,
    required this.studentName,
    required this.submittedAt,
    required this.score,
    required this.totalMarks,
    required this.answers,
    required this.timeTaken,
  });

  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'studentName': studentName,
    'submittedAt': Timestamp.fromDate(submittedAt),
    'score': score,
    'totalMarks': totalMarks,
    'answers': answers,
    'timeTaken': timeTaken,
  };

  factory WorksheetSubmission.fromJson(Map<String, dynamic> json) =>
      WorksheetSubmission(
        studentId: json['studentId'] ?? '',
        studentName: json['studentName'] ?? '',
        submittedAt: (json['submittedAt'] as Timestamp).toDate(),
        score: json['score'] ?? 0,
        totalMarks: json['totalMarks'] ?? 0,
        answers: List<Map<String, dynamic>>.from(json['answers'] ?? []),
        timeTaken: json['timeTaken'] ?? 0,
      );
}

// ========================================
// ENUMS
// ========================================

enum QuestionType {
  mcq,
  trueFalse,
  fillInTheBlank,
  shortAnswer,
  longAnswer,
}
// In worksheet_generator_model.dart

enum DifficultyLevel {
  easy,
  medium,
  hard,
}

// ========================================
// ENUMS
// ========================================


enum WorksheetType {
  practice,      // Practice worksheets for self-study
  homework,      // Homework assignments
  classwork,     // In-class worksheets
  test,          // Formal tests/exams
  quiz,          // Short quizzes
  revision,      // Revision/review materials
}
// ========================================
// BACKWARD COMPATIBILITY ALIASES
// ========================================

// These allow old code to still work
typedef TextbookModel = Textbook;
typedef ChapterModel = Chapter;
typedef TopicModel = Topic;
typedef QuestionModel = Question;