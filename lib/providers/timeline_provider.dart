import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants.dart';
import '../data/models/timeline_event.dart';
import '../services/journey_service.dart';

class TimelineState {
  final List<TimelineEvent> events;
  final bool isLoading;
  final String? error;

  TimelineState({this.events = const [], this.isLoading = false, this.error});

  TimelineState copyWith({
    List<TimelineEvent>? events,
    bool? isLoading,
    String? error,
  }) {
    return TimelineState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TimelineNotifier extends StateNotifier<TimelineState> {
  final JourneyService _journeyService;

  TimelineNotifier(this._journeyService) : super(TimelineState()) {
    loadEvents();
  }

  Future<void> loadEvents() async {
    // 1. Load from Hive first for immediate UI
    final box = Hive.box<TimelineEvent>(AppConstants.timelineBox);
    final localEvents = box.values.toList();

    state = state.copyWith(events: localEvents, isLoading: true);

    // 2. Sync from API
    try {
      final apiJourneys = await _journeyService.getJourneys();
      final List<TimelineEvent> syncedEvents = [];

      for (var data in apiJourneys) {
        syncedEvents.add(
          TimelineEvent(
            id: data['id'].toString(), // Use server ID as local ID or map it
            date: DateTime.parse(data['date']),
            title: data['title'],
            body: data['body'] ?? '',
            isSystemEvent: false,
            serverId: data['id'],
          ),
        );
      }

      // Update Hive cache
      await box.clear();
      for (var event in syncedEvents) {
        await box.add(event);
      }

      state = state.copyWith(events: syncedEvents, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addEvent(TimelineEvent event) async {
    state = state.copyWith(isLoading: true);
    try {
      // 1. Save to API
      final response = await _journeyService.createJourney(event);
      final newEvent = TimelineEvent(
        id: response['id'].toString(),
        date: event.date,
        title: event.title,
        body: event.body,
        isSystemEvent: false,
        serverId: response['id'],
      );

      // 2. Save to Hive
      final box = Hive.box<TimelineEvent>(AppConstants.timelineBox);
      await box.add(newEvent);

      // 3. Update state
      state = state.copyWith(
        events: [newEvent, ...state.events],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateEvent(TimelineEvent event) async {
    if (event.serverId == null) return;

    state = state.copyWith(isLoading: true);
    try {
      // 1. Update API
      await _journeyService.updateJourney(event.serverId!, event);

      // 2. Update Hive
      final box = Hive.box<TimelineEvent>(AppConstants.timelineBox);
      final key = box.keys.firstWhere(
        (k) => box.get(k)?.serverId == event.serverId,
      );
      await box.put(key, event);

      // 3. Update state
      state = state.copyWith(
        events: state.events
            .map((e) => e.serverId == event.serverId ? event : e)
            .toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteEvent(String id, int? serverId) async {
    state = state.copyWith(isLoading: true);
    try {
      // 1. Delete from API if synced
      if (serverId != null) {
        await _journeyService.deleteJourney(serverId);
      }

      // 2. Delete from Hive
      final box = Hive.box<TimelineEvent>(AppConstants.timelineBox);
      final key = box.keys.firstWhere((k) {
        final e = box.get(k);
        if (e == null) return false;
        return e.id == id || (serverId != null && e.serverId == serverId);
      });
      await box.delete(key);

      // 3. Update state
      state = state.copyWith(
        events: state.events
            .where((e) => e.id != id && e.serverId != serverId)
            .toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final timelineProvider = StateNotifierProvider<TimelineNotifier, TimelineState>(
  (ref) {
    final journeyService = ref.watch(journeyServiceProvider);
    return TimelineNotifier(journeyService);
  },
);
