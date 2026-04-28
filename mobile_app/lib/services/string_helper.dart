import 'package:string_similarity/string_similarity.dart';

class StringHelper {
  // Danh sách 317 chất chuẩn (Đã đồng bộ)
  static const List<String> _masterList = [
    "acid acetic", "acid citric", "acid lactic", "acid malic", "acid nitric", 
    "acid phosphoric", "acidity regulator", "axit citric", "bột cà chua", 
    "citric acid", "e270", "e296", "e300", "e330", "e338", "giấm táo", 
    "lactic acid", "phosphoric acid", "150a", "150c", "150d", "160a", "160c", 
    "331iii", "451i", "452i", "471", "472e", "500ii", "additive e102", 
    "additive e211", "additive e621", "baking powder", "baking soda", 
    "benzoate", "beta-caroten", "brilliant blue fcf", "bột nổi", 
    "calcium propionate", "carrageenan", "chất bảo quản", "chất chống oxy hóa", 
    "chất chống đông vón", "chất giữ ẩm", "chất làm dày", "chất nhũ hóa", 
    "chất tạo màu nhân tạo", "chất tạo màu tự nhiên", "chất tạo xốp", 
    "chất ổn định", "e102", "e110", "e124", "e127", "e129", "e133", "e150a", 
    "e200", "e202", "e210", "e211", "e212", "e213", "e220", "e221", "e222", 
    "e223", "e224", "e250", "e251", "e322", "e407", "e412", "e415", "e440", 
    "e450", "e466", "e621", "food additive", "guar gum", "hương liệu tổng hợp", 
    "hương liệu tự nhiên", "ins 110", "ins 124", "ins 211", "ins 322", 
    "kali sorbat", "magnesium stearate", "nitrate", "nitrite", "phẩm màu", 
    "potassium nitrate", "potassium sorbate", "preservative additive", 
    "silicon dioxide", "sodium benzoate", "sodium metabisulphite", 
    "sodium nitrate", "sodium nitrite", "sorbate", "sulphite", 
    "sulfur dioxide", "xanthan gum", "almond", "bao gồm hàu", "barley", 
    "bào ngư", "bánh mì", "bơ sữa", "bơ đậu phộng", "bạch tuộc", "bột cá", 
    "bột kem béo", "bột kem không sữa", "bột kem sữa", "bột lòng trắng trứng", 
    "bột mì", "bột mì nguyên cám", "bột mỳ", "bột phô mai", "bột sữa", 
    "bột sữa dừa", "bột sữa gầy", "bột sữa nguyên kem", "bột trứng", 
    "bột tương đậu nành", "bột whey", "casein", "celery", "cua", "cá thu", 
    "có chứa sữa", "dầu đậu nành", "egg", "gelatin", "gluten", "gluten lúa mì", 
    "hazelnut", "hạt điều", "hạt dẻ", "hạt mè", "hạt phỉ", "hạt phỉ hazelnut", 
    "hải sản", "lecithin đậu nành", "lúa mì", "lúa mạch", "macadamia", "milk", 
    "mù tạt", "mustard", "mực", "organic fresh milk", "peanut oil", "pecan", 
    "phô mai", "pistachio", "protein sữa", "quả ốc chó", "rye", "sesame", 
    "shellfish", "shrimp", "soy lecithin", "soy sauce", "soybean oil", 
    "sữa tươi", "sữa đặc", "trứng gà", "tôm", "walnut", "wheat flour", 
    "wheat gluten", "whey", "đạm sữa", "đậu nành", "đậu phộng", "bơ thực vật", 
    "chất béo bão hòa", "chất béo chuyển hóa", "coconut oil", "dầu cọ", 
    "dầu cọ olein", "dầu dừa", "hydrogenated vegetable oil", "lard", "mỡ bò", 
    "mỡ cừu", "mỡ gà", "mỡ heo", "palm oil", "partially hydrogenated oil", 
    "shortening", "tallow", "trans fat", "beef", "bắp ngọt", "bột tỏi", 
    "calcium carbonate", "chicken", "chiết xuất nấm men", "chiết xuất trà xanh", 
    "cà phê hòa tan", "cà rốt sấy", "gạo", "hành lá", "hành tây", "khoai lang", 
    "khoai tây", "kẽm sulfat", "magnesi carbonat", "nước", "nước bão hòa co2", 
    "nước tinh khiết", "pork", "sắt sulfat", "thịt bò", "thịt gà", "thịt heo", 
    "tinh bột bắp", "tinh bột sắn", "vitamin b12", "vitamin c", "yến mạch", 
    "bột canh", "bột nêm", "disodium guanylate", "disodium inosinate", "e627", 
    "e631", "fish sauce", "hạt nêm", "ins 621", "ins 627", "ins 631", 
    "kali clorua", "mì chính", "monopotassium phosphate", "monosodium glutamate", 
    "monosodium glutamate sodium", "msg", "msg sodium", "muối", "muối i-ốt", 
    "muối ăn", "natri benzoat", "natri clorid", "salt", "sea salt", "sodium", 
    "sodium benzoate", "sodium chloride", "sodium nitrate", "sodium phosphate", 
    "table salt", "bột ớt", "cayenne pepper", "chilli", "jalapeno", 
    "tiêu trắng", "tiêu đen", "ớt bột", "ớt chỉ thiên", "ớt sừng", "added sugar", 
    "agave nectar", "brown sugar", "cane sugar", "corn syrup", "dextrin", 
    "fructose", "glucose syrup", "granulated sugar", "hfcs", 
    "high fructose corn syrup", "maltodextrin", "maltose", "maple syrup", 
    "molasses", "mạch nha", "pure sugar", "refined sugar", "siro glucose", 
    "sucrose sugar", "sugar", "white sugar", "đường", "đường cỏ ngọt", 
    "đường mía", "đường phèn", "đường thốt nốt", "đường tinh luyện", 
    "acesulfame potassium", "artificial sweetener", "aspartame", 
    "chất tạo ngọt nhân tạo", "e420", "e951", "e952", "e954", "e965", "e967", 
    "e968", "erythritol", "isomalt", "lactitol", "low calorie sweetener", 
    "maltitol", "mannitol", "non-nutritive sweetener", "saccharin", "sorbitol", 
    "stevia", "sucralose", "sweetener aspartame", "sweetener sucralose", 
    "xylitol", "đường ăn kiêng"
  ];

