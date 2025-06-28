import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:youtube_kids/Home/index.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  GoogleSignInAccount? _user;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Future<void> handleSignIn() async {
    try {
      await _googleSignIn.signOut(); // Force account picker
      final account = await _googleSignIn.signIn();
      if (account != null) {
        setState(() {
          _user = account;
        });
        print("✅ Signed in: ${account.email}");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (error) {
      print("Sign in error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 127, 127),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 📺 Top logo
              Image.asset('assets/images/kids.png', height: 400),
              // const SizedBox(height: 32),
              // 🔴 Title
              const Text(
                "Sign in with a parent's account",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              // 🧠 Subtitle
              // const Text(
              //   "Sign in with your own account to set up a profile and get more parental controls.",
              //   textAlign: TextAlign.center,
              //   style: TextStyle(fontSize: 15, color: Colors.black),
              // ),
              // const SizedBox(height: 60),
              // ℹ️ Info
              // const Text(
              //   "Activity in YouTube Kids won’t be added to your watch history",
              //   textAlign: TextAlign.center,
              //   style: TextStyle(color: Colors.black),
              // ),
              const SizedBox(height: 40),
              // 🚪 Sign-In Button
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: handleSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'SIGN IN',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
