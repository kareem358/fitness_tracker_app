// lib/models/workout.dart

class Workout {
  final String id;
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

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      duration: map['duration'] ?? 0,
      date: DateTime.parse(map['date']),
    );
  }
}
