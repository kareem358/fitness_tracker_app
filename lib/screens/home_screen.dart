
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:tracker_pulse_app/screens/set_goal_screen.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import 'add_fitness_log_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import '../services/goal_service.dart';
import '../models/goal_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService auth = AuthService();
  AppUser? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final user = await UserService().getUserById(uid);
      if (!mounted) return;
      setState(() {
        _user = user;
      });
    }
  }

  Future<int?> _fetchWeeklyGoal() async {
    if (_user == null) return null;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .collection('goals')
        .doc('weekly_goal')
        .get();
    if (snapshot.exists) {
      return snapshot.data()?['weekly_goal'] as int?;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '🏃  Pulse Tracker',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.flag, color: Colors.white),
            tooltip: 'Weekly Goal',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SetGoalScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            tooltip: 'Profile',
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
              if (updated == true) _loadUser();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () async {
              await auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          FutureBuilder<int?>(
            future: _fetchWeeklyGoal(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: LinearProgressIndicator(),
                );
              }

              final goal = snapshot.data;
              return Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 16),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.flag, color: Colors.deepPurple),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            goal != null
                                ? '🎯 Weekly Goal: $goal minutes'
                                : '🎯 No goal set yet',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SetGoalScreen()),
                            );
                          },
                          child: const Text('Edit'),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(_user!.uid)
                  .collection('fitness_logs')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                final logs = snapshot.data?.docs ?? [];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('🏋️ Fitness Logs',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      logs.isEmpty
                          ? const Expanded(
                        child: Center(
                          child: Text(
                            'No fitness logs yet. Add some! 💪',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      )
                          : Expanded(
                        child: ListView.builder(
                          itemCount: logs.length,
                          itemBuilder: (context, index) {
                            final log = logs[index];
                            final workout = log['workout'];
                            final duration = log['duration'];
                            final notes = log['notes'];
                            final date = (log['date'] as Timestamp)
                                .toDate();

                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(12)),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 6),
                              child: ListTile(
                                onTap: () async {
                                  final result =
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          AddFitnessLogScreen(
                                            existingLog: log,
                                            logId: log.id,
                                          ),
                                    ),
                                  );
                                  if (result == true) {
                                    setState(() {});
                                  }
                                },
                                leading: const Icon(
                                    Icons.fitness_center,
                                    color: Colors.deepPurple),
                                title: Text(workout,
                                    style: const TextStyle(
                                        fontWeight:
                                        FontWeight.bold)),
                                subtitle: Text(
                                    '⏱ $duration mins\n📝 $notes\n📅 ${DateFormat.yMMMd().add_jm().format(date)}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () async {
                                    final confirm =
                                    await showDialog<bool>(
                                      context: context,
                                      builder: (context) =>
                                          AlertDialog(
                                            title:
                                            const Text('Delete Log'),
                                            content: const Text(
                                                'Are you sure you want to delete this fitness log?'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context,
                                                          false),
                                                  child: const Text(
                                                      'Cancel')),
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, true),
                                                  child: const Text(
                                                      'Delete')),
                                            ],
                                          ),
                                    );

                                    if (confirm == true) {
                                      await FirebaseFirestore
                                          .instance
                                          .collection('users')
                                          .doc(_user!.uid)
                                          .collection(
                                          'fitness_logs')
                                          .doc(log.id)
                                          .delete();
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddFitnessLogScreen()),
          );
          if (result == true) {
            setState(() {});
          }
        },
        backgroundColor: Colors.deepPurple,
        tooltip: 'Add New Log',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}


/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:tracker_pulse_app/screens/set_goal_screen.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import 'add_fitness_log_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import '../services/goal_service.dart';
import '../models/goal_model.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService auth = AuthService();
  AppUser? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final user = await UserService().getUserById(uid);
      if (!mounted) return;
      setState(() {
        _user = user;
      });
    }
  }

*/
/*  Widget _buildUserInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("👤 ${_user!.name}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text("📧 ${_user!.email}"),
            const SizedBox(height: 2),
            Text("🎂 Age: ${_user!.age}"),
            const SizedBox(height: 2),
            Text("🚻 Gender: ${_user!.gender}"),
            const SizedBox(height: 2),
            Text("📏 Height: ${_user!.height} cm"),
            const SizedBox(height: 2),
            Text("⚖️ Weight: ${_user!.weight} kg"),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                  if (updated == true) _loadUser();
                },
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }*//*


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '🏃  Pulse Tracker',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.flag, color: Colors.white, ),
            tooltip: 'Weekly Goal',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SetGoalScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            tooltip: 'Profile',
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
              if (updated == true) _loadUser(); // optional: refresh data on return
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () async {
              await auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],

        */
