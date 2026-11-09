class WaterQualityComparison {
  final double turbidityInlet;
  final double turbidityOutlet;
  final double phInlet;
  final double phOutlet;
  final double tempInlet;
  final double tempOutlet;
  final double flowRate;

  WaterQualityComparison({
    required this.turbidityInlet,
    required this.turbidityOutlet,
    required this.phInlet,
    required this.phOutlet,
    required this.tempInlet,
    required this.tempOutlet,
    required this.flowRate,
  });

  // Calculate turbidity reduction percentage
  double get turbidityReductionPercent {
    if (turbidityInlet <= 0) return 0.0;
    final reduction = ((turbidityInlet - turbidityOutlet) / turbidityInlet) * 100;
    return reduction.clamp(0.0, 100.0);
  }

  // pH delta
  double get phDelta => phOutlet - phInlet;

  // Temperature delta
  double get tempDelta => tempOutlet - tempInlet;

  String get turbiditySummary {
    if (turbidityOutlet <= 5.0) {
      return 'Kekeruhan berkurang drastis (${turbidityReductionPercent.toStringAsFixed(1)}%). Filtrasi multimedia bekerja sangat efektif.';
    } else if (turbidityOutlet <= 25.0) {
      return 'Kekeruhan berkurang (${turbidityReductionPercent.toStringAsFixed(1)}%). Namun nilai outlet masih sedikit di atas ambang ideal.';
    } else {
      return 'Efisiensi penurunan kekeruhan rendah (${turbidityReductionPercent.toStringAsFixed(1)}%). Periksa media filter atau lakukan backwash.';
    }
  }

  String get phSummary {
    if (phOutlet >= 6.5 && phOutlet <= 8.5) {
      return 'Nilai pH outlet stabil pada rentang netral ($phOutlet pH), sesuai standar pengolahan air bersih.';
    } else if (phOutlet < 6.5) {
      return 'Nilai pH outlet cenderung asam ($phOutlet pH). Pertimbangkan penambahan media penetral asam.';
    } else {
      return 'Nilai pH outlet cenderung basa ($phOutlet pH).';
    }
  }

  String get tempSummary {
    final diff = tempDelta.abs();
    if (diff <= 1.5) {
      return 'Suhu air stabil ($tempOutlet°C) dengan selisih normal pasca melewati media filter.';
    } else {
      return 'Terdapat fluktuasi suhu sebesar ${tempDelta > 0 ? "+" : ""}${tempDelta.toStringAsFixed(1)}°C pada tahapan pengolahan.';
    }
  }
}
