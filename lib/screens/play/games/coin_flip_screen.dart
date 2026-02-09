import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/app_theme.dart';

class CoinFlipScreen extends StatefulWidget {
  const CoinFlipScreen({super.key});

  @override
  State<CoinFlipScreen> createState() => _CoinFlipScreenState();
}

class _CoinFlipScreenState extends State<CoinFlipScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHeads = true;
  bool _isSpinning = false;

  // Custom text for heads and tails (removed unused variables to fix lint)

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
          _isHeads = Random().nextBool();
        });
        _controller.reset();
      }
    });
  }

  void _flipCoin() {
    if (_isSpinning) return;
    setState(() {
      _isSpinning = true;
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            // Custom Header
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                bottom: 20,
                left: 20,
                right: 20,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    'HEADS OR TAILS?',
                    style: GoogleFonts.varelaRound(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48), // Balance
                ],
              ),
            ),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Instruction
                  Text(
                    _isSpinning
                        ? 'Waiting for destiny...'
                        : 'Ready for a flip? ✨',
                    style: GoogleFonts.varelaRound(
                      fontSize: 18,
                      color: AppColors.textSub,
                    ),
                  ).animate(target: _isSpinning ? 1 : 0).fadeOut(),

                  const SizedBox(height: 40),

                  // The Coin
                  GestureDetector(
                    onTap: _flipCoin,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Floating hearts when spinning
                        if (_isSpinning)
                          ...List.generate(6, (index) {
                            return Icon(
                                  Icons.favorite_rounded,
                                  color: Colors.pink.withOpacity(0.4),
                                  size: 20 + (index * 4).toDouble(),
                                )
                                .animate(
                                  onPlay: (controller) => controller.repeat(),
                                )
                                .moveY(
                                  begin: 0,
                                  end: -200 - (index * 20),
                                  duration: 1.5.seconds + (index * 200).ms,
                                )
                                .fade(begin: 0.8, end: 0)
                                .slideX(
                                  begin: 0,
                                  end: (index % 2 == 0 ? 0.3 : -0.3),
                                );
                          }),

                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            final rotationValue = _controller.value * 8 * pi;
                            final translateY =
                                sin(_controller.value * pi) * -150.0;

                            return Transform(
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..translate(0.0, translateY)
                                ..rotateX(rotationValue),
                              alignment: Alignment.center,
                              child: _buildToken(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Result Section
                  if (!_isSpinning)
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _isHeads
                                    ? 'It\'s HEADS! 🪙'
                                    : 'It\'s TAILS! 🪙',
                                style: GoogleFonts.varelaRound(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn().scale(curve: Curves.elasticOut),
                        const SizedBox(height: 16),
                        Text(
                          _isHeads
                              ? "Destiny has spoken: Heads!"
                              : "Fate has decided: Tails!",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.varelaRound(
                            fontSize: 16,
                            color: AppColors.textSub,
                            fontStyle: FontStyle.italic,
                          ),
                        ).animate().fadeIn(delay: 400.ms),
                        const SizedBox(height: 24),
                        Text(
                          'Tap the coin to toss again',
                          style: GoogleFonts.varelaRound(
                            fontSize: 14,
                            color: Colors.grey.withOpacity(0.6),
                          ),
                        ).animate().fadeIn(delay: 1.seconds),
                      ],
                    ),
                ],
              ),
            ),

            // Decisions help
            if (!_isSpinning)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  "Deciding who picks the movie? 🎥\nLet the flip settle it!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.varelaRound(
                    fontSize: 13,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ),
              ).animate().fadeIn(delay: 1.5.seconds),

            // Flip Button at bottom
            Padding(
              padding: const EdgeInsets.all(40),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child:
                    ElevatedButton(
                          onPressed: _isSpinning ? null : _flipCoin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            _isSpinning ? 'TOSSING...' : 'TOSS COIN',
                            style: GoogleFonts.varelaRound(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                        .animate(target: _isSpinning ? 1 : 0)
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(0.95, 0.95),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToken() {
    final bool showingHeads = _isSpinning
        ? (_controller.value * 8).floor() % 2 == 0
        : _isHeads;

    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: showingHeads
              ? const Color(0xFFFFD700)
              : const Color(0xFFC0C0C0),
          width: 8,
        ),
        boxShadow: [
          BoxShadow(
            color:
                (showingHeads
                        ? const Color(0xFFFFD700)
                        : const Color(0xFFC0C0C0))
                    .withOpacity(0.3),
            blurRadius: 25,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: showingHeads
                      ? [const Color(0xFFFFD700).withOpacity(0.2), Colors.white]
                      : [
                          const Color(0xFFC0C0C0).withOpacity(0.2),
                          Colors.white,
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              showingHeads ? 'H' : 'T',
              style: GoogleFonts.varelaRound(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: showingHeads
                    ? const Color(0xFFB8860B)
                    : Colors.grey.shade700,
              ),
            ),
          ),
          Positioned(
            top: 25,
            right: 25,
            child: Icon(
              Icons.favorite_rounded,
              color:
                  (showingHeads
                          ? const Color(0xFFFFD700)
                          : const Color(0xFFC0C0C0))
                      .withOpacity(0.5),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
