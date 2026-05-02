import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _modelName = 'gemini-2.5-flash';
  static GenerativeModel? _model;
  static String? _apiKey;

  static void setApiKey(String key) {
    _apiKey = key;
    _model = GenerativeModel(model: _modelName, apiKey: key);
  }

  static String? get apiKey => _apiKey;

  static Future<Map<String, String>?> analyzeIngredients({
    required List<String> ingredients,
    required List<String> healthConditions,
  }) async {
    if (_model == null) {
      print(
        'GeminiService Error: API key chưa được thiết lập hoặc Model khởi tạo lỗi.',
      );
      return null;
    }

    final prompt = _buildPrompt(ingredients, healthConditions);

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);

      final text = response.text?.trim() ?? '';
      if (text.isEmpty) return null;

      return _parseResponse(text);
    } catch (e) {
      print('GeminiService Error: $e');
      return null;
    }
  }

  static String _buildPrompt(
    List<String> ingredients,
    List<String> healthConditions,
  ) {
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
