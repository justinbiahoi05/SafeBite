
class HealthLogic {
  static const Map<String, List<String>> labelToConditionMap = {
    'sugar': ['Diabetes'],
    'sweetener': ['Diabetes'],
    'sodium': ['Kidney Disease', 'Hypertension'],
    'allergen': ['Peanut Allergy'],
    'bad_fat': ['Hypertension', 'Kidney Disease'],
    'acidic': ['Pregnancy'],
    'additive': ['Pregnancy'],
    'spicy': ['Hypertension'],
  };

  static const Map<String, String> conditionTranslations = {
    'Diabetes': 'Tiểu đường',
    'Kidney Disease': 'Bệnh thận',
    'Pregnancy': 'Thai kỳ',
    'Peanut Allergy': 'Dị ứng đậu phộng',
    'Hypertension': 'Cao huyết áp',
  };

  /// 
  /// [detectedLabels] 
  /// [userProfile] 
  /// 

  static Map<String, dynamic> analyze({
    required List<String> detectedLabels,
    required Map<String, bool> userProfile,
  }) {
    final List<String> dangerousIngredients = [];
    final List<String> reasons = [];

    if (userProfile.isEmpty || !userProfile.values.any((v) => v == true)) {
      return _buildResult(dangerousIngredients, reasons);
    }

    for (final label in detectedLabels) {
      if (!labelToConditionMap.containsKey(label) || label == 'safe') {
        continue;
      }

      final List<String> affectedConditions = labelToConditionMap[label]!;

      for (final condition in affectedConditions) {
        // STRICT INTERSECTION: Only flag if condition is explicitly TRUE
        if (userProfile[condition] == true) {
          if (!dangerousIngredients.contains(label)) {
            dangerousIngredients.add(label);
            reasons.add(_buildReason(label, condition));
          }
          break;
        }
      }
    }

    return _buildResult(dangerousIngredients, reasons);
  }

  static Map<String, dynamic> _buildResult(
    List<String> dangerousIngredients,
    List<String> reasons,
  ) {
    return {
      'level': dangerousIngredients.isNotEmpty ? 'Danger' : 'Safe',
      'dangerousIngredients': dangerousIngredients,
      'reasons': reasons,
    };
  }

  static String _buildReason(String label, String condition) {
    final String conditionName = conditionTranslations[condition] ?? condition;
    return "Phát hiện '$label': Không tốt cho tình trạng '$conditionName' của bạn.";
  }

  static bool isRiskLabel(String label) {
    return labelToConditionMap.containsKey(label) && label != 'safe';
  }

  static List<String> getConditionsForLabel(String label) {
    return labelToConditionMap[label] ?? [];
  }
}