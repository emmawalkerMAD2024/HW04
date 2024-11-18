import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String? _firstName, _lastName, _email, _role;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _firstName = doc['firstName'];
          _lastName = doc['lastName'];
          _email = doc['email'];
          _role = doc['role'];
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'firstName': _firstName,
          'lastName': _lastName,
          'email': _email,
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully!')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _firstName == null || _lastName == null
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: _firstName,
                      decoration: InputDecoration(labelText: 'First Name'),
                      validator: (value) => value!.isEmpty ? 'Enter your first name' : null,
                      onSaved: (value) => _firstName = value,
                    ),
                    TextFormField(
                      initialValue: _lastName,
                      decoration: InputDecoration(labelText: 'Last Name'),
                      validator: (value) => value!.isEmpty ? 'Enter your last name' : null,
                      onSaved: (value) => _lastName = value,
                    ),
                    TextFormField(
                      initialValue: _email,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (value) => value!.isEmpty ? 'Enter your email' : null,
                      onSaved: (value) => _email = value,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      child: Text('Save'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
