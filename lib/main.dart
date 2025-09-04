

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'services/user_service.dart';
import 'models/user_model.dart';

final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await analytics.logAppOpen();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.deepPurple,

        scaffoldBackgroundColor: Colors.grey[100],
      ),

      home: const AuthGate(),
    );
  }
}

/// AuthGate handles Firebase auth + Firestore user profile check
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});


        if (!authSnapshot.hasData) {
          return const LoginScreen();
        }

        final uid = authSnapshot.data!.uid;

        // Logged in → check Firestore for user profile
        return FutureBuilder<AppUser?>(
          future: UserService().getUserById(uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            // Profile exists → go to Home
            if (userSnapshot.hasData) {
              return const HomeScreen();
            } else {

              return const ProfileScreen();
            }
          },
        );
      },
    );
  }
}

