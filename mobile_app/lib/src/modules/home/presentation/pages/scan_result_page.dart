import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/services/ai_service.dart';
import 'package:mobile_app/services/health_logic.dart';

class ScanResultPage extends StatefulWidget {
  final String text;

  const ScanResultPage({super.key, required this.text});

  @override
  State<ScanResultPage> createState() => _ScanResultPageState();
}

class _ScanResultPageState extends State<ScanResultPage> {
  late TextEditingController _editController;
  String _resultLevel = "Safe";
  List<String> _detectedIngredients = [];
  List<String> _dangerousIngredients = [];
  List<String> _reasons = [];
  Map<String, bool> _userProfile = {};
  bool _isAnalyzing = false;
  bool _isProfileLoaded = false;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.text);
    _loadProfileAndAnalyze();
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  /// Load health profile from SharedPreferences before analysis
  Future<void> _loadProfileAndAnalyze() async {
    debugPrint("=== LOADING PROFILE ===");
    setState(() => _isAnalyzing = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString('health_profile');

      if (profileJson != null) {
        final decoded = jsonDecode(profileJson) as Map<String, dynamic>;
        _userProfile = decoded.map((key, value) => MapEntry(key, value as bool));
      } else {
        // No profile saved yet - treat as empty (all safe)
        _userProfile = {};
      }

      debugPrint("Loaded user profile: $_userProfile");
      _isProfileLoaded = true;

      // Perform analysis after profile is loaded
      debugPrint("Calling _performAnalysisInternal() after profile loaded");
      _performAnalysisInternal();
    } catch (e) {
      debugPrint("Error loading profile: $e");
      _userProfile = {};
      _isProfileLoaded = true;
      _performAnalysisInternal();
    }
  }

  /// Internal analysis method that uses current controller text
  void _performAnalysisInternal() {
    debugPrint("=== AUTO ANALYSIS WHEN PAGE LOAD ===");
    final String text = _editController.text;
    debugPrint("Current text from controller: $text");

    if (text.isEmpty) {
      debugPrint("Text is empty, setting safe state");
      setState(() {
        _resultLevel = "Safe";
        _detectedIngredients = [];
        _dangerousIngredients = [];
        _reasons = [];
        _isAnalyzing = false;
      });
      return;
    }

    // Tokenize and predict using AIService
    final Set<String> foundLabels = {};
    final ai = AIService();

    // Split text into words for AI prediction
    List<String> words = text
        .split(RegExp(r'[,.\s\n]'))
        .where((w) => w.length > 2)
        .toList();
    
    debugPrint("Tokenized words: $words");

    for (var word in words) {
      String label = ai.predict(word);
      debugPrint("Word: $word -> Label: $label");
      // Only include risk labels (not 'Unknown' or 'safe')
      if (HealthLogic.isRiskLabel(label)) {
        foundLabels.add(label);
      }
    }

    debugPrint("Found labels: $foundLabels");

    // Use HealthLogic for strict intersection analysis
    final analysis = HealthLogic.analyze(
      detectedLabels: foundLabels.toList(),
      userProfile: _userProfile,
    );
    
    debugPrint("HealthLogic.analyze result: $analysis");

    setState(() {
      _detectedIngredients = foundLabels.toList();
      _resultLevel = analysis['level'];
      _dangerousIngredients = List<String>.from(analysis['dangerousIngredients']);
      _reasons = List<String>.from(analysis['reasons']);
      _isAnalyzing = false;
    });
    
    debugPrint("State update finished - _resultLevel: $_resultLevel");
  }

  /// Re-analyze button handler - explicitly re-runs AI prediction
  void _onReanalyze() {
    debugPrint("=== MANUAL RE-ANALYZE BUTTON PRESSED ===");
    debugPrint("Current text: ${_editController.text}");
    debugPrint("_isAnalyzing before: $_isAnalyzing");
    
    if (_isAnalyzing) {
      debugPrint("Already analyzing, returning...");
      return;
    }
    
    // Get current text directly from controller
    final String currentText = _editController.text;
    debugPrint("Processing text: $currentText");

    // Update state to show loading
    setState(() {
      _isAnalyzing = true;
    });
    
    debugPrint("_isAnalyzing after setState: true");

    if (currentText.isEmpty) {
      debugPrint("Text is empty, setting safe state");
      setState(() {
        _resultLevel = "Safe";
        _detectedIngredients = [];
        _dangerousIngredients = [];
        _reasons = [];
        _isAnalyzing = false;
      });
      return;
    }

    // Run AI prediction on current text
    final Set<String> foundLabels = {};
    final ai = AIService();
    
    List<String> words = currentText
        .split(RegExp(r'[,.\s\n]'))
        .where((w) => w.length > 2)
        .toList();
    
    debugPrint("Tokenized words: $words");

    for (var word in words) {
      String label = ai.predict(word);
      debugPrint("Word: $word -> Label: $label");
      if (HealthLogic.isRiskLabel(label)) {
        foundLabels.add(label);
      }
    }
    
    debugPrint("Found labels: $foundLabels");

    // Run HealthLogic analysis
    final analysis = HealthLogic.analyze(
      detectedLabels: foundLabels.toList(),
      userProfile: _userProfile,
    );
    
    debugPrint("HealthLogic.analyze result: $analysis");

    // Update UI with results
    setState(() {
      _detectedIngredients = foundLabels.toList();
      _resultLevel = analysis['level'];
      _dangerousIngredients = List<String>.from(analysis['dangerousIngredients']);
      _reasons = List<String>.from(analysis['reasons']);
      _isAnalyzing = false;
    });
    
    debugPrint("State updated - _resultLevel: $_resultLevel");
  }

  @override
  Widget build(BuildContext context) {
    // Determine result color based on analysis level
    Color resultColor = _resultLevel == "Danger" ? Colors.red : Colors.green;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          "Kết quả phân tích",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: resultColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Header displaying result status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: resultColor),
            child: Column(
              children: [
                Icon(
                  _resultLevel == "Danger"
                      ? Icons.warning
                      : Icons.check_circle,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  _resultLevel == "Danger"
                      ? "CẢNH BÁO NGUY HIỂM"
                      : "AN TOÀN CHO BẠN",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!_isProfileLoaded) ...[
                  const SizedBox(height: 4),
                  const Text(
                    "Đang tải hồ sơ sức khỏe...",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),

          // Main content area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Scanned text section
                  const Text(
                    "VĂN BẢN QUÉT ĐƯỢC (BẠN CÓ THỂ SỬA TẠI ĐÂY)",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Large, high-contrast TextField
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _editController,
                      maxLines: 8,
                      minLines: 4,
                      // HIGH-CONTRAST: Black text on white background
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        height: 1.5,
                      ),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(16),
                        border: InputBorder.none,
                        hintText: "Nhập hoặc chỉnh sửa văn bản...",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Re-analyze button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        debugPrint("Button onPressed called!");
                        _onReanalyze();
                      },
                      icon: _isAnalyzing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.refresh, color: Colors.white),
                      label: Text(
                        _isAnalyzing ? "ĐANG PHÂN TÍCH..." : "PHÂN TÍCH LẠI VĂN BẢN",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Detected ingredients section
                  if (_detectedIngredients.isNotEmpty) ...[
                    const Text(
                      "AI PHÁT HIỆN CÁC CHẤT:",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _detectedIngredients.map((label) {
                        bool isBad = _dangerousIngredients.contains(label);
                        return Chip(
                          label: Text(
                            label,
                            style: TextStyle(
                              color: isBad ? Colors.red.shade800 : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          backgroundColor:
                              isBad ? Colors.red.shade50 : Colors.grey.shade100,
                          side: BorderSide(
                            color: isBad ? Colors.red.shade300 : Colors.grey.shade300,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Warning details section
                  if (_reasons.isNotEmpty) ...[
                    const Text(
                      "CHI TIẾT NGUY CƠ:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._reasons.map((r) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  r,
                                  style: TextStyle(
                                    color: Colors.red.shade900,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],

                  // Safe state message
                  if (_resultLevel == "Safe" && _detectedIngredients.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.green.shade700,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _userProfile.isEmpty || !_userProfile.values.any((v) => v)
                                  ? "Không phát hiện chất nguy hiểm nào. Hãy cập nhật hồ sơ sức khỏe để được phân tích chính xác hơn."
                                  : "Các thành phần phát hiện đều an toàn với hồ sơ sức khỏe của bạn.",
                              style: TextStyle(
                                color: Colors.green.shade900,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}