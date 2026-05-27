import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/hydration_service.dart';
import 'theme/app_theme.dart';

class HydraBloomApp extends StatelessWidget {
  const HydraBloomApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<HydrationService>().settings;
    return MaterialApp(
      title: 'HydraBloom',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(
        seedColor: AppTheme.accentFromKey(settings.themeAccent),
      ),
      home: const HomeScreen(),
    );
  }
}
