import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/providers.dart';
import 'screens/home_screen.dart';
import 'services/event_repository.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final events = await EventRepository.open();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      eventRepositoryProvider.overrideWithValue(events),
    ],
  );
  runApp(UncontrolledProviderScope(container: container, child: const PasoonApp()));
  container.read(todayNotificationServiceProvider).sync(container.read(cityProvider));
}

class PasoonApp extends StatelessWidget {
  const PasoonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'پسون',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [Locale('fa', 'IR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeScreen(),
    );
  }
}
