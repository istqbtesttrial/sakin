import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sakin_app/core/services/settings_service.dart';

void main() {
  group('Settings & Persistence Verification', () {
    setUp(() async {
      // 1. Mock SharedPreferences with empty initial values
      SharedPreferences.setMockInitialValues({});
      await SettingsService.init();
    });

    test('Verify Dark Mode Toggle & Persistence', () async {
      // Default should be false (Light Mode)
      expect(SettingsService.isDarkMode, false);

      // Verify Notifier updates (simulating main.dart logic)
      final ValueNotifier<ThemeMode> testThemeNotifier =
          ValueNotifier(ThemeMode.light);

      // Act: Turn on Dark Mode
      await SettingsService.setDarkMode(true);
      testThemeNotifier.value =
          SettingsService.isDarkMode ? ThemeMode.dark : ThemeMode.light;

      // Assert
      expect(SettingsService.isDarkMode, true); // Persisted
      expect(testThemeNotifier.value, ThemeMode.dark); // Notifier updated

      // Act: Turn off
      await SettingsService.setDarkMode(false);
      expect(SettingsService.isDarkMode, false);
    });

    test('Verify Language Switching & Persistence', () async {
      // Default should be 'ar'
      expect(SettingsService.language, 'ar');

      // Act: Change to English
      await SettingsService.setLanguage('en');

      // Assert
      expect(SettingsService.language, 'en');

      // Act: Change to French
      await SettingsService.setLanguage('fr');
      expect(SettingsService.language, 'fr');
    });

    test('Verify Location Update & Persistence', () async {
      // Default
      expect(SettingsService.location, 'تونس، قابس');

      // Act
      await SettingsService.setLocation('Cairo, Egypt');

      // Assert
      expect(SettingsService.location, 'Cairo, Egypt');
    });

    test('Verify Manual Time Offset & Persistence', () async {
      // Default
      expect(SettingsService.manualOffset, 0);

      // Act
      await SettingsService.setManualOffset(5);

      // Assert
      expect(SettingsService.manualOffset, 5);

      // Act: Negative offset
      await SettingsService.setManualOffset(-10);
      expect(SettingsService.manualOffset, -10);
    });

    test('Verify Install Date Initialization', () async {
      // Should initialize on first access
      final date1 = SettingsService.installDate;
      expect(date1, isNotNull);

      // Should persist same date on second access
      final date2 = SettingsService.installDate;
      expect(date1, date2);
    });

    test('Verify Prayer Notification Toggles', () async {
      // Default should be true
      expect(SettingsService.getPrayerNotification('fajr'), true);

      // Act: Disable Fajr
      await SettingsService.setPrayerNotification('fajr', false);

      // Assert
      expect(SettingsService.getPrayerNotification('fajr'), false);
      expect(SettingsService.getPrayerNotification('dhuhr'),
          true); // Others remain true
    });
  });
}
