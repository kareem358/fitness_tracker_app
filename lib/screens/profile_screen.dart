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
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      final data = doc.data();
      if (mounted) {
        if (data != null) {
          setState(() {
            name = data['name'] ?? '';
            age = (data['age'] is int)
                ? data['age']
                : int.tryParse(data['age'].toString()) ?? 0;
            gender = data['gender'] ?? '';
            height = (data['height'] as num?)?.toDouble() ?? 0.0;
            weight = (data['weight'] as num?)?.toDouble() ?? 0.0;
          });
        }
        setState(() => loading = false);
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Failed to load profile')),
        );
        setState(() => loading = false);
      }
    }
  }

  void saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => saving = true);

    try {
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'age': age,
        'gender': gender,
        'height': height,
        'weight': weight,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Profile updated')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Failed to save profile')),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Widget _buildTextField({
    required String label,
    required String? initialValue,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    required void Function(String?) onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        keyboardType: keyboardType,
        validator: validator,
        onSaved: onSaved,
      ),
    );
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
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(label: 'Name', initialValue: name, onSaved: (val) => name = val!.trim()),
                _buildTextField(
                  label: 'Age',
                  initialValue: age > 0 ? age.toString() : '',
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    final parsed = int.tryParse(val ?? '');
                    return (parsed == null || parsed <= 0) ? 'Enter valid age' : null;
                  },
                  onSaved: (val) => age = int.parse(val!),
                ),
                DropdownButtonFormField<String>(
                  value: gender.isNotEmpty ? gender : null,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  items: ['Male', 'Female', 'Other'].map((value) {
                    return DropdownMenuItem<String>(
                      value: value.toLowerCase(),
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => gender = value ?? ''),
                  validator: (val) => (val == null || val.isEmpty) ? 'Please select gender' : null,
                ),
                SizedBox(height: 10,),
                _buildTextField(
                  label: 'Height (cm)',
                  initialValue: height > 0 ? height.toString() : '',
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    final parsed = double.tryParse(val ?? '');
                    return (parsed == null || parsed <= 0) ? 'Enter valid height' : null;
                  },
                  onSaved: (val) => height = double.parse(val!),
                ),
                _buildTextField(
                  label: 'Weight (kg)',
                  initialValue: weight > 0 ? weight.toString() : '',
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    final parsed = double.tryParse(val ?? '');
                    return (parsed == null || parsed <= 0) ? 'Enter valid weight' : null;
                  },
                  onSaved: (val) => weight = double.parse(val!),
                ),
                const SizedBox(height: 24),
                saving
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    'Save',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: saveProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*
// this  is the initial code for this screen now making the ui more polish
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
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      final data = doc.data();
      if (mounted) {
        if (data != null) {
          setState(() {
            name = data['name'] ?? '';
            age = (data['age'] is int)
                ? data['age']
                : int.tryParse(data['age'].toString()) ?? 0;
            gender = data['gender'] ?? '';
            height = (data['height'] as num?)?.toDouble() ?? 0.0;
            weight = (data['weight'] as num?)?.toDouble() ?? 0.0;
          });
        }
        setState(() => loading = false);
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Failed to load profile')),
        );
        setState(() => loading = false);
      }
    }
  }

  void saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => saving = true);

    try {
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'age': age,
        'gender': gender,
        'height': height,
        'weight': weight,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Profile updated')),
      );

      Navigator.pop(context, true); // Return to previous screen with success
    } catch (e) {
      debugPrint('Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Failed to save profile')),
      );
    } finally {
      if (mounted) setState(() => saving = false);
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
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
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
                validator: (val) =>
                val == null || val.trim().isEmpty ? 'Required' : null,
                onSaved: (val) => name = val!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: age > 0 ? age.toString() : '',
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (val) {
                  final parsed = int.tryParse(val ?? '');
                  return (parsed == null || parsed <= 0)
                      ? 'Enter valid age'
                      : null;
                },
                onSaved: (val) => age = int.parse(val!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: gender.isNotEmpty ? gender : null,
                items: ['Male', 'Female', 'Other'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value.toLowerCase(),
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    gender = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Gender'),
                validator: (val) =>
                (val == null || val.isEmpty) ? 'Please select gender' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: height > 0 ? height.toString() : '',
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
                validator: (val) {
                  final parsed = double.tryParse(val ?? '');
                  return (parsed == null || parsed <= 0)
                      ? 'Enter valid height'
                      : null;
                },
                onSaved: (val) => height = double.parse(val!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: weight > 0 ? weight.toString() : '',
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                validator: (val) {
                  final parsed = double.tryParse(val ?? '');
                  return (parsed == null || parsed <= 0)
                      ? 'Enter valid weight'
                      : null;
                },
                onSaved: (val) => weight = double.parse(val!),
              ),
              const SizedBox(height: 24),
              saving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                icon: const Icon(
                  Icons.save,
                  color: Colors.white,
                ),
                label: const Text(
                  'Save',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
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


*/
