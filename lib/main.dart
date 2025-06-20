import 'package:flutter/material.dart';
import 'Signin/index.dart'; // 👈 Import your SignIn screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'YouTube Kids Clone',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.deepPurple[50],
      ),
      home: SignInPage(), // 👈 Set your custom sign-in page here
    );
  }
}
