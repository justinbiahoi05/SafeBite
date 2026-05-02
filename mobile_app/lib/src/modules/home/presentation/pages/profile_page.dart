import 'dart:convert';
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
  String? _photoData;
  bool _isLoading = true;
  bool _isUploading = false;
  String _healthSearchQuery = '';

  final Map<String, List<String>> _healthGroups = {
    'Medical Conditions': [
      'Diabetes',
      'Kidney Disease',
      'Hypertension',
      'Gout',
      'Gastritis',
      'Asthma',
      'Heart Disease',
      'IBS',
      'Celiac Disease',
    ],
    'Allergies': ['Nut Allergy', 'Lactose Intolerance'],
    'Diet & Lifestyle': [
      'Vegan',
      'Keto Diet',
      'Pregnancy',
      'Children',
      'Skin Health',
    ],
  };

  final Map<String, bool> _healthMap = {
    'Diabetes': false,
    'Kidney Disease': false,
    'Pregnancy': false,
    'Nut Allergy': false,
    'Hypertension': false,
    'Vegan': false,
    'Gout': false,
    'Gastritis': false,
    'Asthma': false,
    'Lactose Intolerance': false,
    'Keto Diet': false,
    'IBS': false,
    'Celiac Disease': false,
    'Heart Disease': false,
    'Skin Health': false,
    'Children': false,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

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
          for (var c in savedConditions) {
            if (_healthMap.containsKey(c)) _healthMap[c] = true;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _changePhoto() async {
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 25,
      maxWidth: 200,
      maxHeight: 200,
    );
    if (image == null) return;

    setState(() => _isUploading = true);

    try {
      final bytes = await image.readAsBytes();
      String base64Image = base64Encode(bytes);
      await _service.updatePhotoUrl(base64Image);

      if (mounted) {
        setState(() => _photoData = base64Image);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Avatar updated!"),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Upload failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _editName() async {
    final controller = TextEditingController(text: _displayName);
    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "Edit Name",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await _service.updateDisplayName(controller.text);
              setState(() => _displayName = controller.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveHealth() async {
    await _service.updateHealthConditions(
      _healthMap.entries.where((e) => e.value).map((e) => e.key).toList(),
    );
  }

  Future<void> _setApiKey() async {
    final controller = TextEditingController(text: GeminiService.apiKey ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "Gemini API Key",
          style: TextStyle(color: AppColors.textPrimary),
        ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null) {
      GeminiService.setApiKey(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API key saved!'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }
    }
    controller.dispose();
  }

  ImageProvider? _getAvatarImage() {
    if (_photoData == null) return null;
    if (_photoData!.startsWith('http')) return NetworkImage(_photoData!);
    try {
      return MemoryImage(base64Decode(_photoData!));
    } catch (e) {
      return null;
    }
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(Icons.settings, color: AppColors.textPrimary),
                  SizedBox(width: 12),
                  Text(
                    "Settings",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildSettingTile(
                    icon: Icons.key,
                    iconColor: Colors.purple,
                    title: "Gemini API Key",
                    subtitle: GeminiService.apiKey?.isNotEmpty == true
                        ? "API key configured"
                        : "Not set",
                    onTap: _setApiKey,
                  ),
                  _buildSettingTile(
                    icon: Icons.info_outline,
                    iconColor: Colors.blue,
                    title: "About SafeBite",
                    subtitle: "Version 1.0.0",
                    onTap: () {},
                  ),
                  _buildSettingTile(
                    icon: Icons.privacy_tip_outlined,
                    iconColor: Colors.teal,
                    title: "Privacy Policy",
                    subtitle: "View our privacy policy",
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackgroundLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundLight,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "MY PROFILE",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
                GestureDetector(
                  onTap: _showSettings,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.settings,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Profile Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar
                  GestureDetector(
                    onTap: _isUploading ? null : _changePhoto,
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryGreen,
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            backgroundImage: _getAvatarImage(),
                            child: _photoData == null
                                ? const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: AppColors.textSecondary,
                                  )
                                : null,
                          ),
                        ),
                        if (_isUploading)
                          const Positioned.fill(
                            child: CircleAvatar(
                              backgroundColor: Colors.black54,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _displayName ?? '',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: _editName,
                      ),
                    ],
                  ),

                  // Stats row
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.eco,
                          color: AppColors.primaryGreen,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "SafeBite User",
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Health Conditions Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.red, Colors.redAccent],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "HEALTH CONDITIONS",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      if (_healthMap.values.any((v) => v))
                        TextButton(
                          onPressed: () {
                            setState(() {
                              for (var k in _healthMap.keys)
                                _healthMap[k] = false;
                            });
                            _saveHealth();
                          },
                          child: const Text(
                            "Clear all",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Select conditions for personalized warnings",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search input
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.scaffoldBackgroundLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            onChanged: (v) =>
                                setState(() => _healthSearchQuery = v),
                            decoration: const InputDecoration(
                              hintText: "Search conditions...",
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        if (_healthSearchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () =>
                                setState(() => _healthSearchQuery = ''),
                            child: const Icon(
                              Icons.close,
                              color: AppColors.textSecondary,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2-Column Grid Layout for Health Conditions
                  _HealthConditionsGrid(
                    healthMap: _healthMap,
                    healthGroups: _healthGroups,
                    searchQuery: _healthSearchQuery,
                    onToggle: (key, value) {
                      setState(() => _healthMap[key] = value);
                      _saveHealth();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            _buildActionButton(
              icon: Icons.logout,
              color: Colors.redAccent,
              label: "Log Out",
              onTap: () async {
                await AuthService().signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (r) => false,
                );
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.key,
              color: AppColors.primaryGreen,
              label: GeminiService.apiKey?.isNotEmpty == true
                  ? "API Key Set"
                  : "Set API Key",
              onTap: _setApiKey,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Premium Health Chip with Gradient & Animation
class _PremiumHealthChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final Function(bool) onTap;

  const _PremiumHealthChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_PremiumHealthChip> createState() => _PremiumHealthChipState();
}

class _PremiumHealthChipState extends State<_PremiumHealthChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails d) => _controller.forward();
  void _onTapUp(TapUpDetails d) {
    _controller.reverse();
    widget.onTap(!widget.isSelected);
  }

  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: widget.isSelected
                    ? const LinearGradient(
                        colors: [AppColors.primaryGreen, Color(0xFF22C55E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: widget.isSelected
                    ? null
                    : AppColors.scaffoldBackgroundLight,
                borderRadius: BorderRadius.circular(100),
                border: widget.isSelected
                    ? null
                    : Border.all(color: Colors.grey.shade300, width: 1),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primaryGreen.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isSelected) ...[
                    const Icon(Icons.check, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.isSelected
                          ? Colors.white
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// 2-Column Grid Layout for Health Conditions
class _HealthConditionsGrid extends StatelessWidget {
  final Map<String, bool> healthMap;
  final Map<String, List<String>> healthGroups;
  final String searchQuery;
  final Function(String, bool) onToggle;

  const _HealthConditionsGrid({
    required this.healthMap,
    required this.healthGroups,
    required this.searchQuery,
    required this.onToggle,
  });

  String _getGroupIcon(String group) {
    switch (group) {
      case 'Medical Conditions':
        return '🏥';
      case 'Allergies':
        return '⚠️';
      case 'Diet Preferences':
        return '🥗';
      default:
        return '📋';
    }
  }

  String _getGroupEmoji(String group) {
    switch (group) {
      case 'Medical Conditions':
        return '🩺';
      case 'Allergies':
        return '😷';
      case 'Diet Preferences':
        return '🥗';
      default:
        return '📋';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredGroups = healthGroups.entries
        .where(
          (g) =>
              searchQuery.isEmpty ||
              g.value.any(
                (c) => c.toLowerCase().contains(searchQuery.toLowerCase()),
              ),
        )
        .toList();

    if (filteredGroups.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            "No conditions found",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...filteredGroups.map((group) {
          final conditions = group.value
              .where(
                (k) =>
                    healthMap.containsKey(k) &&
                    (searchQuery.isEmpty ||
                        k.toLowerCase().contains(searchQuery.toLowerCase())),
              )
              .toList();

          if (conditions.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group Header
              Padding(
                padding: const EdgeInsets.only(bottom: 12, top: 8),
                child: Row(
                  children: [
                    Text(
                      _getGroupEmoji(group.key),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      group.key,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              // 2-Column Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: conditions.length,
                itemBuilder: (context, index) {
                  final condition = conditions[index];
                  return _EqualSizeHealthChip(
                    label: condition,
                    isSelected: healthMap[condition] ?? false,
                    onTap: (value) => onToggle(condition, value),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      ],
    );
  }
}

// Equal-sized Health Chip for Grid
class _EqualSizeHealthChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final Function(bool) onTap;

  const _EqualSizeHealthChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_EqualSizeHealthChip> createState() => _EqualSizeHealthChipState();
}

class _EqualSizeHealthChipState extends State<_EqualSizeHealthChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap(!widget.isSelected);
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: widget.isSelected
                    ? const LinearGradient(
                        colors: [AppColors.primaryGreen, Color(0xFF22C55E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: widget.isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: widget.isSelected
                    ? null
                    : Border.all(color: Colors.grey.shade200, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: widget.isSelected
                        ? AppColors.primaryGreen.withOpacity(0.25)
                        : Colors.black.withOpacity(0.03),
                    blurRadius: widget.isSelected ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isSelected) ...[
                    const Icon(Icons.check, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        color: widget.isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
