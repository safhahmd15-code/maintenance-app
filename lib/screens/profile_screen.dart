import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatelessWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('الملف الشخصي')),
      body: FutureBuilder<UserModel?>(
        future: firestoreService.getUserProfile(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text('تعذر تحميل بيانات المستخدم'));
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.person, size: 40),
                  ),
                ),
                const SizedBox(height: 24),
                _buildInfoRow('الاسم', user.name),
                _buildInfoRow('البريد الإلكتروني', user.email),
                _buildInfoRow(
                  'الدور',
                  user.role == 'employee' ? 'موظف' : 'مسؤول صيانة',
                ),
                _buildInfoRow('تاريخ الإنشاء', user.createdAt.toString()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}