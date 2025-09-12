class Goal {
  final int targetMinutes;
  final DateTime createdAt;

  Goal({required this.targetMinutes, required this.createdAt});

  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      targetMinutes: map['targetMinutes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
