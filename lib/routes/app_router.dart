import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants.dart';
import '../data/models/user_profile.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/timeline/timeline_screen.dart';
import '../screens/play/play_screen.dart';
import '../screens/feelings/feelings_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/edit_profile_screen.dart';
import '../screens/debug/widget_debug_screen.dart';
import '../screens/main_screen.dart';

import '../screens/play/games/truth_or_dare_screen.dart';
import '../screens/play/games/coin_flip_screen.dart';
import '../screens/play/games/spin_wheel_screen.dart';
import '../screens/play/games/love_questions_screen.dart';
import '../screens/play/games/daily_challenge_screen.dart';
import '../screens/play/games/compliment_generator_screen.dart';
import '../screens/play/games/finish_sentence_screen.dart';
import '../screens/play/games/act_it_out_screen.dart';

// Simple check for onboarding (placeholder logic)
// In a real app, check Hive if user exists.
final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final userBox = Hive.box<UserProfile>(AppConstants.userBox);
    final hasUser = userBox.isNotEmpty;
    final isGoingToOnboarding = state.uri.toString() == '/onboarding';

    if (!hasUser && !isGoingToOnboarding) {
      return '/onboarding';
    }

    if (hasUser && isGoingToOnboarding) {
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(path: '/', builder: (context, state) => const MainScreen()),
    GoRoute(
      path: '/timeline',
      builder: (context, state) => const TimelineScreen(),
    ),
    GoRoute(
      path: '/play',
      builder: (context, state) => const PlayScreen(),
      routes: [
        GoRoute(
          path: 'truth-or-dare',
          builder: (context, state) => const TruthOrDareScreen(),
        ),
        GoRoute(
          path: 'coin-flip',
          builder: (context, state) => const CoinFlipScreen(),
        ),
        GoRoute(
          path: 'spin-wheel',
          builder: (context, state) => const SpinWheelScreen(),
        ),
        GoRoute(
          path: 'love-questions',
          builder: (context, state) => const LoveQuestionsScreen(),
        ),
        GoRoute(
          path: 'daily-challenge',
          builder: (context, state) => const DailyChallengeScreen(),
        ),
        GoRoute(
          path: 'compliment-generator',
          builder: (context, state) => const ComplimentGeneratorScreen(),
        ),
        GoRoute(
          path: 'finish-sentence',
          builder: (context, state) => const FinishSentenceScreen(),
        ),
        GoRoute(
          path: 'act-it-out',
          builder: (context, state) => const ActItOutScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/feelings',
      builder: (context, state) => const FeelingsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
      routes: [
        GoRoute(
          path: 'edit-profile',
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: 'widget-debug',
          builder: (context, state) => const WidgetDebugScreen(),
        ),
      ],
    ),
  ],
);
