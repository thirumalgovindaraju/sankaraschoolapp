// lib/data/services/claude_worksheet_service.dart
// AI-powered worksheet generation using Claude API

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/worksheet_generator_model.dart';

class ClaudeWorksheetService {
  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const String _apiVersion = '2023-06-01';

  // ⚠️ IMPORTANT: In production, store this securely (environment variables, secure storage)
  // For development, you can add your key here temporarily
  static const String _apiKey = 'YOUR_ANTHROPIC_API_KEY_HERE';

  /// Generate questions using Claude AI
  static Future<List<Question>> generateQuestions({
    required Topic topic,
    required String topicContent,
    required int mcqCount,
    required int shortAnswerCount,
    required int longAnswerCount,
    String difficulty = 'medium',
  }) async {
    try {
      if (kDebugMode) {
        print('🤖 Generating questions with Claude AI');
        print('📚 Topic: ${topic.name}');
        print('📊 MCQ: $mcqCount, Short: $shortAnswerCount, Long: $longAnswerCount');
      }

      // Build the prompt for Claude
      final prompt = _buildPrompt(
        topic: topic,
        topicContent: topicContent,
        mcqCount: mcqCount,
        shortAnswerCount: shortAnswerCount,
        longAnswerCount: longAnswerCount,
        difficulty: difficulty,
      );

      // Call Claude API
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': _apiVersion,
        },
        body: jsonEncode({
          'model': 'claude-sonnet-4-20250514',
          'max_tokens': 4000,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['content'][0]['text'] as String;

        if (kDebugMode) print('✅ Claude API response received');

        // Parse the JSON response
        return _parseClaudeResponse(content);
      } else {
        if (kDebugMode) {
          print('❌ Claude API error: ${response.statusCode}');
          print('Response: ${response.body}');
        }

        // Return mock questions as fallback
        return _generateMockQuestions(
          topic: topic,
          mcqCount: mcqCount,
          shortAnswerCount: shortAnswerCount,
          longAnswerCount: longAnswerCount,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error calling Claude API: $e');

      // Return mock questions as fallback
      return _generateMockQuestions(
        topic: topic,
        mcqCount: mcqCount,
        shortAnswerCount: shortAnswerCount,
        longAnswerCount: longAnswerCount,
      );
    }
  }

  /// Build prompt for Claude
  static String _buildPrompt({
    required Topic topic,
    required String topicContent,
    required int mcqCount,
    required int shortAnswerCount,
    required int longAnswerCount,
    required String difficulty,
  }) {
    return '''
You are an expert education content creator. Generate high-quality exam questions for students.

TOPIC INFORMATION:
$topicContent

REQUIREMENTS:
- Generate exactly $mcqCount multiple choice questions (MCQs)
- Generate exactly $shortAnswerCount short answer questions
- Generate exactly $longAnswerCount long answer questions
- Difficulty level: $difficulty
- Questions should be clear, educational, and appropriate for the topic
- MCQs should have 4 options (A, B, C, D) with one correct answer

RESPONSE FORMAT:
Return ONLY a valid JSON array with this exact structure (no markdown, no explanations):

[
  {
    "type": "mcq",
    "question": "Question text here?",
    "options": ["A) Option 1", "B) Option 2", "C) Option 3", "D) Option 4"],
    "correctAnswer": "A) Option 1",
    "marks": 2,
    "hint": "Optional hint for students"
  },
  {
    "type": "shortAnswer",
    "question": "Question text here?",
    "marks": 4,
    "hint": "Optional hint"
  },
  {
    "type": "longAnswer",
    "question": "Question text here?",
    "marks": 8,
    "hint": "Optional hint"
  }
]

Generate the questions now:''';
  }

  /// Parse Claude's JSON response
  static List<Question> _parseClaudeResponse(String responseText) {
    try {
      // Clean up the response (remove markdown code blocks if present)
      String cleanedResponse = responseText.trim();
      if (cleanedResponse.startsWith('```json')) {
        cleanedResponse = cleanedResponse.replaceFirst('```json', '');
      }
      if (cleanedResponse.startsWith('```')) {
        cleanedResponse = cleanedResponse.replaceFirst('```', '');
      }
      if (cleanedResponse.endsWith('```')) {
        cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length - 3);
      }
      cleanedResponse = cleanedResponse.trim();

      // Parse JSON
      final List<dynamic> jsonList = jsonDecode(cleanedResponse);

      List<Question> questions = [];
      int questionNumber = 1;

      for (var item in jsonList) {
        final type = _parseQuestionType(item['type'] as String);

        questions.add(Question(
          id: 'q_${DateTime.now().millisecondsSinceEpoch}_$questionNumber',
          questionNumber: questionNumber++,
          type: type,
          questionText: item['question'] as String,
          options: item['options'] != null
              ? List<String>.from(item['options'])
              : null,
          correctAnswer: item['correctAnswer'] as String?,
          marks: item['marks'] as int? ?? _getDefaultMarks(type),
          hint: item['hint'] as String?,
        ));
      }

      if (kDebugMode) print('✅ Parsed ${questions.length} questions from Claude');
      return questions;
    } catch (e) {
      if (kDebugMode) print('❌ Error parsing Claude response: $e');
      return [];
    }
  }

  /// Parse question type string to enum
  static QuestionType _parseQuestionType(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'mcq':
        return QuestionType.mcq;
      case 'shortanswer':
      case 'short_answer':
        return QuestionType.shortAnswer;
      case 'longanswer':
      case 'long_answer':
        return QuestionType.longAnswer;
      default:
        return QuestionType.mcq;
    }
  }

