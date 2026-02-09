import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/app_theme.dart';
import '../../core/constants.dart';
import '../../providers/theme_provider.dart';
import '../../providers/profile_provider.dart';
import '../../services/notification_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Custom Gradient Header
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                bottom: 30,
                left: 24,
                right: 24,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Settings',
                        style: GoogleFonts.varelaRound(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 48), // Spacer
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Icon(
                    Icons.settings_suggest_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ],
              ),
            ),

            // Settings Sections
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Account'),
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Edit Profile',
                    subtitle: 'Change nicknames and photos',
                    onTap: () => context.push('/settings/edit-profile'),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('App Customization'),
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: Icons.palette_outlined,
                    title: 'App Theme',
                    subtitle: 'Choose your favorite colors',
                    onTap: () => _showThemeSelector(context, ref),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Danger Zone'),
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: Icons.delete_forever_rounded,
                    title: 'Reset Data',
                    subtitle: 'Clear all profiles and memories',
                    isDestructive: true,
                    onTap: () => _showResetDialog(context, ref),
                  ),
                  const SizedBox(height: 48),
                  Center(
                    child: FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            'Version ${snapshot.data!.version}',
                            style: GoogleFonts.varelaRound(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSub.withOpacity(0.5),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.varelaRound(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textSub,
        ),
      ),
    );
  }

  void _showThemeSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Theme',
              style: GoogleFonts.varelaRound(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: AppPalettes.palettes.values.map((palette) {
                final isSelected = ref.watch(themeProvider) == palette.id;
                return GestureDetector(
                  onTap: () {
                    ref.read(themeProvider.notifier).setTheme(palette.id);
                    Navigator.pop(context);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: palette.gradient,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: palette.primary.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        palette.name,
                        style: GoogleFonts.varelaRound(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Everything?'),
        content: const Text(
          'This will delete all your profiles, memories, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Use provider to reset (clears Hive + State + Widget)
              await ref.read(profileProvider.notifier).reset();

              // Clear other boxes
              await Hive.box(AppConstants.settingsBox).clear();
              await Hive.box(AppConstants.timelineBox).clear();
              await Hive.box(AppConstants.remindersBox).clear();

              // Clear notifications
              await NotificationService().cancelAllNotifications();

              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                context.go('/onboarding'); // Go to start
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: GoogleFonts.varelaRound(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textMain,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.varelaRound(
            fontSize: 12,
            color: AppColors.textSub,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textSub.withOpacity(0.3),
        ),
      ),
    );
  }
}
