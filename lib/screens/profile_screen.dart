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
/*is the widget we which will show the detail of the user profile in a
separate contianer but no it has almost no need as the profile icon shows
this screen having all the details and optional for the editing as well these
information*/
// widget is
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
  }*/