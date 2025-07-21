import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';


final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await analytics.logAppOpen();  // Log app open event
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FTA',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
            centerTitle: true,
            title: Text('Tracker Home')),
        body: Center(child: Text('Firebase Initialized!')),
      ),
    );
  }
}
