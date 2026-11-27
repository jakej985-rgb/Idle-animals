import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/game_notifier.dart';
import 'screens/sanctuary_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const ProviderScope(child: ExtinctionSanctuaryApp()));
}

class ExtinctionSanctuaryApp extends ConsumerStatefulWidget {
  const ExtinctionSanctuaryApp({super.key});

  @override
  ConsumerState<ExtinctionSanctuaryApp> createState() =>
      _ExtinctionSanctuaryAppState();
}

class _ExtinctionSanctuaryAppState
    extends ConsumerState<ExtinctionSanctuaryApp> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    // Both hide and pause fire on the way out of the foreground; the notifier
    // treats them idempotently. Same for show and resume.
    _lifecycleListener = AppLifecycleListener(
      onPause: _pauseGame,
      onHide: _pauseGame,
      onResume: _resumeGame,
      onShow: _resumeGame,
    );
  }

  void _pauseGame() {
    unawaited(ref.read(gameProvider.notifier).handleAppPaused());
  }

  void _resumeGame() {
    unawaited(ref.read(gameProvider.notifier).handleAppResumed());
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(gameProvider.notifier);
    return MaterialApp(
      title: 'Extinction Sanctuary',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: buildAppTheme(),
      // The first frame must not present GameState.initial() as the player's
      // progress: until the save has been read, the header would show the wrong
      // numbers and any tap would be discarded when the load replaces the state.
      home: FutureBuilder<void>(
        future: notifier.ready,
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.done
            ? const SanctuaryScreen()
            : const _BootSplash(),
      ),
    );
  }
}

class _BootSplash extends StatelessWidget {
  const _BootSplash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}
