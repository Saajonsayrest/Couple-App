import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/app_theme.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/timeline_event.dart';
import '../../data/models/reminder.dart';
import '../../providers/profile_provider.dart';
import '../../providers/timeline_provider.dart';
import '../../providers/reminder_provider.dart';

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  @override
  void initState() {
    super.initState();
  }

  List<TimelineEvent> _processEvents(
    UserProfile me,
    UserProfile partner,
    List<TimelineEvent> userEvents,
    List<Reminder> reminders,
  ) {
    List<TimelineEvent> events = [];

    // 1. User Created Events (from provider)
    events.addAll(userEvents);

    // 2. System Events
    final startDate = me.relationshipStartDate ?? DateTime.now();

    events.add(
      TimelineEvent(
        id: 'system_start',
        date: startDate,
        title: 'Our Journey Began ❤️',
        body: 'The day we officially started our beautiful story together.',
        isSystemEvent: true,
      ),
    );

    final now = DateTime.now();
    int years = now.year - startDate.year;
    final partnerName = partner.nickname.isNotEmpty
        ? partner.nickname
        : partner.name;

    for (int i = 0; i <= years; i++) {
      final year = startDate.year + i;
      if (i > 0) {
        final anniDate = DateTime(
          startDate.year + i,
          startDate.month,
          startDate.day,
        );
        if (anniDate.isBefore(now) || anniDate.isAtSameMomentAs(now)) {
          events.add(
            TimelineEvent(
              id: 'system_anni_$i',
              date: anniDate,
              title: '$i Year Anniversary 🥂',
              body: 'Another amazing year of love and happiness together!',
              isSystemEvent: true,
            ),
          );
        }
      }

      final myBday = me.birthday;
      final myYearBday = DateTime(year, myBday.month, myBday.day);
      if (myYearBday.isAfter(startDate) &&
          (myYearBday.isBefore(now) || myYearBday.isAtSameMomentAs(now))) {
        events.add(
          TimelineEvent(
            id: 'system_bday_me_$year',
            date: myYearBday,
            title: "My Birthday 🎂",
            body: "Celebrating the day I was born!",
            isSystemEvent: true,
          ),
        );
      }

      final partnerBday = partner.birthday;
      final partnerYearBday = DateTime(
        year,
        partnerBday.month,
        partnerBday.day,
      );
      if (partnerYearBday.isAfter(startDate) &&
          (partnerYearBday.isBefore(now) ||
              partnerYearBday.isAtSameMomentAs(now))) {
        events.add(
          TimelineEvent(
            id: 'system_bday_partner_$year',
            date: partnerYearBday,
            title: "$partnerName's Birthday 🎂",
            body: "The day my favorite person was born!",
            isSystemEvent: true,
          ),
        );
      }
    }

    // 3. User Reminders (from provider)
    final timelineReminders = reminders
        .where((r) => !r.isCompleted)
        .map(
          (r) => TimelineEvent(
            id: 'reminder_${r.id}',
            date: r.dateTime,
            title: r.title,
            body: 'Scheduled Reminder 🔔',
            isSystemEvent: false,
          ),
        )
        .toList();
    events.addAll(timelineReminders);

    // Sort, Unique, Sort
    final Map<String, TimelineEvent> uniqueEvents = {};
    for (var event in events) {
      uniqueEvents[event.id] = event;
    }

    return uniqueEvents.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void _showEventEditor({TimelineEvent? eventToEdit}) {
    final titleController = TextEditingController(text: eventToEdit?.title);
    final bodyController = TextEditingController(text: eventToEdit?.body);
    DateTime selectedDate = eventToEdit?.date ?? DateTime.now();

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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    eventToEdit == null
                        ? 'Capture a Memory 📸'
                        : 'Update Memory 📝',
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
                      labelText: 'Title',
                      hintText: 'What happened?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: bodyController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Body',
                      hintText: 'Tell the story...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Date: ${DateFormat('MMM dd, yyyy').format(selectedDate)}',
                    ),
                    trailing: const Icon(Icons.calendar_today_rounded),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setModalState(() => selectedDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty) {
                        if (eventToEdit == null) {
                          final newEvent = TimelineEvent(
                            id: const Uuid().v4(),
                            date: selectedDate,
                            title: titleController.text,
                            body: bodyController.text,
                          );
                          ref
                              .read(timelineProvider.notifier)
                              .addEvent(newEvent);
                        } else {
                          final updatedEvent = TimelineEvent(
                            id: eventToEdit.id,
                            date: selectedDate,
                            title: titleController.text,
                            body: bodyController.text,
                            serverId: eventToEdit.serverId,
                          );
                          ref
                              .read(timelineProvider.notifier)
                              .updateEvent(updatedEvent);
                        }
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
                    child: Text(
                      eventToEdit == null ? 'Save Memory' : 'Update Memory',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _deleteEvent(TimelineEvent event) async {
    if (event.id.startsWith('reminder_')) {
      final actualId = event.id.replaceFirst('reminder_', '');
      ref.read(reminderProvider.notifier).deleteReminder(actualId, null);
      return;
    }

    ref.read(timelineProvider.notifier).deleteEvent(event.id, event.serverId);
  }

  void _showReminderEditor(String reminderId) {
    final reminders = ref.read(reminderProvider).reminders;
    final reminder = reminders.firstWhere((r) => r.id == reminderId);

    final titleController = TextEditingController(text: reminder.title);
    DateTime selectedDate = reminder.dateTime;

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
                  'Edit Reminder 🔔',
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
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 30),
                      ),
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
                      reminder.title = titleController.text;
                      reminder.dateTime = selectedDate;

                      ref
                          .read(reminderProvider.notifier)
                          .updateReminder(reminder);

                      if (context.mounted) Navigator.pop(context);
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
                  child: const Text('Update Reminder'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(TimelineEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Memory?', style: GoogleFonts.varelaRound()),
        content: const Text('Are you sure you want to remove this memory?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSub)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEvent(event);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(profileProvider);
    if (profiles.isEmpty) {
      return const Scaffold(body: Center(child: Text('No profiles found')));
    }
    final me = profiles[0];
    final partner = profiles[1];

    final timelineState = ref.watch(timelineProvider);
    final reminderState = ref.watch(reminderProvider);

    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 48),
                Text(
                  'Our Journey',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildTimelineHeaderActions(context),
              ],
            ),
          ),
        ),
        Expanded(
          child: Builder(
            builder: (context) {
              final events = _processEvents(
                me,
                partner,
                timelineState.events,
                reminderState.reminders,
              );
              if (events.isEmpty) {
                return _buildEmptyTimeline();
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await ref.read(timelineProvider.notifier).loadEvents();
                  await ref.read(reminderProvider.notifier).loadReminders();
                },
                child: ListView.builder(
                  padding: EdgeInsets.only(
                    left: 12,
                    right: 12,
                    top: 24,
                    bottom: MediaQuery.of(context).padding.bottom + 120,
                  ),
                  itemCount: events.length,
                  cacheExtent: 1000,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final daysSince = event.date
                        .difference(me.relationshipStartDate ?? DateTime.now())
                        .inDays;
                    final isEventLeft = index % 2 == 0;

                    return _TimelineItem(
                          event: event,
                          dayCount: daysSince >= 0 ? daysSince + 1 : null,
                          isLeft: isEventLeft,
                          isFirst: index == 0,
                          isLast: index == events.length - 1,
                          color: Theme.of(context).primaryColor,
                          onDelete: event.isSystemEvent
                              ? null
                              : () => _confirmDelete(event),
                          onEdit: event.isSystemEvent
                              ? null
                              : () {
                                  if (event.id.startsWith('reminder_')) {
                                    _showReminderEditor(
                                      event.id.replaceFirst('reminder_', ''),
                                    );
                                  } else {
                                    _showEventEditor(eventToEdit: event);
                                  }
                                },
                        )
                        .animate()
                        .fadeIn(delay: (50 * index).clamp(0, 400).ms)
                        .slideY(
                          begin: 0.1,
                          end: 0,
                          duration: 400.ms,
                          curve: Curves.easeOutCubic,
                        );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineHeaderActions(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.add_rounded, size: 26, color: Colors.white),
        onPressed: () => _showEventEditor(),
      ),
    );
  }

  Widget _buildEmptyTimeline() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_stories_rounded,
            size: 64,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Our story starts here...',
            style: GoogleFonts.outfit(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final TimelineEvent event;
  final int? dayCount;
  final bool isLeft;
  final bool isFirst;
  final bool isLast;
  final Color color;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const _TimelineItem({
    required this.event,
    this.dayCount,
    required this.isLeft,
    required this.isFirst,
    required this.isLast,
    required this.color,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              width: 24,
              child: Column(
                children: [
                  Container(
                    width: 2,
                    height: 24,
                    color: isFirst
                        ? Colors.transparent
                        : color.withOpacity(0.2),
                  ),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(color: color.withOpacity(0.4), blurRadius: 8),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isLast
                          ? Colors.transparent
                          : color.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: isLeft
                    ? _ContentCard(
                        event: event,
                        dayCount: dayCount,
                        color: color,
                        onDelete: onDelete,
                        onEdit: onEdit,
                      )
                    : const SizedBox(),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: !isLeft
                    ? _ContentCard(
                        event: event,
                        dayCount: dayCount,
                        color: color,
                        onDelete: onDelete,
                        onEdit: onEdit,
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContentCard extends StatelessWidget {
  final TimelineEvent event;
  final int? dayCount;
  final Color color;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const _ContentCard({
    required this.event,
    this.dayCount,
    required this.color,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onDelete,
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    DateFormat('MMM dd, yyyy').format(event.date),
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSub,
                    ),
                  ),
                ),
                if (dayCount != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Day $dayCount',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              event.title,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
                height: 1.2,
              ),
            ),
            if (event.body.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                event.body,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: AppColors.textSub,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
