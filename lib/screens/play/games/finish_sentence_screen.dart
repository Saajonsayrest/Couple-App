import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/game_data.dart';
import '../../../core/app_theme.dart';

class FinishSentenceScreen extends StatefulWidget {
  const FinishSentenceScreen({super.key});

  @override
  State<FinishSentenceScreen> createState() => _FinishSentenceScreenState();
}

class _FinishSentenceScreenState extends State<FinishSentenceScreen> {
  String _sentence = '';

  @override
  void initState() {
    super.initState();
    _loadSentence();
  }

  void _loadSentence() {
    setState(() {
      _sentence = GameData.getRandomSentenceStarter();
    });
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
                    'Finish the Sentence',
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Instructions
                    Text(
                      'Take turns completing this...',
                      style: GoogleFonts.varelaRound(
                        fontSize: 16,
                        color: AppColors.textSub,
                      ),
                    ).animate().fadeIn().slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 32),

                    // Sentence Card
                    Container(
                          key: ValueKey(
                            _sentence,
                          ), // Re-animate when sentence changes
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 60,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Decorative Heart
                              Positioned(
                                top: -85,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(
                                            context,
                                          ).primaryColor.withOpacity(0.2),
                                          blurRadius: 15,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      '✍️',
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                  ),
                                ),
                              ),

                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _sentence,
                                    style: GoogleFonts.caveat(
                                      fontSize: 34,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                      height: 1.2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  Container(
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    '"Say the ending out loud to your partner"',
                                    style: GoogleFonts.varelaRound(
                                      fontSize: 14,
                                      color: Colors.grey.withOpacity(0.5),
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                        .animate(key: ValueKey(_sentence))
                        .fadeIn(duration: 600.ms)
                        .scale(
                          begin: const Offset(0.9, 0.9),
                          curve: Curves.elasticOut,
                        ),

                    const SizedBox(height: 48),

                    // Floating icons decoration
                    Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite,
                              color: Colors.pink.withOpacity(0.2),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.auto_awesome,
                              color: Colors.amber.withOpacity(0.2),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.favorite,
                              color: Colors.pink.withOpacity(0.2),
                              size: 16,
                            ),
                          ],
                        )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.2, 1.2),
                          duration: 2.seconds,
                        ),
                  ],
                ),
              ),
            ),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(40),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _loadSentence,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.refresh_rounded),
                      const SizedBox(width: 12),
                      Text(
                        'NEXT STARTER',
                        style: GoogleFonts.varelaRound(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
