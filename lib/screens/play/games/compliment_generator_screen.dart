import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/game_data.dart';

class ComplimentGeneratorScreen extends StatefulWidget {
  const ComplimentGeneratorScreen({super.key});

  @override
  State<ComplimentGeneratorScreen> createState() =>
      _ComplimentGeneratorScreenState();
}

class _ComplimentGeneratorScreenState extends State<ComplimentGeneratorScreen> {
  String _compliment = '';

  @override
  void initState() {
    super.initState();
    _generateCompliment();
  }

  void _generateCompliment() {
    setState(() {
      _compliment = GameData.getRandomCompliment();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compliment Generator')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.2),
              Theme.of(context).primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
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
                    Text('💌', style: const TextStyle(fontSize: 60)),
                    const SizedBox(height: 24),
                    Text(
                      _compliment,
                      style: GoogleFonts.caveat(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Share this with your partner 💕',
                style: GoogleFonts.varelaRound(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _generateCompliment,
                  child: const Text('GENERATE NEW'),
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
