import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import '../screens/my_requests_screen.dart';
import '../screens/profile_screen.dart';

class AppDrawer extends StatelessWidget {
  final String userName;
  final String userRole;
  final String userId;

  const AppDrawer({
    super.key,
    required this.userName,
    required this.userRole,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: Text(
              userRole == 'employee' ? 'موظف' : 'مسؤول صيانة',
            ),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('الملف الشخصي'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(userId: userId),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('سجل الطلبات السابقة'),
            onTap: () {
              Navigator.pop(context);
              if (userRole == 'employee') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyRequestsScreen(userId: userId),
                  ),
                );
              }
              // لاحقًا: شاشة History خاصة بمسؤول الصيانة
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await AuthService().signOut();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}