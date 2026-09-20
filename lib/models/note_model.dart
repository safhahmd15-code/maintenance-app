import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String requestId;
  final String userId;
  final String note;
  final DateTime createdAt;

  NoteModel({
    required this.id,
    required this.requestId,
    required this.userId,
    required this.note,
    required this.createdAt,
  });

  factory NoteModel.fromMap(Map<String, dynamic> map, String documentId) {
    return NoteModel(
      id: documentId,
      requestId: map['requestId'] ?? '',
      userId: map['userId'] ?? '',
      note: map['note'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'userId': userId,
      'note': note,
      'createdAt': createdAt,
    };
  }
}