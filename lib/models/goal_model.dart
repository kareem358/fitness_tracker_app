class Goal {
  final int targetMinutes;
  final DateTime createdAt;

  Goal({required this.targetMinutes, required this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'targetMinutes': targetMinutes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      targetMinutes: map['targetMinutes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
