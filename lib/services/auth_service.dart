import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // تسجيل الدخول
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('خطأ تسجيل الدخول: ${e.message}');
      return null;
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // معرفة هل فيه مستخدم مسجل دخوله حاليًا
  User? get currentUser => _auth.currentUser;
}