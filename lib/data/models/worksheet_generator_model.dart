// lib/data/models/worksheet_generator_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Textbook model for storing uploaded PDFs and their content
class TextbookModel {
  final String id;
  final String title;
  final String subject;
  final String board; // IGCSE, CBSE, IB
  final String grade; // Year 9, 10, 11
  final String pdfUrl; // Firebase Storage URL
  final List<ChapterModel> chapters;
  final DateTime uploadedAt;
  final String uploadedBy;
  final int totalPages;
  final String? publisher;
  final String? edition;
  final ProcessingStatus processingStatus;

  TextbookModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.board,
    required this.grade,
    required this.pdfUrl,
    required this.chapters,
    required this.uploadedAt,
    required this.uploadedBy,
    required this.totalPages,
    this.publisher,
    this.edition,
    this.processingStatus = ProcessingStatus.pending,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'board': board,
      'grade': grade,
      'pdfUrl': pdfUrl,
      'chapters': chapters.map((c) => c.toMap()).toList(),
      'uploadedAt': uploadedAt,
      'uploadedBy': uploadedBy,
      'totalPages': totalPages,
      'publisher': publisher,
      'edition': edition,
      'processingStatus': processingStatus.toString(),
    };
  }

  factory TextbookModel.fromMap(Map<String, dynamic> map) {
    return TextbookModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      board: map['board'] ?? '',
      grade: map['grade'] ?? '',
      pdfUrl: map['pdfUrl'] ?? '',
      chapters: (map['chapters'] as List?)
          ?.map((c) => ChapterModel.fromMap(c))
          .toList() ??
          [],
      uploadedAt: (map['uploadedAt'] as Timestamp).toDate(),
      uploadedBy: map['uploadedBy'] ?? '',
      totalPages: map['totalPages'] ?? 0,
      publisher: map['publisher'],
      edition: map['edition'],
      processingStatus: ProcessingStatus.values.firstWhere(
            (e) => e.toString() == map['processingStatus'],
        orElse: () => ProcessingStatus.pending,
      ),
    );
  }
}

/// Chapter model for organizing textbook content
class ChapterModel {
  final String id;
  final String title;
  final int chapterNumber;
  final int startPage;
  final int endPage;
  final List<TopicModel> topics;
  final String extractedText;

  ChapterModel({
    required this.id,
    required this.title,
    required this.chapterNumber,
    required this.startPage,
    required this.endPage,
    required this.topics,
    required this.extractedText,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'chapterNumber': chapterNumber,
      'startPage': startPage,
      'endPage': endPage,
      'topics': topics.map((t) => t.toMap()).toList(),
      'extractedText': extractedText,
    };
  }

  factory ChapterModel.fromMap(Map<String, dynamic> map) {
    return ChapterModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      chapterNumber: map['chapterNumber'] ?? 0,
      startPage: map['startPage'] ?? 0,
      endPage: map['endPage'] ?? 0,
      topics: (map['topics'] as List?)
          ?.map((t) => TopicModel.fromMap(t))
          .toList() ??
          [],
      extractedText: map['extractedText'] ?? '',
    );
  }
}

/// Topic model for specific subjects within chapters
class TopicModel {
  final String id;
  final String name;
  final String description;
  final List<String> keywords;
  final List<String> formulas;
  final DifficultyLevel difficulty;
  final int pageReference;
  final List<String> learningObjectives;

  TopicModel({
    required this.id,
    required this.name,
    required this.description,
    required this.keywords,
    required this.formulas,
    required this.difficulty,
    required this.pageReference,
    required this.learningObjectives,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'keywords': keywords,
      'formulas': formulas,
      'difficulty': difficulty.toString(),
      'pageReference': pageReference,
      'learningObjectives': learningObjectives,
    };
  }

  factory TopicModel.fromMap(Map<String, dynamic> map) {
    return TopicModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      keywords: List<String>.from(map['keywords'] ?? []),
      formulas: List<String>.from(map['formulas'] ?? []),
      difficulty: DifficultyLevel.values.firstWhere(
            (e) => e.toString() == map['difficulty'],
        orElse: () => DifficultyLevel.medium,
      ),
      pageReference: map['pageReference'] ?? 0,
      learningObjectives: List<String>.from(map['learningObjectives'] ?? []),
    );
  }
}

