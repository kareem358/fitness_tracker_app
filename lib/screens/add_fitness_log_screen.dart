import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddFitnessLogScreen extends StatefulWidget {
  final QueryDocumentSnapshot? existingLog;
  final String? logId;

  const AddFitnessLogScreen({Key? key, this.existingLog, this.logId})
      : super(key: key);

  @override
  State<AddFitnessLogScreen> createState() => _AddFitnessLogScreenState();
}

class _AddFitnessLogScreenState extends State<AddFitnessLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _workoutController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingLog != null) {
      final log = widget.existingLog!;
      _workoutController.text = log['workout'];
      _durationController.text = log['duration'].toString();
      _notesController.text = log['notes'];
    }
  }

  @override
  void dispose() {
    _workoutController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveLog() async {
    if (!_formKey.currentState!.validate()) return;

    final workout = _workoutController.text.trim();
    final duration = int.tryParse(_durationController.text.trim());
    final notes = _notesController.text.trim();

    if (duration == null || duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid duration.')),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final logData = {
      'workout': workout,
      'duration': duration,
      'notes': notes,
      'date': Timestamp.now(),
    };

    final logsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('fitness_logs');

    if (widget.existingLog != null && widget.logId != null) {
      // Update existing log
      await logsRef.doc(widget.logId).update(logData);
    } else {
      // Add new log
      await logsRef.add(logData);
    }

    Navigator.pop(context, true); // Return true to refresh HomeScreen
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingLog != null;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(isEditing ? 'Edit Fitness Log' : 'Add Fitness Log',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _workoutController,
                decoration: const InputDecoration(labelText: 'Workout Name'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(labelText: 'Duration (mins)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value == null || value.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveLog,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                child: Text(isEditing ? 'Update Log' : 'Save Log', style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _uid = FirebaseAuth.instance.currentUser!.uid;


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
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('fitness_logs')
          .add({
        'workout': _workoutController.text.trim(),
        'duration': int.parse(_durationController.text.trim()),
        'notes': _notesController.text.trim(),
        'date': _selectedDate,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Log added successfully!')),
      );

      Navigator.pop(context, true); // returns `true` to HomeScreen
    } catch (e) {
      print("Error adding log: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Something went wrong')),
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter duration';
                  }

                  final number = int.tryParse(value.trim());
                  if (number == null) {
                    return 'Enter a valid number';
                  }

                  if (number <= 0) {
                    return 'Duration must be positive';
                  }

                  return null; // ✅ All good
                },
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
*/
