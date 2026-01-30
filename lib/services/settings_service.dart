import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/prayer_notification_settings.dart';

/// Service to manage notification settings
class SettingsService with ChangeNotifier {
  PrayerNotificationSettings _settings = const PrayerNotificationSettings();

  PrayerNotificationSettings get settings => _settings;

  DateTime? _installDate;
  DateTime? get installDate => _installDate;

  Locale _locale = const Locale('ar');
  Locale get locale => _locale;

  /// Load settings from Hive
  Future<void> loadSettings() async {
    try {
      final box = await Hive.openBox('settings');

      // Load prayer notification settings
      final data = box.get('prayer_notifications');
      if (data != null) {
        _settings = PrayerNotificationSettings.fromJson(
            Map<String, dynamic>.from(data));
      }

      // Load locale
      final langCode = box.get('language_code');
      if (langCode != null) {
        _locale = Locale(langCode);
      }

      // Load installation date
      final installTimestamp = box.get('install_date');
      if (installTimestamp != null) {
        _installDate = DateTime.parse(installTimestamp);
      } else {
        _installDate = DateTime.now();
        await box.put('install_date', _installDate!.toIso8601String());
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  /// Change locale and persist it
  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;
    _locale = newLocale;
    notifyListeners();

    try {
      final box = await Hive.openBox('settings');
      await box.put('language_code', newLocale.languageCode);
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }

  /// Save current settings to Hive
  Future<void> saveSettings() async {
    try {
      final box = await Hive.openBox('settings');
      await box.put('prayer_notifications', _settings.toJson());
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  /// Update the enabled state of a specific prayer
  Future<void> togglePrayer(String prayerName, bool value) async {
    _settings = _settings.copyWith(
      fajrEnabled: prayerName == 'fajr' ? value : null,
      dhuhrEnabled: prayerName == 'dhuhr' ? value : null,
      asrEnabled: prayerName == 'asr' ? value : null,
      maghribEnabled: prayerName == 'maghrib' ? value : null,
      ishaEnabled: prayerName == 'isha' ? value : null,
    );
    await saveSettings();
  }
}
