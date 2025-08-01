// user_model.dart

class AppUser {
  final String uid;
  final String name;
  final String email;
  final int age;
  final String gender;
  final double height;
  final double weight;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      age: data['age'] ?? 0,
      gender: data['gender'] ?? '',
      height: (data['height'] as num?)?.toDouble() ?? 0.0,
      weight: (data['weight'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
