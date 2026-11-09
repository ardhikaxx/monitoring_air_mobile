import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:monitoring_air_mobile/main.dart';
import 'package:monitoring_air_mobile/providers/sensor_provider.dart';
import 'package:monitoring_air_mobile/screens/dashboard_screen.dart';

void main() {
  testWidgets('AquaMonitorApp smoke test', (WidgetTester tester) async {
    final provider = SensorProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const AquaMonitorApp(),
      ),
    );

    // Initial splash frame
    expect(find.text('AquaMonitor'), findsOneWidget);
    expect(find.text('Monitoring Water Treatment System'), findsOneWidget);

    // Advance timer past splash duration (2.4s)
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pump(const Duration(milliseconds: 200));

    // Verify Dashboard screen is now rendered
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Selamat Datang, Administrator'), findsOneWidget);
    expect(find.text('7 Sensor Aktif Terpasang'), findsNothing); // that's on monitoring tab

    // Dispose provider to clean up periodic timer
    provider.dispose();
  });
}
