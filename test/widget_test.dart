import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:monitoring_air_mobile/main.dart';
import 'package:monitoring_air_mobile/models/sensor_model.dart';
import 'package:monitoring_air_mobile/models/sensor_reading_model.dart';
import 'package:monitoring_air_mobile/models/sensor_test_result_model.dart';
import 'package:monitoring_air_mobile/models/device_model.dart';
import 'package:monitoring_air_mobile/services/simulation_service.dart';
import 'package:monitoring_air_mobile/providers/sensor_simulation_provider.dart';
import 'package:monitoring_air_mobile/screens/dashboard_screen.dart';

void main() {
  testWidgets('AquaMonitorApp single page dashboard smoke test', (WidgetTester tester) async {
    final provider = SensorSimulationProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const AquaMonitorApp(),
      ),
    );

    // Initial frame
    await tester.pump(const Duration(milliseconds: 100));

    // Verify Single Page Dashboard is rendered with its primary sections
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('AquaMonitor'), findsOneWidget);
    expect(find.text('IoT Water Treatment Monitoring'), findsOneWidget);
    expect(find.text('Total Sensor'), findsOneWidget);
    expect(find.text('Inlet Monitoring'), findsOneWidget);
    expect(find.text('Outlet Monitoring'), findsOneWidget);

    provider.dispose();
  });

  test('SensorSimulationProvider initializes with 7 sensors (4 inlet, 3 outlet)', () {
    final provider = SensorSimulationProvider();

    expect(provider.sensors.length, 7);
    expect(provider.inletSensors.length, 4);
    expect(provider.outletSensors.length, 3);

    // Verify baseline values
    final turbInlet = provider.inletSensors.firstWhere((s) => s.type == SensorType.turbidityInlet);
    final turbOutlet = provider.outletSensors.firstWhere((s) => s.type == SensorType.turbidityOutlet);
    expect(turbInlet.currentValue, 85.0);
    expect(turbOutlet.currentValue, 3.0);

    // Verify water quality comparison metrics
    final quality = provider.waterQualityComparison;
    expect(quality.turbidityReductionPercent, greaterThan(95.0));

    provider.dispose();
  });

  test('Demonstration scenario alters sensor states predictably', () {
    final provider = SensorSimulationProvider();

    // High turbidity scenario
    provider.applyScenario(DemoScenario.highTurbidity);
    final turbInlet = provider.inletSensors.firstWhere((s) => s.type == SensorType.turbidityInlet);
    expect(turbInlet.currentValue, greaterThanOrEqualTo(140.0));
    expect(turbInlet.status, SensorStatus.critical);

    // Sensor offline scenario
    provider.applyScenario(DemoScenario.sensorOffline);
    final offlineSensors = provider.sensors.where((s) => s.status == SensorStatus.offline);
    expect(offlineSensors.isNotEmpty, isTrue);

    // Device offline scenario
    provider.setDeviceStatus(DeviceConnectionStatus.offline);
    expect(provider.device.status, DeviceConnectionStatus.offline);

    // Reset back to normal
    provider.resetScenario();
    expect(provider.currentScenario, DemoScenario.normal);

    provider.dispose();
  });

  test('Sensor test routine executes and returns valid diagnostics', () async {
    final provider = SensorSimulationProvider();
    final sensor = provider.sensors.first;

    final result = await provider.testSensor(sensor.id, (step, progress) {});
    expect(result.sensorId, sensor.id);
    expect(result.latencyMs, greaterThan(0));
    expect(result.voltage, greaterThan(0.0));
    expect(result.status, TestStatus.passed);

    provider.dispose();
  });
}
