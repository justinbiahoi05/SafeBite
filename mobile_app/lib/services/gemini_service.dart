import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _model = 'gemini-2.5-flash';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  // API key - in production, use environment variable or secure storage
  // For demo, we'll ask user to provide or use a placeholder
  static String? _apiKey;

  static void setApiKey(String key) {
    _apiKey = key;
  }

  static String? get apiKey => _apiKey;

  /// Analyze ingredients and return safety labels using Gemini
  /// [ingredients] - List of ingredient names from OCR
  /// [healthConditions] - User's health conditions
  static Future<Map<String, String>?> analyzeIngredients({
    required List<String> ingredients,
    required List<String> healthConditions,
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      print('GeminiService: API key not set');
      return null;
    }

    // Build optimized prompt with context
    final prompt = _buildPrompt(ingredients, healthConditions);

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': [
            {'parts': [{'text': prompt}]}
          ],
          'generationConfig': {
            'temperature': 0.9,
            'maxOutputTokens': 3000,
            'topP': 0.95,
          },
        }),
      );

      if (response.statusCode != 200) {
        print('GeminiService Error: ${response.statusCode} - ${response.body}');
        return null;
      }

      final data = json.decode(response.body);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';

      if (text.isEmpty) {
        return null;
      }

      // Parse the response to extract ingredient-label pairs
      return _parseResponse(text);
    } catch (e) {
      print('GeminiService Error: $e');
      return null;
    }
  }

  static String _buildPrompt(List<String> ingredients, List<String> healthConditions) {
    final conditionsText = healthConditions.isEmpty
        ? 'None specified'
        : healthConditions.join(', ');

    final ingredientsText = ingredients.join(', ');

    return '''
Analyze the following ingredient list for safety based on the user's health conditions.

USER HEALTH CONDITIONS: $conditionsText

INGREDIENTS: $ingredientsText

For each ingredient, classify it as one of these safety labels based on the user's health conditions:
- safe: Ingredient is safe for the user
- caution: Ingredient should be used with caution
- danger: Ingredient is unsafe/harmful for the user
- unknown: Unable to determine

Output in this exact JSON format:
{
  "ingredient_name": "label",
  ...
}

Only output valid JSON, no other text.
''';
  }

  static Map<String, String>? _parseResponse(String response) {
    try {
      // Try to extract JSON from response
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;

      if (jsonStart == -1 || jsonEnd == 0) return null;

      final jsonStr = response.substring(jsonStart, jsonEnd);
      final data = json.decode(jsonStr) as Map<String, dynamic>;

      return data.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      print('GeminiService Parse Error: $e');
      return null;
    }
  }
}