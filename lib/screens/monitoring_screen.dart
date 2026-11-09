import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/sensor_model.dart';
import '../providers/sensor_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/sensor_monitoring_card.dart';
import 'inlet_monitoring_screen.dart';
import 'outlet_monitoring_screen.dart';

class MonitoringScreen extends StatefulWidget {
  final int initialTabIndex;

  const MonitoringScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SensorProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final inletSensors = provider.inletSensors;
    final outletSensors = provider.outletSensors;

    // Find inlet values for comparison with outlet
    final turbInletVal = provider.getSensorById('SEN-IN-TURB')?.currentValue ?? 85.0;
    final phInletVal = provider.getSensorById('SEN-IN-PH')?.currentValue ?? 6.3;
    final tempInletVal = provider.getSensorById('SEN-IN-TEMP')?.currentValue ?? 27.0;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Monitoring Sensor',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Perbarui Data Sensor',
            onPressed: () async {
              await provider.refreshAllSensors();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data seluruh sensor diperbarui.'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Subheader: Active sensors & Tab Bar
          Container(
            color: isDark ? AppColors.darkCard : Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.sensors_rounded, size: 16, color: AppColors.techBlue),
                        const SizedBox(width: 6),
                        Text(
                          '7 Sensor Aktif Terpasang',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.navyBlue,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Interval: ${provider.updateInterval}s',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Material 3 Styled TabBar
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.techBlue,
                  indicatorWeight: 3,
                  labelColor: AppColors.techBlue,
                  unselectedLabelColor: AppColors.textMuted,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.input_rounded, size: 16),
                          const SizedBox(width: 8),
                          Text('Jalur Inlet (${inletSensors.length})'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.output_rounded, size: 16),
                          const SizedBox(width: 8),
                          Text('Jalur Outlet (${outletSensors.length})'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tab Bar Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: INLET (4 Sensor)
                _buildInletTab(context, inletSensors, isDark),

                // TAB 2: OUTLET (3 Sensor)
                _buildOutletTab(
                  context,
                  outletSensors,
                  isDark,
                  turbInletVal,
                  phInletVal,
                  tempInletVal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInletTab(
    BuildContext context,
    List<SensorModel> inletSensors,
    bool isDark,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        // Informational banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.rawWater.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.rawWater.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.water_rounded, color: AppColors.rawWater, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Monitoring Air Baku (Jalur Inlet)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.rawWater,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Memantau kondisi fisik & kimia air sungai sebelum memasuki tahapan sedimentasi dan filtrasi multimedia.',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textMuted : AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Dedicated pipe visualization button
        OutlinedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InletMonitoringScreen()),
            );
          },
          icon: const Icon(Icons.linear_scale_rounded, size: 16),
          label: const Text('Buka Halaman Visual Diagram Jalur Pipa Inlet'),
        ),

        const SizedBox(height: 14),

        // 4 Sensor Cards
        ...inletSensors.map(
          (sensor) => Padding(
            padding: const EdgeInsets.only(bottom: 14.0),
            child: SensorMonitoringCard(sensor: sensor),
          ),
        ),
      ],
    );
  }

  Widget _buildOutletTab(
    BuildContext context,
    List<SensorModel> outletSensors,
    bool isDark,
    double turbInlet,
    double phInlet,
    double tempInlet,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        // Informational banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.techBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.techBlue.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: AppColors.techBlue, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Monitoring Air Bersih (Jalur Outlet)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.techBlue,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Memantau kualitas air olahan pasca filtrasi multimedia bertingkat dan disinfeksi sinar ultraviolet (UV).',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textMuted : AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Dedicated pipe visualization button
        OutlinedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OutletMonitoringScreen()),
            );
          },
          icon: const Icon(Icons.linear_scale_rounded, size: 16),
          label: const Text('Buka Halaman Visual Diagram Jalur Pipa Outlet'),
        ),

        const SizedBox(height: 14),

        // 3 Sensor Cards with comparison against inlet
        ...outletSensors.map((sensor) {
          double? compVal;
          if (sensor.type == SensorType.turbidityOutlet) {
            compVal = turbInlet;
          } else if (sensor.type == SensorType.phOutlet) {
            compVal = phInlet;
          } else if (sensor.type == SensorType.temperatureOutlet) {
            compVal = tempInlet;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 14.0),
            child: SensorMonitoringCard(
              sensor: sensor,
              inletComparisonValue: compVal,
            ),
          );
        }),
      ],
    );
  }
}
