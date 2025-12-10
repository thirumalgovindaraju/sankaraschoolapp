// lib/data/services/pdf_processor_service.dart
// ✅ FIXED - All Topic constructors include name and difficulty

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/worksheet_generator_model.dart';

class PDFProcessorService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Upload textbook PDF
  static Future<Textbook?> uploadTextbook({
    required String title,
    required String subject,
    required String board,
    required String grade,
    required String uploadedBy,
    String? publisher,
    String? edition,
    int? totalPages,
  }) async {
    try {
      if (kDebugMode) print('📚 Starting textbook upload...');

      // Step 1: Pick PDF file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result == null) {
        if (kDebugMode) print('❌ No file selected');
        return null;
      }

      final file = result.files.first;
      if (kDebugMode) print('✅ File selected: ${file.name} (${file.size} bytes)');

      if (file.size > 100 * 1024 * 1024) {
        throw Exception('File too large. Maximum size is 100MB');
      }

      // Step 2: Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final textbookId = 'textbook_$timestamp';
      final sanitizedFileName = file.name.replaceAll(' ', '_');
      final fileName = '${textbookId}_$sanitizedFileName';
      final storagePath = 'textbooks/$fileName';

      if (kDebugMode) print('📤 Uploading to: $storagePath');

      // Step 3: Upload to Firebase Storage
      final storageRef = _storage.ref().child(storagePath);

      final metadata = SettableMetadata(
        contentType: 'application/pdf',
        customMetadata: {
          'uploadedBy': uploadedBy,
          'subject': subject,
          'textbookId': textbookId,
        },
      );

      UploadTask uploadTask;

      if (file.bytes != null) {
        if (kDebugMode) print('📱 Uploading from bytes...');
        uploadTask = storageRef.putData(file.bytes!, metadata);
      } else if (file.path != null) {
        if (kDebugMode) print('💻 Uploading from file path...');
        uploadTask = storageRef.putFile(File(file.path!), metadata);
      } else {
        throw Exception('Cannot read file data');
      }

      // Monitor progress
      uploadTask.snapshotEvents.listen((event) {
        final progress = (event.bytesTransferred / event.totalBytes) * 100;
        if (kDebugMode) print('📊 Upload progress: ${progress.toStringAsFixed(1)}%');
      });

      // Wait for upload to complete
      if (kDebugMode) print('⏳ Waiting for upload to complete...');
      final snapshot = await uploadTask.whenComplete(() => null);

      if (kDebugMode) {
        print('✅ Upload complete!');
        print('📦 State: ${snapshot.state}');
        print('📦 Bytes: ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
      }

      // ✅ CRITICAL FIX: Check upload state before getting URL
      if (snapshot.state != TaskState.success) {
        throw Exception('Upload did not complete successfully. State: ${snapshot.state}');
      }

      // Add delay to ensure file is fully written
      if (kDebugMode) print('⏳ Waiting for file to be fully written...');
      await Future.delayed(const Duration(seconds: 2));

      // Get download URL with multiple retry attempts
      String? pdfUrl;
      int maxRetries = 5;

      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          if (kDebugMode) print('🔗 Attempt $attempt/$maxRetries: Getting download URL...');

          // Try getting URL from completed snapshot
          pdfUrl = await snapshot.ref.getDownloadURL();
          if (kDebugMode) print('✅ Download URL obtained: $pdfUrl');
          break;

        } catch (e) {
          if (kDebugMode) print('⚠️ Attempt $attempt failed: $e');

          if (attempt < maxRetries) {
            // Wait progressively longer between retries
            final waitSeconds = attempt * 2;
            if (kDebugMode) print('⏳ Waiting ${waitSeconds}s before retry...');
            await Future.delayed(Duration(seconds: waitSeconds));

            // Try with a fresh reference
            try {
              final freshRef = _storage.ref().child(storagePath);
              pdfUrl = await freshRef.getDownloadURL();
              if (kDebugMode) print('✅ Got URL from fresh reference: $pdfUrl');
              break;
            } catch (freshError) {
              if (kDebugMode) print('⚠️ Fresh reference also failed: $freshError');
            }
          } else {
            // Last attempt failed - check if file exists
            if (kDebugMode) {
              print('❌ All retry attempts exhausted');
              print('🔍 Checking if file exists in Storage...');
            }

            try {
              final listResult = await _storage.ref('textbooks').listAll();
              if (kDebugMode) {
                print('📂 Files in textbooks folder:');
                for (var item in listResult.items) {
                  print('  - ${item.name}');
                }
              }
            } catch (listError) {
              if (kDebugMode) print('⚠️ Could not list files: $listError');
            }

            throw Exception(
                'Failed to get download URL after $maxRetries attempts. '
                    'The file may not have been saved to Firebase Storage. '
                    'Check your Firebase Storage rules and ensure they allow authenticated reads/writes.'
            );
          }
        }
      }

      if (pdfUrl == null) {
        throw Exception('Failed to obtain download URL');
      }

      if (kDebugMode) print('🎉 File successfully uploaded and accessible!');

      // Step 4: Create textbook using unified model
      final textbook = Textbook(
        id: textbookId,
        title: title,
        subject: subject,
        board: board,
        grade: grade,
        pdfUrl: pdfUrl,
        chapters: _createSampleChapters(subject),
        uploadedAt: DateTime.now(),
        status: 'ready',
        publisher: publisher,
        edition: edition,
      );

      // Step 5: Save to Firestore
      if (kDebugMode) print('💾 Saving textbook metadata to Firestore...');
      await _firestore
          .collection('textbooks')
          .doc(textbookId)
          .set(textbook.toJson());

      if (kDebugMode) {
        print('✅ Textbook saved successfully!');
        print('📚 ID: $textbookId');
        print('📖 Chapters: ${textbook.chapters.length}');
      }

      return textbook;

    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('❌ Firebase Error: ${e.code}');
        print('📝 Message: ${e.message}');
        print('📍 Plugin: ${e.plugin}');

        if (e.code == 'object-not-found') {
          print('');
          print('🔧 TROUBLESHOOTING STEPS:');
          print('1. Check Firebase Storage Rules in Firebase Console');
          print('2. Ensure rules allow: allow read, write: if request.auth != null;');
          print('3. Make sure user is authenticated');
          print('4. Verify Storage bucket exists');
          print('');
        }
      }

      return null;

    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error uploading textbook: $e');
        print('📋 Stack trace: $stackTrace');
      }
      return null;
    }
  }

  /// Create sample chapters based on subject (using unified models)
  static List<Chapter> _createSampleChapters(String subject) {
    if (subject.toLowerCase() == 'mathematics') {
      return [
        Chapter(
          id: 'ch1',
          title: 'Number Systems',
          chapterNumber: 1,
          topics: [
            Topic(
              id: 'topic_1_1',
              name: 'Integers and Rational Numbers',  // ✅ Added
              title: 'Integers and Rational Numbers',
              description: 'Understanding integers and rational numbers',
              keywords: ['integers', 'rational', 'numbers'],
              difficulty: DifficultyLevel.easy,  // ✅ Added
            ),
            Topic(
              id: 'topic_1_2',
              name: 'Real Numbers',  // ✅ Added
              title: 'Real Numbers',
              description: 'Properties of real numbers',
              keywords: ['real', 'irrational', 'numbers'],
              difficulty: DifficultyLevel.medium,  // ✅ Added
            ),
          ],
          summary: 'Introduction to number systems',
        ),
        Chapter(
          id: 'ch2',
          title: 'Algebra',
          chapterNumber: 2,
          topics: [
            Topic(
              id: 'topic_2_1',
              name: 'Linear Equations',  // ✅ Added
              title: 'Linear Equations',
              description: 'Solving linear equations',
              keywords: ['linear', 'equations', 'variables'],
              difficulty: DifficultyLevel.medium,  // ✅ Added
            ),
            Topic(
              id: 'topic_2_2',
              name: 'Quadratic Equations',  // ✅ Added
              title: 'Quadratic Equations',
              description: 'Solving quadratic equations',
              keywords: ['quadratic', 'formula', 'roots'],
              difficulty: DifficultyLevel.hard,  // ✅ Added
            ),
          ],
          summary: 'Algebraic concepts and equations',
        ),
        Chapter(
          id: 'ch3',
          title: 'Geometry',
          chapterNumber: 3,
          topics: [
            Topic(
              id: 'topic_3_1',
              name: 'Triangles',  // ✅ Added
              title: 'Triangles',
              description: 'Triangle properties and theorems',
              keywords: ['triangles', 'pythagoras', 'angles'],
              difficulty: DifficultyLevel.medium,  // ✅ Added
            ),
          ],
          summary: 'Geometric shapes and theorems',
        ),
      ];
    }

    // Generic chapters for other subjects
    return [
      Chapter(
        id: 'ch1',
        title: 'Introduction',
        chapterNumber: 1,
        topics: [
          Topic(
            id: 'topic_1',
            name: 'Basic Concepts',  // ✅ Added
            title: 'Basic Concepts',
            description: 'Fundamental concepts',
            keywords: ['basics', 'introduction'],
            difficulty: DifficultyLevel.easy,  // ✅ Added
          ),
        ],
        summary: 'Introduction chapter',
      ),
    ];
  }
  /// Upload textbook with pre-selected file
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
      if (kDebugMode) print('📚 Starting textbook upload with pre-selected file...');

      // Validate file
      if (file.size > 100 * 1024 * 1024) {
        throw Exception('File too large. Maximum size is 100MB');
      }

      if (kDebugMode) print('✅ File: ${file.name} (${file.size} bytes)');

      // Step 2: Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final textbookId = 'textbook_$timestamp';
      final sanitizedFileName = file.name.replaceAll(' ', '_');
      final fileName = '${textbookId}_$sanitizedFileName';
      final storagePath = 'textbooks/$fileName';

      if (kDebugMode) print('📤 Uploading to: $storagePath');

      // Step 3: Upload to Firebase Storage
      final storageRef = _storage.ref().child(storagePath);

      final metadata = SettableMetadata(
        contentType: 'application/pdf',
        customMetadata: {
          'uploadedBy': uploadedBy,
          'subject': subject,
          'textbookId': textbookId,
        },
      );

      UploadTask uploadTask;

      if (file.bytes != null) {
        if (kDebugMode) print('📱 Uploading from bytes...');
        uploadTask = storageRef.putData(file.bytes!, metadata);
      } else if (file.path != null) {
        if (kDebugMode) print('💻 Uploading from file path...');
        uploadTask = storageRef.putFile(File(file.path!), metadata);
      } else {
        throw Exception('Cannot read file data');
      }

      // Monitor progress
      uploadTask.snapshotEvents.listen((event) {
        final progress = (event.bytesTransferred / event.totalBytes) * 100;
        if (kDebugMode) print('📊 Upload progress: ${progress.toStringAsFixed(1)}%');
      });

      // Wait for upload
      if (kDebugMode) print('⏳ Waiting for upload to complete...');
      final snapshot = await uploadTask.whenComplete(() => null);

      if (kDebugMode) {
        print('✅ Upload complete!');
        print('📦 State: ${snapshot.state}');
        print('📦 Bytes: ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
      }

      // Check upload state
      if (snapshot.state != TaskState.success) {
        throw Exception('Upload did not complete successfully. State: ${snapshot.state}');
      }

      // Add delay
      if (kDebugMode) print('⏳ Waiting for file to be fully written...');
      await Future.delayed(const Duration(seconds: 2));

      // Get download URL with retries
      String? pdfUrl;
      int maxRetries = 5;

      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          if (kDebugMode) print('🔗 Attempt $attempt/$maxRetries: Getting download URL...');
          pdfUrl = await snapshot.ref.getDownloadURL();
          if (kDebugMode) print('✅ Download URL obtained: $pdfUrl');
          break;
        } catch (e) {
          if (kDebugMode) print('⚠️ Attempt $attempt failed: $e');

          if (attempt < maxRetries) {
            final waitSeconds = attempt * 2;
            if (kDebugMode) print('⏳ Waiting ${waitSeconds}s before retry...');
            await Future.delayed(Duration(seconds: waitSeconds));

            try {
              final freshRef = _storage.ref().child(storagePath);
              pdfUrl = await freshRef.getDownloadURL();
              if (kDebugMode) print('✅ Got URL from fresh reference: $pdfUrl');
              break;
            } catch (freshError) {
              if (kDebugMode) print('⚠️ Fresh reference also failed: $freshError');
            }
          } else {
            throw Exception(
                'Failed to get download URL after $maxRetries attempts. '
                    'Check Firebase Storage rules.'
            );
          }
        }
      }

      if (pdfUrl == null) {
        throw Exception('Failed to obtain download URL');
      }

      if (kDebugMode) print('🎉 File successfully uploaded and accessible!');

      // Step 4: Create textbook
      final textbook = Textbook(
        id: textbookId,
        title: title,
        subject: subject,
        board: board,
        grade: grade,
        pdfUrl: pdfUrl,
        chapters: _createSampleChapters(subject),
        uploadedAt: DateTime.now(),
        status: 'ready',
        publisher: publisher,
        edition: edition,
      );

      // Step 5: Save to Firestore
      if (kDebugMode) print('💾 Saving textbook metadata to Firestore...');
      await _firestore
          .collection('textbooks')
          .doc(textbookId)
          .set(textbook.toJson());

      if (kDebugMode) {
        print('✅ Textbook saved successfully!');
        print('📚 ID: $textbookId');
        print('📖 Chapters: ${textbook.chapters.length}');
      }

      return textbook;

    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('❌ Firebase Error: ${e.code}');
        print('📝 Message: ${e.message}');
      }
      return null;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error uploading textbook: $e');
        print('📋 Stack trace: $stackTrace');
      }
      return null;
    }
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
      final textbook = await getTextbookById(id);
      if (textbook == null) return false;

      // Delete from Storage
      if (textbook.pdfUrl != null) {
        try {
          final ref = _storage.refFromURL(textbook.pdfUrl!);
          await ref.delete();
          if (kDebugMode) print('✅ File deleted from Storage');
        } catch (e) {
          if (kDebugMode) print('⚠️ Could not delete file from Storage: $e');
        }
      }

      // Delete from Firestore
      await _firestore.collection('textbooks').doc(id).delete();
      if (kDebugMode) print('✅ Textbook deleted from Firestore');

      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error deleting textbook: $e');
      return false;
    }
  }
}