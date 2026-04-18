import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Service for interacting with Cerebras AI API
class CerebrasAiService {
  final http.Client client;
  final String _apiKey = dotenv.env['CEREBRAS_APIKEY']!;

  static const String _baseUrl = 'https://api.cerebras.ai/v1/chat/completions';
  static const Duration _timeout = Duration(seconds: 30);

  CerebrasAiService({required this.client});

  /// Generate a summary using Cerebras AI
  ///
  /// [content] - Formatted content to process
  /// [systemPrompt] - System prompt defining AI behavior
  /// [userPrompt] - User prompt with instructions
  /// [temperature] - Controls randomness (default: 0.3)
  /// [maxTokens] - Maximum response length (default: 300)
  /// Returns the AI-generated response text
  Future<String> generateCompletion({
    required String content,
    required String systemPrompt,
    required String userPrompt,
    double temperature = 0.3,
    int maxTokens = 300,
  }) async {
    try {
      final response = await client
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': 'llama3.1-8b',
              'messages': [
                {'role': 'system', 'content': systemPrompt},
                {'role': 'user', 'content': '$userPrompt\n\n$content'},
              ],
              'temperature': temperature,
              'max_tokens': maxTokens,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final summary = data['choices']?[0]?['message']?['content'] as String?;

        if (summary == null || summary.isEmpty) {
          throw Exception('Empty response from AI service');
        }

        return summary.trim();
      } else {
        print('❌ Cerebras API Error: Status ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception(
          'API request failed with status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Cerebras AI Service Error: $e');
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timed out. Please try again.');
      }
      rethrow;
    }
  }

  /// Format news items into a structured prompt for the AI
  String formatNewsForPrompt(List<Map<String, String>> newsItems) {
    final buffer = StringBuffer();

    for (int i = 0; i < newsItems.length; i++) {
      buffer.writeln('Title: ${newsItems[i]['title']}');

      if (newsItems[i]['content'] != null &&
          newsItems[i]['content']!.isNotEmpty) {
        buffer.writeln('${newsItems[i]['content']}');
      }

      if (newsItems[i]['publishedAt'] != null) {
        buffer.writeln('Date: ${newsItems[i]['publishedAt']}');
      }

      buffer.writeln('---');
    }

    return buffer.toString();
  }
}