/*  actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SetGoalScreen()),
              );
            },
            child: const Text("Weekly Goal"),
          ),

          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          )
        ],*//*

      ),
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .collection('fitness_logs')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final logs = snapshot.data?.docs ?? [];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                */
/*_buildUserInfoCard(),*//*

                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('🏋️ Fitness Logs',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                logs.isEmpty
                    ? const Expanded(
                  child: Center(
                      child: Text(
                        'No fitness logs yet. Add some! 💪',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      )),
                )
                    : Expanded(
                  child: ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      final workout = log['workout'];
                      final duration = log['duration'];
                      final notes = log['notes'];
                      final date = (log['date'] as Timestamp).toDate();

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddFitnessLogScreen(
                                  existingLog: log,
                                  logId: log.id,
                                ),
                              ),
                            );
                            if (result == true) setState(() {});
                          },
                          leading: const Icon(Icons.fitness_center,
                              color: Colors.deepPurple),
                          title: Text(workout,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              '⏱ $duration mins\n📝 $notes\n📅 ${DateFormat.yMMMd().add_jm().format(date)}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Log'),
                                  content: const Text(
                                      'Are you sure you want to delete this fitness log?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel')),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Delete')),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(_user!.uid)
                                    .collection('fitness_logs')
                                    .doc(log.id)
                                    .delete();
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddFitnessLogScreen()),
          );
          if (result == true) {
            setState(() {});
          }
        },
        backgroundColor: Colors.deepPurple,
        tooltip: 'Add New Log',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
*/


/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:tracker_pulse_app/screens/set_goal_screen.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import 'add_fitness_log_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import '../services/goal_service.dart';
import '../models/goal_model.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService auth = AuthService();
  AppUser? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final user = await UserService().getUserById(uid);
      if (!mounted) return;
      setState(() {
        _user = user;
      });
    }
  }

*/
/*  Widget _buildUserInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("👤 ${_user!.name}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text("📧 ${_user!.email}"),
            const SizedBox(height: 2),
            Text("🎂 Age: ${_user!.age}"),
            const SizedBox(height: 2),
            Text("🚻 Gender: ${_user!.gender}"),
            const SizedBox(height: 2),
            Text("📏 Height: ${_user!.height} cm"),
            const SizedBox(height: 2),
            Text("⚖️ Weight: ${_user!.weight} kg"),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                  if (updated == true) _loadUser();
                },
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }*//*


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '🏃  Pulse Tracker',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.flag, color: Colors.white, ),
            tooltip: 'Weekly Goal',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SetGoalScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            tooltip: 'Profile',
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
              if (updated == true) _loadUser(); // optional: refresh data on return
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () async {
              await auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],

        */
/*  actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SetGoalScreen()),
              );
            },
            child: const Text("Weekly Goal"),
          ),

          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          )
        ],*//*

      ),
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .collection('fitness_logs')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final logs = snapshot.data?.docs ?? [];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                */
/*_buildUserInfoCard(),*//*

                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('🏋️ Fitness Logs',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                logs.isEmpty
                    ? const Expanded(
                  child: Center(
                      child: Text(
                        'No fitness logs yet. Add some! 💪',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      )),
                )
                    : Expanded(
                  child: ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      final workout = log['workout'];
                      final duration = log['duration'];
                      final notes = log['notes'];
                      final date = (log['date'] as Timestamp).toDate();

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddFitnessLogScreen(
                                  existingLog: log,
                                  logId: log.id,
                                ),
                              ),
                            );
                            if (result == true) setState(() {});
                          },
                          leading: const Icon(Icons.fitness_center,
                              color: Colors.deepPurple),
                          title: Text(workout,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              '⏱ $duration mins\n📝 $notes\n📅 ${DateFormat.yMMMd().add_jm().format(date)}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Log'),
                                  content: const Text(
                                      'Are you sure you want to delete this fitness log?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel')),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Delete')),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(_user!.uid)
                                    .collection('fitness_logs')
                                    .doc(log.id)
                                    .delete();
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddFitnessLogScreen()),
          );
          if (result == true) {
            setState(() {});
          }
        },
        backgroundColor: Colors.deepPurple,
        tooltip: 'Add New Log',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

*/


