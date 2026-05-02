import 'dart:convert';
import 'package:flutter/services.dart';

class HealthLogic {
  // 1. ÁNH XẠ NHÃN AI -> BỆNH LÝ BỊ CẤM KỴ
  static const Map<String, List<String>> labelToConditionMap = {
    'sugar': ['Diabetes', 'Keto Diet', 'Skin Health', 'Children'],
    'sweetener': ['Diabetes', 'Pregnancy', 'IBS', 'Keto Diet'],
    'sodium': ['Kidney Disease', 'Hypertension', 'Gout', 'Heart Disease'],
    'allergen': ['Nut Allergy', 'Lactose Intolerance', 'Celiac Disease', 'Asthma', 'Peanut Allergy', 'Shellfish Allergy'],
    'bad_fat': ['Hypertension', 'Heart Disease', 'Vegan', 'Pregnancy', 'Skin Health'],
    'acidic': ['Gastritis', 'Kidney Disease', 'Pregnancy'],
    'additive': ['Pregnancy', 'Children', 'Asthma', 'Skin Health'],
    'spicy': ['Gastritis', 'Pregnancy'],
    'safe': [],
  };

  // Alias map: Chuẩn hóa tên bệnh từ profile về tên chuẩn trong map
  static const Map<String, String> _conditionAlias = {
    'peanut allergy': 'Nut Allergy',
    'shellfish allergy': 'Shellfish Allergy',
    'lactose intolerance': 'Lactose Intolerance',
    'celiac disease': 'Celiac Disease',
    'heart disease': 'Heart Disease',
    'kidney disease': 'Kidney Disease',
    'skin health': 'Skin Health',
  };

  // 2. DATASET V3 CHUẨN XÁC 100% (Khắc phục AI đoán sai)
  static const Map<String, List<String>> _exactDataset = {
    "acidic": ["acid acetic", "acid citric", "acid citric-ins 330", "acid lactic", "acid malic", "acid nitric", "acid phosphoric", "acidity regulator", "axit citric", "bột cà chua", "citric acid", "e270", "e296", "e300", "e330", "e338", "giấm táo", "lactic acid", "phosphoric acid"],
    "allergen": ["almond", "bao gồm hàu", "barley", "bào ngư", "bánh mì", "bơ sữa", "bơ đậu phộng", "bạch tuộc", "bột cá", "bột kem béo", "bột kem không sữa", "bột kem sữa", "bột lòng trắng trứng", "bột mì", "bột mì nguyên cám", "bột mỳ", "bột phô mai", "bột sữa", "bột sữa dừa", "bột sữa gầy", "bột sữa nguyên kem", "bột trứng", "bột tương đậu nành", "bột whey", "casein", "celery", "cua", "cá thu", "có chứa sữa", "dầu đậu nành", "egg", "gelatin", "gluten", "gluten lúa mì", "hazelnut", "hạt dẻ", "hạt mè", "hạt phỉ", "hạt phỉ hazelnut", "hạt điều", "hải sản", "lecithin đậu nành", "lúa mì", "lúa mạch", "macadamia", "milk", "mustard", "mù tạt", "mực", "organic fresh milk", "peanut oil", "pecan", "phô mai", "pistachio", "protein sữa", "quả ốc chó", "rye", "sesame", "shellfish", "shrimp", "soy lecithin", "soy sauce", "soybean oil", "sữa tươi", "sữa đặc", "trứng gà", "tôm", "walnut", "wheat flour", "wheat gluten", "whey", "đạm sữa", "đậu nành", "đậu phộng"],
    "bad_fat": ["bơ thực vật", "chất béo bão hòa", "chất béo chuyển hóa", "coconut oil", "dầu cọ", "dầu cọ olein", "dầu dừa", "hydrogenated vegetable oil", "lard", "mỡ bò", "mỡ cừu", "mỡ gà", "mỡ heo", "palm oil", "partially hydrogenated oil", "shortening", "tallow", "trans fat"],
    "safe": ["beef", "bắp ngọt", "bột tỏi", "calcium carbonate", "chicken", "chiết xuất nấm men", "chiết xuất trà xanh", "cà phê hòa tan", "cà rốt sấy", "gạo", "hành lá", "hành tây", "khoai lang", "khoai tây", "kẽm sulfat", "magnesi carbonat", "nước", "nước bão hòa co2", "nước tinh khiết", "pork", "sắt sulfat", "thịt bò", "thịt gà", "thịt heo", "tinh bột bắp", "tinh bột sắn", "vitamin b12", "vitamin c", "yến mạch"],
    "sodium": ["bột canh", "bột nêm", "disodium guanylate", "disodium inosinate", "e627", "e631", "fish sauce", "hạt nêm", "ins 621", "ins 627", "ins 631", "kali clorua", "monopotassium phosphate", "monosodium glutamate", "monosodium glutamate sodium", "msg", "msg sodium", "muối", "muối i-ốt", "muối ăn", "mì chính", "natri benzoat", "natri clorid", "salt", "sea salt", "sodium", "sodium benzoate", "sodium chloride", "sodium nitrate", "sodium phosphate", "table salt"],
    "spicy": ["bột ớt", "cayenne pepper", "chilli", "jalapeno", "tiêu trắng", "tiêu đen", "ớt bột", "ớt chỉ thiên", "ớt sừng"],
    "sugar": ["added sugar", "agave nectar", "brown sugar", "cane sugar", "corn syrup", "dextrin", "fructose", "glucose syrup", "granulated sugar", "hfcs", "high fructose corn syrup", "maltodextrin", "maltose", "maple syrup", "molasses", "mạch nha", "pure sugar", "refined sugar", "siro glucose", "sucrose sugar", "sugar", "white sugar", "đường", "đường cỏ ngọt", "đường mía", "đường phèn", "đường thốt nốt", "đường tinh luyện"],
    "sweetener": ["acesulfame potassium", "artificial sweetener", "aspartame", "chất tạo ngọt nhân tạo", "e420", "e951", "e952", "e954", "e965", "e967", "e968", "erythritol", "isomalt", "lactitol", "low calorie sweetener", "maltitol", "mannitol", "non-nutritive sweetener", "saccharin", "sorbitol", "stevia", "sucralose", "sweetener aspartame", "sweetener sucralose", "xylitol", "đường ăn kiêng"]
  };

