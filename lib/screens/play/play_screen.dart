import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_theme.dart';

class PlayScreen extends StatelessWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play Together'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Couple Games Section
            _buildSectionTitle('🏆 Top Couple Games'),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _GameCard(
                  title: 'Truth or Dare',
                  subtitle: '4 Levels',
                  icon: Icons.tips_and_updates_rounded,
                  color: const Color(0xFFFFB7B2),
                  onTap: () => context.push('/play/truth-or-dare'),
                ),
                _GameCard(
                  title: 'Spin the Wheel',
                  subtitle: 'Decide Together',
                  icon: Icons.explore_rounded,
                  color: const Color(0xFFA0D8F1),
                  onTap: () => context.push('/play/spin-wheel'),
                ),
                _GameCard(
                  title: 'Love Questions',
                  subtitle: 'Deep Connection',
                  icon: Icons.favorite_rounded,
                  color: const Color(0xFFDCD0FF),
                  onTap: () => context.push('/play/love-questions'),
                ),
                _GameCard(
                  title: 'Coin Flip',
                  subtitle: 'Quick Choice',
                  icon: Icons.star_rounded,
                  color: const Color(0xFFFFD700),
                  onTap: () => context.push('/play/coin-flip'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Fun & Connection Section
            _buildSectionTitle('💕 Fun & Connection'),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _GameCard(
                  title: 'Daily Challenge',
                  subtitle: 'Love Tasks',
                  icon: Icons.auto_awesome_rounded,
                  color: const Color(0xFFFFA07A),
                  onTap: () => context.push('/play/daily-challenge'),
                ),
                _GameCard(
                  title: 'Compliments',
                  subtitle: 'Sweet Words',
                  icon: Icons.volunteer_activism_rounded,
                  color: const Color(0xFFA0E8AF),
                  onTap: () => context.push('/play/compliment-generator'),
                ),
                _GameCard(
                  title: 'Finish Sentence',
                  subtitle: 'Complete It',
                  icon: Icons.auto_stories_rounded,
                  color: const Color(0xFFFFDAB9),
                  onTap: () => context.push('/play/finish-sentence'),
                ),
                _GameCard(
                  title: 'Act It Out',
                  subtitle: 'Funny Acting',
                  icon: Icons.theater_comedy_rounded,
                  color: const Color(0xFFB0E0E6),
                  onTap: () => context.push('/play/act-it-out'),
                ),
              ],
            ),
            const SizedBox(height: 120), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.varelaRound(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textMain,
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.varelaRound(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.varelaRound(
                fontSize: 10,
                color: AppColors.textSub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
