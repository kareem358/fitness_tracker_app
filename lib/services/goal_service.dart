import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal_model.dart';

class GoalService {
  final _firestore = FirebaseFirestore.instance;

  // Set the user's weekly goal
  Future<void> setWeeklyGoal(String uid, Goal goal) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc('weekly_goal')
        .set(goal.toMap());
  }

  // Get the user's weekly goal
  Future<Goal?> getWeeklyGoal(String uid) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc('weekly_goal')
        .get();

    if (doc.exists) {
      return Goal.fromMap(doc.data()!);
    }
    return null;
  }
}



