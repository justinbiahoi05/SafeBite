import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../../services/scan_history_service.dart';
import '../../../../../services/health_logic.dart';

class ArchivePage extends StatelessWidget {
  const ArchivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundLight,
      appBar: AppBar(
        title: const Text("Scan Archive", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ScanHistoryService().getScans(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
          }
          final scans = snapshot.data?.docs ?? [];

          if (scans.isEmpty) {
            return const Center(child: Text("No history found.", style: TextStyle(color: AppColors.textSecondary)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: scans.length,
            itemBuilder: (context, index) {
              var doc = scans[index];
              bool isSafe = doc['result'] == 'safe';
              DateTime date = (doc['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
              final imageUrl = doc['imageUrl'] as String?;

              // Get ingredient predictions
              final predictions = doc['ingredientPredictions'] as Map<String, dynamic>? ?? {};
              final ingredients = doc['ingredients'] as List<dynamic>? ?? [];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (imageUrl != null && imageUrl.isNotEmpty)
                          Container(
                            width: 60,
                            height: 60,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey.shade200,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                errorWidget: (context, url, error) => const Icon(Icons.image_not_supported),
                              ),
                            ),
                          ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: isSafe ? AppColors.primaryGreen.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                  child: Icon(isSafe ? Icons.check : Icons.warning_amber, color: isSafe ? AppColors.primaryGreen : Colors.red),
                                ),
                                title: Text(doc['productName'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                subtitle: Text("${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                  onPressed: () => ScanHistoryService().deleteScan(doc.id),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (ingredients.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text("Ingredients:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 0.5)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: ingredients.map<Widget>((ingredient) {
                          final label = predictions[ingredient] as String? ?? 'safe';
                          final categoryInfo = _getCategoryInfo(label);
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: categoryInfo['color'] as Color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  ingredient.toString().toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: categoryInfo['textColor'] as Color,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  label == 'safe' ? Icons.check_circle : Icons.warning,
                                  size: 12,
                                  color: categoryInfo['textColor'] as Color,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Map<String, dynamic> _getCategoryInfo(String label) {
    switch (label.toLowerCase()) {
      case 'sugar':
        return {'name': 'SUGAR', 'color': Colors.orange.shade100, 'textColor': Colors.orange.shade800};
      case 'sweetener':
        return {'name': 'SWEETENER', 'color': Colors.pink.shade100, 'textColor': Colors.pink.shade800};
      case 'sodium':
        return {'name': 'SODIUM', 'color': Colors.blue.shade100, 'textColor': Colors.blue.shade800};
      case 'allergen':
        return {'name': 'ALLERGEN', 'color': Colors.red.shade100, 'textColor': Colors.red.shade800};
      case 'bad_fat':
        return {'name': 'BAD FAT', 'color': Colors.yellow.shade100, 'textColor': Colors.yellow.shade800};
      case 'acidic':
        return {'name': 'ACIDIC', 'color': Colors.purple.shade100, 'textColor': Colors.purple.shade800};
      case 'additive':
        return {'name': 'ADDITIVE', 'color': Colors.grey.shade200, 'textColor': Colors.grey.shade700};
      case 'spicy':
        return {'name': 'SPICY', 'color': Colors.red.shade100, 'textColor': Colors.red.shade800};
      default:
        return {'name': 'SAFE', 'color': AppColors.primaryGreen.withOpacity(0.1), 'textColor': AppColors.primaryGreen};
    }
  }
}