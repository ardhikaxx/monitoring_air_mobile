import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/sensor_model.dart';
import '../models/sensor_reading_model.dart';

class SensorGaugeConfig {
  final double min;
  final double max;
  final double targetMin;
  final double targetMax;
  final int decimalDigits;
  final String unitDisplay;

  const SensorGaugeConfig({
    required this.min,
    required this.max,
    required this.targetMin,
    required this.targetMax,
    required this.decimalDigits,
    required this.unitDisplay,
  });

  static SensorGaugeConfig forSensor(SensorModel sensor) {
    switch (sensor.type) {
      case SensorType.phInlet:
      case SensorType.phOutlet:
        return const SensorGaugeConfig(
          min: 0.0,
          max: 14.0,
          targetMin: 6.5,
          targetMax: 8.5,
          decimalDigits: 2,
          unitDisplay: 'PH',
        );
      case SensorType.turbidityInlet:
        return const SensorGaugeConfig(
          min: 0.0,
          max: 150.0,
          targetMin: 0.0,
          targetMax: 50.0,
          decimalDigits: 1,
          unitDisplay: 'NTU',
        );
      case SensorType.turbidityOutlet:
        return const SensorGaugeConfig(
          min: 0.0,
          max: 20.0,
          targetMin: 0.0,
          targetMax: 5.0,
          decimalDigits: 1,
          unitDisplay: 'NTU',
        );
      case SensorType.flowRateInlet:
        return const SensorGaugeConfig(
          min: 0.0,
          max: 40.0,
          targetMin: 10.0,
          targetMax: 30.0,
          decimalDigits: 1,
          unitDisplay: 'L/MIN',
        );
      case SensorType.temperatureInlet:
      case SensorType.temperatureOutlet:
        return const SensorGaugeConfig(
          min: 0.0,
          max: 50.0,
          targetMin: 20.0,
          targetMax: 30.0,
          decimalDigits: 1,
          unitDisplay: '°C',
        );
    }
  }
}

