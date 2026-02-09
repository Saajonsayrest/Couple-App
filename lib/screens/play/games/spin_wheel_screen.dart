import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/game_data.dart';

class SpinWheelScreen extends StatefulWidget {
  const SpinWheelScreen({super.key});

  @override
  State<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends State<SpinWheelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _selectedCategory = 'who_pays';
  String _result = '';
  bool _isSpinning = false;
  double _finalAngle = 0;
  int _selectedIndex = 0;

  final Map<String, String> _categories = {
    'who_pays': 'Who Pays? 💰',
    'what_to_eat': 'What to Eat? 🍕',
    'movie_choice': 'Movie Choice 🎬',
    'date_ideas': 'Date Ideas 💕',
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // First determine which option the rose is pointing at
        _determineResult();
        // Then update the UI with the result
        setState(() {
          _isSpinning = false;
        });
      }
    });
  }

  void _spin() {
    if (_isSpinning) return;

    final random = Random();

    // Generate a random final angle (5-7 full rotations plus a random position)
    final fullRotations = 5 + random.nextDouble() * 2;
    final randomAngle = random.nextDouble() * 2 * pi;
    _finalAngle = (fullRotations * 2 * pi) + randomAngle;

    setState(() {
      _isSpinning = true;
      _result = '';
      _selectedIndex = -1;
    });

    _controller.forward(from: 0);
  }

  void _determineResult() {
    final options = GameData.getWheelOptions(_selectedCategory);
    if (options.isEmpty) return;

    // Normalize the final angle to 0-2π range
    final normalizedAngle = _finalAngle % (2 * pi);

    // The rose points at angle: normalizedAngle - pi/2
    // Option i is at angle: (2*pi*i/N) - pi/2
    // So theta matches when i = normalizedAngle / (2*pi/N)
    final anglePerOption = 2 * pi / options.length;

    // Use round() to find the nearest option
    _selectedIndex =
        (normalizedAngle / anglePerOption).round() % options.length;
    _result = options[_selectedIndex];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final options = GameData.getWheelOptions(_selectedCategory);

    return Scaffold(
      appBar: AppBar(title: const Text('Spin the Wheel')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Category Selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: _categories.entries.map((entry) {
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedCategory = entry.key;
                      _result = '';
                      _finalAngle = 0;
                      _selectedIndex = 0;
                      _controller.reset();
                    }),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedCategory == entry.key
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            color: _selectedCategory == entry.key
                                ? Colors.white
                                : Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Options Display
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Options around the wheel
                  ...List.generate(options.length, (index) {
                    final angle = (2 * pi * index / options.length) - pi / 2;
                    final radius = 140.0;
                    final x = radius * cos(angle);
                    final y = radius * sin(angle);

                    return Transform.translate(
                      offset: Offset(x, y),
                      child: Container(
                        width: 100,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                (_result.isNotEmpty &&
                                    _selectedIndex >= 0 &&
                                    index == _selectedIndex)
                                ? Theme.of(context).primaryColor
                                : Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.3),
                            width:
                                (_result.isNotEmpty &&
                                    _selectedIndex >= 0 &&
                                    index == _selectedIndex)
                                ? 3
                                : 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          options[index],
                          style: GoogleFonts.varelaRound(
                            fontSize: 11,
                            fontWeight:
                                (_result.isNotEmpty &&
                                    _selectedIndex >= 0 &&
                                    index == _selectedIndex)
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: Theme.of(context).primaryColor,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }),

                  // Center Circle (base)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.6),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                  ),

                  // Spinning Rose Arrow
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final currentAngle = _controller.value * _finalAngle;
                      return Transform.rotate(
                        angle: currentAngle,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Rose pointing upward
                            const Text('🌹', style: TextStyle(fontSize: 50)),
                            // Stem (thin line)
                            Container(
                              width: 3,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.red.shade400,
                                    Colors.green.shade700,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Result
            if (_result.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '🎉 Result',
                      style: GoogleFonts.varelaRound(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _result,
                      style: GoogleFonts.varelaRound(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Spin Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSpinning ? null : _spin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _isSpinning ? 'SPINNING...' : 'SPIN!',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
