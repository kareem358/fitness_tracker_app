


/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
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

  Widget _buildUserInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("👤 Name: ${_user!.name}", style: const TextStyle(fontSize: 18)),
        Text("📧 Email: ${_user!.email}", style: const TextStyle(fontSize: 18)),
        Text("🎂 Age: ${_user!.age}", style: const TextStyle(fontSize: 18)),
        Text("🚻 Gender: ${_user!.gender}", style: const TextStyle(fontSize: 18)),
        Text("📏 Height: ${_user!.height} cm", style: const TextStyle(fontSize: 18)),
        Text("⚖️ Weight: ${_user!.weight} kg", style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            final updated = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
            if (updated == true) _loadUser();
          },
          child: const Text('✏️ Edit Profile'),
        ),
      ],
    );
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
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserInfoSection(),
                  const SizedBox(height: 20),
                  const Center(child: Text('No fitness logs yet. Add some!')),
                ],
              ),
            );
          }

          final logs = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInfoSection(),
                const SizedBox(height: 20),
                const Text('🏋️ Fitness Logs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      final workout = log['workout'];
                      final duration = log['duration'];
                      final notes = log['notes'];
                      final date = (log['date'] as Timestamp).toDate();

                      return Card(
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

                            if (result == true) {
                              setState(() {}); // Refresh the list after edit
                            }
                          },
                          title: Text(workout, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            'Duration: $duration mins\nNotes: $notes\nDate: ${DateFormat.yMd().add_jm().format(date)}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Log'),
                                  content: const Text('Are you sure you want to delete this fitness log?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
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
            print('New fitness log added');
          }
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),

    );
  }
}

*/
