import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final String priority;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RequestModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory RequestModel.fromMap(Map<String, dynamic> map, String documentId) {
    return RequestModel(
      id: documentId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      priority: map['priority'] ?? '',
      status: map['status'] ?? 'New',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}