import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sakin_app/core/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Settings & Persistence Verification', () {
    setUpAll(() async {
      // Base init once (safe for CI)
      SharedPreferences.setMockInitialValues({});
      await SettingsService.init();
    });

    setUp(() async {
      // Reset state before each test to avoid test order dependency
      SharedPreferences.setMockInitialValues({});
      await SettingsService.init();
    });

    test('Verify Dark Mode Toggle & Persistence', () async {
      expect(SettingsService.isDarkMode, false);

      final ValueNotifier<ThemeMode> testThemeNotifier =
          ValueNotifier(ThemeMode.light);

      await SettingsService.setDarkMode(true);
      testThemeNotifier.value =
          SettingsService.isDarkMode ? ThemeMode.dark : ThemeMode.light;

      expect(SettingsService.isDarkMode, true);
      expect(testThemeNotifier.value, ThemeMode.dark);

      await SettingsService.setDarkMode(false);
      expect(SettingsService.isDarkMode, false);
    });

    test('Verify Language Switching & Persistence', () async {
      expect(SettingsService.language, 'ar');

      await SettingsService.setLanguage('en');
      expect(SettingsService.language, 'en');

      await SettingsService.setLanguage('fr');
      expect(SettingsService.language, 'fr');
    });

    test('Verify Location Update & Persistence', () async {
      // Arrange: set a known baseline to avoid relying on default
      await SettingsService.setLocation('تونس، قابس');
      expect(SettingsService.location, 'تونس، قابس');

      // Act
      await SettingsService.setLocation('Cairo, Egypt');

      // Assert
      expect(SettingsService.location, 'Cairo, Egypt');
    });

    test('Verify Manual Time Offset & Persistence', () async {
      expect(SettingsService.manualOffset, 0);

      await SettingsService.setManualOffset(5);
      expect(SettingsService.manualOffset, 5);

      await SettingsService.setManualOffset(-10);
      expect(SettingsService.manualOffset, -10);
    });

    test('Verify Install Date Initialization', () async {
      final date1 = SettingsService.installDate;
      expect(date1, isNotNull);

      final date2 = SettingsService.installDate;
      expect(date1, date2);
    });

    test('Verify Prayer Notification Toggles', () async {
      expect(SettingsService.getPrayerNotification('fajr'), true);

      await SettingsService.setPrayerNotification('fajr', false);

      expect(SettingsService.getPrayerNotification('fajr'), false);
      expect(SettingsService.getPrayerNotification('dhuhr'), true);
    });
  });
}
