import 'package:extinction_sanctuary/core/save/save_codec.dart';
import 'package:extinction_sanctuary/models/game_state.dart';
import 'package:extinction_sanctuary/providers/game_notifier.dart';
import 'package:extinction_sanctuary/theme/app_theme.dart';
import 'package:extinction_sanctuary/widgets/save_transfer_dialog.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pumps the dialog over a real container, so copy and restore exercise the
/// notifier rather than a stand-in. The tall viewport keeps the bottom of the
/// dialog on screen.
Future<ProviderContainer> _pumpDialog(WidgetTester tester) async {
  tester.view.physicalSize = const Size(500, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  final container = ProviderContainer();
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: buildAppTheme(),
        // Opened the way the operations sheet opens it, so the dialog owns its
        // own route and can close itself.
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const SaveTransferDialog(),
                ),
                child: const Text('Open save data'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  // Let the first load settle, then open the dialog.
  await tester.pump();
  await tester.tap(find.text('Open save data'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  return container;
}

/// Tears the tree down before the container, so the notifier's timers are
/// cancelled inside the test instead of tripping the pending-timer check.
Future<void> _disposeDialog(
  WidgetTester tester,
  ProviderContainer container,
) async {
  await tester.pumpWidget(const SizedBox());
  container.dispose();
}

void main() {
  testWidgets('copies the current save as a token', (tester) async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          calls.add(call);
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    final container = await _pumpDialog(tester);
    final token = SaveCodec.encode(container.read(gameProvider));

    await tester.tap(find.widgetWithText(OutlinedButton, 'Copy backup'));
    await tester.pump();

    final copy = calls.lastWhere((call) => call.method == 'Clipboard.setData');
    expect((copy.arguments as Map)['text'], equals(token));
    // The button reports success without a snackbar over the dialog.
    expect(find.text('Copied'), findsOneWidget);

    await _disposeDialog(tester, container);
  });

  testWidgets('rejects a paste that is not a save and keeps the game', (
    tester,
  ) async {
    final container = await _pumpDialog(tester);
    final creditsBefore = container.read(gameProvider).credits;

    await tester.enterText(find.byType(TextField), 'not a save');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Restore'));
    await tester.pump();

    expect(
      find.text('That is not a complete Extinction Sanctuary backup.'),
      findsOneWidget,
    );
    expect(find.byType(SaveTransferDialog), findsOneWidget);
    expect(container.read(gameProvider).credits, equals(creditsBefore));

    await _disposeDialog(tester, container);
  });

  testWidgets('restores a pasted save and closes the dialog', (tester) async {
    final container = await _pumpDialog(tester);
    final token = SaveCodec.encode(
      GameState.initial().copyWith(credits: 4321.0, dna: 33.0),
    );

    await tester.enterText(find.byType(TextField), token);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Restore'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(container.read(gameProvider).credits, equals(4321.0));
    expect(container.read(gameProvider).dna, equals(33.0));
    expect(find.byType(SaveTransferDialog), findsNothing);

    // The restored progress is what a relaunch would read back. The write is
    // queued behind a real platform-channel call, so it needs real async.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('extinction_sanctuary_save_v2'), contains('4321'));

    await _disposeDialog(tester, container);
  });
}
