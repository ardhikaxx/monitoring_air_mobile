import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyInterval = 'sim_update_interval';
  static const String _keyIsDarkMode = 'app_dark_mode';
  static const String _keyTurbidityThreshold = 'thresh_turbidity_outlet';
  static const String _keyPhMinThreshold = 'thresh_ph_min';
  static const String _keyPhMaxThreshold = 'thresh_ph_max';
  static const String _keyFlowMinThreshold = 'thresh_flow_min';
  static const String _keyFlowMaxThreshold = 'thresh_flow_max';

  static Future<int> getUpdateInterval() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyInterval) ?? 4; // default 4 seconds
  }

  static Future<void> saveUpdateInterval(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyInterval, seconds);
  }

  static Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsDarkMode) ?? false;
  }

  static Future<void> saveDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsDarkMode, isDark);
  }

  static Future<Map<String, double>> getCustomThresholds() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'turbidityOutlet': prefs.getDouble(_keyTurbidityThreshold) ?? 5.0,
      'phMin': prefs.getDouble(_keyPhMinThreshold) ?? 6.5,
      'phMax': prefs.getDouble(_keyPhMaxThreshold) ?? 8.5,
      'flowMin': prefs.getDouble(_keyFlowMinThreshold) ?? 15.0,
      'flowMax': prefs.getDouble(_keyFlowMaxThreshold) ?? 25.0,
    };
  }

  static Future<void> saveThresholds({
    required double turbidityOutlet,
    required double phMin,
    required double phMax,
    required double flowMin,
    required double flowMax,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyTurbidityThreshold, turbidityOutlet);
    await prefs.setDouble(_keyPhMinThreshold, phMin);
    await prefs.setDouble(_keyPhMaxThreshold, phMax);
    await prefs.setDouble(_keyFlowMinThreshold, flowMin);
    await prefs.setDouble(_keyFlowMaxThreshold, flowMax);
  }

  static Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
