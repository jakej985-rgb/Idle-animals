import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  runApp(
    const ProviderScope(
      child: ExtinctionSanctuaryApp(),
    ),
  );
}

class ExtinctionSanctuaryApp extends StatelessWidget {
  const ExtinctionSanctuaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Extinction Sanctuary',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: buildAppTheme(),
      home: const SanctuaryScreen(),
    );
  }
}
