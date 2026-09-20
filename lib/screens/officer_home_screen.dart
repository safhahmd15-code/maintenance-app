import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../services/firestore_service.dart';
import '../models/request_model.dart';
import 'request_details_screen.dart';

class OfficerHomeScreen extends StatelessWidget {
  final String userName;
  final String userId;

  const OfficerHomeScreen({super.key, required this.userName, required this.userId});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('طلبات الصيانة')),
      drawer: AppDrawer(userName: userName, userRole: 'maintenance_officer', userId: userId),
      body: StreamBuilder<List<RequestModel>>(
        stream: firestoreService.getAllRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }

          final requests = snapshot.data ?? [];

          if (requests.isEmpty) {
            return const Center(child: Text('لا يوجد طلبات صيانة حاليًا'));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _priorityColor(request.priority),
                    child: Icon(_categoryIcon(request.category),
                        color: Colors.white, size: 20),
                  ),
                  title: Text(request.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${request.category} • ${request.priority}'),
                  trailing: Chip(
                    label: Text(request.status,
                        style: const TextStyle(fontSize: 12, color: Colors.white)),
                    backgroundColor: _statusColor(request.status),
                    padding: EdgeInsets.zero,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RequestDetailsScreen(
                          request: request,
                          userRole: 'maintenance_officer',
                          userId: userId,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
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

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Computer':
        return Icons.computer;
      case 'Printer':
        return Icons.print;
      case 'Internet':
        return Icons.wifi;
      case 'Software':
        return Icons.apps;
      default:
        return Icons.build;
    }
  }
}