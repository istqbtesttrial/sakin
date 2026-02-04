import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'notification_service.dart';
import 'package:hive/hive.dart';
import '../core/services/settings_service.dart';

class PrayerService with ChangeNotifier {
  PrayerTimes? _prayerTimes;
  SunnahTimes? _sunnahTimes;
  Coordinates _coordinates = Coordinates(33.8869, 9.7963); // Default: Tunisia

  Map<String, int> _offsets = {};

  PrayerService() {
    _loadOffsets();
  }

  // Expose notifyListeners safely
  void notifyUpdate() {
    notifyListeners();
  }

  Future<void> _loadOffsets() async {
    final box = await Hive.openBox('settings');
    final data = box.get('prayer_offsets');
    if (data != null) {
      _offsets = Map<String, int>.from(data);
    }
    calculatePrayers();
  }

  void updateLocation(double latitude, double longitude) {
    _coordinates = Coordinates(latitude, longitude);
    calculatePrayers();
  }

  // Force reload of settings (e.g. after manual adjustment)
  Future<void> reloadSettings() async {
    await _loadOffsets();
  }

  void calculatePrayers() {
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;

    final date = DateComponents.from(DateTime.now());
    final rawPrayerTimes = PrayerTimes(_coordinates, date, params);

    _prayerTimes = rawPrayerTimes;

    // Calculate Sunnah times (Middle of the Night, Last Third)
    if (_prayerTimes != null) {
      _sunnahTimes = SunnahTimes(_prayerTimes!);
    }

    notifyListeners();
  }

  // Getters for adjusted prayer times
  DateTime? get fajr => _prayerTimes?.fajr.add(Duration(
      minutes: (_offsets['fajr'] ?? 0) + SettingsService.manualOffset));
  DateTime? get dhuhr => _prayerTimes?.dhuhr.add(Duration(
      minutes: (_offsets['dhuhr'] ?? 0) + SettingsService.manualOffset));
  DateTime? get asr => _prayerTimes?.asr.add(
      Duration(minutes: (_offsets['asr'] ?? 0) + SettingsService.manualOffset));
  DateTime? get maghrib => _prayerTimes?.maghrib.add(Duration(
      minutes: (_offsets['maghrib'] ?? 0) + SettingsService.manualOffset));
  DateTime? get isha => _prayerTimes?.isha.add(Duration(
      minutes: (_offsets['isha'] ?? 0) + SettingsService.manualOffset));

  // Helper to get adjusted time by enum
  DateTime? getAdjustedTime(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return fajr;
      case Prayer.dhuhr:
        return dhuhr;
      case Prayer.asr:
        return asr;
      case Prayer.maghrib:
        return maghrib;
      case Prayer.isha:
        return isha;
      default:
        return null;
    }
  }

  /// Schedule notifications based on the current settings
  Future<void> scheduleNotifications() async {
    if (_prayerTimes == null) return;

    debugPrint('⏳ 📅 Scheduling notifications...');

    // List of prayers to be scheduled
    final currentPrayers = {
      'fajr': fajr,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
    };

    int alarmId = 0;
    final now = DateTime.now();

    for (var entry in currentPrayers.entries) {
      final prayerKey = entry.key; // lowercase key
      final prayerTime = entry.value;

      // Check if the specific prayer is enabled in settings
      bool isEnabled = SettingsService.getPrayerNotification(prayerKey);

      // Capitalize for display/ID consistency
      final displayTitle = prayerKey[0].toUpperCase() + prayerKey.substring(1);

      if (prayerTime != null && isEnabled && prayerTime.isAfter(now)) {
        debugPrint('✅ Scheduling $displayTitle at $prayerTime');
        await NotificationService.scheduleAdhan(
            alarmId, displayTitle, prayerTime);
      }
      alarmId++;
    }
  }

  PrayerTimes? get prayerTimes => _prayerTimes;
  SunnahTimes? get sunnahTimes => _sunnahTimes;

  Prayer get nextPrayer => _prayerTimes?.nextPrayer() ?? Prayer.none;

  // Middle of the night time
  DateTime? get middleOfTheNight => _sunnahTimes?.middleOfTheNight;

  // Last third of the night time
  DateTime? get lastThirdOfTheNight => _sunnahTimes?.lastThirdOfTheNight;

  // Returns the next prayer's time as raw DateTime
  DateTime? getNextPrayerTime() {
    if (_prayerTimes == null) return null;
    final next = _prayerTimes!.nextPrayer();
    if (next == Prayer.none) return null;
    return _prayerTimes!.timeForPrayer(next);
  }

  // Returns time remaining until next prayer as a Duration
  Duration? getTimeRemainingDuration() {
    if (_prayerTimes == null) return null;

    final next = _prayerTimes!.nextPrayer();
    if (next == Prayer.none) return null;

    final nextTime = _prayerTimes!.timeForPrayer(next)!;
    final now = DateTime.now();
    return nextTime.difference(now);
  }

  // Placeholder implementation for Hijri date
  DateTime get now => DateTime.now();

  // Format time (e.g., 5:30 PM)
  String getFormattedTime(DateTime? time) {
    if (time == null) return "";
    return DateFormat.jm().format(time);
  }

  // Get remaining time as string (e.g., 02:15:30)
  String getTimeRemaining() {
    final duration = getTimeRemainingDuration();
    if (duration == null) return "";
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  // Get Hijri date (Placeholder/Basic implementation)
  String getHijriDate() {
    return DateFormat.yMMMMd('ar').format(DateTime.now());
  }
}
