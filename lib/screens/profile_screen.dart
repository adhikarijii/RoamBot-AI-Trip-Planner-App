import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roambot/commons/widgets/custom_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  String? _photoUrl;
  File? _pickedImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null) {
        _nameController.text = data['name'] ?? '';
        setState(() {
          _photoUrl = data['photoUrl'];
        });
      }
    }
  }

  // Future<void> _saveProfile() async {
  //   final uid = FirebaseAuth.instance.currentUser?.uid;
  //   if (uid == null) return;

  //   setState(() => _isSaving = true); // Show loading

  //   String? imageUrl = _photoUrl;
  //   if (_pickedImage != null) {
  //     final ref = FirebaseStorage.instance.ref('profile_photos/$uid.jpg');
  //     await ref.putFile(_pickedImage!);
  //     imageUrl = await ref.getDownloadURL();
  //   }

  //   await FirebaseFirestore.instance.collection('users').doc(uid).set({
  //     'name': _nameController.text.trim(),
  //     'photoUrl': imageUrl,
  //   });

  //   setState(() {
  //     _photoUrl = imageUrl;
  //     _isSaving = false;
  //   });

  //   FocusScope.of(context).unfocus(); // Prevent black screen
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text("Profile updated successfully")),
  //   );
  // }

  Future<void> _saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final trimmedName = _nameController.text.trim();

    // ❌ Check for empty or whitespace-only name
    if (trimmedName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Name cannot be empty or just spaces."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    String? imageUrl = _photoUrl;

    try {
      if (_pickedImage != null) {
        final ref = FirebaseStorage.instance.ref('profile_photos/$uid.jpg');
        await ref.putFile(_pickedImage!);
        imageUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': trimmedName,
        'photoUrl': imageUrl,
      });

      setState(() {
        _photoUrl = imageUrl;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
    } catch (e) {
      setState(() => _isSaving = false);
      debugPrint("🔥 Error saving profile: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to save profile: $e")));
    }

    FocusScope.of(context).unfocus(); // Prevent keyboard flicker
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = GlassColors.dark();

    final avatar =
        _pickedImage != null
            ? FileImage(_pickedImage!)
            : _photoUrl != null
            ? NetworkImage(_photoUrl!)
            : const AssetImage('assets/roambot_splash with bg.png')
                as ImageProvider;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: CustomAppBar(title: ("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(radius: 50, backgroundImage: avatar),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              style: TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Name",
                labelStyle: TextStyle(color: Color(0xFF2CE0D0)),
              ),
            ),
            const SizedBox(height: 20),
            _isSaving
                ? const CircularProgressIndicator()
                : FilledButton(
                  onPressed: _saveProfile,
                  child: const Text("Save"),
                ),
            // : ElevatedButton(
            //   onPressed: _saveProfile,
            //   child: const Text("Save"),
            // ),
          ],
        ),
      ),
    );
  }
}

class GlassColors {
  final Color background;
  final Color appBar;
  final Color primary;
  final Color onPrimary;
  final Color text;
  final Color icon;
  final Color glassStart;
  final Color glassEnd;
  final Color glassBorder;
  final Color glassButton;
  final Color shadow;

  GlassColors({
    required this.background,
    required this.appBar,
    required this.primary,
    required this.onPrimary,
    required this.text,
    required this.icon,
    required this.glassStart,
    required this.glassEnd,
    required this.glassBorder,
    required this.glassButton,
    required this.shadow,
  });

  factory GlassColors.dark() {
    return GlassColors(
      background: const Color(0xFF0D0F14), // Deep dark background
      appBar: const Color(0xFF1A2327), // Dark teal app bar
      primary: const Color(0xFF2CE0D0), // Vibrant teal
      onPrimary: const Color(0xFF0D0F14), // Dark text for light elements
      text: const Color(0xFFE0F3FF), // Light text
      icon: const Color(0xFF2CE0D0), // Teal icons
      glassStart: const Color(0xFF1A2327).withOpacity(0.8), // Dark teal glass
      glassEnd: const Color(0xFF253A3E).withOpacity(0.6), // Lighter teal glass
      glassBorder: const Color(
        0xFF3FE0D0,
      ).withOpacity(0.15), // Subtle teal border
      glassButton: const Color(
        0xFF1E2A2D,
      ).withOpacity(0.4), // Dark glass buttons
      shadow: Colors.black.withOpacity(0.5), // Deep shadows
    );
  }

  factory GlassColors.light() {
    return GlassColors(
      background: const Color(0xFFF5F7FA),
      appBar: const Color(0x804E8C87),
      primary: const Color(0xFF4E8C87),
      onPrimary: Colors.white,
      text: const Color(0xFF2D3748),
      icon: const Color(0xFF4E8C87),
      glassStart: const Color(0x90A5D8D3),
      glassEnd: const Color(0x60E2F3F0),
      glassBorder: Colors.white.withOpacity(0.4),
      glassButton: Colors.white.withOpacity(0.3),
      shadow: const Color(0x554A5568),
    );
  }
}
