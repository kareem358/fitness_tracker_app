// lib/models/workout.dart

class Workout {
  final String id;
  final String type; // e.g., Running
  final int duration; // only now in minutes
  final DateTime date;

  Workout({
    required this.id,
    required this.type,
    required this.duration,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'duration': duration,
      'date': date.toIso8601String(),
    };
  }


