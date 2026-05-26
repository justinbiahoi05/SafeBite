import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import 'component/home_bottom_navbar.dart';
import 'pages/ai_chat_page.dart';
import 'pages/scanner_page.dart';
import 'pages/insights_page.dart';
import 'pages/profile_page.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ScannerPage(),
    InsightsPage(),
    AIChatPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundLight,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,


        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder<DocumentSnapshot>(
            stream: user != null
                ? FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots()
                : const Stream.empty(),
            builder: (context, snapshot) {
              String? photoUrl;

              if (snapshot.hasData && snapshot.data!.data() != null) {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                photoUrl = data['photoUrl'];
              }

              photoUrl ??= user?.photoURL;

              return CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.scaffoldBackgroundLight,


                backgroundImage: photoUrl != null
                    ? (photoUrl.startsWith('http')
                        ? NetworkImage(photoUrl)
                        : MemoryImage(base64Decode(photoUrl)) as ImageProvider)
                    : null,


                child: photoUrl == null
                    ? const Icon(Icons.person, color: AppColors.textSecondary)
                    : null,
              );
            },
          ),
        ),

        title: const Text(
          'SafeBite',
          style: TextStyle(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),


        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
              child: const Icon(
                Icons.health_and_safety_rounded,
                color: AppColors.primaryGreen,
                size: 24,
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: HomeBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
