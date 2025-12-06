// lib/data/services/worksheet_generator_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/worksheet_generator_model.dart';
import 'gemini_ai_service.dart';

class WorksheetGeneratorService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generate worksheet questions using AI
  static Future<WorksheetModel?> generateWorksheet({
    required String title,
    required TextbookModel textbook,
    required List<TopicModel> selectedTopics,
    required int mcqCount,
    required int shortAnswerCount,
    required int longAnswerCount,
    required DifficultyLevel difficulty,
    required int durationMinutes,
    required String createdBy,
    required String createdByName,
    required WorksheetType type,
  }) async {
    try {
      print('🎯 Generating worksheet...');

      List<QuestionModel> allQuestions = [];
      int totalMarks = 0;

      // Generate questions for each selected topic
      for (var topic in selectedTopics) {
        print('📝 Generating questions for: ${topic.name}');

        // Get topic content (in real app, fetch from stored chapter text)
        final topicContent = topic.description + '\n' + topic.keywords.join(', ');

        // Calculate questions per topic (distribute evenly)
        final mcqPerTopic = (mcqCount / selectedTopics.length).ceil();
        final shortPerTopic = (shortAnswerCount / selectedTopics.length).ceil();
        final longPerTopic = (longAnswerCount / selectedTopics.length).ceil();

        // Generate questions using AI
        final questions = await GeminiAIService.generateQuestions(
          topic: topic,
          topicContent: topicContent,
          mcqCount: mcqPerTopic,
          shortAnswerCount: shortPerTopic,
          longAnswerCount: longPerTopic,
          difficulty: difficulty,
        );

        allQuestions.addAll(questions);
      }

      // Shuffle and limit to requested counts
      allQuestions.shuffle();
      final mcqs = allQuestions
          .where((q) => q.type == QuestionType.mcq)
          .take(mcqCount)
          .toList();
      final shortAnswers = allQuestions
          .where((q) => q.type == QuestionType.shortAnswer)
          .take(shortAnswerCount)
          .toList();
      final longAnswers = allQuestions
          .where((q) => q.type == QuestionType.longAnswer)
          .take(longAnswerCount)
          .toList();

      final finalQuestions = [...mcqs, ...shortAnswers, ...longAnswers];

      // Renumber questions
      for (int i = 0; i < finalQuestions.length; i++) {
        finalQuestions[i] = QuestionModel(
          id: finalQuestions[i].id,
          questionNumber: i + 1,
          type: finalQuestions[i].type,
          text: finalQuestions[i].text,
          options: finalQuestions[i].options,
          correctAnswer: finalQuestions[i].correctAnswer,
          markingScheme: finalQuestions[i].markingScheme,
          marks: finalQuestions[i].marks,
          difficulty: finalQuestions[i].difficulty,
          topicId: finalQuestions[i].topicId,
          topicName: finalQuestions[i].topicName,
          pageReference: finalQuestions[i].pageReference,
          diagramUrl: finalQuestions[i].diagramUrl,
          hint: finalQuestions[i].hint,
        );
        totalMarks += finalQuestions[i].marks;
      }

      // Create worksheet model
      final worksheetId = 'worksheet_${DateTime.now().millisecondsSinceEpoch}';
      final worksheet = WorksheetModel(
        id: worksheetId,
        title: title,
        textbookId: textbook.id,
        textbookTitle: textbook.title,
        topicIds: selectedTopics.map((t) => t.id).toList(),
        topicNames: selectedTopics.map((t) => t.name).toList(),
        questions: finalQuestions,
        totalMarks: totalMarks,
        durationMinutes: durationMinutes,
        createdAt: DateTime.now(),
        createdBy: createdBy,
        createdByName: createdByName,
        assignedToStudents: [],
        assignedToClasses: [],
        type: type,
        status: WorksheetStatus.draft,
        overallDifficulty: difficulty,
      );

      // Save to Firestore
      await _firestore
          .collection('worksheets')
          .doc(worksheetId)
          .set(worksheet.toMap());

      print('✅ Worksheet generated: ${finalQuestions.length} questions, $totalMarks marks');

      return worksheet;
    } catch (e) {
      print('❌ Error generating worksheet: $e');
      return null;
    }
  }

  /// Generate PDF from worksheet
  static Future<void> generateAndPrintPDF(WorksheetModel worksheet) async {
    final pdf = pw.Document();

    // Add worksheet pages
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          _buildHeader(worksheet),
          pw.SizedBox(height: 20),

          // Instructions
          _buildInstructions(worksheet),
          pw.SizedBox(height: 20),

          // Questions
          ..._buildQuestions(worksheet),
        ],
      ),
    );

    // Add marking scheme page
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'MARKING SCHEME (For Teacher Use Only)',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          ..._buildMarkingScheme(worksheet),
        ],
      ),
    );

    // Print or save PDF
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  /// Build PDF header
  static pw.Widget _buildHeader(WorksheetModel worksheet) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Center(
          child: pw.Text(
            'SRI SANKARA GLOBAL SCHOOL - IGCSE',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Center(
          child: pw.Text(
            worksheet.title.toUpperCase(),
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Divider(),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Student Name: ___________________'),
            pw.Text('Date: __________'),
          ],
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Class: ___________'),
            pw.Text('Duration: ${worksheet.durationMinutes} minutes'),
          ],
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Total Marks: ${worksheet.totalMarks}'),
            pw.Text('Pass Marks: ${(worksheet.totalMarks * 0.5).round()}'),
          ],
        ),
        pw.Divider(),
      ],
    );
  }

  /// Build instructions
  static pw.Widget _buildInstructions(WorksheetModel worksheet) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'INSTRUCTIONS:',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.Bullet(text: 'Read all questions carefully before answering'),
        pw.Bullet(text: 'Answer all questions in the spaces provided'),
        pw.Bullet(text: 'Show all your working for full marks'),
        pw.Bullet(text: 'Calculators are permitted'),
        pw.SizedBox(height: 10),
      ],
    );
  }

  /// Build questions
  static List<pw.Widget> _buildQuestions(WorksheetModel worksheet) {
    List<pw.Widget> widgets = [];

    // Group by type
    final mcqs = worksheet.questions
        .where((q) => q.type == QuestionType.mcq)
        .toList();
    final shortAnswers = worksheet.questions
        .where((q) => q.type == QuestionType.shortAnswer)
        .toList();
    final longAnswers = worksheet.questions
        .where((q) => q.type == QuestionType.longAnswer)
        .toList();

    // Section A: MCQs
    if (mcqs.isNotEmpty) {
      widgets.add(pw.Header(
        level: 1,
        child: pw.Text(
          'SECTION A: MULTIPLE CHOICE (${mcqs.length} questions × ${mcqs.first.marks} marks = ${mcqs.length * mcqs.first.marks} marks)',
        ),
      ));
      widgets.add(pw.Text('Select the correct answer.'));
      widgets.add(pw.SizedBox(height: 10));

      for (var q in mcqs) {
        widgets.add(_buildMCQ(q));
        widgets.add(pw.SizedBox(height: 10));
      }
    }

    // Section B: Short Answers
    if (shortAnswers.isNotEmpty) {
      widgets.add(pw.SizedBox(height: 20));
      widgets.add(pw.Header(
        level: 1,
        child: pw.Text(
          'SECTION B: SHORT ANSWER (${shortAnswers.length} questions × ${shortAnswers.first.marks} marks = ${shortAnswers.length * shortAnswers.first.marks} marks)',
        ),
      ));
      widgets.add(pw.Text('Show your working.'));
      widgets.add(pw.SizedBox(height: 10));

      for (var q in shortAnswers) {
        widgets.add(_buildShortAnswer(q));
        widgets.add(pw.SizedBox(height: 20));
      }
    }

    // Section C: Long Answers
    if (longAnswers.isNotEmpty) {
      widgets.add(pw.SizedBox(height: 20));
      widgets.add(pw.Header(
        level: 1,
        child: pw.Text(
          'SECTION C: LONG ANSWER (${longAnswers.length} questions × ${longAnswers.first.marks} marks = ${longAnswers.length * longAnswers.first.marks} marks)',
        ),
      ));
      widgets.add(pw.Text('Show all steps clearly.'));
      widgets.add(pw.SizedBox(height: 10));

      for (var q in longAnswers) {
        widgets.add(_buildLongAnswer(q));
        widgets.add(pw.SizedBox(height: 30));
      }
    }

    return widgets;
  }

  /// Build MCQ question
  static pw.Widget _buildMCQ(QuestionModel q) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '${q.questionNumber}. ${q.text}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        ...?q.options?.map((option) => pw.Text('   $option')),
        pw.SizedBox(height: 3),
        pw.Text(
          '[Difficulty: ${q.difficulty.toString().split('.').last} | Topic: ${q.topicName} | Ref: Page ${q.pageReference}]',
          style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
        ),
      ],
    );
  }

  /// Build short answer question
  static pw.Widget _buildShortAnswer(QuestionModel q) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '${q.questionNumber}. ${q.text}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.Container(
          height: 80,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Padding(
            padding: pw.EdgeInsets.all(5),
            child: pw.Text('[Space for working]'),
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text('Answer: _______________'),
        pw.Text(
          '[Difficulty: ${q.difficulty.toString().split('.').last} | Topic: ${q.topicName} | Ref: Page ${q.pageReference}]',
          style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
        ),
      ],
    );
  }

  /// Build long answer question
  static pw.Widget _buildLongAnswer(QuestionModel q) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '${q.questionNumber}. ${q.text}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.Container(
          height: 150,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Padding(
            padding: pw.EdgeInsets.all(5),
            child: pw.Text('[Large space for working]'),
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          '[Difficulty: ${q.difficulty.toString().split('.').last} | Topic: ${q.topicName} | Ref: Page ${q.pageReference}]',
          style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
        ),
      ],
    );
  }

  /// Build marking scheme
  static List<pw.Widget> _buildMarkingScheme(WorksheetModel worksheet) {
    List<pw.Widget> widgets = [];

    for (var q in worksheet.questions) {
      widgets.add(
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              '${q.questionNumber}. ${q.text}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 5),
            if (q.type == QuestionType.mcq)
              pw.Text('Answer: ${q.correctAnswer}')
            else
              pw.Text(q.markingScheme ?? 'Detailed marking scheme'),
            pw.SizedBox(height: 10),
            pw.Divider(),
          ],
        ),
      );
    }

    return widgets;
  }

  /// Get all worksheets
  static Future<List<WorksheetModel>> getWorksheets() async {
    try {
      final snapshot = await _firestore
          .collection('worksheets')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => WorksheetModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error fetching worksheets: $e');
      return [];
    }
  }

  /// Assign worksheet to students/classes
  static Future<bool> assignWorksheet({
    required String worksheetId,
    List<String>? studentIds,
    List<String>? classIds,
  }) async {
    try {
      await _firestore.collection('worksheets').doc(worksheetId).update({
        if (studentIds != null) 'assignedToStudents': studentIds,
        if (classIds != null) 'assignedToClasses': classIds,
        'status': WorksheetStatus.published.toString(),
      });

      print('✅ Worksheet assigned');
      return true;
    } catch (e) {
      print('❌ Error assigning worksheet: $e');
      return false;
    }
  }
}