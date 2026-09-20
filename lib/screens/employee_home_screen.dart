import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../services/firestore_service.dart';
import '../models/request_model.dart';
import 'add_request_screen.dart';
import 'my_requests_screen.dart';

class EmployeeHomeScreen extends StatelessWidget {
  final String userName;
  final String userId;

  const EmployeeHomeScreen({super.key, required this.userName, required this.userId});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('الصفحة الرئيسية')),
      drawer: AppDrawer(userName: userName, userRole: 'employee', userId: userId),
      body: StreamBuilder<List<RequestModel>>(
        stream: firestoreService.getUserRequests(userId),
        builder: (context, snapshot) {
          final requests = snapshot.data ?? [];
          final recentRequests = requests.take(3).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحبًا بك $userName ',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'لديك ${requests.length} طلب صيانة مسجّل',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),

                // زر كبير واضح لإضافة طلب
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddRequestScreen(userId: userId),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('طلب صيانة جديد'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'آخر الطلبات',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyRequestsScreen(userId: userId),
                          ),
                        );
                      },
                      child: const Text('عرض الكل'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(child: CircularProgressIndicator())
                else if (recentRequests.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('لا يوجد طلبات بعد، ابدأ بإضافة طلبك الأول')),
                  )
                else
                  ...recentRequests.map((request) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(request.title),
                      subtitle: Text(request.category),
                      trailing: Chip(
                        label: Text(request.status,
                            style: const TextStyle(fontSize: 12, color: Colors.white)),
                        backgroundColor: _statusColor(request.status),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  )),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'New':
        return Colors.blue;
      case 'In Progress':
        return Colors.orange;
      case 'Resolved':
        return Colors.green;
      case 'Reopened':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}