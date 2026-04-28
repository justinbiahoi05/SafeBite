import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Thư viện Rung
import '../../../../../services/ai_service.dart';
import '../../../../../services/health_logic.dart';
import '../../../../../services/user_profile_service.dart';
import '../../../../../services/string_helper.dart';
import '../../../../../services/scan_history_service.dart';
import '../../../../core/theme/app_colors.dart';

class ScanResultPage extends StatefulWidget {
  final String rawText;
  const ScanResultPage({super.key, required this.rawText});

  @override
  State<ScanResultPage> createState() => _ScanResultPageState();
}

class _ScanResultPageState extends State<ScanResultPage> {
  final AIService _ai = AIService();
  List<Map<String, String>> _analyzedResults = [];
  List<String> _userConditions = [];
  
  bool _isEditing = true; 
  bool _isAnalyzing = false; 
  bool _hasDanger = false;
  
  final TextEditingController _nameController = TextEditingController();
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.rawText.replaceAll('\n', ' '));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _runAIAnalysis() async {
    print("DEBUG 1: Nút bấm đã nhận, bắt đầu hàm _runAIAnalysis");

    if (_nameController.text.trim().isEmpty) {
      print("DEBUG: Tên sản phẩm trống");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a product name!")));
      return;
    }

    try {
      setState(() {
        _isEditing = false;
        _isAnalyzing = true;
      });

      print("DEBUG 2: Đang lấy Profile từ Firebase...");
      // LỖI CÓ THỂ Ở ĐÂY: Nếu Firebase chưa đăng nhập hoặc Rules bị chặn
      _userConditions = await UserProfileService().getHealthConditions();
      print("DEBUG 3: Đã lấy được Profile: $_userConditions");

      print("DEBUG 4: Đang tách từ...");
      // LỖI CÓ THỂ Ở ĐÂY: Nếu StringHelper chưa có hàm extractCleanIngredients
      List<String> cleanIngredients = _textController.text
          .split(RegExp(r'[,\n\s]'))
          .where((e) => e.trim().length > 2)
          .toList();
      print("DEBUG 5: Tách được ${cleanIngredients.length} chất");

      List<Map<String, String>> temp = [];
      for (var item in cleanIngredients) {
        print("DEBUG 6: AI đang đoán chất: $item");
        final pred = _ai.predict(item);
        
        // Dùng bộ lọc y khoa
        String finalLabel = pred['label'] ?? 'unknown';
        temp.add({'name': item, 'label': finalLabel});
      }

      _hasDanger = temp.any((item) => HealthLogic.isRiskForUser(
        label: item['label']!, 
        ingredientName: item['name']!, 
        userConditions: _userConditions
      ));

      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _analyzedResults = temp;
        });
        
        print("DEBUG FINAL: Phân tích XONG. Nguy hiểm: $_hasDanger");

        if (_hasDanger) {
          _playDangerAlert();
        }
      }
    } catch (e, stacktrace) {
      // NẾU CÓ LỖI, DÒNG NÀY SẼ HIỆN MÀU ĐỎ TRONG CONSOLE
      print("❌ LỖI NGHIÊM TRỌNG: $e");
      print("❌ CHI TIẾT: $stacktrace");
      setState(() => _isAnalyzing = false);
    }
  }

  void _playDangerAlert() async {
    debugPrint("Triggering Danger Vibration..."); // Để kiểm tra xem logic có chạy vào đây không
    
    for (int i = 0; i < 5; i++) {
      // Lệnh rung mạnh nhất của hệ thống
      HapticFeedback.vibrate(); 
      
      // Chờ một chút rồi rung tiếp để tạo hiệu ứng dồn dập
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Thêm lệnh này để chắc chắn motor rung được kích hoạt
      HapticFeedback.heavyImpact(); 
    }
  }

  Future<void> _saveToCloud() async {
    await ScanHistoryService().addScan(
      result: _hasDanger ? 'caution' : 'safe', confidence: 0.99,
      ingredients: _analyzedResults.map((e) => e['name']!).toList(), 
      productName: _nameController.text,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved to History!"), backgroundColor: AppColors.primaryGreen));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color headerColor = _hasDanger && !_isEditing ? Colors.red.shade600 : AppColors.scaffoldBackgroundLight;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundLight,
      appBar: AppBar(
        title: Text(
          _isEditing ? "VERIFY DATA" : "ANALYSIS RESULT", 
          style: TextStyle(color: _hasDanger && !_isEditing ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 16)
        ),
        backgroundColor: headerColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: _hasDanger && !_isEditing ? Colors.white : AppColors.textPrimary),
      ),
      body: _isAnalyzing 
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primaryGreen),
                SizedBox(height: 16),
                Text("AI is processing...", style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold))
              ],
            )
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _isEditing ? _buildEditState() : _buildResultState(),
          ),
    );
  }

  Widget _buildEditState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("STEP 1: PRODUCT NAME", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.0, color: AppColors.primaryGreen)),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: "e.g. Lay's Potato Chips",
            filled: true, fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(20),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2)),
          ),
        ),
        
        const SizedBox(height: 32),
        
        const Text("STEP 2: INGREDIENTS LIST", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.0, color: AppColors.primaryGreen)),
        const SizedBox(height: 12),
        TextField(
          controller: _textController,
          maxLines: 8,
          style: const TextStyle(color: AppColors.textPrimary, height: 1.6, fontSize: 15),
          decoration: InputDecoration(
            hintText: "Edit ingredients here...",
            filled: true, fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(20),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2)),
          ),
        ),
        
        const SizedBox(height: 40),
        
        SizedBox(
          width: double.infinity, height: 60,
          child: ElevatedButton(
            onPressed: _runAIAnalysis,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
            child: const Text("ANALYZE NOW", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.0)),
          ),
        ),
      ],
    );
  }

  Widget _buildResultState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_hasDanger)
          Container(
            padding: const EdgeInsets.all(20), margin: const EdgeInsets.only(bottom: 32),
            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.red.shade200)),
            child: const Row(
              children: [
                Icon(Icons.warning_rounded, color: Colors.red, size: 36),
                SizedBox(width: 16),
                Expanded(child: Text("WARNING: Unsafe ingredients detected for your health profile!", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w800, fontSize: 15, height: 1.4))),
              ],
            ),
          ),

        ..._analyzedResults.map((item) {
          bool isDanger = HealthLogic.isRiskForUser(label: item['label']!, ingredientName: item['name']!, userConditions: _userConditions);
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDanger ? Colors.red.shade300 : Colors.grey.shade200),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: isDanger ? Colors.red.shade50 : AppColors.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(isDanger ? Icons.warning_amber_rounded : Icons.check_circle_outline, color: isDanger ? Colors.red : AppColors.primaryGreen, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['name']!.toUpperCase(), style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      Text(item['label']!.toUpperCase(), style: TextStyle(color: isDanger ? Colors.red : AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity, height: 60,
          child: ElevatedButton.icon(
            onPressed: _saveToCloud,
            icon: const Icon(Icons.cloud_upload, color: Colors.white),
            label: const Text("SAVE TO HISTORY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
            style: ElevatedButton.styleFrom(backgroundColor:  AppColors.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
          ),
        ),
      ],
    );
  }
}