import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';

/*import 'home_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';*/

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Not logged in
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // Logged in → check Firestore profile
        final uid = snapshot.data!.uid;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return const Scaffold(
                body: Center(child: Text('Error checking profile')),
              );
            }

            final hasProfile = snapshot.data!.exists;

            return hasProfile ? const HomeScreen() : const ProfileScreen();
          },
        );
      },
    );
  }
}
