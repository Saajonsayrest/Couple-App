import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CoupleCard extends StatelessWidget {
  final String name1;
  final String name2;
  final String? avatar1;
  final String? avatar2;
  final DateTime startDate;

  const CoupleCard({
    super.key,
    required this.name1,
    required this.name2,
    this.avatar1,
    this.avatar2,
    required this.startDate,
  });

  @override
  Widget build(BuildContext context) {
    final days = DateTime.now().difference(startDate).inDays + 1;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.1),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        children: [
          // Avatars connected by love
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSweetAvatar(avatar1, name1, theme.primaryColor),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    Icon(
                          Icons.favorite_rounded,
                          color: Colors.redAccent.withOpacity(0.9),
                          size: 28,
                        )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(duration: 1.2.seconds, curve: Curves.easeInOut),
                    const SizedBox(height: 2),
                    Container(
                      width: 32,
                      height: 3,
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
              _buildSweetAvatar(avatar2, name2, theme.colorScheme.secondary),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$name1 & $name2',
            style: GoogleFonts.quicksand(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
              letterSpacing: -0.2,
            ),
          ),

          const SizedBox(height: 16),
          // Short & Sweet Counter
          Column(
            children: [
              Text(
                '$days',
                style: GoogleFonts.quicksand(
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  color: theme.primaryColor,
                  height: 1,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'Days Together',
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSweetAvatar(String? path, String name, Color color) {
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4), // For the white border feel
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: path != null
              ? (path.startsWith('http')
                    ? Image.network(path, fit: BoxFit.cover)
                    : Image.file(File(path), fit: BoxFit.cover))
              : Container(
                  color: color.withOpacity(0.1),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0] : '?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
