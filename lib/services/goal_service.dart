import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal_model.dart';

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



