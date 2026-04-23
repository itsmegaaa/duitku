import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String settingsBoxName = 'settingsBox';
  static const String sessionBoxName = 'sessionBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(settingsBoxName);
    await Hive.openBox(sessionBoxName);
  }

  static Box get settingsBox => Hive.box(settingsBoxName);
  static Box get sessionBox => Hive.box(sessionBoxName);

  // Session
  static String? get activeProfileId => sessionBox.get('activeProfileId') as String?;
  static Future<void> setActiveProfileId(String? id) => sessionBox.put('activeProfileId', id);

  static bool get isAuthenticated => sessionBox.get('isAuthenticated', defaultValue: false) as bool;
  static Future<void> setAuthenticated(bool val) => sessionBox.put('isAuthenticated', val);

  // Settings (Auth & UI)
  static bool get hasSeenOnboarding => settingsBox.get('hasSeenOnboarding', defaultValue: false) as bool;
  static Future<void> setHasSeenOnboarding(bool val) => settingsBox.put('hasSeenOnboarding', val);
  
  static String? get pinCode => settingsBox.get('pinCode') as String?;
  static Future<void> setPinCode(String? val) => settingsBox.put('pinCode', val);

  static bool get isPinActive => settingsBox.get('isPinActive', defaultValue: false) as bool;
  static Future<void> setIsPinActive(bool val) => settingsBox.put('isPinActive', val);

  // Legacy Settings
  static int? get themeColorIndex => settingsBox.get('themeColorIndex') as int?;
  static Future<void> setThemeColorIndex(int index) => settingsBox.put('themeColorIndex', index);

  static bool? get isDarkMode => settingsBox.get('isDarkMode') as bool?;
  static Future<void> setIsDarkMode(bool isDark) => settingsBox.put('isDarkMode', isDark);
}
