import 'package:flutter/material.dart';
import '../models/request_model.dart';
import '../services/firestore_service.dart';

class RequestDetailsScreen extends StatefulWidget {
  final RequestModel request;
  final String userRole;
  final String userId;

  const RequestDetailsScreen({
    super.key,
    required this.request,
    required this.userRole,
    required this.userId,
  });

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _noteController = TextEditingController();

  late String _currentStatus;
  final List<String> _statusOptions = ['New', 'In Progress', 'Resolved', 'Reopened'];

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.request.status;
  }

  void _updateStatus(String newStatus) async {
    await _firestoreService.updateRequestStatus(widget.request.id, newStatus);
    setState(() {
      _currentStatus = newStatus;
    });
  }

  void _submitNote() async {
    if (_noteController.text.trim().isEmpty) return;

    await _firestoreService.addNote(
      widget.request.id,
      widget.userId,
      _noteController.text.trim(),
    );
    _noteController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الطلب')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              widget.request.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Chip(label: Text(_currentStatus)),
            const SizedBox(height: 24),
            _buildInfoRow('الوصف', widget.request.description),
            _buildInfoRow('التصنيف', widget.request.category),
            _buildInfoRow('الأولوية', widget.request.priority),
            _buildInfoRow('تاريخ الإنشاء', widget.request.createdAt.toString()),
            const SizedBox(height: 24),

            // هذا الجزء يظهر فقط لمسؤول الصيانة
            if (widget.userRole == 'maintenance_officer') ...[
              const Divider(),
              const Text(
                'إجراءات مسؤول الصيانة',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _currentStatus,
                decoration: const InputDecoration(
                  labelText: 'تغيير الحالة',
                  border: OutlineInputBorder(),
                ),
                items: _statusOptions
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) _updateStatus(value);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'إضافة ملاحظة',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _submitNote,
                child: const Text('إرسال الملاحظة'),
              ),
            ],

            const SizedBox(height: 24),
            const Divider(),
            const Text(
              'الملاحظات',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firestoreService.getRequestNotes(widget.request.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final notes = snapshot.data ?? [];
                if (notes.isEmpty) {
                  return const Text('لا توجد ملاحظات بعد');
                }
                return Column(
                  children: notes
                      .map((note) => ListTile(
                    leading: const Icon(Icons.note_outlined),
                    title: Text(note['note'] ?? ''),
                  ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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