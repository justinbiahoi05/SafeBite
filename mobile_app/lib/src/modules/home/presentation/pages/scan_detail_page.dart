import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';

class ScanDetailPage extends StatelessWidget {
  final QueryDocumentSnapshot scan;

  const ScanDetailPage({super.key, required this.scan});

  // Safe field getter that returns null instead of throwing
  T? _getField<T>(String key) {
    try {
      return scan.get(key) as T?;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSafe = _getField<String>('result') == 'safe';
    final DateTime date = (_getField<Timestamp>('createdAt'))?.toDate() ?? DateTime.now();
    final imageUrl = _getField<String>('imageUrl');

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundLight,
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: isSafe ? AppColors.primaryGreen : Colors.orange,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isSafe
                      ? [AppColors.primaryGreen, AppColors.primaryGreen.withGreen(180)]
                      : [Colors.orange, Colors.orange.shade300],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSafe ? Icons.check_circle : Icons.warning_amber_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isSafe ? 'SAFE' : 'CAUTION',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name Card
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PRODUCT',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getField<String>('productName') ?? 'Unknown Product',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Product Image Card (if available)
                  if (imageUrl != null && imageUrl.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PRODUCT IMAGE',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 200,
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 200,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.error),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Scan Info Card
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SCAN INFO',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.calendar_today,
                          'Date',
                          '${date.day}/${date.month}/${date.year}',
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.access_time,
                          'Time',
                          '${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          isSafe ? Icons.eco : Icons.warning_amber,
                          'Result',
                          isSafe ? 'Safe to consume' : 'Use with caution',
                          valueColor: isSafe ? AppColors.primaryGreen : Colors.orange,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Ingredients Card
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'INGREDIENTS ANALYZED',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildIngredientsList(),
                      ],
                    ),
                  ),

                  // Warning Section (if not safe)
                  if (!isSafe) ...[
                    const SizedBox(height: 16),
                    _buildWarningCard(),
                  ],

                  const SizedBox(height: 24),

                  // Health Warnings
                  _buildHealthWarnings(),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsList() {
    try {
      final ingredients = _getField<List<dynamic>>('ingredients');
      final predictions = _getField<Map<String, dynamic>>('ingredientPredictions') ?? {};

      if (ingredients == null || ingredients.isEmpty) {
        return const Text(
          'No ingredients data available',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        );
      }

      return Column(
        children: ingredients.map<Widget>((ing) {
        final ingredientName = ing.toString();
        final label = predictions[ingredientName] as String? ?? 'safe';
        final categoryInfo = _getCategoryInfo(label);
        final isSafe = label == 'safe';

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: categoryInfo['color'] as Color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                isSafe ? Icons.check_circle : Icons.warning_amber,
                color: categoryInfo['textColor'] as Color,
                size: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ingredientName.toUpperCase(),
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: categoryInfo['textColor'] as Color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            categoryInfo['name'] as String,
                            style: TextStyle(
                              color: categoryInfo['color'] as Color,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isSafe ? 'SAFE' : 'CAUTION',
                          style: TextStyle(
                            color: isSafe ? AppColors.primaryGreen : Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
      );
    } catch (e) {
      return const Text(
        'No ingredients data available',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontStyle: FontStyle.italic,
        ),
      );
    }
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

  Widget _buildHealthWarnings() {
    try {
      final warnings = _getField<List<dynamic>>('healthWarnings');
      if (warnings == null || warnings.isEmpty) {
        return const SizedBox.shrink();
      }

      return _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.health_and_safety, color: Colors.redAccent, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'HEALTH WARNINGS',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...warnings.map<Widget>((warning) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning, color: Colors.orange, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      warning.toString(),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
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
      child: child,
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryGreen, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildWarningCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Caution',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'This product may not be suitable for your health conditions.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}