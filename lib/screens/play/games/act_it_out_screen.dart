import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/game_data.dart';

class ActItOutScreen extends StatefulWidget {
  const ActItOutScreen({super.key});

  @override
  State<ActItOutScreen> createState() => _ActItOutScreenState();
}

class _ActItOutScreenState extends State<ActItOutScreen> {
  String _prompt = '';
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _loadPrompt();
  }

  void _loadPrompt() {
    setState(() {
      _prompt = GameData.getRandomActingPrompt();
      _revealed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Act It Out')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() => _revealed = true),
              child: Container(
                height: 300,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: _revealed
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: _revealed
                      ? Text(
                          _prompt,
                          style: GoogleFonts.caveat(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('🎭', style: const TextStyle(fontSize: 60)),
                            const SizedBox(height: 16),
                            Text(
                              'Tap to Reveal',
                              style: GoogleFonts.varelaRound(
                                fontSize: 20,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const Spacer(),
            Text(
              'One person acts, the other guesses! 🎬',
              style: GoogleFonts.varelaRound(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loadPrompt,
                child: const Text('NEXT PROMPT'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
