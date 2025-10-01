import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

enum HistoryFilter { all, week, month }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  HistoryFilter _filter = HistoryFilter.all;

  /// Builds Firestore query based on filter
  Stream<QuerySnapshot> _buildQuery(String uid) {
    final base = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('fitness_logs')
        .orderBy('date', descending: true);

    final now = DateTime.now();

    if (_filter == HistoryFilter.week) {
      final startOfWeek =
      DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
      return base.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek)).snapshots();
    } else if (_filter == HistoryFilter.month) {
      final startOfMonth = DateTime(now.year, now.month, 1);
      return base.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth)).snapshots();
    } else {
      return base.snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Workout History",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔘 Filter Buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ChoiceChip(
                  label: const Text("All"),
                  selected: _filter == HistoryFilter.all,
                  onSelected: (_) => setState(() => _filter = HistoryFilter.all),
                ),
                ChoiceChip(
                  label: const Text("This Week"),
                  selected: _filter == HistoryFilter.week,
                  onSelected: (_) => setState(() => _filter = HistoryFilter.week),
                ),
                ChoiceChip(
                  label: const Text("This Month"),
                  selected: _filter == HistoryFilter.month,
                  onSelected: (_) => setState(() => _filter = HistoryFilter.month),
                ),
              ],
            ),
          ),

          // 📋 Logs List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildQuery(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No workout history found.",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                final logs = snapshot.data!.docs;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index].data() as Map<String, dynamic>;
                      final date = (log['date'] as Timestamp).toDate();
                      final workout = log['workout'] ?? 'Unknown Workout';
                      final duration = log['duration'] ?? 0;
                      final notes = log['notes'] ?? '';

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.fitness_center,
                              color: Colors.deepPurple),
                          title: Text(
                            workout,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '⏱ $duration mins\n'
                                '${notes.isNotEmpty ? "📝 $notes\n" : ""}'
                                '📅 ${DateFormat.yMMMd().add_jm().format(date)}',
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}







/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Workout History",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('fitness_logs')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No workout history yet.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final logs = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index].data() as Map<String, dynamic>;
                final date = (log['date'] as Timestamp).toDate();
                final workout = log['workout'] ?? 'Unknown Workout';
                final duration = log['duration'] ?? 0;
                final notes = log['notes'] ?? '';

                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.fitness_center,
                        color: Colors.deepPurple),
                    title: Text(
                      workout,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '⏱ $duration mins\n'
                          '${notes.isNotEmpty ? "📝 $notes\n" : ""}'
                          '📅 ${DateFormat.yMMMd().add_jm().format(date)}',
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
*/
