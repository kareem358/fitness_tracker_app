class Goal {
  final int targetMinutes;
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      targetMinutes: map['targetMinutes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
