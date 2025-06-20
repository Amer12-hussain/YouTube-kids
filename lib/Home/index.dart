// import 'package:flutter/material.dart';
// class HomePage extends StatelessWidget {
//   const HomePage({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home'),
//         backgroundColor: Colors.red, // You can change the color
//       ),
//       body: const Center(
//         child: Text(
//           'Welcome to the Home Page!',
//           style: TextStyle(fontSize: 24),
//         ),
//       ),
//     );
//   }
// }
// lib/Home/HomePage.dart
import 'package:flutter/material.dart';
import 'package:youtube_kids/YouTube/index.dart'; // ✅ use correct path based on your project

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('YouTube Kids Shorts')),
      body: const ShortsList(),
    );
  }
}
