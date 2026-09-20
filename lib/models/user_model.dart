import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // "employee" أو "maintenance_officer"
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  // يحوّل بيانات قادمة من Firestore (Map) إلى كائن UserModel
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'employee',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // يحوّل كائن UserModel إلى Map عشان نخزنه بـ Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'createdAt': createdAt,
    };
  }
}