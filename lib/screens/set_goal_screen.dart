import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/goal_model.dart';
import '../services/goal_service.dart';

class SetGoalScreen extends StatefulWidget {
  const SetGoalScreen({super.key});

  @override
  State<SetGoalScreen> createState() => _SetGoalScreenState();
}

class _SetGoalScreenState extends State<SetGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _minutesController = TextEditingController();
  bool _isSaving = false;

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final goal = Goal(
      targetMinutes: int.parse(_minutesController.text.trim()),
      createdAt: DateTime.now(),
    );

    await GoalService().setWeeklyGoal(uid, goal);

    setState(() => _isSaving = false);
    if (context.mounted) Navigator.pop(context); // Go back after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
          centerTitle: true,
          title: const Text("Set Weekly Goal",
            style: TextStyle(fontSize: 22,
                fontWeight: FontWeight.bold,color: Colors.white), )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text("Enter your weekly fitness goal in minutes:"),
              const SizedBox(height: 16),
              TextFormField(
                controller: _minutesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Target Minutes",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return "Required";
                  final minutes = int.tryParse(value.trim());
                  if (minutes == null || minutes <= 0) return "Enter a valid number";
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveGoal,
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text("Save Goal"),
              )
            ],
          ),
        ),
      ),
    );
  }
}


/*
import 'package:flutter/material.dart';
import '../services/goal_service.dart';

class SetGoalScreen extends StatefulWidget {
  const SetGoalScreen({super.key});

  @override
  State<SetGoalScreen> createState() => _SetGoalScreenState();
}

class _SetGoalScreenState extends State<SetGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _minutesController = TextEditingController();

  bool _loading = false;
  String _message = '';

  void _submitGoal() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
        _message = '';
      });
      final minutes = int.parse(_minutesController.text);
      await GoalService().setWeeklyGoal(minutes);
      setState(() {
        _loading = false;
        _message = 'Goal saved successfully!';      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Set Weekly Goal")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text("Enter your weekly workout target (in minutes)"),
              TextFormField(
                controller: _minutesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Target Minutes"),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (int.tryParse(value) == null) return 'Enter valid number';
                  return null;

            ],
          ),
        ),
      ),
    );
  }
}
*/
