import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_kids/YouTube/index.dart'; // adjust path

class AgeSelectionScreen extends StatelessWidget {
  final List<String> ageGroups = ['1-2', '3-4', '5-6', '7-8', '9-10'];
  Future<void> _handleAgeTap(BuildContext context, String ageGroup) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedAgeGroup', ageGroup);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ShortsList()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 127, 127),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 70),
            Text(
              'Choose Your Age Group',
              style: GoogleFonts.balooBhaijaan2(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double itemWidth = (constraints.maxWidth - 40) / 2;
                  return Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: ageGroups.map((age) {
                      return GestureDetector(
                        onTap: () => _handleAgeTap(context, age),
                        child: Container(
                          width: itemWidth,
                          height: itemWidth * 1.1,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(3, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '$age Years',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
