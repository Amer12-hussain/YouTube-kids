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
      await _googleSignIn.signOut(); // Important: force picker
      final account = await _googleSignIn
          .signIn(); // Will show the account list again
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
      backgroundColor: Colors.pink.shade100,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 📺 Top logo
              Image.asset('assets/images/kids.png', height: 300),
              SizedBox(height: 32),
              // 🔴 Title
              Text(
                "Sign in with a parent's account",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 8),
              // 🧠 Subtitle
              Text(
                "Sign in with your own account to set up a profile and get more parental controls.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              ),
              SizedBox(height: 40),
              // 📧 Account Email (if signed in)
              if (_user != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        child: Text(
                          _user!.displayName?[0].toUpperCase() ?? '',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        _user!.email,
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      IconButton(
                        icon: Icon(Icons.logout, color: Colors.red),
                        onPressed: () async {
                          await _googleSignIn.signOut();
                          setState(() {
                            _user = null;
                          });
                        },
                      ),
                    ],
                  ),
                )
              else
                // 👉 Google Sign-in prompt
                GestureDetector(
                  onTap: handleSignIn, // Open Google account picker
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          child: Text(
                            _user?.displayName?[0].toUpperCase() ?? '?',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          _user?.email ?? "Select your account",
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_drop_down, color: Colors.black),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 30),
              Text(
                "Activity in YouTube Kids won’t be added to your watch history",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              SizedBox(height: 40),
              // 🚪 Sign-In Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: handleSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
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
