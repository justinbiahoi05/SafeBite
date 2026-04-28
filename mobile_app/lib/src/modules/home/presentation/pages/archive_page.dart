import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../../services/scan_history_service.dart';

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

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: ListTile(
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
              );
            },
          );
        },
      ),
    );
  }
}