// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:roambot/commons/widgets/custom_app_bar.dart';
// import 'package:roambot/screens/About.dart';
// import 'package:roambot/screens/PrivacyPolicy.dart';
// import 'package:roambot/screens/TermsOfUse.dart';
// import 'package:roambot/screens/login_screen.dart';
// import 'package:roambot/screens/profile_screen.dart';
// import 'package:roambot/utils/constants.dart';

// class UserProfileScreen extends StatefulWidget {
//   const UserProfileScreen({super.key});

//   @override
//   State<UserProfileScreen> createState() => _UserProfileScreenState();
// }

// class _UserProfileScreenState extends State<UserProfileScreen> {
//   String? name;
//   String? photoUrl;
//   bool isLoading = true;
//   double profileCompletion = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserProfile();
//   }

//   Future<void> _loadUserProfile() async {
//     try {
//       final userDoc =
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(currentUserId)
//               .get();
//       final data = userDoc.data();

//       int filled = 0;
//       int total = 2; // Currently checking 'name' and 'photoUrl'

//       final loadedName = data?['name'];
//       final loadedPhotoUrl = data?['photoUrl'];

//       if (loadedName != null && loadedName.toString().trim().isNotEmpty)
//         filled++;
//       if (loadedPhotoUrl != null && loadedPhotoUrl.toString().trim().isNotEmpty)
//         filled++;

//       setState(() {
//         name = loadedName ?? 'Explorer';
//         photoUrl = loadedPhotoUrl;
//         profileCompletion = filled / total;
//         isLoading = false;
//       });
//     } catch (e) {
//       print("Error loading profile: $e");
//       setState(() => isLoading = false);
//     }
//   }

//   void _showLogoutConfirmation(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Icon(Icons.logout, size: 40, color: Colors.red),
//           content: const Text(
//             'Are you sure you want to log out?',
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 16),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _logout(context);
//               },
//               child: const Text('Logout', style: TextStyle(color: Colors.red)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _logout(BuildContext context) async {
//     try {
//       await FirebaseAuth.instance.signOut();
//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Logged out successfully")));
//       Navigator.of(
//         context,
//       ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Logout failed. Please try again.")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const CustomAppBar(title: 'Profile'),
//       body:
//           isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Center(
//                       child: Column(
//                         children: [
//                           CircleAvatar(
//                             radius: 40,
//                             backgroundImage:
//                                 photoUrl != null
//                                     ? NetworkImage(photoUrl!)
//                                     : const AssetImage(
//                                           'assets/default_avatar.png',
//                                         )
//                                         as ImageProvider,
//                           ),
//                           const SizedBox(height: 12),
//                           Text(
//                             'Hi, ${name ?? 'Explorer'}',
//                             style: const TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           // LinearProgressIndicator(
//                           //   value: profileCompletion,
//                           //   backgroundColor: Colors.grey.shade300,
//                           //   color: Colors.orange,
//                           // ),
//                           // const SizedBox(height: 4),
//                           // Text(
//                           //   '${(profileCompletion * 100).toInt()}% completed',
//                           // ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 20),

//                     // Appearance section
//                     // const Align(
//                     //   alignment: Alignment.centerLeft,
//                     //   child: Text(
//                     //     "Appearance",
//                     //     style: TextStyle(
//                     //       fontWeight: FontWeight.bold,
//                     //       fontSize: 16,
//                     //     ),
//                     //   ),
//                     // ),
//                     // const SizedBox(height: 10),
//                     // ToggleButtons(
//                     //   isSelected: const [false, true, false],
//                     //   borderRadius: BorderRadius.circular(10),
//                     //   children: const [
//                     //     Padding(
//                     //       padding: EdgeInsets.symmetric(horizontal: 16),
//                     //       child: Text('Default'),
//                     //     ),
//                     //     Padding(
//                     //       padding: EdgeInsets.symmetric(horizontal: 16),
//                     //       child: Text('Light'),
//                     //     ),
//                     //     Padding(
//                     //       padding: EdgeInsets.symmetric(horizontal: 16),
//                     //       child: Text('Dark'),
//                     //     ),
//                     //   ],
//                     //   onPressed: (index) {
//                     //     // TODO: Handle theme change
//                     //   },
//                     // ),
//                     // const SizedBox(height: 30),