  // Các chất phụ gia
  static const List<String> _additives = ["150a", "150c", "150d", "160a", "160c", "331iii", "451i", "452i", "471", "472e", "500ii", "additive e102", "additive e211", "additive e621", "baking powder", "baking soda", "benzoate", "beta-caroten", "brilliant blue fcf", "bột nổi", "calcium propionate", "carrageenan", "chất bảo quản", "chất chống oxy hóa", "chất chống đông vón", "chất giữ ẩm", "chất làm dày", "chất nhũ hóa", "chất tạo màu nhân tạo", "chất tạo màu tự nhiên", "chất tạo xốp", "chất ổn định", "e102", "e110", "e124", "e127", "e129", "e133", "e150a", "e200", "e202", "e210", "e211", "e212", "e213", "e220", "e221", "e222", "e223", "e224", "e250", "e251", "e322", "e407", "e412", "e415", "e440", "e450", "e466", "e621", "food additive", "guar gum", "hương liệu tổng hợp", "hương liệu tự nhiên", "ins 110", "ins 124", "ins 211", "ins 322", "kali sorbat", "magnesium stearate", "nitrate", "nitrite", "phẩm màu", "potassium nitrate", "potassium sorbate", "preservative additive", "silicon dioxide", "sodium metabisulphite", "sodium nitrite", "sorbate", "sulfur dioxide", "sulphite", "xanthan gum"];

  static Map<String, dynamic>? _ingredientsDb;

  static Future<void> loadRawDb() async {
    try {
      String jsonString = await rootBundle.loadString('assets/ai/ingredients_db.json');
      _ingredientsDb = json.decode(jsonString);
    } catch (e) {
      print("HealthLogic Error: Không thể load file JSON - $e");
    }
  }

  // --- HÀM TRA CỨU ĐỈNH CAO: Bỏ qua AI nếu chất đã có trong DB ---
  static String getAccurateLabel(String ingredientName, String aiLabel) {
    String name = ingredientName.toLowerCase().trim();

    // 1. Quét trong Từ điển chuẩn xác (Dataset V3)
    for (var entry in _exactDataset.entries) {
      if (entry.value.contains(name)) {
        return entry.key; // Trả về nhãn chính xác 100% (vd: "đậu nành" -> "allergen")
      }
    }

    // Kiểm tra riêng nhóm phụ gia (vì danh sách dài)
    if (_additives.contains(name)) return "additive";

    // 2. Chặn các lỗi cơ bản mà OCR hay nối chữ sai
    if (name.contains("đường") || name.contains("sugar") || name.contains("syrup")) return "sugar";
    if (name.contains("muối") || name.contains("salt") || name.contains("sodium")) return "sodium";
    if (name.contains("sữa") || name.contains("milk") || name.contains("đậu")) return "allergen";
    if (name.startsWith("e") && name.length == 4) return "additive";

    // 3. Chỉ khi nào chất LẠ HOẮC không có trong CSV, mới dùng kết quả do TFLite đoán
    return aiLabel;
  }

  // HÀM KIỂM TRA MỨC ĐỘ NGUY HIỂM VỚI NGƯỜI DÙNG
  static bool isRiskForUser({
    required String label,
    required String ingredientName,
    required List<String> userConditions
  }) {
    // Chuẩn hóa danh sách điều kiện người dùng: lowercase -> map alias -> lowercase chuẩn
    final normalizedConditions = userConditions.map((c) {
      final lower = c.toLowerCase().trim();
      return _conditionAlias[lower] ?? c.trim();
    }).toList();

    final lowerNormalized = normalizedConditions.map((c) => c.toLowerCase().trim()).toList();

    // Nếu nhãn AI xung đột với Bệnh của User -> Báo Đỏ (so sánh không phân biệt hoa/thường)
    if (labelToConditionMap.containsKey(label)) {
      bool aiRisk = labelToConditionMap[label]!.any((c) =>
        lowerNormalized.contains(c.toLowerCase().trim())
      );
      if (aiRisk) return true;
    }

    // Nếu JSON Y Khoa có ghi cấm chất này -> Báo Đỏ
    if (_ingredientsDb != null) {
      String name = ingredientName.toLowerCase().trim();
      if (_ingredientsDb!.containsKey(name)) {
        List<dynamic> restrictedFor = _ingredientsDb![name];
        return restrictedFor.any((c) => lowerNormalized.contains(c.toString().toLowerCase().trim()));
      }
    }

    return false;
  }
}