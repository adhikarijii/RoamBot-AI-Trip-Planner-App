import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roambot/commons/widgets/custom_elevated_buttons.dart';
import 'package:roambot/utils/constants.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  // void signup() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   final email = emailController.text.trim();
  //   final mobile = mobileController.text.trim();
  //   final password = passwordController.text.trim();
  //   final confirmPassword = confirmPasswordController.text.trim();

  //   if (password != confirmPassword) {
  //     showSnackBar("Passwords do not match");
  //     return;
  //   }

  //   try {
  //     setState(() => _isLoading = true);
  //     final userCredential = await FirebaseAuth.instance
  //         .createUserWithEmailAndPassword(email: email, password: password);
  //     final uid = userCredential.user!.uid;

  //     // Store mobile number in Firestore
  //     await FirebaseFirestore.instance.collection('users').doc(uid).set({
  //       'email': email,
  //       'mobile': mobile,
  //       'createdAt': Timestamp.now(),
  //     });

  //     currentUserId = uid;

  //     // Show success dialog
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder:
  //           (_) => AlertDialog(
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //             title: const Text("Signup Successful 🎉"),
  //             content: const Text(
  //               "Your account has been created successfully!",
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.of(context).pop(); // Close dialog
  //                   Navigator.of(context).pop(); // Go back to login screen
  //                 },
  //                 child: const Text("OK"),
  //               ),
  //             ],
  //           ),
  //     );
  //   } catch (e) {
  //     showSnackBar("Signup failed: ${e.toString()}");
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  void signup() async {
    if (!_formKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    final mobile = mobileController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      showSnackBar("Passwords do not match");
      return;
    }

    try {
      setState(() => _isLoading = true);

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user!;
      final uid = user.uid;

      // Send email verification
      await user.sendEmailVerification();

      // Save user data to Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': email,
        'mobile': mobile,
        'createdAt': Timestamp.now(),
      });

      // Clear form fields
      emailController.clear();
      mobileController.clear();
      passwordController.clear();
      confirmPasswordController.clear();

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text("Verify Your Email 📧"),
              content: const Text(
                "A verification link has been sent to your email. Please verify your email before logging in.",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Back to login screen
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    } catch (e) {
      showSnackBar("Signup failed: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.teal.shade800,
              Colors.teal.shade600,
              Colors.teal.shade400,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Get started with Roambot',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: inputDecoration(
                            "Email",
                            Icons.email_outlined,
                          ),
                          validator: (val) {
                            if (val == null ||
                                val.isEmpty ||
                                !val.contains("@")) {
                              return "Enter a valid email";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // TextFormField(
                        //   controller: mobileController,
                        //   keyboardType: TextInputType.phone,
                        //   decoration: inputDecoration(
                        //     "Mobile Number",
                        //     Icons.phone,
                        //   ),
                        //   validator: (val) {
                        //     if (val == null || val.length != 10) {
                        //       return "Enter 10-digit mobile number";
                        //     }
                        //     return null;
                        //   },
                        // ),
                        // const SizedBox(height: 16),
                        TextFormField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          decoration: inputDecoration(
                            "Password",
                            Icons.lock_outline,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(
                                  () => _obscurePassword = !_obscurePassword,
                                );
                              },
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: true,
                          decoration: inputDecoration(
                            "Confirm Password",
                            Icons.lock,
                          ),
                          validator: (val) {
                            if (val != passwordController.text) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: customButtons(
                            bcolor: Colors.teal.shade700,
                            child: _isLoading ? 'Signing Up...' : 'Sign Up',
                            fcolor: Colors.white,
                            onPressed: _isLoading ? null : signup,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.teal.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
