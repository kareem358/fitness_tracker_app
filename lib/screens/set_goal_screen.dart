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
        _message = 'Goal saved successfully!';
      });
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
