import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/request_model.dart';

class AddRequestScreen extends StatefulWidget {
  final String userId;

  const AddRequestScreen({super.key, required this.userId});

  @override
  State<AddRequestScreen> createState() => _AddRequestScreenState();
}

class _AddRequestScreenState extends State<AddRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Computer';
  String _selectedPriority = 'Medium';
  bool _isSubmitting = false;

  final FirestoreService _firestoreService = FirestoreService();

  final List<String> _categories = ['Computer', 'Printer', 'Internet', 'Software', 'Other'];
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  void _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return; // فيه حقول فاضية أو غير صحيحة
    }

    setState(() {
      _isSubmitting = true;
    });

    final newRequest = RequestModel(
      id: '',
      // Firestore بيولّده تلقائيًا
      userId: widget.userId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      priority: _selectedPriority,
      status: 'New',
      createdAt: DateTime.now(),
    );

    await _firestoreService.createRequest(newRequest);

    setState(() {
      _isSubmitting = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إرسال طلبك بنجاح ✅'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلب صيانة جديد')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان المشكلة',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء كتابة عنوان المشكلة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'وصف المشكلة',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء كتابة وصف المشكلة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'تصنيف المشكلة',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'درجة الأولوية',
                  border: OutlineInputBorder(),
                ),
                items: _priorities
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _submitRequest,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('إرسال الطلب'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}