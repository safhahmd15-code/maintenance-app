import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/request_model.dart';

class FirestoreService {
  final CollectionReference _usersCollection =
  FirebaseFirestore.instance.collection('users');

  final CollectionReference _requestsCollection =
  FirebaseFirestore.instance.collection('maintenance_requests');

  final CollectionReference _notesCollection =
  FirebaseFirestore.instance.collection('maintenance_notes');

  // حفظ بيانات مستخدم جديد بـ Firestore (بعد إنشائه بـ Authentication)
  Future<void> createUserProfile(UserModel user) async {
    await _usersCollection.doc(user.id).set(user.toMap());
  }

  // جلب بيانات مستخدم معيّن (نحتاجها بعد تسجيل الدخول عشان نعرف الـ Role)
  Future<UserModel?> getUserProfile(String userId) async {
    DocumentSnapshot doc = await _usersCollection.doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // إنشاء طلب صيانة جديد
  Future<void> createRequest(RequestModel request) async {
    await _requestsCollection.add(request.toMap());
  }

  // جلب طلبات موظف معيّن (My Requests)
  Stream<List<RequestModel>> getUserRequests(String userId) {
    return _requestsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RequestModel.fromMap(
        doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  // جلب كل الطلبات (لمسؤول الصيانة)
  Stream<List<RequestModel>> getAllRequests() {
    return _requestsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RequestModel.fromMap(
        doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }
  // تحديث حالة الطلب
  Future<void> updateRequestStatus(String requestId, String newStatus) async {
    await _requestsCollection.doc(requestId).update({
      'status': newStatus,
      'updatedAt': DateTime.now(),
    });
  }

  // إضافة ملاحظة على طلب معيّن
  Future<void> addNote(String requestId, String userId, String note) async {
    await _notesCollection.add({
      'requestId': requestId,
      'userId': userId,
      'note': note,
      'createdAt': DateTime.now(),
    });
  }

  // جلب كل الملاحظات الخاصة بطلب معيّن
  Stream<List<Map<String, dynamic>>> getRequestNotes(String requestId) {
    return _notesCollection
        .where('requestId', isEqualTo: requestId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList());
  }
}