import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_theme.dart';

class MiniCoupleCard extends StatelessWidget {
  final String? avatar1;
  final String? avatar2;
  final String name1;
  final String name2;
  final DateTime startDate;

  const MiniCoupleCard({
    super.key,
    this.avatar1,
    this.avatar2,
    required this.name1,
    required this.name2,
    required this.startDate,
  });

  @override
  Widget build(BuildContext context) {
    final days = DateTime.now().difference(startDate).inDays + 1;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.08),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          // Left side: Avatars & Names
          Expanded(
            flex: 6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildMiniAvatar(avatar1, name1, theme.primaryColor),
                    const SizedBox(width: 8),
                    _buildMiniAvatar(
                      avatar2,
                      name2,
                      theme.colorScheme.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '$name1 & $name2',
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Connected with love',
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    color: AppColors.textSub,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            width: 1.5,
            height: 60,
            color: theme.primaryColor.withOpacity(0.1),
          ),

          // Right side: Counter
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$days',
                  style: GoogleFonts.quicksand(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: theme.primaryColor,
                    height: 1,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Days',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniAvatar(String? path, String name, Color color) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: path != null
            ? (path.startsWith('http')
                  ? Image.network(path, fit: BoxFit.cover)
                  : Image.file(File(path), fit: BoxFit.cover))
            : Container(
                color: color.withOpacity(0.15),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0] : '?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