class SensorRadialArcGauge extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final double? targetMin;
  final double? targetMax;
  final String unit;
  final int decimalDigits;
  final Color arcColor;
  final Color targetColor;
  final Color trackColor;
  final bool isOffline;
  final double width;
  final double height;

  const SensorRadialArcGauge({
    super.key,
    required this.value,
    this.min = 0.0,
    required this.max,
    this.targetMin,
    this.targetMax,
    required this.unit,
    this.decimalDigits = 1,
    this.arcColor = AppColors.techBlue,
    this.targetColor = const Color(0xFF8BD3C7), // Mint/Seafoam target zone matching reference
    this.trackColor = const Color(0xFFE2E8F0),  // Light slate grey track matching reference
    this.isOffline = false,
    this.width = 220,
    this.height = 135,
  });

  factory SensorRadialArcGauge.fromSensor({
    Key? key,
    required SensorModel sensor,
    Color? customArcColor,
    double width = 220,
    double height = 135,
  }) {
    final config = SensorGaugeConfig.forSensor(sensor);

    Color color = customArcColor ?? AppColors.techBlue;
    if (customArcColor == null) {
      switch (sensor.type) {
        case SensorType.turbidityInlet:
          color = AppColors.rawWater;
          break;
        case SensorType.turbidityOutlet:
          color = AppColors.techBlue;
          break;
        case SensorType.phInlet:
          color = const Color(0xFF1677C8);
          break;
        case SensorType.phOutlet:
          color = const Color(0xFF1677C8);
          break;
        case SensorType.flowRateInlet:
          color = AppColors.accentCyan;
          break;
        case SensorType.temperatureInlet:
        case SensorType.temperatureOutlet:
          color = const Color(0xFFF97316);
          break;
      }
    }

    return SensorRadialArcGauge(
      key: key,
      value: sensor.currentValue,
      min: config.min,
      max: config.max,
      targetMin: config.targetMin,
      targetMax: config.targetMax,
      unit: config.unitDisplay,
      decimalDigits: config.decimalDigits,
      arcColor: color,
      isOffline: sensor.status == SensorStatus.offline,
      width: width,
      height: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    final clampedVal = value.clamp(min, max);

    // Format min and max labels
    final minLabel = min % 1 == 0 ? min.toInt().toString() : min.toStringAsFixed(1);
    final maxLabel = max % 1 == 0 ? max.toInt().toString() : max.toStringAsFixed(1);

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Semicircular Arc Custom Paint with smooth animation
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: min, end: isOffline ? min : clampedVal),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, animatedVal, _) {
              return CustomPaint(
                size: Size(width, height),
                painter: _RadialArcPainter(
                  value: animatedVal,
                  min: min,
                  max: max,
                  targetMin: targetMin,
                  targetMax: targetMax,
                  arcColor: arcColor,
                  targetColor: targetColor,
                  trackColor: trackColor,
                  isOffline: isOffline,
                ),
              );
            },
          ),

          // Central Reading & Unit (matching image.png)
          Positioned(
            bottom: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isOffline ? '--' : value.toStringAsFixed(decimalDigits),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navyBlue,
                    letterSpacing: -0.6,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  unit.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),

          // Left Bound Label (0)
          Positioned(
            left: 20,
            bottom: 2,
            child: Text(
              minLabel,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),

          // Right Bound Label (14, 150, etc.)
          Positioned(
            right: 20,
            bottom: 2,
            child: Text(
              maxLabel,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadialArcPainter extends CustomPainter {
  final double value;
  final double min;
  final double max;
  final double? targetMin;
  final double? targetMax;
  final Color arcColor;
  final Color targetColor;
  final Color trackColor;
  final bool isOffline;

  _RadialArcPainter({
    required this.value,
    required this.min,
    required this.max,
    this.targetMin,
    this.targetMax,
    required this.arcColor,
    required this.targetColor,
    required this.trackColor,
    required this.isOffline,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 16.0;

    // The center of the semicircle arc (bottom baseline where ends rest)
    final center = Offset(size.width / 2, size.height - 24);
    // Radius accounts for strokeWidth and horizontal bounds padding
    final radius = (size.width / 2) - 24;

    final arcRect = Rect.fromCircle(center: center, radius: radius);

    // 1. Draw Background Track (Semicircle from math.pi to 2*math.pi)
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(arcRect, math.pi, math.pi, false, trackPaint);

    if (isOffline) return;

    final range = max - min;
    if (range <= 0) return;

    // 2. Draw Target / Safe Zone Arc Segment (Soft mint/teal segment)
    if (targetMin != null && targetMax != null) {
      final tMinRatio = ((targetMin! - min) / range).clamp(0.0, 1.0);
      final tMaxRatio = ((targetMax! - min) / range).clamp(0.0, 1.0);

      final targetStartAngle = math.pi + (tMinRatio * math.pi);
      final targetSweepAngle = (tMaxRatio - tMinRatio) * math.pi;

      if (targetSweepAngle > 0.005) {
        final targetPaint = Paint()
          ..color = targetColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

        canvas.drawArc(arcRect, targetStartAngle, targetSweepAngle, false, targetPaint);
      }
    }

    // 3. Draw Active Value Arc (Vibrant Blue with rounded cap)
    final valRatio = ((value - min) / range).clamp(0.0, 1.0);
    final activeSweepAngle = valRatio * math.pi;

    if (activeSweepAngle > 0.01) {
      final activePaint = Paint()
        ..color = arcColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(arcRect, math.pi, activeSweepAngle, false, activePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadialArcPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.min != min ||
        oldDelegate.max != max ||
        oldDelegate.targetMin != targetMin ||
        oldDelegate.targetMax != targetMax ||
        oldDelegate.arcColor != arcColor ||
        oldDelegate.isOffline != isOffline;
  }
}
