import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'employee_home_screen.dart';
import 'officer_home_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService(); // جديد

  bool _isLoading = false;
  String? _errorMessage;

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final user = await _authService.signIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (user == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'بيانات الدخول غير صحيحة';
      });
      return;
    }

    // نجح تسجيل الدخول -> نجيب بياناته من Firestore عشان نعرف الـ role
    final userProfile = await _firestoreService.getUserProfile(user.uid);

    setState(() {
      _isLoading = false;
    });

    if (userProfile == null) {
      setState(() {
        _errorMessage = 'لا يوجد ملف شخصي لهذا المستخدم';
      });
      return;
    }

    if (!mounted) return;

    if (userProfile.role == 'employee') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EmployeeHomeScreen(
            userName: userProfile.name,
            userId: userProfile.id,
          ),
        ),
      );
    } else if (userProfile.role == 'maintenance_officer') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OfficerHomeScreen(
            userName: userProfile.name,
            userId: userProfile.id,

          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.build, size: 80, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'نظام إدارة طلبات الصيانة',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 16),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('تسجيل الدخول'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}