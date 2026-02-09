import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/game_data.dart';

class TruthOrDareScreen extends StatefulWidget {
  const TruthOrDareScreen({super.key});

  @override
  State<TruthOrDareScreen> createState() => _TruthOrDareScreenState();
}

class _TruthOrDareScreenState extends State<TruthOrDareScreen> {
  bool _isFlipped = false;
  String _currentQuestion = "";
  String _type = "";
  String _selectedLevel = 'cute';

  void _spin(String type) {
    setState(() {
      _isFlipped = false;
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _type = type;
        if (type == 'TRUTH') {
          _currentQuestion = GameData.getRandomTruth(_selectedLevel);
        } else {
          _currentQuestion = GameData.getRandomDare(_selectedLevel);
        }
        _isFlipped = true;
      });
    });
  }

  Color _getLevelColor() {
    switch (_selectedLevel) {
      case 'cute':
        return const Color(0xFFFFB7B2);
      case 'fun':
        return const Color(0xFFA0E8AF);
      case 'spicy':
        return const Color(0xFFFF6961);
      case 'extreme':
        return const Color(0xFF9370DB);
      default:
        return const Color(0xFFFFB7B2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Truth or Dare')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Level Selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _LevelButton(
                    label: '😊 Cute',
                    isSelected: _selectedLevel == 'cute',
                    color: const Color(0xFFFFB7B2),
                    onTap: () => setState(() {
                      _selectedLevel = 'cute';
                      _isFlipped = false;
                    }),
                  ),
                  _LevelButton(
                    label: '🎉 Fun',
                    isSelected: _selectedLevel == 'fun',
                    color: const Color(0xFFA0E8AF),
                    onTap: () => setState(() {
                      _selectedLevel = 'fun';
                      _isFlipped = false;
                    }),
                  ),
                  _LevelButton(
                    label: '🔥 Spicy',
                    isSelected: _selectedLevel == 'spicy',
                    color: const Color(0xFFFF6961),
                    onTap: () => setState(() {
                      _selectedLevel = 'spicy';
                      _isFlipped = false;
                    }),
                  ),
                  _LevelButton(
                    label: '💥 Extreme',
                    isSelected: _selectedLevel == 'extreme',
                    color: const Color(0xFF9370DB),
                    onTap: () => setState(() {
                      _selectedLevel = 'extreme';
                      _isFlipped = false;
                    }),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // The Card
            GestureDetector(
              onTap: () {
                if (_isFlipped) setState(() => _isFlipped = false);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOutBack,
                height: 400,
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: _isFlipped ? _getLevelColor() : Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: _isFlipped ? Colors.white : Colors.grey.shade200,
                    width: 4,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isFlipped) ...[
                      Icon(
                        Icons.help_outline_rounded,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Pick Truth or Dare!",
                        style: GoogleFonts.varelaRound(
                          fontSize: 24,
                          color: Colors.grey.shade400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      Text(
                        _type,
                        style: GoogleFonts.blackOpsOne(
                          fontSize: 32,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            child: Text(
                              _currentQuestion,
                              style: GoogleFonts.caveat(
                                fontSize: 28,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ).animate().fadeIn(delay: 300.ms),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _spin('TRUTH'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getLevelColor(),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: const Text("TRUTH"),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _spin('DARE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getLevelColor().withOpacity(0.7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: const Text("DARE"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _LevelButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _LevelButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
