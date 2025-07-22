import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Form fields
  String name = '';
  int age = 0;
  String gender = '';
  double height = 0;
  double weight = 0;

  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        name = data['name'];
        age = data['age'];
        gender = data['gender'];
        height = (data['height'] as num).toDouble();
        weight = (data['weight'] as num).toDouble();
        loading = false;
      });
    }
  }

  void saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() => saving = true);

      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'age': age,
        'gender': gender,
        'height': height,
        'weight': weight,
      });

      setState(() => saving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Profile updated')),
      );

      Navigator.pop(context, true); // Return true to refresh HomeScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white,
        fontSize: 24)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                onSaved: (val) => name = val ?? '',
              ),
              TextFormField(
                initialValue: age.toString(),
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (val) =>
                (val == null || int.tryParse(val) == null || int.parse(val) <= 0)
                    ? 'Enter valid age'
                    : null,
                onSaved: (val) => age = int.tryParse(val ?? '') ?? 0,
              ),
              TextFormField(
                initialValue: gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                onSaved: (val) => gender = val ?? '',
              ),
              TextFormField(
                initialValue: height.toString(),
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
                validator: (val) =>
                (val == null || double.tryParse(val) == null || double.parse(val) <= 0)
                    ? 'Enter valid height'
                    : null,
                onSaved: (val) => height = double.tryParse(val ?? '') ?? 0,
              ),
              TextFormField(
                initialValue: weight.toString(),
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                validator: (val) =>
                (val == null || double.tryParse(val) == null || double.parse(val) <= 0)
                    ? 'Enter valid weight'
                    : null,
                onSaved: (val) => weight = double.tryParse(val ?? '') ?? 0,
              ),
              const SizedBox(height: 24),
              saving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}



/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Form fields
  String name = '';
  int age = 0;
  String gender = '';
  double height = 0;
  double weight = 0;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        name = data['name'];
        age = data['age'];
        gender = data['gender'];
        height = (data['height'] as num).toDouble();
        weight = (data['weight'] as num).toDouble();
        loading = false;
      });
    }
  }

  void saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'age': age,
        'gender': gender,
        'height': height,
        'weight': weight,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Name'),
                onSaved: (val) => name = val ?? '',
              ),
              TextFormField(
                initialValue: age.toString(),
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                onSaved: (val) => age = int.tryParse(val ?? '') ?? 0,
              ),
              TextFormField(
                initialValue: gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                onSaved: (val) => gender = val ?? '',
              ),
              TextFormField(
                initialValue: height.toString(),
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
                onSaved: (val) => height = double.tryParse(val ?? '') ?? 0,
              ),
              TextFormField(
                initialValue: weight.toString(),
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                onSaved: (val) => weight = double.tryParse(val ?? '') ?? 0,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveProfile,
                child: const Text('Save'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
*/
