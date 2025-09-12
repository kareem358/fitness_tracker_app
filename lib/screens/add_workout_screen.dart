import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/workout.dart';

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  String workoutType = '';
  int duration = 0;
  DateTime date = DateTime.now();

  void _saveWorkout() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final workout = Workout(
        id: const Uuid().v4(),
        type: workoutType,
        duration: duration,
        date: date,
      );

      Navigator.pop(context, workout); // Return the workout to previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Workout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Workout Type'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                onSaved: (val) => workoutType = val!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                keyboardType: TextInputType.number,
                validator: (val) {
                  final parsed = int.tryParse(val ?? '');
                  return (parsed == null || parsed <= 0) ? 'Enter valid duration' : null;
                },
                onSaved: (val) => duration = int.parse(val!),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Date: ${date.toLocal().toString().split(' ')[0]}'),
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => date = picked);
                      }
                    },
                    child: const Text('Pick Date'),
                  )
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveWorkout,
                child: const Text('Save Workout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
