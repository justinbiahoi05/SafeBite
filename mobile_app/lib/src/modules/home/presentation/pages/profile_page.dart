import 'dart:convert'; // Thêm thư viện này để mã hóa ảnh
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../services/user_profile_service.dart';
import '../../../../../services/auth_service.dart';
import '../../../../../services/gemini_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../modules/auth/presentation/login_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserProfileService _service = UserProfileService();
  
  String? _displayName;
  String? _photoData; // Đổi tên biến cho chuẩn
  bool _isLoading = true;
  bool _isUploading = false;

  final Map<String, bool> _healthMap = {
    'Diabetes': false, 'Kidney Disease': false, 'Pregnancy': false, 'Nut Allergy': false,
    'Hypertension': false, 'Vegan': false, 'Gout': false, 'Gastritis': false, 'Asthma': false,
    'Lactose Intolerance': false, 'Keto Diet': false, 'IBS': false, 'Celiac Disease': false,
    'Heart Disease': false, 'Skin Health': false, 'Children': false,
  };

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    try {
      final name = await _service.getDisplayName();
      final photo = await _service.getPhotoUrl();
      final savedConditions = await _service.getHealthConditions();
      final user = FirebaseAuth.instance.currentUser;

      if (mounted) {
        setState(() {
          _displayName = name ?? user?.displayName ?? 'User';
          _photoData = photo ?? user?.photoURL;
          for (var c in savedConditions) { if (_healthMap.containsKey(c)) _healthMap[c] = true; }
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // THỦ THUẬT HACK FIREBASE: Lưu ảnh thành chuỗi Base64
  Future<void> _changePhoto() async {
    // Ép dung lượng ảnh cực nhỏ để lưu dạng chữ không bị lag
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery, 
      imageQuality: 25, 
      maxWidth: 200, 
      maxHeight: 200
    );
    if (image == null) return;

    setState(() => _isUploading = true);
    
    try {
      // Đọc file ảnh và mã hóa thành chuỗi chữ (Base64)
      final bytes = await image.readAsBytes();
      String base64Image = base64Encode(bytes);
      
      // Lưu trực tiếp chuỗi này vào Firestore (như lưu tên User) -> Không bao giờ lỗi
      await _service.updatePhotoUrl(base64Image);
      
      if (mounted) {
        setState(() => _photoData = base64Image);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Avatar updated!"), backgroundColor: AppColors.primaryGreen));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload failed: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _editName() async {
    final controller = TextEditingController(text: _displayName);
    await showDialog(context: context, builder: (c) => AlertDialog(
      backgroundColor: Colors.white,
      title: const Text("Edit Name", style: TextStyle(color: AppColors.textPrimary)),
      content: TextField(controller: controller, style: const TextStyle(color: AppColors.textPrimary)),
      actions: [
        ElevatedButton(onPressed: () async {
          await _service.updateDisplayName(controller.text);
          setState(() => _displayName = controller.text);
          Navigator.pop(context);
        }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen), child: const Text("Save", style: TextStyle(color: Colors.white)))
      ],
    ));
  }

  Future<void> _saveHealth() async {
    await _service.updateHealthConditions(_healthMap.entries.where((e) => e.value).map((e) => e.key).toList());
  }

  Future<void> _setApiKey() async {
    final controller = TextEditingController(text: GeminiService.apiKey ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Gemini API Key", style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your Google Gemini API key for cloud-based analysis.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
                hintText: 'AIza...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null) {
      GeminiService.setApiKey(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API key saved!'), backgroundColor: AppColors.primaryGreen),
        );
      }
    }
    controller.dispose();
  }

  // Hàm hỗ trợ đọc ảnh (Nhận diện xem là link web hay chuỗi Base64)
  ImageProvider? _getAvatarImage() {
    if (_photoData == null) return null;
    if (_photoData!.startsWith('http')) return NetworkImage(_photoData!); // Ảnh mạng (Google)
    try {
      return MemoryImage(base64Decode(_photoData!)); // Ảnh tự up (Base64)
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
    
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("MY PROFILE", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 16)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        children: [
          Center(
            child: GestureDetector(
              onTap: _isUploading ? null : _changePhoto,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 55, backgroundColor: Colors.white,
                    backgroundImage: _getAvatarImage(),
                    child: _photoData == null ? const Icon(Icons.person, size: 50, color: AppColors.textSecondary) : null,
                  ),
                  if (_isUploading) const Positioned.fill(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
                  const Positioned(right: 0, bottom: 0, child: CircleAvatar(radius: 18, backgroundColor: AppColors.primaryGreen, child: Icon(Icons.camera_alt, size: 16, color: Colors.white))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_displayName ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                IconButton(icon: const Icon(Icons.edit, color: AppColors.textSecondary, size: 20), onPressed: _editName),
              ],
            ),
          ),
          const SizedBox(height: 32),

          const Text("MY HEALTH CONDITIONS", style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.0)),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
            child: Wrap(
              spacing: 10, runSpacing: 10,
              children: _healthMap.keys.map((k) => FilterChip(
                label: Text(k, style: TextStyle(color: _healthMap[k]! ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                selected: _healthMap[k]!,
                selectedColor: AppColors.primaryGreen,
                backgroundColor: AppColors.scaffoldBackgroundLight,
                checkmarkColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: _healthMap[k]! ? AppColors.primaryGreen : Colors.grey.shade300)),
                onSelected: (v) { setState(() => _healthMap[k] = v); _saveHealth(); },
              )).toList(),
            ),
          ),
          
          const SizedBox(height: 40),
          
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.redAccent)), elevation: 0),
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            label: const Text("Log Out", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
            onPressed: () async {
              await AuthService().signOut();
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
            },
          ),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
            icon: const Icon(Icons.key, color: Colors.white),
            label: Text(GeminiService.apiKey?.isNotEmpty == true ? "API Key Set" : "Set API Key", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            onPressed: _setApiKey,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}