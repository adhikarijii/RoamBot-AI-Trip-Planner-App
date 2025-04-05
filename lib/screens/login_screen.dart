import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'package:roambot/utils/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void login() async {
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
      currentUserId = userCredential.user!.uid;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: Text("Login")),
            TextButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SignupScreen()),
                  ),
              child: Text("Don't have an account? Sign up"),
            ),
          ],
        ),
      ),
    );
  }
}
