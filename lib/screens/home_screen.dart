import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import 'add_fitness_log_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';


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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Welcome',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        actions: [
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
        ],
      ),
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("👤 Name: ${_user!.name}", style: const TextStyle(fontSize: 18)),
            Text("📧 Email: ${_user!.email}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const Text("🏋️ Fitness Logs", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(_user!.uid)
                    .collection('fitness_logs')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final logs = snapshot.data?.docs ?? [];

                  if (logs.isEmpty) {
                    return const Center(child: Text('No fitness logs found.'));
                  }

                  return ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index].data() as Map<String, dynamic>;
                      final date = log['date'] != null
                          ? (log['date'] as Timestamp).toDate()
                          : null;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: const Icon(Icons.fitness_center),
                          title: Text(log['workout'] ?? 'No workout'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("⏱ Duration: ${log['duration']} mins"),
                              if (log['notes'] != null && log['notes'].toString().isNotEmpty)
                                Text("📝 Notes: ${log['notes']}"),
                              if (date != null)
                                Text("📅 Date: ${date.toLocal().toString().split(' ')[0]}"),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddFitnessLogScreen()),
          );

          if (result == true) {
            print('New fitness log added');
          }
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),

    );
  }
}

