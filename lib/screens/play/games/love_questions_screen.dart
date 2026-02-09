import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/game_data.dart';

class LoveQuestionsScreen extends StatefulWidget {
  const LoveQuestionsScreen({super.key});

  @override
  State<LoveQuestionsScreen> createState() => _LoveQuestionsScreenState();
}

class _LoveQuestionsScreenState extends State<LoveQuestionsScreen> {
  String _currentQuestion = '';
  bool _showQuestion = false;

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  void _loadQuestion() {
    setState(() {
      _showQuestion = false;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _currentQuestion = GameData.getRandomLoveQuestion();
        _showQuestion = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Love Questions')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Theme.of(context).primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              // Question Card
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      size: 60,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 24),
                    if (_showQuestion)
                      Text(
                        _currentQuestion,
                        style: GoogleFonts.caveat(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 600.ms).scale(),
                    if (!_showQuestion)
                      const SizedBox(
                        height: 100,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
              ),
              const Spacer(),
              // Hint Text
              Text(
                'Take turns answering honestly 💕',
                style: GoogleFonts.varelaRound(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              // Next Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loadQuestion,
                  child: const Text('NEXT QUESTION'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
