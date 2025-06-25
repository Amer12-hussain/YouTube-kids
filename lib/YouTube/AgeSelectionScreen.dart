import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_kids/YouTube/index.dart'; // adjust path

class AgeSelectionScreen extends StatefulWidget {
  const AgeSelectionScreen({super.key});
  @override
  State<AgeSelectionScreen> createState() => _AgeSelectionScreenState();
}

class _AgeSelectionScreenState extends State<AgeSelectionScreen>
    with TickerProviderStateMixin {
  final List<String> ageGroups = ['1-2', '3-4', '5-6', '7-8', '9-10'];
  late AnimationController _fadeController;
  late Animation<double> _fadeIn;
  late AnimationController _bgController;
  late Animation<Color?> _bgAnimation;
  late Animation<Color?> _titleTextColorAnimation;
  late Animation<Color?> _boxColorAnimation;
  late Animation<Color?> _boxTextColorAnimation;
  late List<AnimationController> _tapControllers;
  late List<Animation<double>> _tapAnimations;
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
    _bgController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    _bgAnimation = ColorTween(
      begin: Colors.pink.shade100,
      end: const Color.fromARGB(255, 68, 55, 135),
    ).animate(_bgController);
    _titleTextColorAnimation = ColorTween(
      begin: Colors.black,
      end: Colors.white,
    ).animate(_bgController);
    _boxColorAnimation = ColorTween(
      begin: Colors.deepPurple.shade700,
      end: Colors.white,
    ).animate(_bgController);
    _boxTextColorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.black,
    ).animate(_bgController);
    _tapControllers = List.generate(
      ageGroups.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 150),
      ),
    );
    _tapAnimations = _tapControllers.map((controller) {
      return Tween<double>(
        begin: 1.0,
        end: 0.9,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _bgController.dispose();
    for (var c in _tapControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _handleAgeTap(String ageGroup, int index) async {
    await _tapControllers[index].forward();
    await _tapControllers[index].reverse();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedAgeGroup', ageGroup);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ShortsList()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgAnimation,
      builder: (context, child) {
        final bgColor = _bgAnimation.value ?? Colors.white;
        return Scaffold(
          backgroundColor: bgColor,
          body: FadeTransition(
            opacity: _fadeIn,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 70),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 500),
                    style: GoogleFonts.balooBhaijaan2(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color:
                          _titleTextColorAnimation.value ?? Colors.deepPurple,
                    ),
                    child: const Text('Choose Your Age Group'),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: GridView.builder(
                      itemCount: ageGroups.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio: 1.1,
                          ),
                      itemBuilder: (context, index) {
                        final age = ageGroups[index];
                        return ScaleTransition(
                          scale: _tapAnimations[index],
                          child: GestureDetector(
                            onTap: () => _handleAgeTap(age, index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                              decoration: BoxDecoration(
                                color:
                                    _boxColorAnimation.value ?? Colors.purple,
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
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 500),
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        _boxTextColorAnimation.value ??
                                        Colors.white,
                                  ),
                                  child: Text('$age Years'),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
