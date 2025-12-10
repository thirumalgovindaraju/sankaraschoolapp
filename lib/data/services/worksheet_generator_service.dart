// lib/data/services/worksheet_generator_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:file_picker/file_picker.dart';
import '../models/worksheet_generator_model.dart';
import 'gemini_ai_service.dart';
import 'pdf_processor_service.dart';

class WorksheetGeneratorService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generate worksheet with AI-powered questions
  static Future<WorksheetModel?> generateWorksheet({
    required String title,
    required Textbook textbook,
    required List<Topic> selectedTopics,
    required int mcqCount,
    required int shortAnswerCount,
    required int longAnswerCount,
    required String difficulty,
    required int durationMinutes,
    required String createdBy,
    required String createdByName,
    required String type,
  }) async {
    try {
      if (kDebugMode) print('🔄 Generating worksheet: $title');

      List<Question> allQuestions = [];
      int questionNumber = 1;

      // Generate questions for each selected topic
      for (var topic in selectedTopics) {
        if (kDebugMode) print('📝 Generating questions for: ${topic.name}');

        // Get relevant content for this topic (simplified - you might want to enhance this)
        String topicContent = '''
Topic: ${topic.name}
Description: ${topic.description}
Keywords: ${topic.keywords.join(', ')}
        ''';

        // Calculate questions per topic (distribute evenly)
        int topicMcq = (mcqCount / selectedTopics.length).round();
        int topicShort = (shortAnswerCount / selectedTopics.length).round();
        int topicLong = (longAnswerCount / selectedTopics.length).round();

        // Generate questions using Gemini AI
        final questions = await GeminiAIService.generateQuestions(
          topic: topic,
          topicContent: topicContent,
          mcqCount: topicMcq,
          shortAnswerCount: topicShort,
          longAnswerCount: topicLong,
        );

        // Renumber questions sequentially
        for (var question in questions) {
          allQuestions.add(Question(
            id: question.id,
            questionNumber: questionNumber++,
            type: question.type,
            questionText: question.questionText,
            options: question.options,
            correctAnswer: question.correctAnswer,
            marks: question.marks,
            hint: question.hint,
          ));
        }
      }

      if (allQuestions.isEmpty) {
        if (kDebugMode) print('❌ No questions generated');
        return null;
      }

      // Calculate total marks
      int totalMarks = allQuestions.fold(0, (sum, q) => sum + q.marks);

      // Create worksheet model
      final worksheetId = 'worksheet_${DateTime.now().millisecondsSinceEpoch}';
      final worksheet = WorksheetModel(
        id: worksheetId,
        title: title,
        textbookId: textbook.id,
        textbookTitle: textbook.title,
        topicIds: selectedTopics.map((t) => t.id).toList(),
        topicNames: selectedTopics.map((t) => t.name).toList(),
        questions: allQuestions,
        totalMarks: totalMarks,
        durationMinutes: durationMinutes,
        createdAt: DateTime.now(),
        createdBy: createdBy,
        createdByName: createdByName,
        status: 'draft',
        overallDifficulty: difficulty,
      );

      // Save to Firestore
      await _firestore
          .collection('worksheets')
          .doc(worksheetId)
          .set(worksheet.toJson());

      if (kDebugMode) {
        print('✅ Worksheet generated successfully');
        print('📊 Total questions: ${allQuestions.length}');
        print('📊 Total marks: $totalMarks');
      }

      return worksheet;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error generating worksheet: $e');
        print('Stack trace: $stackTrace');
      }
      return null;
    }
  }

  /// Fetch all worksheets
  static Future<List<WorksheetModel>> fetchWorksheets() async {
    try {
      if (kDebugMode) print('📚 Fetching worksheets...');

      final snapshot = await _firestore
          .collection('worksheets')
          .orderBy('createdAt', descending: true)
          .get();

      final worksheets = snapshot.docs
          .map((doc) => WorksheetModel.fromJson(doc.data()))
          .toList();

      if (kDebugMode) print('✅ Fetched ${worksheets.length} worksheets');
      return worksheets;
    } catch (e) {
      if (kDebugMode) print('❌ Error fetching worksheets: $e');
      return [];
    }
  }

  /// Fetch worksheet by ID
  static Future<WorksheetModel?> fetchWorksheetById(String id) async {
    try {
      final doc = await _firestore.collection('worksheets').doc(id).get();
      if (doc.exists) {
        return WorksheetModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('❌ Error fetching worksheet: $e');
      return null;
    }
  }

  /// Generate and print PDF
  static Future<void> generateAndPrintPDF(WorksheetModel worksheet) async {
    try {
      if (kDebugMode) print('📄 Generating PDF for: ${worksheet.title}');

      final pdf = pw.Document();

      // Add pages to PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            // Header
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    worksheet.title,
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total Marks: ${worksheet.totalMarks}'),
                      pw.Text('Duration: ${worksheet.durationMinutes} minutes'),
                    ],
                  ),
                  pw.Divider(thickness: 2),
                  pw.SizedBox(height: 16),
                ],
              ),
            ),

            // Questions
            ...worksheet.questions.map((question) {
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 16),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Question text
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Q${question.questionNumber}. ',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Expanded(
                          child: pw.Text(question.questionText),
                        ),
                        pw.Text(
                          '[${question.marks} marks]',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),

                    // Options for MCQ
                    if (question.type == QuestionType.mcq &&
                        question.options != null)
                      ...question.options!.map((option) {
                        return pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 20, top: 4),
                          child: pw.Text(option),
                        );
                      }),

                    // Answer space for non-MCQ
                    if (question.type != QuestionType.mcq)
                      pw.Container(
                        margin: const pw.EdgeInsets.only(left: 20, top: 8),
                        height: question.type == QuestionType.longAnswer
                            ? 100
                            : 40,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300),
                        ),
                      ),

                    pw.SizedBox(height: 16),
                  ],
                ),
              );
            }),
          ],
        ),
      );

      // Print or save PDF
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: '${worksheet.title}.pdf',
      );

      if (kDebugMode) print('✅ PDF generated successfully');
    } catch (e) {
      if (kDebugMode) print('❌ Error generating PDF: $e');
      rethrow;
    }
  }

  /// Assign worksheet to students/classes
  static Future<bool> assignWorksheet({
    required String worksheetId,
    List<String>? studentIds,
    List<String>? classIds,
  }) async {
    try {
      if (kDebugMode) print('📤 Assigning worksheet: $worksheetId');

      await _firestore.collection('worksheets').doc(worksheetId).update({
        'assignedToStudents': studentIds ?? [],
        'assignedToClasses': classIds ?? [],
        'status': 'published',
      });

      if (kDebugMode) print('✅ Worksheet assigned successfully');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error assigning worksheet: $e');
      return false;
    }
  }

  /// Submit worksheet answers
  static Future<bool> submitWorksheet(
      String worksheetId,
      WorksheetSubmission submission,
      ) async {
    try {
      if (kDebugMode) print('📥 Submitting worksheet: $worksheetId');

      final worksheet = await fetchWorksheetById(worksheetId);
      if (worksheet == null) return false;

      final submissions = worksheet.submissions ?? [];
      submissions.add(submission);

      await _firestore.collection('worksheets').doc(worksheetId).update({
        'submissions': submissions.map((s) => s.toJson()).toList(),
      });

      if (kDebugMode) print('✅ Worksheet submitted successfully');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error submitting worksheet: $e');
      return false;
    }
  }

  /// Delete worksheet
  static Future<bool> deleteWorksheet(String worksheetId) async {
    try {
      await _firestore.collection('worksheets').doc(worksheetId).delete();
      if (kDebugMode) print('✅ Worksheet deleted');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error deleting worksheet: $e');
      return false;
    }
  }

  /// Upload textbook (delegates to PDFProcessorService)
  static Future<Textbook?> uploadTextbook({
    required String title,
    required String subject,
    required String board,
    required String grade,
    required PlatformFile file,
    String? publisher,
    String? edition,
  }) async {
    try {
      if (kDebugMode) print('📤 Uploading textbook via PDFProcessorService...');

      // Delegate to PDFProcessorService which handles the actual upload
      final textbook = await PDFProcessorService.uploadTextbook(
        title: title,
        subject: subject,
        board: board,
        grade: grade,
        uploadedBy: 'current_user', // You may want to pass this as a parameter
        publisher: publisher,
        edition: edition,
      );

      return textbook;
    } catch (e) {
      if (kDebugMode) print('❌ Error in uploadTextbook: $e');
      return null;
    }
  }
}