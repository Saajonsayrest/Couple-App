import 'dart:async';
import 'dart:typed_data';

import 'package:couple_app/core/constants.dart';
import 'package:couple_app/screens/reader/book_reader_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

// google_fonts cannot download in tests and reports that as an async error.
// Swallow only those so real errors (overflow included) still fail the test.
Future<void> _ignoringFontErrors(Future<void> Function() body) {
  final done = Completer<void>();
  runZonedGuarded(
    () async {
      await body();
      if (!done.isCompleted) done.complete();
    },
    (error, stack) {
      final message = '$error';
      if (message.contains('font') || message.contains('Font')) return;
      if (!done.isCompleted) done.completeError(error, stack);
    },
  );
  return done.future;
}

Future<void> _setScreen(
  WidgetTester tester, {
  required Size size,
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

Future<void> _pumpReader(
  WidgetTester tester, {
  bool pushed = false,
  ValueChanged<bool>? onFullscreenChanged,
}) async {
  if (!pushed) {
    await tester.pumpWidget(
      MaterialApp(
        home: BookReaderScreen(
          isEmbeddedTab: true,
          onFullscreenChanged: onFullscreenChanged,
        ),
      ),
    );
  } else {
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(navigatorKey: navigatorKey, home: const Scaffold()),
    );
    navigatorKey.currentState!.push(
      MaterialPageRoute(builder: (_) => const BookReaderScreen()),
    );
  }
  await tester.pumpAndSettle();
}

void main() {
  late Box settingsBox;

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    // In-memory box: nothing touches disk.
    settingsBox = await Hive.openBox(
      AppConstants.settingsBox,
      bytes: Uint8List(0),
    );
  });

  setUp(() async {
    await settingsBox.clear();
  });

  const screens = {
    'small phone 320x568': Size(320, 568),
    'phone 360x640': Size(360, 640),
    'large phone 412x915': Size(412, 915),
    'tablet 800x1280': Size(800, 1280),
  };

  for (final entry in screens.entries) {
    for (final textScale in [1.0, 1.3, 2.0]) {
      for (final pushed in [false, true]) {
        final label =
            '${entry.key}, text x$textScale, ${pushed ? 'pushed' : 'tab'}';

        testWidgets('no overflow: $label', (tester) async {
          await _ignoringFontErrors(() async {
            await _setScreen(tester, size: entry.value, textScale: textScale);
            await _pumpReader(tester, pushed: pushed);
            expect(tester.takeException(), isNull);

            // Eye comfort sheet
            await tester.tap(find.byTooltip('Eye comfort'));
            await tester.pumpAndSettle();
            expect(find.text('Reading Peace & Eye Comfort'), findsOneWidget);
            expect(tester.takeException(), isNull);
            // At big text scales the sheet covers the barrier, so close it
            // directly.
            Navigator.of(
              tester.element(find.text('Reading Peace & Eye Comfort')),
            ).pop();
            await tester.pumpAndSettle();

            // Jump sheet
            await tester.tap(find.textContaining('Page 1 of 224'));
            await tester.pumpAndSettle();
            expect(find.text('Jump to Page'), findsOneWidget);
            expect(tester.takeException(), isNull);
          });
        });
      }
    }
  }

  testWidgets('fullscreen hides controls and back restores them', (
    tester,
  ) async {
    await _ignoringFontErrors(() async {
      final events = <bool>[];
      await _setScreen(tester, size: const Size(412, 915));
      await _pumpReader(tester, onFullscreenChanged: events.add);

      await tester.tap(find.byTooltip('Fullscreen'));
      await tester.pumpAndSettle();
      expect(events, [true]);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(events, [true, false]);
    });
  });

  testWidgets('fullscreen stays one page at a time; edge taps turn pages', (
    tester,
  ) async {
    await _ignoringFontErrors(() async {
      await _setScreen(tester, size: const Size(412, 915));
      await settingsBox.put(BookReaderKeys.currentPage, 40);
      await _pumpReader(tester);

      await tester.tap(find.byTooltip('Fullscreen'));
      await tester.pumpAndSettle();
      expect(find.byType(PageView), findsOneWidget);
      expect(find.byType(ListView), findsNothing);

      await tester.tapAt(const Offset(400, 450)); // right edge
      await tester.pumpAndSettle();
      expect(settingsBox.get(BookReaderKeys.currentPage), 41);

      await tester.tapAt(const Offset(12, 450)); // left edge
      await tester.pumpAndSettle();
      expect(settingsBox.get(BookReaderKeys.currentPage), 40);
    });
  });

  testWidgets('text size is saved, carried into fullscreen, hidden there', (
    tester,
  ) async {
    await _ignoringFontErrors(() async {
      await _setScreen(tester, size: const Size(412, 915));
      await _pumpReader(tester);

      await tester.tap(find.byTooltip('Bigger text'));
      await tester.tap(find.byTooltip('Bigger text'));
      await tester.pumpAndSettle();
      expect(settingsBox.get(BookReaderKeys.zoomLevel), closeTo(1.2, 0.001));
      expect(find.text('120%'), findsOneWidget);

      await tester.tap(find.byTooltip('Fullscreen'));
      await tester.pumpAndSettle();
      // Slider is not reachable in fullscreen...
      expect(find.byTooltip('Bigger text').hitTestable(), findsNothing);
      // ...but the page is still shown at 120%.
      final viewer = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer).first,
      );
      expect(
        viewer.transformationController!.value.getMaxScaleOnAxis(),
        closeTo(1.2, 0.001),
      );

      // A fresh reader opens at the saved size too.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      await _pumpReader(tester);
      expect(find.text('120%'), findsOneWidget);
    });
  });

  testWidgets('mode choice is saved', (tester) async {
    await _ignoringFontErrors(() async {
      await _setScreen(tester, size: const Size(412, 915));
      await _pumpReader(tester);

      await tester.tap(find.byTooltip('B/W Peace'));
      await tester.pumpAndSettle();
      expect(
        settingsBox.get(BookReaderKeys.visualMode),
        ReaderVisualMode.bw.name,
      );
    });
  });

  testWidgets('first open starts at the cover', (tester) async {
    await _ignoringFontErrors(() async {
      await _setScreen(tester, size: const Size(412, 915));
      await _pumpReader(tester);
      expect(find.textContaining('Page 1 of 224'), findsOneWidget);
    });
  });

  testWidgets('reopens exactly where reading stopped', (tester) async {
    await _ignoringFontErrors(() async {
      await _setScreen(tester, size: const Size(412, 915));
      await _pumpReader(tester);

      // Turn a page, then close the reader and open a fresh one.
      await tester.tap(find.byTooltip('Next page'));
      await tester.pumpAndSettle();
      expect(settingsBox.get(BookReaderKeys.currentPage), 2);

      await tester.pumpWidget(const SizedBox());
      await _pumpReader(tester);
      expect(find.textContaining('Page 2 of 224'), findsOneWidget);
    });
  });

  testWidgets('follows a page saved by another reader instance', (
    tester,
  ) async {
    await _ignoringFontErrors(() async {
      await _setScreen(tester, size: const Size(412, 915));
      await _pumpReader(tester);
      expect(find.textContaining('Page 1 of 224'), findsOneWidget);

      await settingsBox.put(BookReaderKeys.currentPage, 10);
      await tester.pumpAndSettle();
      expect(find.textContaining('Page 10 of 224'), findsOneWidget);
    });
  });
}
