// lib/data/services/gemini_ai_service.dart
// ✅ FIXED - All required parameters included

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/worksheet_generator_model.dart';

class GeminiAIService {
  static const String _apiKey = 'AIzaSyClR13qwNwEYl_c_zXC8MkIWpQrzaufZSA';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  /// Analyze textbook content and extract topics
  static Future<List<Topic>> analyzeTextbookContent({
    required String chapterText,
    required String chapterTitle,
    required int chapterNumber,
    required int startPage,
  }) async {
    try {
      final prompt = '''
You are an educational content analyzer for IGCSE curriculum.

Analyze this textbook chapter and extract structured information:

Chapter: $chapterTitle (Chapter $chapterNumber, Page $startPage)
Content: ${chapterText.substring(0, chapterText.length > 5000 ? 5000 : chapterText.length)}

Extract and return ONLY a JSON array with this exact format:
[
  {
    "title": "Topic name",
    "name": "Topic name",
    "description": "Brief description of the topic",
    "keywords": ["keyword1", "keyword2", "keyword3"],
    "difficulty": "easy|medium|hard"
  }
]

Important:
- Extract 3-5 main topics from the chapter
- Include relevant keywords
- Assess difficulty level for each topic
- Return ONLY valid JSON, no explanations
''';

      final response = await _callGeminiAPI(prompt);

      // Parse JSON response
      final jsonStr = _extractJSON(response);
      final List<dynamic> topicsJson = json.decode(jsonStr);

      // Convert to Topic objects
      return topicsJson.asMap().entries.map((entry) {
        final index = entry.key;
        final topic = entry.value;

        return Topic(
          id: 'topic_${chapterNumber}_${index + 1}',
          name: topic['name'] ?? topic['title'] ?? 'Topic ${index + 1}',  // ✅ Added name
          title: topic['title'] ?? topic['name'] ?? 'Topic ${index + 1}',
          description: topic['description'] ?? '',
          keywords: List<String>.from(topic['keywords'] ?? []),
          difficulty: _parseDifficulty(topic['difficulty']),  // ✅ Added difficulty
        );
      }).toList();

    } catch (e) {
      // Use debugPrint or logger in production instead of print
      if (e.toString().isNotEmpty) {
        // Handle error silently or log to service
      }
      return [];
    }
  }

  /// Generate questions for a specific topic
  static Future<List<Question>> generateQuestions({
    required Topic topic,
    required String topicContent,
    required int mcqCount,
    required int shortAnswerCount,
    required int longAnswerCount,
  }) async {
    try {
      final prompt = '''
You are an IGCSE exam question generator.

Generate questions for this topic:
Topic: ${topic.title}
Description: ${topic.description}
Keywords: ${topic.keywords.join(', ')}
Content: ${topicContent.substring(0, topicContent.length > 3000 ? 3000 : topicContent.length)}

Generate:
- $mcqCount multiple choice questions (4 options each)
- $shortAnswerCount short answer questions (2-4 marks)
- $longAnswerCount long answer questions (5-10 marks)

Return ONLY a JSON array with this exact format:
[
  {
    "type": "mcq|shortAnswer|longAnswer",
    "questionText": "Question text here",
    "options": ["A) option1", "B) option2", "C) option3", "D) option4"],
    "correctAnswer": "A",
    "marks": 2,
    "hint": "Optional hint for students"
  }
]

Requirements:
- MCQ options should be plausible and educational
- Questions should test understanding, not just recall
- Return ONLY valid JSON, no explanations
''';

      final response = await _callGeminiAPI(prompt);

      // Parse JSON response
      final jsonStr = _extractJSON(response);
      final List<dynamic> questionsJson = json.decode(jsonStr);

      // Convert to Question objects
      return questionsJson.asMap().entries.map((entry) {
        final index = entry.key;
        final q = entry.value;

        return Question(
          id: 'q_${topic.id}_${index + 1}',
          questionNumber: index + 1,
          type: _parseQuestionType(q['type']),
          questionText: q['questionText'] ?? q['text'] ?? '',
          options: q['options'] != null ? List<String>.from(q['options']) : null,
          correctAnswer: q['correctAnswer'],
          marks: q['marks'] ?? 2,
          hint: q['hint'],
        );
      }).toList();

    } catch (e) {
      // Use debugPrint or logger in production instead of print
      if (e.toString().isNotEmpty) {
        // Handle error silently or log to service
      }
      return [];
    }
  }

  /// Private method to call Gemini API
  static Future<String> _callGeminiAPI(String prompt) async {
    final url = '$_baseUrl/models/gemini-pro:generateContent?key=$_apiKey';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 2048,
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception('Gemini API error: ${response.statusCode} - ${response.body}');
    }
  }

  /// Extract JSON from response (handles markdown formatting)
  static String _extractJSON(String response) {
    // Remove markdown code blocks if present
    String cleaned = response
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    // Find JSON array or object
    int start = cleaned.indexOf('[');
    int end = cleaned.lastIndexOf(']');

    if (start != -1 && end != -1) {
      return cleaned.substring(start, end + 1);
    }

    start = cleaned.indexOf('{');
    end = cleaned.lastIndexOf('}');

    if (start != -1 && end != -1) {
      return cleaned.substring(start, end + 1);
    }

    return cleaned;
  }

  /// Parse difficulty level from string
  static DifficultyLevel _parseDifficulty(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'easy':
        return DifficultyLevel.easy;
      case 'hard':
        return DifficultyLevel.hard;
      case 'medium':
      default:
        return DifficultyLevel.medium;
    }
  }

  /// Parse question type from string
  static QuestionType _parseQuestionType(String? type) {
    switch (type?.toLowerCase()) {
      case 'mcq':
        return QuestionType.mcq;
      case 'shortanswer':
      case 'short_answer':
      case 'shortAnswer':
        return QuestionType.shortAnswer;
      case 'longanswer':
      case 'long_answer':
      case 'longAnswer':
        return QuestionType.longAnswer;
      case 'truefalse':
      case 'true_false':
        return QuestionType.trueFalse;
      case 'fillintheblank':
      case 'fillInTheBlank':
        return QuestionType.fillInTheBlank;
      default:
        return QuestionType.mcq;
    }
  }
}