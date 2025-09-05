// lib/models/workout.dart

class Workout {
  final String id;
    return Workout(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      duration: map['duration'] ?? 0,
      date: DateTime.parse(map['date']),
    );
  }
}
