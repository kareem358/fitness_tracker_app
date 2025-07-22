import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddFitnessLogScreen extends StatefulWidget {
  const AddFitnessLogScreen({Key? key}) : super(key: key);

  @override
  _AddFitnessLogScreenState createState() => _AddFitnessLogScreenState();
}
// adding state and controllers
class _AddFitnessLogScreenState extends State<AddFitnessLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _workoutController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

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
// submitting a function to the firestore

  Future<void> _submitLog() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('fitness_logs').add({
        'workout': _workoutController.text.trim(),
        'duration': int.parse(_durationController.text.trim()),
        'notes': _notesController.text.trim(),
        'date': _selectedDate,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log added successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      print("Error adding log: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong')),
      );
    }

    setState(() => _isSaving = false);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Fitness Log')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isSaving
            ? const Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _workoutController,
                decoration: const InputDecoration(labelText: 'Workout'),
                validator: (value) =>
                value!.isEmpty ? 'Enter workout name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? 'Enter duration' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
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
              ElevatedButton(
                onPressed: _submitLog,
                child: const Text('Save Log'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _workoutController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