/// Worksheet model for generated question papers
class WorksheetModel {
  final String id;
  final String title;
  final String textbookId;
  final String textbookTitle;
  final List<String> topicIds;
  final List<String> topicNames;
  final List<QuestionModel> questions;
  final int totalMarks;
  final int durationMinutes;
  final DateTime createdAt;
  final String createdBy;
  final String createdByName;
  final List<String> assignedToStudents;
  final List<String> assignedToClasses;
  final WorksheetType type;
  final WorksheetStatus status;
  final DifficultyLevel overallDifficulty;

  WorksheetModel({
    required this.id,
    required this.title,
    required this.textbookId,
    required this.textbookTitle,
    required this.topicIds,
    required this.topicNames,
    required this.questions,
    required this.totalMarks,
    required this.durationMinutes,
    required this.createdAt,
    required this.createdBy,
    required this.createdByName,
    required this.assignedToStudents,
    required this.assignedToClasses,
    required this.type,
    this.status = WorksheetStatus.draft,
    this.overallDifficulty = DifficultyLevel.medium,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'textbookId': textbookId,
      'textbookTitle': textbookTitle,
      'topicIds': topicIds,
      'topicNames': topicNames,
      'questions': questions.map((q) => q.toMap()).toList(),
      'totalMarks': totalMarks,
      'durationMinutes': durationMinutes,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'assignedToStudents': assignedToStudents,
      'assignedToClasses': assignedToClasses,
      'type': type.toString(),
      'status': status.toString(),
      'overallDifficulty': overallDifficulty.toString(),
    };
  }

  factory WorksheetModel.fromMap(Map<String, dynamic> map) {
    return WorksheetModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      textbookId: map['textbookId'] ?? '',
      textbookTitle: map['textbookTitle'] ?? '',
      topicIds: List<String>.from(map['topicIds'] ?? []),
      topicNames: List<String>.from(map['topicNames'] ?? []),
      questions: (map['questions'] as List?)
          ?.map((q) => QuestionModel.fromMap(q))
          .toList() ??
          [],
      totalMarks: map['totalMarks'] ?? 0,
      durationMinutes: map['durationMinutes'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      createdBy: map['createdBy'] ?? '',
      createdByName: map['createdByName'] ?? '',
      assignedToStudents: List<String>.from(map['assignedToStudents'] ?? []),
      assignedToClasses: List<String>.from(map['assignedToClasses'] ?? []),
      type: WorksheetType.values.firstWhere(
            (e) => e.toString() == map['type'],
        orElse: () => WorksheetType.practice,
      ),
      status: WorksheetStatus.values.firstWhere(
            (e) => e.toString() == map['status'],
        orElse: () => WorksheetStatus.draft,
      ),
      overallDifficulty: DifficultyLevel.values.firstWhere(
            (e) => e.toString() == map['overallDifficulty'],
        orElse: () => DifficultyLevel.medium,
      ),
    );
  }
}

/// Question model for individual questions in worksheets
class QuestionModel {
  final String id;
  final int questionNumber;
  final QuestionType type;
  final String text;
  final List<String>? options; // For MCQ
  final String? correctAnswer;
  final String? markingScheme;
  final int marks;
  final DifficultyLevel difficulty;
  final String topicId;
  final String topicName;
  final int pageReference;
  final String? diagramUrl;
  final String? hint;

  QuestionModel({
    required this.id,
    required this.questionNumber,
    required this.type,
    required this.text,
    this.options,
    this.correctAnswer,
    this.markingScheme,
    required this.marks,
    required this.difficulty,
    required this.topicId,
    required this.topicName,
    required this.pageReference,
    this.diagramUrl,
    this.hint,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionNumber': questionNumber,
      'type': type.toString(),
      'text': text,
      'options': options,
      'correctAnswer': correctAnswer,
      'markingScheme': markingScheme,
      'marks': marks,
      'difficulty': difficulty.toString(),
      'topicId': topicId,
      'topicName': topicName,
      'pageReference': pageReference,
      'diagramUrl': diagramUrl,
      'hint': hint,
    };
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id'] ?? '',
      questionNumber: map['questionNumber'] ?? 0,
      type: QuestionType.values.firstWhere(
            (e) => e.toString() == map['type'],
        orElse: () => QuestionType.mcq,
      ),
      text: map['text'] ?? '',
      options: map['options'] != null ? List<String>.from(map['options']) : null,
      correctAnswer: map['correctAnswer'],
      markingScheme: map['markingScheme'],
      marks: map['marks'] ?? 0,
      difficulty: DifficultyLevel.values.firstWhere(
            (e) => e.toString() == map['difficulty'],
        orElse: () => DifficultyLevel.medium,
      ),
      topicId: map['topicId'] ?? '',
      topicName: map['topicName'] ?? '',
      pageReference: map['pageReference'] ?? 0,
      diagramUrl: map['diagramUrl'],
      hint: map['hint'],
    );
  }
}

