import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class AddFitnessLogScreen extends StatefulWidget {
  final QueryDocumentSnapshot? existingLog;
  final String? logId;

  const AddFitnessLogScreen({super.key, this.existingLog, this.logId});

  @override
  State<AddFitnessLogScreen> createState() => _AddFitnessLogScreenState();
}

class _AddFitnessLogScreenState extends State<AddFitnessLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _workoutController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingLog != null) {
      final log = widget.existingLog!;
      _workoutController.text = log['workout'];
      _durationController.text = log['duration'].toString();
      _notesController.text = log['notes'];
      _selectedDate = (log['date'] as Timestamp).toDate();
    }
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (time == null) return;

    setState(() {
      _selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _saveLog() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final workout = _workoutController.text.trim();
    final duration = int.tryParse(_durationController.text.trim()) ?? 0;
    final notes = _notesController.text.trim();

    final logData = {
      'workout': workout,
      'duration': duration,
      'notes': notes,
      'date': _selectedDate,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      final logsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('fitness_logs');

      if (widget.existingLog != null && widget.logId != null) {
        await logsRef.doc(widget.logId).update(logData);
        _showSnackbar('✅ Log updated successfully!');
      } else {
        logData['createdAt'] = FieldValue.serverTimestamp();
        await logsRef.add(logData);
        _showSnackbar('✅ Log added successfully!');
      }

      Navigator.pop(context, true);
    } catch (e) {
      _showSnackbar('❌ Saving log Failed . Try again.');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _workoutController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingLog != null;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          isEditing ? 'Edit Fitness Log' : 'Add Fitness Log',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _isSaving
            ? const Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _workoutController,
                decoration: const InputDecoration(
                  labelText: 'Workout Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter duration';
                  }
                  final number = int.tryParse(value.trim());
                  if (number == null || number <= 0) {
                    return 'Enter valid positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Date & Time: ${DateFormat.yMd().add_jm().format(_selectedDate)}',
                    ),
                  ),
                  TextButton(
                    onPressed: _selectDateTime,
                    child: const Text('Change'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveLog,
                  icon: const Icon(Icons.save),
                  label: Text(isEditing ? 'Update Log' : 'Save Log'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