  /// Get default marks based on question type
  static int _getDefaultMarks(QuestionType type) {
    switch (type) {
      case QuestionType.mcq:
        return 2;
      case QuestionType.shortAnswer:
        return 4;
      case QuestionType.longAnswer:
        return 8;
    }
  }

  /// Generate mock questions as fallback (when API fails or for testing)
  static List<Question> _generateMockQuestions({
    required Topic topic,
    required int mcqCount,
    required int shortAnswerCount,
    required int longAnswerCount,
  }) {
    if (kDebugMode) print('⚠️ Generating mock questions as fallback');

    List<Question> questions = [];
    int questionNumber = 1;

    // Generate MCQs
    for (int i = 0; i < mcqCount; i++) {
      questions.add(Question(
        id: 'q_mock_${DateTime.now().millisecondsSinceEpoch}_$questionNumber',
        questionNumber: questionNumber++,
        type: QuestionType.mcq,
        questionText: 'Multiple choice question ${i + 1} about ${topic.name}?',
        options: [
          'A) Option 1',
          'B) Option 2',
          'C) Option 3',
          'D) Option 4',
        ],
        correctAnswer: 'A) Option 1',
        marks: 2,
        hint: 'Review the topic: ${topic.name}',
      ));
    }

    // Generate Short Answer questions
    for (int i = 0; i < shortAnswerCount; i++) {
      questions.add(Question(
        id: 'q_mock_${DateTime.now().millisecondsSinceEpoch}_$questionNumber',
        questionNumber: questionNumber++,
        type: QuestionType.shortAnswer,
        questionText: 'Short answer question ${i + 1} about ${topic.name}?',
        marks: 4,
        hint: 'Provide a brief explanation',
      ));
    }

    // Generate Long Answer questions
    for (int i = 0; i < longAnswerCount; i++) {
      questions.add(Question(
        id: 'q_mock_${DateTime.now().millisecondsSinceEpoch}_$questionNumber',
        questionNumber: questionNumber++,
        type: QuestionType.longAnswer,
        questionText: 'Long answer question ${i + 1} about ${topic.name}. Explain in detail.',
        marks: 8,
        hint: 'Provide a detailed explanation with examples',
      ));
    }

    if (kDebugMode) print('✅ Generated ${questions.length} mock questions');
    return questions;
  }

  /// Test Claude API connection
  static Future<bool> testConnection() async {
    try {
      if (kDebugMode) print('🔍 Testing Claude API connection...');

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': _apiVersion,
        },
        body: jsonEncode({
          'model': 'claude-sonnet-4-20250514',
          'max_tokens': 100,
          'messages': [
            {
              'role': 'user',
              'content': 'Respond with "OK" if you can read this.',
            }
          ],
        }),
      );

      final success = response.statusCode == 200;

      if (kDebugMode) {
        if (success) {
          print('✅ Claude API connection successful');
        } else {
          print('❌ Claude API connection failed: ${response.statusCode}');
          print('Response: ${response.body}');
        }
      }

      return success;
    } catch (e) {
      if (kDebugMode) print('❌ Claude API test error: $e');
      return false;
    }
  }
}