//                     // Profile section
//                     const Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         "Profile",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     _buildTile(Icons.person, "Edit personal information", () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => const ProfileScreen(),
//                         ),
//                       );
//                     }),

//                     // _buildTile(
//                     //   Icons.scatter_plot_outlined,
//                     //   "Edit interests",
//                     //   () {},
//                     // ),
//                     // _buildTile(
//                     //   Icons.map_outlined,
//                     //   "Edit extra information",
//                     //   () {},
//                     // ),
//                     const SizedBox(height: 30),

//                     // More
//                     const Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         "More",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     _buildTile(Icons.question_mark_sharp, "About", () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => const About()),
//                       );
//                     }),
//                     _buildTile(Icons.shield_sharp, "Terms of use", () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => const TermsOfUse()),
//                       );
//                     }),
//                     _buildTile(
//                       Icons.privacy_tip_outlined,
//                       "Privacy Policy",
//                       () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => const PrivacyPolicy(),
//                           ),
//                         );
//                       },
//                     ),
//                     _buildTile(Icons.delete, "Delete Account", () {}),
//                     const SizedBox(height: 10),
//                     _buildTile(Icons.logout_outlined, "Log out", () {
//                       _showLogoutConfirmation(context);
//                     }),
//                   ],
//                 ),
//               ),
//     );
//   }

//   Widget _buildTile(IconData icon, String title, VoidCallback onTap) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       child: ListTile(
//         leading: Icon(icon, color: Colors.black87),
//         title: Text(
//           title,
//           style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
//         ),
//         trailing: const Icon(Icons.arrow_forward_ios, size: 14),
//         onTap: onTap,
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roambot/commons/widgets/custom_app_bar.dart';
import 'package:roambot/screens/About.dart';
import 'package:roambot/screens/PrivacyPolicy.dart';
import 'package:roambot/screens/TermsOfUse.dart';
import 'package:roambot/screens/login_screen.dart';
import 'package:roambot/screens/profile_screen.dart';
import 'package:roambot/utils/constants.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Icon(Icons.logout, size: 40, color: Colors.red),
          content: const Text(
            'Are you sure you want to log out?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Logged out successfully")));
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logout failed. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Profile'),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(currentUserId)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;

          final name = data?['name'] ?? 'Explorer';
          final photoUrl = data?['photoUrl'];

          int filled = 0;
          if (name.toString().trim().isNotEmpty) filled++;
          if (photoUrl?.toString().trim().isNotEmpty ?? false) filled++;

          double completion = filled / 2;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage:
                            photoUrl != null
                                ? NetworkImage(photoUrl)
                                : const AssetImage('assets/default_avatar.png')
                                    as ImageProvider,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Hi, $name',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Uncomment this if you want to show profile completion
                      // const SizedBox(height: 4),
                      // LinearProgressIndicator(
                      //   value: completion,
                      //   backgroundColor: Colors.grey.shade300,
                      //   color: Colors.orange,
                      // ),
                      // const SizedBox(height: 4),
                      // Text('${(completion * 100).toInt()}% completed'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSections(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSections(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Profile",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 10),
        _buildTile(Icons.person, "Edit personal information", () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        }),

        const SizedBox(height: 30),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "More",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 10),
        _buildTile(Icons.question_mark_sharp, "About", () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const About()),
          );
        }),
        _buildTile(Icons.shield_sharp, "Terms of use", () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TermsOfUse()),
          );
        }),
        _buildTile(Icons.privacy_tip_outlined, "Privacy Policy", () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PrivacyPolicy()),
          );
        }),
        _buildTile(Icons.delete, "Delete Account", () {
          // TODO: Add account deletion logic
        }),
        const SizedBox(height: 10),
        _buildTile(Icons.logout_outlined, "Log out", () {
          _showLogoutConfirmation(context);
        }),
      ],
    );
  }

  Widget _buildTile(IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.black87),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}
