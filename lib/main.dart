import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'services/hydration_service.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const widgetChannel = MethodChannel('hydrabloom/widget');

  final storageService = StorageService();
  final notificationService = NotificationService();
  final hydrationService = HydrationService(
    storageService: storageService,
    notificationService: notificationService,
  );

  await hydrationService.init();
  final pending = await widgetChannel.invokeMethod<int>('consumePendingAddCount') ?? 0;
  for (var i = 0; i < pending; i++) {
    await hydrationService.addGlass();
  }
  await widgetChannel.invokeMethod(
    'syncWidgetCountFromApp',
    hydrationService.todayGlasses,
  );

  runApp(
    ChangeNotifierProvider.value(
      value: hydrationService,
      child: const HydraBloomApp(),
    ),
  );
}
