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
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _submitGoal,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text("Save Goal"),
              ),
              const SizedBox(height: 10),
              Text(_message, style: const TextStyle(color: Colors.green)),
            ],
          ),
        ),
      ),
    );
  }
}
*/
