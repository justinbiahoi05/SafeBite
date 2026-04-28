import 'dart:convert';
import 'package:http/http.dart' as http;

class BarcodeService {
  static Future<Map<String, dynamic>?> getProductInfo(String barcode) async {
    final url = Uri.parse('https://world.openfoodfacts.org/api/v2/product/$barcode.json');
    
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 8)); 
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 1 && data['product'] != null) {
          final product = data['product'];
          
          // 1. Ưu tiên lấy tên Tiếng Việt, không có mới lấy Tiếng Anh
          String name = product['product_name_vi'] ?? 
                        product['product_name'] ?? 
                        product['product_name_en'] ?? 
                        "Unknown Product";
          
          String ingredients = "";

          // 2. LỤC LỌI THÀNH PHẦN KHẮP MỌI NƠI TRONG DATABASE
          if (product['ingredients_text_vi'] != null && product['ingredients_text_vi'].toString().trim().isNotEmpty) {
            ingredients = product['ingredients_text_vi'];
          } 
          else if (product['ingredients_text'] != null && product['ingredients_text'].toString().trim().isNotEmpty) {
            ingredients = product['ingredients_text'];
          } 
          else if (product['ingredients_text_en'] != null && product['ingredients_text_en'].toString().trim().isNotEmpty) {
            ingredients = product['ingredients_text_en'];
          } 
          // 3. Nếu vẫn trống, lôi các thẻ Tags ra cắt ghép lại
          else if (product['ingredients_tags'] != null && (product['ingredients_tags'] as List).isNotEmpty) {
            List<dynamic> tags = product['ingredients_tags'];
            ingredients = tags.map((t) {
              String tag = t.toString();
              // Xóa tiền tố ngôn ngữ (vd: vi:đường -> đường, en:sugar -> sugar)
              if (tag.contains(':')) {
                tag = tag.split(':').last;
              }
              return tag.replaceAll('-', ' ');
            }).join(', ');
          }

          return {
            'name': name,
            'ingredients': ingredients,
          };
        }
      }
    } catch (e) {
      print("Barcode API Error: $e");
    }
    return null; 
  }
}