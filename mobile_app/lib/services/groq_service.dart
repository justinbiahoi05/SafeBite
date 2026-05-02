import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'secrets.dart';

class GroqService {
  static const String _apiKey = Secrets.groqApiKey;
  static const String _baseUrl =
      "https://api.groq.com/openai/v1/chat/completions";

  /// PHASE 1: EXTRACT ALL INGREDIENTS (VISION)
  static Future<Map<String, dynamic>?> extractIngredients(XFile photo) async {
    final bytes = await photo.readAsBytes();
    final base64Image = base64Encode(bytes);

    final payload = {
      "model": "meta-llama/llama-4-scout-17b-16e-instruct",
      "messages": [
        {
          "role": "user",
          "content": [
            {
              "type": "text",
              "text":
                  "Identify and extract EVERY single ingredient and nutrition value from this image. Do not miss any items. Return a JSON object where the key is the ingredient name (in Vietnamese with accents) and the value is the amount. If amount is not clear, use 'N/A'. Return ONLY the JSON object.",
            },
            {
              "type": "image_url",
              "image_url": {"url": "data:image/jpeg;base64,$base64Image"},
            },
          ],
        },
      ],
      "temperature": 0.1,
      "response_format": {"type": "json_object"},
    };

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'];
        return jsonDecode(content) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// PHASE 2: HEALTH ADVICE (TEXT)
  static Future<String?> getHealthAdvice({
    required Map<String, dynamic> ingredientsData,
    required List<String> healthConditions,
  }) async {
    final conditionsText = healthConditions.isEmpty
        ? "Healthy individual"
        : healthConditions.join(", ");

    final ingredientsText = jsonEncode(ingredientsData);

    final payload = {
      "model": "llama-3.3-70b-versatile",
      "messages": [
        {
          "role": "system",
          "content":
              "You are a senior nutritionist. Provide expert advice in Vietnamese based on the provided data.",
        },
        {
          "role": "user",
          "content":
              "Data: $ingredientsText. User Conditions: $conditionsText. Provide a concise 3-line advice in Vietnamese. Focus on the most critical risks or benefits.",
        },
      ],
      "temperature": 0.7,
    };

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// PHASE 3: COMPREHENSIVE PER-INGREDIENT ANALYSIS
  static Future<Map<String, String>?> analyzeIngredients({
    required List<String> ingredients,
    required List<String> healthConditions,
  }) async {
    final ingredientsText = ingredients.join(", ");
    final conditionsText = healthConditions.isEmpty
        ? "Healthy individual"
        : healthConditions.join(", ");

    final payload = {
      "model": "llama-3.3-70b-versatile",
      "messages": [
        {
          "role": "system",
          "content":
              "You are a meticulous nutritionist. You MUST analyze EVERY SINGLE ingredient in the provided list. DO NOT skip any item. For EACH ingredient, return one of these labels: 'sugar', 'sweetener', 'sodium', 'allergen', 'bad_fat', 'acidic', 'additive', 'spicy', 'safe'. If an ingredient is not harmful for the given health conditions, you MUST label it as 'safe'. The output MUST be a JSON object containing ALL input ingredients.",
        },
        {
          "role": "user",
          "content":
              "Analyze all these ingredients: $ingredientsText. User has these conditions: $conditionsText. Return a complete JSON for ALL items.",
        },
      ],
      "temperature": 0.1,
      "response_format": {"type": "json_object"},
    };

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'];
        final Map<String, dynamic> rawMap = jsonDecode(content);
        return rawMap.map((key, value) => MapEntry(key, value.toString()));
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
