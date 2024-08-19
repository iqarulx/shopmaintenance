// /*
//   Copyright 2024 Srisoftwarez. All rights reserved.
//   Use of this source code is governed by a BSD-style license that can be
//   found in the LICENSE file.
// */

// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class GoogleSignInButton extends StatelessWidget {
//   final GoogleSignIn _googleSignIn = GoogleSignIn();

//   GoogleSignInButton({super.key});

//   void _signInWithGoogle(BuildContext context) async {
//     try {
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser != null) {
//         final GoogleSignInAuthentication googleAuth =
//             await googleUser.authentication;

//         final OAuthCredential credential = GoogleAuthProvider.credential(
//           accessToken: googleAuth.accessToken,
//           idToken: googleAuth.idToken,
//         );

//         final UserCredential userCredential =
//             await FirebaseAuth.instance.signInWithCredential(credential);
//         final User? user = userCredential.user;

//         if (user != null) {
//           print('User signed in with Google: ${user.displayName}');
//           print('User email: ${user.email}');
//           print('User photo URL: ${user.photoURL}');

//           showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//               title: Text('Welcome, ${user.displayName}'),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   CircleAvatar(
//                     backgroundImage: NetworkImage(user.photoURL!),
//                     radius: 50,
//                   ),
//                   const SizedBox(height: 10),
//                   Text(user.email ?? ''),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   child: const Text('Close'),
//                 ),
//               ],
//             ),
//           );
//         }
//       }
//     } catch (error) {
//       print('Google sign-in error: $error');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: OutlinedButton(
//           onPressed: () => _signInWithGoogle(context),
//           child: const Text('Sign in with Google'),
//         ),
//       ),
//     );
//   }
// }


// /* CustomDropdown<String>.multiSelectSearch(
//   hintText = 'Select category',
//   items = stateList!
//       .map((states) => states.toString())
//       .toList(),
//   decoration = CustomDropdownDecoration(
//     expandedBorderRadius: BorderRadius.circular(10),
//     expandedBorder: Border.all(color: Colors.black),
//     closedBorderRadius: BorderRadius.circular(10),
//     closedBorder: Border.all(color: Colors.black),
//     closedSuffixIcon: const Icon(
//       Icons.keyboard_arrow_down_rounded,
//       color: Colors.black,
//     ),
//     expandedSuffixIcon: const Icon(
//       Icons.keyboard_arrow_up_rounded,
//       color: Colors.black,
//     ),
//     hintStyle: const TextStyle(
//       color: Colors.black,
//     ),
//     listItemStyle: const TextStyle(
//       color: Colors.black,
//     ),
//     searchFieldDecoration: const SearchFieldDecoration(
//       textStyle: TextStyle(
//         color: Colors.black,
//       ),
//       hintStyle: TextStyle(
//         color: Colors.black,
//       ),
//     ),
//   ),
//   overlayHeight = 342,
//   onListChanged = (value) {},
// ), */
                      