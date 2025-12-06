// lib/data/services/pdf_processor_service.dart
// ✅ FIXED VERSION - No pdf_text dependency required

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/worksheet_generator_model.dart';
import 'gemini_ai_service.dart';

class PDFProcessorService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Pick and upload PDF textbook
  static Future<TextbookModel?> uploadTextbook({
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
      // Step 1: Pick PDF file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result == null) {
        print('❌ No file selected');
        return null;
      }

      final file = result.files.first;
      print('✅ File selected: ${file.name} (${file.size} bytes)');

      // Step 2: Upload to Firebase Storage
      final textbookId = 'textbook_${DateTime.now().millisecondsSinceEpoch}';
      final storageRef = _storage.ref().child('textbooks/$textbookId/${file.name}');

      UploadTask uploadTask;
      if (file.bytes != null) {
        uploadTask = storageRef.putData(file.bytes!);
      } else {
        uploadTask = storageRef.putFile(File(file.path!));
      }

      final snapshot = await uploadTask;
      final pdfUrl = await snapshot.ref.getDownloadURL();
      print('✅ PDF uploaded: $pdfUrl');

      // Step 3: Create textbook model with manual chapter entry
      final textbook = TextbookModel(
        id: textbookId,
        title: title,
        subject: subject,
        board: board,
        grade: grade,
        pdfUrl: pdfUrl,
        chapters: _createDefaultChapters(), // Create default chapters
        uploadedAt: DateTime.now(),
        uploadedBy: uploadedBy,
        totalPages: totalPages ?? 100, // User provides or estimate
        publisher: publisher,
        edition: edition,
        processingStatus: ProcessingStatus.completed,
      );

      // Step 4: Save to Firestore
      await _firestore
          .collection('textbooks')
          .doc(textbookId)
          .set(textbook.toMap());

      print('✅ Textbook saved to Firestore');

      return textbook;
    } catch (e) {
      print('❌ Error uploading textbook: $e');
      return null;
    }
  }

  /// Create default chapters (teacher can edit later)
  static List<ChapterModel> _createDefaultChapters() {
    return List.generate(10, (index) {
      final chapterNum = index + 1;
      return ChapterModel(
        id: 'chapter_$chapterNum',
        title: 'Chapter $chapterNum',
        chapterNumber: chapterNum,
        startPage: chapterNum * 10 - 9,
        endPage: chapterNum * 10,
        topics: [],
        extractedText: '',
      );
    });
  }

  /// Add chapter to textbook
  static Future<bool> addChapter({
    required String textbookId,
    required String title,
    required int chapterNumber,
    required int startPage,
    required int endPage,
    List<TopicModel>? topics,
  }) async {
    try {
      final chapter = ChapterModel(
        id: 'chapter_$chapterNumber',
        title: title,
        chapterNumber: chapterNumber,
        startPage: startPage,
        endPage: endPage,
        topics: topics ?? [],
        extractedText: '',
      );

      await _firestore.collection('textbooks').doc(textbookId).update({
        'chapters': FieldValue.arrayUnion([chapter.toMap()]),
      });

      print('✅ Chapter added successfully');
      return true;
    } catch (e) {
      print('❌ Error adding chapter: $e');
      return false;
    }
  }

  /// Update chapter in textbook
  static Future<bool> updateChapter({
    required String textbookId,
    required ChapterModel chapter,
  }) async {
    try {
      final doc = await _firestore.collection('textbooks').doc(textbookId).get();
      if (!doc.exists) return false;

      final textbook = TextbookModel.fromMap(doc.data()!);
      final chapters = textbook.chapters;

      // Find and update chapter
      final index = chapters.indexWhere((c) => c.id == chapter.id);
      if (index != -1) {
        chapters[index] = chapter;

        await _firestore.collection('textbooks').doc(textbookId).update({
          'chapters': chapters.map((c) => c.toMap()).toList(),
        });

        print('✅ Chapter updated successfully');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Error updating chapter: $e');
      return false;
    }
  }

  /// Get all textbooks
  static Future<List<TextbookModel>> getTextbooks() async {
    try {
      final snapshot = await _firestore
          .collection('textbooks')
          .orderBy('uploadedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TextbookModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error fetching textbooks: $e');
      return [];
    }
  }

  /// Get textbooks by filters
  static Future<List<TextbookModel>> getTextbooksFiltered({
    String? subject,
    String? board,
    String? grade,
  }) async {
    try {
      Query query = _firestore.collection('textbooks');

      if (subject != null) {
        query = query.where('subject', isEqualTo: subject);
      }
      if (board != null) {
        query = query.where('board', isEqualTo: board);
      }
      if (grade != null) {
        query = query.where('grade', isEqualTo: grade);
      }

      final snapshot = await query.orderBy('uploadedAt', descending: true).get();

      return snapshot.docs
          .map((doc) => TextbookModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error fetching textbooks: $e');
      return [];
    }
  }

  /// Get textbook by ID
  static Future<TextbookModel?> getTextbookById(String id) async {
    try {
      final doc = await _firestore.collection('textbooks').doc(id).get();

      if (doc.exists) {
        return TextbookModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('❌ Error fetching textbook: $e');
      return null;
    }
  }

  /// Delete textbook
  static Future<bool> deleteTextbook(String id) async {
    try {
      // Delete from Firestore
      await _firestore.collection('textbooks').doc(id).delete();

      // Optionally delete from Storage
      try {
        final ref = _storage.ref().child('textbooks/$id');
        await ref.delete();
      } catch (e) {
        print('⚠️ Could not delete storage files: $e');
      }

      print('✅ Textbook deleted');
      return true;
    } catch (e) {
      print('❌ Error deleting textbook: $e');
      return false;
    }
  }
}