  /// HÀM MỚI: Dọn dẹp rác OCR cực mạnh trước khi so sánh
  static List<String> extractCleanIngredients(String rawOcr) {
    // 1. Chuyển thành chữ thường
    String text = rawOcr.toLowerCase();

    // 2. Loại bỏ các từ khóa không phải là thành phần (Rác OCR)
    final garbageWords = [
      "thành phần:", "ingredients:", "khối lượng", "net weight", 
      "hsd", "nsx", "bảo quản", "nơi khô ráo", "sản xuất tại", "kcal", 
      "calo", "protein", "carbohydrate", "fat", "chất béo", "energy", "năng lượng"
    ];
    for (var word in garbageWords) {
      text = text.replaceAll(word, " ");
    }

    // 3. Xóa bớt các con số, tỷ lệ phần trăm (VD: 50g, 10%) và ký tự lạ
    text = text.replaceAll(RegExp(r'\d+%'), ''); // Xóa phần trăm
    text = text.replaceAll(RegExp(r'\d+\s*(g|mg|ml|kg)'), ''); // Xóa khối lượng
    text = text.replaceAll(RegExp(r'[\[\]\(\)\{\}\:\.]'), ','); // Biến ngoặc, chấm thành dấu phẩy để cắt

    // 4. Cắt chuỗi thành mảng
    List<String> rawChunks = text.split(RegExp(r'[,\n;]'));
    
    List<String> finalIngredients = [];

    // 5. Quét từng mảnh và dùng AI so sánh chuỗi
    for (String chunk in rawChunks) {
      String cleanChunk = chunk.trim();
      
      // Nếu chữ quá ngắn (dưới 3 ký tự) và không phải mã E (như E102) -> Bỏ qua
      if (cleanChunk.length < 3 && !cleanChunk.startsWith('e')) continue;

      // Tìm chuỗi giống nhất trong Master List
      BestMatch match = StringSimilarity.findBestMatch(cleanChunk, _masterList);
      
      // HẠ NGƯỠNG XUỐNG 0.45: Chấp nhận OCR bị sai chính tả nhẹ (Vd: "đừog" vẫn thành "đường")
      if (match.bestMatch.rating! > 0.45) {
        finalIngredients.add(match.bestMatch.target!);
      }
    }

    // Xóa trùng lặp và trả về
    return finalIngredients.toSet().toList();
  }
}