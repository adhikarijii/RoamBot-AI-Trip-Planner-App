import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roambot/commons/widgets/custom_app_bar.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  final userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (snapshot.exists) {
      final data = snapshot.data();
      nameController.text = data?['name'] ?? '';
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    String? imageUrl;

    if (_imageFile != null) {
      final ref = FirebaseStorage.instance.ref().child(
        'profile_pics/$userId.jpg',
      );
      await ref.putFile(_imageFile!);
      imageUrl = await ref.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'name': nameController.text.trim(),
      if (imageUrl != null) 'profileImage': imageUrl,
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Profile updated!")));

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: ("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    _imageFile != null ? FileImage(_imageFile!) : null,
                child:
                    _imageFile == null
                        ? const Icon(Icons.camera_alt, size: 40)
                        : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text("Save Profile"),
                ),
          ],
        ),
      ),
    );
  }
}
