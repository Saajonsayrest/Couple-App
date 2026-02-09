import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../widgets/couple_card.dart';
import '../../core/app_theme.dart';
import '../../core/constants.dart';
import '../../data/models/user_profile.dart';
import '../../data/game_data.dart';
import '../../data/models/timeline_event.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/reminder.dart';
import '../../services/notification_service.dart';
import '../../widgets/liquid_background.dart';
import 'package:home_widget/home_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read from Hive
    final userBox = Hive.box<UserProfile>(AppConstants.userBox);
    final timelineBox = Hive.box(AppConstants.timelineBox);

    if (userBox.isEmpty) {
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.go('/onboarding'),
            child: const Text('Go to Onboarding'),
          ),
        ),
      );
    }

    final myProfile = userBox.getAt(0);
    final partnerProfile = userBox.getAt(1);

    if (myProfile == null || partnerProfile == null) {
      return const Scaffold(
        body: Center(child: Text('Error loading profiles')),
      );
    }

    final startDate = myProfile.relationshipStartDate ?? DateTime.now();
    final days = DateTime.now().difference(startDate).inDays + 1;
    final name1 = myProfile.nickname.isNotEmpty
        ? myProfile.nickname
        : myProfile.name;
    final name2 = partnerProfile.nickname.isNotEmpty
        ? partnerProfile.nickname
        : partnerProfile.name;

    // Update Home Screen Widget
    _updateWidget(days.toString(), name1, name2);

    final upcomingEvents = _getUpcomingEvents(
      myProfile,
      partnerProfile,
      timelineBox,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Our Space',
          style: GoogleFonts.quicksand(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 6, bottom: 6),
            child: GestureDetector(
              onTap: () => context.push('/settings'),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.settings_rounded,
                  size: 22,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
      body: LiquidBackground(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),

              // Couple Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CoupleCard(
                  name1: myProfile.nickname.isNotEmpty
                      ? myProfile.nickname
                      : myProfile.name,
                  name2: partnerProfile.nickname.isNotEmpty
                      ? partnerProfile.nickname
                      : partnerProfile.name,
                  avatar1: myProfile.avatarPath,
                  avatar2: partnerProfile.avatarPath,
                  startDate: startDate,
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
              ),

              const SizedBox(height: 24),

              // Quote of the Day Section (Signature Style)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      '"',
                      style: GoogleFonts.outfit(
                        fontSize: 48,
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        height: 0.5,
                      ),
                    ),
                    Text(
                      GameData.getRandomQuote(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMain.withOpacity(0.9),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 32),

              // Reminders Section
              _buildRemindersSection(context),

              const SizedBox(height: 24),

              // Special Days Section
              _buildSectionHeader('Days We Love', '❤️'),

              if (upcomingEvents.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      "Your journey is waiting for more memories. ✨",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        color: AppColors.textSub,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              else
                ...upcomingEvents.map((e) => _buildReminderCard(context, e)),

              const SizedBox(height: 120), // Padding for BottomNav
            ],
          ),
        ),
      ),
    );
  }

  void _updateWidget(String days, String name1, String name2) {
    HomeWidget.saveWidgetData<String>('name1', name1);
    HomeWidget.saveWidgetData<String>('name2', name2);
    HomeWidget.saveWidgetData<String>('days', days);
    HomeWidget.updateWidget(name: 'CoupleWidget', androidName: 'CoupleWidget');
  }

  List<_UpcomingEventModel> _getUpcomingEvents(
    UserProfile me,
    UserProfile partner,
    Box timelineBox,
  ) {
    final List<_UpcomingEventModel> list = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 1. Check Timeline Box for manual events
    final userEvents = timelineBox.values
        .map((e) => TimelineEvent.fromMap(Map<dynamic, dynamic>.from(e)))
        .where(
          (e) =>
              !e.isSystemEvent &&
              (e.date.isAfter(today) || e.date.isAtSameMomentAs(today)),
        )
        .toList();

    for (var e in userEvents) {
      list.add(
        _UpcomingEventModel(
          title: e.title,
          date: e.date,
          icon: Icons.calendar_today_rounded,
          color: const Color(0xFFA0D8F1), // Soft Blue
          subtitle: e.body.isNotEmpty
              ? e.body
              : DateFormat('MMM dd, yyyy').format(e.date),
        ),
      );
    }

    // 2. Add Partner Birthday
    final partnerBday = partner.birthday;
    DateTime partnerNextBday = DateTime(
      now.year,
      partnerBday.month,
      partnerBday.day,
    );
    if (partnerNextBday.isBefore(today)) {
      partnerNextBday = DateTime(
        now.year + 1,
        partnerBday.month,
        partnerBday.day,
      );
    }

    final partnerDisplayName = partner.nickname.isNotEmpty
        ? partner.nickname
        : partner.name;
    list.add(
      _UpcomingEventModel(
        title: "$partnerDisplayName's Birthday",
        date: partnerNextBday,
        icon: Icons.celebration_rounded,
        color: AppColors.femaleAccent,
        subtitle: "Don't forget to prepare a surprise! 🎁",
      ),
    );

    // 3. Add My Birthday
    final myBday = me.birthday;
    DateTime myNextBday = DateTime(now.year, myBday.month, myBday.day);
    if (myNextBday.isBefore(today)) {
      myNextBday = DateTime(now.year + 1, myBday.month, myBday.day);
    }

    list.add(
      _UpcomingEventModel(
        title: "My Birthday",
        date: myNextBday,
        icon: Icons.cake_rounded,
        color: AppColors.femaleSecondary,
        subtitle: "Celebrating another wonderful year! ✨",
      ),
    );

    // 4. Add Anniversary
    final relStartDate = me.relationshipStartDate;
    if (relStartDate != null) {
      DateTime nextAnni = DateTime(
        now.year,
        relStartDate.month,
        relStartDate.day,
      );
      if (nextAnni.isBefore(today)) {
        nextAnni = DateTime(now.year + 1, relStartDate.month, relStartDate.day);
      }

      list.add(
        _UpcomingEventModel(
          title: "Our Anniversary",
          date: nextAnni,
          icon: Icons.favorite_rounded,
          color: const Color(0xFFFFB7B2), // Soft Pink
          subtitle: "Cheers to our love story! 🥂",
        ),
      );
    }

    // Sort by date and take next 3
    list.sort((a, b) => a.date.compareTo(b.date));

    return list.take(3).toList();
  }

  Widget _buildSectionHeader(String title, String emoji) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.quicksand(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 8),
          Text(emoji, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context, _UpcomingEventModel event) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final difference = event.date.difference(today).inDays;

    String relativeTime = "";
    if (difference == 0) {
      relativeTime = "Today";
    } else if (difference == 1) {
      relativeTime = "Tomorrow";
    } else {
      relativeTime = "In $difference days";
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: event.color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: event.color.withOpacity(0.12),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: event.color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: event.color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(event.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      event.title,
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textMain,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: event.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        relativeTime,
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: event.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  event.subtitle,
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSub,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildRemindersSection(BuildContext context) {
    final remindersBox = Hive.box(AppConstants.remindersBox);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionHeader('Our Reminders', '🔔'),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  Icons.add_circle_outline_rounded,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                onPressed: () => _showAddReminderDialog(context),
              ),
            ],
          ),
        ),
        ValueListenableBuilder(
          valueListenable: remindersBox.listenable(),
          builder: (context, Box box, _) {
            final reminders = box.values
                .map((e) => Reminder.fromMap(Map<dynamic, dynamic>.from(e)))
                .where((r) => !r.isCompleted)
                .toList();

            reminders.sort((a, b) => a.dateTime.compareTo(b.dateTime));

            if (reminders.isEmpty) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Center(
                  child: Text(
                    "No pending reminders. ☁️",
                    style: GoogleFonts.quicksand(
                      color: AppColors.textSub,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: reminders
                  .map((r) => _buildReminderItem(context, r))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReminderItem(BuildContext context, Reminder reminder) {
    final color = Theme.of(context).primaryColor;
    final isOverdue = reminder.dateTime.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isOverdue
              ? Colors.red.withOpacity(0.1)
              : color.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.check_circle_outline_rounded,
              color: color.withOpacity(0.3),
            ),
            onPressed: () async {
              reminder.isCompleted = true;
              final box = Hive.box(AppConstants.remindersBox);
              final key = box.keys.firstWhere(
                (k) =>
                    Reminder.fromMap(
                      Map<dynamic, dynamic>.from(box.get(k)),
                    ).id ==
                    reminder.id,
              );
              await box.delete(key);
              await NotificationService().cancelReminder(reminder.id);
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textMain,
                  ),
                ),
                Text(
                  DateFormat('MMM dd, hh:mm a').format(reminder.dateTime),
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    color: isOverdue ? Colors.redAccent : AppColors.textSub,
                    fontWeight: isOverdue ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (reminder.isNotificationEnabled)
            Icon(
              Icons.notifications_active_outlined,
              size: 16,
              color: color.withOpacity(0.4),
            ),
        ],
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    final titleController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(hours: 1));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Set a Reminder 🔔',
                  style: GoogleFonts.varelaRound(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'What to remind?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Time: ${DateFormat('MMM dd, hh:mm a').format(selectedDate)}',
                  ),
                  trailing: const Icon(Icons.access_time_rounded),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedDate),
                      );
                      if (time != null) {
                        setModalState(() {
                          selectedDate = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isNotEmpty) {
                      final reminder = Reminder(
                        id: const Uuid().v4(),
                        title: titleController.text,
                        dateTime: selectedDate,
                      );

                      final box = Hive.box(AppConstants.remindersBox);
                      await box.add(reminder.toMap());

                      await NotificationService().scheduleReminder(reminder);

                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text('Save Reminder'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UpcomingEventModel {
  final String title;
  final DateTime date;
  final IconData icon;
  final Color color;
  final String subtitle;

  _UpcomingEventModel({
    required this.title,
    required this.date,
    required this.icon,
    required this.color,
    required this.subtitle,
  });
}
