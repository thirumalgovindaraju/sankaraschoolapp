// lib/data/services/gemini_ai_service.dart
// FREE AI Service using Google Gemini API (60 requests/minute free)

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/worksheet_generator_model.dart';

class GeminiAIService {
  // ✅ Get FREE API key from: https://makersuite.google.com/app/apikey
  static const String _apiKey = 'AIzaSyClR13qwNwEYl_c_zXC8MkIWpQrzaufZSA';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  // Free tier limits: 60 requests per minute, 1500 per day

  /// Analyze textbook content and extract topics
  static Future<List<TopicModel>> analyzeTextbookContent({
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
    "name": "Topic name",
    "description": "Brief description of the topic",
    "keywords": ["keyword1", "keyword2", "keyword3"],
    "formulas": ["formula1", "formula2"],
    "difficulty": "easy|medium|hard",
    "learningObjectives": ["objective1", "objective2"]
  }
]

Important:
- Extract 3-5 main topics from the chapter
- Include relevant keywords and formulas
- Set appropriate difficulty level
- Return ONLY valid JSON, no explanations
''';

      final response = await _callGeminiAPI(prompt);

      // Parse JSON response
      final jsonStr = _extractJSON(response);
      final List<dynamic> topicsJson = json.decode(jsonStr);

      // Convert to TopicModel objects
      return topicsJson.asMap().entries.map((entry) {
        final index = entry.key;
        final topic = entry.value;

        return TopicModel(
          id: 'topic_${chapterNumber}_${index + 1}',
          name: topic['name'] ?? '',
          description: topic['description'] ?? '',
          keywords: List<String>.from(topic['keywords'] ?? []),
          formulas: List<String>.from(topic['formulas'] ?? []),
          difficulty: _parseDifficulty(topic['difficulty']),
          pageReference: startPage,
          learningObjectives: List<String>.from(topic['learningObjectives'] ?? []),
        );
      }).toList();

    } catch (e) {
      print('❌ Error analyzing content: $e');
      return [];
    }
  }

  /// Generate questions for a specific topic
  static Future<List<QuestionModel>> generateQuestions({
    required TopicModel topic,
    required String topicContent,
    required int mcqCount,
    required int shortAnswerCount,
    required int longAnswerCount,
    required DifficultyLevel difficulty,
  }) async {
    try {
      final prompt = '''
You are an IGCSE exam question generator.

Generate questions for this topic:
Topic: ${topic.name}
Description: ${topic.description}
Keywords: ${topic.keywords.join(', ')}
Difficulty: ${difficulty.toString().split('.').last}
Content: ${topicContent.substring(0, topicContent.length > 3000 ? 3000 : topicContent.length)}

Generate:
- $mcqCount multiple choice questions (4 options each)
- $shortAnswerCount short answer questions (2-4 marks)
- $longAnswerCount long answer questions (5-10 marks)

Return ONLY a JSON array with this exact format:
[
  {
    "type": "mcq|shortAnswer|longAnswer",
    "text": "Question text here",
    "options": ["A) option1", "B) option2", "C) option3", "D) option4"],
    "correctAnswer": "A",
    "markingScheme": "Detailed marking scheme with steps",
    "marks": 2,
    "hint": "Optional hint for students"
  }
]

Requirements:
- MCQ options should be plausible and educational
- Include page references where applicable
- Marking schemes should show step-by-step solutions
- Questions should test understanding, not just recall
- Return ONLY valid JSON, no explanations
''';

      final response = await _callGeminiAPI(prompt);

      // Parse JSON response
      final jsonStr = _extractJSON(response);
      final List<dynamic> questionsJson = json.decode(jsonStr);

      // Convert to QuestionModel objects
      return questionsJson.asMap().entries.map((entry) {
        final index = entry.key;
        final q = entry.value;

        return QuestionModel(
          id: 'q_${topic.id}_${index + 1}',
          questionNumber: index + 1,
          type: _parseQuestionType(q['type']),
          text: q['text'] ?? '',
          options: q['options'] != null ? List<String>.from(q['options']) : null,
          correctAnswer: q['correctAnswer'],
          markingScheme: q['markingScheme'],
          marks: q['marks'] ?? 2,
          difficulty: difficulty,
          topicId: topic.id,
          topicName: topic.name,
          pageReference: topic.pageReference,
          hint: q['hint'],
        );
      }).toList();

    } catch (e) {
      print('❌ Error generating questions: $e');
      return [];
    }
  }

  /// Generate marking scheme for subjective answers
  static Future<String> generateMarkingFeedback({
    required QuestionModel question,
    required String studentAnswer,
  }) async {
    try {
      final prompt = '''
You are an IGCSE examiner providing feedback.

Question: ${question.text}
Marking Scheme: ${question.markingScheme}
Student Answer: $studentAnswer
Total Marks: ${question.marks}

Analyze the student's answer and provide:
1. Marks awarded (out of ${question.marks})
2. What was done correctly
3. What was missing or incorrect
4. Constructive feedback for improvement

Return ONLY a JSON object:
{
  "marksAwarded": 3,
  "feedback": "Detailed feedback here...",
  "strengths": ["strength1", "strength2"],
  "improvements": ["area1", "area2"]
}
''';

      final response = await _callGeminiAPI(prompt);
      return response;

    } catch (e) {
      print('❌ Error generating feedback: $e');
      return 'Unable to generate feedback at this time.';
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
        return QuestionType.shortAnswer;
      case 'longanswer':
      case 'long_answer':
        return QuestionType.longAnswer;
      case 'truefalse':
      case 'true_false':
        return QuestionType.trueFalse;
      default:
        return QuestionType.mcq;
    }
  }
}

// ============================================================================
// ALTERNATIVE: Claude API Service (for when you upgrade to paid)
// ============================================================================

class ClaudeAIService {
  static const String _apiKey = 'YOUR_CLAUDE_API_KEY_HERE';
  static const String _baseUrl = 'https://api.anthropic.com/v1/messages';

  static Future<String> _callClaudeAPI(String prompt) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': _apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: json.encode({
        'model': 'claude-3-sonnet-20240229',
        'max_tokens': 2048,
        'messages': [
          {
            'role': 'user',
            'content': prompt,
          }
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['content'][0]['text'];
    } else {
      throw Exception('Claude API error: ${response.statusCode}');
    }
  }
}