/// Student submission model for worksheet attempts
class StudentSubmissionModel {
  final String id;
  final String worksheetId;
  final String worksheetTitle;
  final String studentId;
  final String studentName;
  final List<StudentAnswer> answers;
  final DateTime? submittedAt;
  final int? marksObtained;
  final int totalMarks;
  final SubmissionStatus status;
  final String? teacherFeedback;
  final DateTime? gradedAt;
  final String? gradedBy;
  final double? percentage;
  final String? grade; // A*, A, B, C, etc.

  StudentSubmissionModel({
    required this.id,
    required this.worksheetId,
    required this.worksheetTitle,
    required this.studentId,
    required this.studentName,
    required this.answers,
    this.submittedAt,
    this.marksObtained,
    required this.totalMarks,
    this.status = SubmissionStatus.pending,
    this.teacherFeedback,
    this.gradedAt,
    this.gradedBy,
    this.percentage,
    this.grade,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'worksheetId': worksheetId,
      'worksheetTitle': worksheetTitle,
      'studentId': studentId,
      'studentName': studentName,
      'answers': answers.map((a) => a.toMap()).toList(),
      'submittedAt': submittedAt,
      'marksObtained': marksObtained,
      'totalMarks': totalMarks,
      'status': status.toString(),
      'teacherFeedback': teacherFeedback,
      'gradedAt': gradedAt,
      'gradedBy': gradedBy,
      'percentage': percentage,
      'grade': grade,
    };
  }

  factory StudentSubmissionModel.fromMap(Map<String, dynamic> map) {
    return StudentSubmissionModel(
      id: map['id'] ?? '',
      worksheetId: map['worksheetId'] ?? '',
      worksheetTitle: map['worksheetTitle'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      answers: (map['answers'] as List?)
          ?.map((a) => StudentAnswer.fromMap(a))
          .toList() ??
          [],
      submittedAt: map['submittedAt'] != null
          ? (map['submittedAt'] as Timestamp).toDate()
          : null,
      marksObtained: map['marksObtained'],
      totalMarks: map['totalMarks'] ?? 0,
      status: SubmissionStatus.values.firstWhere(
            (e) => e.toString() == map['status'],
        orElse: () => SubmissionStatus.pending,
      ),
      teacherFeedback: map['teacherFeedback'],
      gradedAt: map['gradedAt'] != null
          ? (map['gradedAt'] as Timestamp).toDate()
          : null,
      gradedBy: map['gradedBy'],
      percentage: map['percentage']?.toDouble(),
      grade: map['grade'],
    );
  }
}

/// Student answer model
class StudentAnswer {
  final String questionId;
  final int questionNumber;
  final String answer;
  final List<String>? attachmentUrls; // For image uploads
  final int? marksAwarded;
  final String? feedback;
  final bool? isCorrect; // For auto-graded questions

  StudentAnswer({
    required this.questionId,
    required this.questionNumber,
    required this.answer,
    this.attachmentUrls,
    this.marksAwarded,
    this.feedback,
    this.isCorrect,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'questionNumber': questionNumber,
      'answer': answer,
      'attachmentUrls': attachmentUrls,
      'marksAwarded': marksAwarded,
      'feedback': feedback,
      'isCorrect': isCorrect,
    };
  }

  factory StudentAnswer.fromMap(Map<String, dynamic> map) {
    return StudentAnswer(
      questionId: map['questionId'] ?? '',
      questionNumber: map['questionNumber'] ?? 0,
      answer: map['answer'] ?? '',
      attachmentUrls: map['attachmentUrls'] != null
          ? List<String>.from(map['attachmentUrls'])
          : null,
      marksAwarded: map['marksAwarded'],
      feedback: map['feedback'],
      isCorrect: map['isCorrect'],
    );
  }
}

// Enums
enum ProcessingStatus { pending, processing, completed, failed }

enum DifficultyLevel { easy, medium, hard }

enum QuestionType { mcq, shortAnswer, longAnswer, trueFalse, fillInBlanks }

enum WorksheetType { practice, assessment, homework, test, mock }

enum WorksheetStatus { draft, published, archived }

enum SubmissionStatus { pending, submitted, graded }