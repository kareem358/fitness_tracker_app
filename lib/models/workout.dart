// lib/models/workout.dart

class Workout {
  final String id;
  final String type; // e.g., Running
  final int duration; // only now in minutes
  final DateTime date;

  Workout({
    required this.id,
    required this.type,
      date: DateTime.parse(map['date']),
    );
  }
}
