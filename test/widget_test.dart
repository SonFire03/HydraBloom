import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:hydra_bloom/app.dart';
import 'package:hydra_bloom/services/hydration_service.dart';
import 'package:hydra_bloom/services/notification_service.dart';
import 'package:hydra_bloom/services/storage_service.dart';

void main() {
  testWidgets('HydraBloom app smoke test', (WidgetTester tester) async {
    final hydrationService = HydrationService(
      storageService: StorageService(),
      notificationService: NotificationService(),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: hydrationService,
        child: const HydraBloomApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('HydraBloom'), findsOneWidget);
    expect(find.text('Accueil'), findsOneWidget);
  });
}
