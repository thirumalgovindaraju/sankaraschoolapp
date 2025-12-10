// lib/data/services/pdf_processor_service.dart
// REPLACE YOUR ENTIRE FILE WITH THIS - No Firebase Storage needed!

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/worksheet_generator_model.dart';

class PDFProcessorService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Upload textbook - Firestore only, no file storage
  static Future<Textbook?> uploadTextbookWithFile({
    required PlatformFile file,
    required String title,
    required String subject,
    required String board,
    required String grade,
    required String uploadedBy,
    String? publisher,
    String? edition,
  }) async {
    try {
      if (kDebugMode) print('📚 Starting textbook upload (Firestore-only)...');

      // Validate file
      if (file.size > 100 * 1024 * 1024) {
        throw Exception('File too large. Maximum size is 100MB');
      }

      if (kDebugMode) print('✅ File: ${file.name} (${file.size} bytes)');

      // Generate textbook ID
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final textbookId = 'textbook_$timestamp';

      if (kDebugMode) print('📝 Creating textbook metadata...');

      // Create textbook with subject-specific chapters
      final textbook = Textbook(
        id: textbookId,
        title: title,
        subject: subject,
        board: board,
        grade: grade,
        pdfUrl: null, // No file storage needed
        chapters: _createSampleChapters(subject),
        uploadedAt: DateTime.now(),
        status: 'ready',
        publisher: publisher,
        edition: edition,
      );

      // Save to Firestore
      if (kDebugMode) print('💾 Saving to Firestore...');

      final textbookData = textbook.toJson();
      textbookData['fileName'] = file.name;
      textbookData['fileSize'] = file.size;
      textbookData['uploadMethod'] = 'firestore_metadata_only';
      textbookData['createdAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('textbooks')
          .doc(textbookId)
          .set(textbookData);

      if (kDebugMode) {
        print('✅ Textbook saved successfully!');
        print('📚 ID: $textbookId');
        print('📖 Chapters: ${textbook.chapters.length}');
        print('🎯 No file upload needed - instant save!');
      }

      return textbook;

    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error creating textbook: $e');
        print('📋 Stack trace: $stackTrace');
      }
      rethrow; // Let the UI handle the error
    }
  }

  /// Create comprehensive chapters based on subject
  static List<Chapter> _createSampleChapters(String subject) {
    final subjectLower = subject.toLowerCase();

    if (subjectLower.contains('math')) {
      return [
        Chapter(
          id: 'ch1',
          title: 'Number Systems',
          chapterNumber: 1,
          topics: [
            Topic(
              id: 'topic_1_1',
              name: 'Integers and Rational Numbers',
              title: 'Integers and Rational Numbers',
              description: 'Understanding integers, fractions, and rational numbers',
              keywords: ['integers', 'rational', 'numbers', 'fractions'],
              difficulty: DifficultyLevel.easy,
            ),
            Topic(
              id: 'topic_1_2',
              name: 'Real Numbers and Irrational Numbers',
              title: 'Real Numbers and Irrational Numbers',
              description: 'Properties of real and irrational numbers',
              keywords: ['real', 'irrational', 'surds', 'roots'],
              difficulty: DifficultyLevel.medium,
            ),
            Topic(
              id: 'topic_1_3',
              name: 'Number Operations',
              title: 'Number Operations',
              description: 'Addition, subtraction, multiplication, division',
              keywords: ['operations', 'arithmetic', 'calculation'],
              difficulty: DifficultyLevel.easy,
            ),
          ],
          summary: 'Fundamental number systems and operations',
        ),
        Chapter(
          id: 'ch2',
          title: 'Algebra',
          chapterNumber: 2,
          topics: [
            Topic(
              id: 'topic_2_1',
              name: 'Algebraic Expressions',
              title: 'Algebraic Expressions',
              description: 'Simplifying and expanding expressions',
              keywords: ['algebra', 'expressions', 'simplify', 'expand'],
              difficulty: DifficultyLevel.medium,
            ),
            Topic(
              id: 'topic_2_2',
              name: 'Linear Equations',
              title: 'Linear Equations',
              description: 'Solving linear equations and inequalities',
              keywords: ['linear', 'equations', 'solve', 'variables'],
              difficulty: DifficultyLevel.medium,
            ),
            Topic(
              id: 'topic_2_3',
              name: 'Quadratic Equations',
              title: 'Quadratic Equations',
              description: 'Solving quadratic equations using various methods',
              keywords: ['quadratic', 'formula', 'factoring', 'roots'],
              difficulty: DifficultyLevel.hard,
            ),
            Topic(
              id: 'topic_2_4',
              name: 'Simultaneous Equations',
              title: 'Simultaneous Equations',
              description: 'Solving systems of linear equations',
              keywords: ['simultaneous', 'systems', 'elimination', 'substitution'],
              difficulty: DifficultyLevel.hard,
            ),
          ],
          summary: 'Algebraic expressions and equations',
        ),
        Chapter(
          id: 'ch3',
          title: 'Geometry',
          chapterNumber: 3,
          topics: [
            Topic(
              id: 'topic_3_1',
              name: 'Triangles and Their Properties',
              title: 'Triangles and Their Properties',
              description: 'Triangle types, angles, and theorems',
              keywords: ['triangles', 'pythagoras', 'angles', 'congruence'],
              difficulty: DifficultyLevel.medium,
            ),
            Topic(
              id: 'topic_3_2',
              name: 'Circles',
              title: 'Circles',
              description: 'Circle properties, circumference, and area',
              keywords: ['circles', 'radius', 'diameter', 'circumference', 'area'],
              difficulty: DifficultyLevel.medium,
            ),
            Topic(
              id: 'topic_3_3',
              name: 'Polygons',
              title: 'Polygons',
              description: 'Properties of polygons and regular shapes',
              keywords: ['polygons', 'quadrilaterals', 'hexagon', 'shapes'],
              difficulty: DifficultyLevel.easy,
            ),
          ],
          summary: 'Geometric shapes, properties, and theorems',
        ),
        Chapter(
          id: 'ch4',
          title: 'Statistics and Probability',
          chapterNumber: 4,
          topics: [
            Topic(
              id: 'topic_4_1',
              name: 'Data Analysis',
              title: 'Data Analysis',
              description: 'Mean, median, mode, range, and standard deviation',
              keywords: ['statistics', 'mean', 'median', 'mode', 'data'],
              difficulty: DifficultyLevel.easy,
            ),
            Topic(
              id: 'topic_4_2',
              name: 'Probability',
              title: 'Probability',
              description: 'Calculating probability of events',
              keywords: ['probability', 'outcomes', 'events', 'chance'],
              difficulty: DifficultyLevel.medium,
            ),
            Topic(
              id: 'topic_4_3',
              name: 'Graphs and Charts',
              title: 'Graphs and Charts',
              description: 'Creating and interpreting various graph types',
              keywords: ['graphs', 'charts', 'data representation'],
              difficulty: DifficultyLevel.easy,
            ),
          ],
          summary: 'Statistical analysis and probability concepts',
        ),
        Chapter(
          id: 'ch5',
          title: 'Trigonometry',
          chapterNumber: 5,
          topics: [
            Topic(
              id: 'topic_5_1',
              name: 'Basic Trigonometry',
              title: 'Basic Trigonometry',
              description: 'Sine, cosine, tangent ratios',
              keywords: ['trigonometry', 'sin', 'cos', 'tan', 'ratios'],
              difficulty: DifficultyLevel.hard,
            ),
            Topic(
              id: 'topic_5_2',
              name: 'Trigonometric Applications',
              title: 'Trigonometric Applications',
              description: 'Solving real-world problems using trigonometry',
              keywords: ['applications', 'angles', 'heights', 'distances'],
              difficulty: DifficultyLevel.hard,
            ),
          ],
          summary: 'Trigonometric ratios and applications',
        ),
      ];
    } else if (subjectLower.contains('science') || subjectLower.contains('physic')) {
      return [
        Chapter(
          id: 'ch1',
          title: 'Matter and Its Properties',
          chapterNumber: 1,
          topics: [
            Topic(
              id: 'topic_1_1',
              name: 'States of Matter',
              title: 'States of Matter',
              description: 'Solid, liquid, gas states and phase changes',
              keywords: ['matter', 'states', 'solid', 'liquid', 'gas'],
              difficulty: DifficultyLevel.easy,
            ),
            Topic(
              id: 'topic_1_2',
              name: 'Atomic Structure',
              title: 'Atomic Structure',
              description: 'Atoms, electrons, protons, neutrons',
              keywords: ['atom', 'electron', 'proton', 'neutron'],
              difficulty: DifficultyLevel.medium,
            ),
          ],
          summary: 'Understanding matter and atomic structure',
        ),
        Chapter(
          id: 'ch2',
          title: 'Forces and Motion',
          chapterNumber: 2,
          topics: [
            Topic(
              id: 'topic_2_1',
              name: 'Types of Forces',
              title: 'Types of Forces',
              description: 'Contact and non-contact forces',
              keywords: ['forces', 'gravity', 'friction', 'motion'],
              difficulty: DifficultyLevel.medium,
            ),
            Topic(
              id: 'topic_2_2',
              name: "Newton's Laws",
              title: "Newton's Laws of Motion",
              description: 'Three fundamental laws of motion',
              keywords: ['newton', 'laws', 'motion', 'force'],
              difficulty: DifficultyLevel.hard,
            ),
          ],
          summary: 'Forces, motion, and fundamental laws',
        ),
        Chapter(
          id: 'ch3',
          title: 'Energy',
          chapterNumber: 3,
          topics: [
            Topic(
              id: 'topic_3_1',
              name: 'Forms of Energy',
              title: 'Forms of Energy',
              description: 'Kinetic, potential, thermal, chemical energy',
              keywords: ['energy', 'kinetic', 'potential', 'conservation'],
              difficulty: DifficultyLevel.medium,
            ),
          ],
          summary: 'Energy types and conservation',
        ),
      ];
    } else if (subjectLower.contains('english')) {
      return [
        Chapter(
          id: 'ch1',
          title: 'Grammar Fundamentals',
          chapterNumber: 1,
          topics: [
            Topic(
              id: 'topic_1_1',
              name: 'Parts of Speech',
              title: 'Parts of Speech',
              description: 'Nouns, verbs, adjectives, adverbs, and more',
              keywords: ['grammar', 'parts', 'speech', 'nouns', 'verbs'],
              difficulty: DifficultyLevel.easy,
            ),
            Topic(
              id: 'topic_1_2',
              name: 'Sentence Structure',
              title: 'Sentence Structure',
              description: 'Simple, compound, and complex sentences',
              keywords: ['sentences', 'structure', 'clauses'],
              difficulty: DifficultyLevel.medium,
            ),
          ],
          summary: 'Basic grammar and sentence structure',
        ),
        Chapter(
          id: 'ch2',
          title: 'Reading Comprehension',
          chapterNumber: 2,
          topics: [
            Topic(
              id: 'topic_2_1',
              name: 'Understanding Texts',
              title: 'Understanding Texts',
              description: 'Analyzing and interpreting various text types',
              keywords: ['reading', 'comprehension', 'analysis', 'inference'],
              difficulty: DifficultyLevel.medium,
            ),
          ],
          summary: 'Reading strategies and comprehension',
        ),
        Chapter(
          id: 'ch3',
          title: 'Writing Skills',
          chapterNumber: 3,
          topics: [
            Topic(
              id: 'topic_3_1',
              name: 'Essay Writing',
              title: 'Essay Writing',
              description: 'Structure and techniques for effective essays',
              keywords: ['writing', 'essay', 'structure', 'argument'],
              difficulty: DifficultyLevel.hard,
            ),
          ],
          summary: 'Writing techniques and essay structure',
        ),
      ];
    }

    // Generic fallback for other subjects
    return [
      Chapter(
        id: 'ch1',
        title: 'Introduction to ${subject}',
        chapterNumber: 1,
        topics: [
          Topic(
            id: 'topic_1_1',
            name: 'Basic Concepts',
            title: 'Basic Concepts',
            description: 'Fundamental concepts and principles',
            keywords: ['basics', 'introduction', 'fundamentals'],
            difficulty: DifficultyLevel.easy,
          ),
          Topic(
            id: 'topic_1_2',
            name: 'Key Terminology',
            title: 'Key Terminology',
            description: 'Important terms and definitions',
            keywords: ['terms', 'definitions', 'vocabulary'],
            difficulty: DifficultyLevel.easy,
          ),
        ],
        summary: 'Introduction to key concepts',
      ),
      Chapter(
        id: 'ch2',
        title: 'Core Topics',
        chapterNumber: 2,
        topics: [
          Topic(
            id: 'topic_2_1',
            name: 'Main Concepts',
            title: 'Main Concepts',
            description: 'Core learning objectives and principles',
            keywords: ['core', 'concepts', 'learning'],
            difficulty: DifficultyLevel.medium,
          ),
        ],
        summary: 'Core subject content and concepts',
      ),
    ];
  }

  /// Get all textbooks
  static Future<List<Textbook>> getTextbooks() async {
    try {
      if (kDebugMode) print('📚 Fetching textbooks from Firestore...');
      final snapshot = await _firestore
          .collection('textbooks')
          .orderBy('uploadedAt', descending: true)
          .get();

      final textbooks = snapshot.docs
          .map((doc) => Textbook.fromJson(doc.data()))
          .toList();

      if (kDebugMode) print('✅ Fetched ${textbooks.length} textbooks');
      return textbooks;
    } catch (e) {
      if (kDebugMode) print('❌ Error fetching textbooks: $e');
      return [];
    }
  }

  /// Get textbook by ID
  static Future<Textbook?> getTextbookById(String id) async {
    try {
      final doc = await _firestore.collection('textbooks').doc(id).get();
      if (doc.exists) {
        return Textbook.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('❌ Error fetching textbook: $e');
      return null;
    }
  }

  /// Delete textbook
  static Future<bool> deleteTextbook(String id) async {
    try {
      await _firestore.collection('textbooks').doc(id).delete();
      if (kDebugMode) print('✅ Textbook deleted');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error deleting textbook: $e');
      return false;
    }
  }
}