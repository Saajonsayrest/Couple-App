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
  double _baseAngle = 0;
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
    final random = Random();

    setState(() {
      if (_isSpinning) {
        _baseAngle += _controller.value * _finalAngle;
      } else {
        _baseAngle = 0;
      }

      // Generate a random final angle (5-7 full rotations plus a random position)
      final fullRotations = 5 + random.nextDouble() * 2;
      final randomAngle = random.nextDouble() * 2 * pi;
      _finalAngle = (fullRotations * 2 * pi) + randomAngle;

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
    final totalAngle = _baseAngle + _finalAngle;
    final normalizedAngle = totalAngle % (2 * pi);

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
            // Category Selector (Horizontal)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _categories.entries.map((entry) {
                  final isSelected = _selectedCategory == entry.key;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedCategory = entry.key;
                      _result = '';
                      _finalAngle = 0;
                      _baseAngle = 0;
                      _isSpinning = false;
                      _selectedIndex = 0;
                      _controller.reset();
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                        ],
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Responsive Wheel
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wheelSize = min(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  final radius = wheelSize * 0.38;
                  final centerSize = wheelSize * 0.2;
                  final roseSize = wheelSize * 0.12;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Options around the wheel
                      ...List.generate(options.length, (index) {
                        final angle =
                            (2 * pi * index / options.length) - pi / 2;
                        final x = radius * cos(angle);
                        final y = radius * sin(angle);

                        return Transform.translate(
                          offset: Offset(x, y),
                          child: Container(
                            width: 85,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
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
                                    ? 2.5
                                    : 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              options[index],
                              style: GoogleFonts.varelaRound(
                                fontSize: 10,
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

                      // Center Circle
                      Container(
                        width: centerSize,
                        height: centerSize,
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
                              blurRadius: 20,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                      ),

                      // Spinning Rose Arrow
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          final currentAngle =
                              _baseAngle + (_controller.value * _finalAngle);
                          return Transform.rotate(
                            angle: currentAngle,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '🌹',
                                  style: TextStyle(fontSize: roseSize),
                                ),
                                Container(
                                  width: 2,
                                  height: wheelSize * 0.1,
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
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Result
            if (_result.isNotEmpty)
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 500),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, opacity, child) {
                  return Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: 0.8 + (0.2 * opacity),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '🎉 Result',
                              style: GoogleFonts.varelaRound(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _result,
                              style: GoogleFonts.varelaRound(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 24),

            // Spin Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _spin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _isSpinning
                      ? Theme.of(context).primaryColor.withOpacity(0.8)
                      : null,
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
