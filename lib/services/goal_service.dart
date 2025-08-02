import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/goal_model.dart';




class GoalService {
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  final _goalsRef = FirebaseFirestore.instance.collection('users');

  Future<void> setWeeklyGoal(int minutes) async {
    await _goalsRef.doc(_uid).collection('goals').doc('weekly_goal').set({
      'targetMinutes': minutes,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<Goal?> getWeeklyGoal() async {
    final doc = await _goalsRef.doc(_uid).collection('goals').doc('weekly_goal').get();
    if (doc.exists) {
      return Goal.fromMap(doc.data()!);
    }
    return null;
  }
}
