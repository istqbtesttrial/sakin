import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'notification_service.dart';
import 'package:hive/hive.dart';
import '../models/prayer_offsets.dart';
import '../models/prayer_notification_settings.dart';

class PrayerService with ChangeNotifier {
  PrayerTimes? _prayerTimes;
  SunnahTimes? _sunnahTimes;
  Coordinates _coordinates = Coordinates(33.8869, 9.7963); // Default: Tunisia

  PrayerService() {
    calculatePrayers();
  }

  void updateLocation(double latitude, double longitude) {
    _coordinates = Coordinates(latitude, longitude);
    calculatePrayers();
  }

  void calculatePrayers() {
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;

    final date = DateComponents.from(DateTime.now());
    final rawPrayerTimes = PrayerTimes(_coordinates, date, params);

    // We can't modify PrayerTimes fields directly.
    // We'll store adjusted times in a Map for convenience if needed,
    // but the getNextPrayerTime etc will need to be updated.
    _prayerTimes = rawPrayerTimes; // Still keep it for the type

    // Calculate Sunnah times (Middle of the Night, Last Third)
    if (_prayerTimes != null) {
      _sunnahTimes = SunnahTimes(_prayerTimes!);
    }

    notifyListeners();
  }

  // Helper to get adjusted time
  DateTime? getAdjustedTime(Prayer prayer) {
    if (_prayerTimes == null) return null;
    final rawTime = _prayerTimes!.timeForPrayer(prayer);
    if (rawTime == null) return null;

    final box = Hive.isBoxOpen('settings') ? Hive.box('settings') : null;
    final offsetsData = box?.get('prayer_offsets');
    final offsets = offsetsData != null
        ? PrayerOffsets.fromJson(Map<String, dynamic>.from(offsetsData))
        : PrayerOffsets();

    switch (prayer) {
      case Prayer.fajr:
        return rawTime.add(Duration(minutes: offsets.fajr));
      case Prayer.dhuhr:
        return rawTime.add(Duration(minutes: offsets.dhuhr));
      case Prayer.asr:
        return rawTime.add(Duration(minutes: offsets.asr));
      case Prayer.maghrib:
        return rawTime.add(Duration(minutes: offsets.maghrib));
      case Prayer.isha:
        return rawTime.add(Duration(minutes: offsets.isha));
      default:
        return rawTime;
    }
  }

  /// Schedule notifications based on the current settings
  Future<void> scheduleNotifications(
      PrayerNotificationSettings settings) async {
    if (_prayerTimes == null) return;

    debugPrint('⏳ 📅 Scheduling notifications...');

    // List of prayers to be scheduled
    final currentPrayers = {
      'Fajr': _prayerTimes!.fajr,
      'Dhuhr': _prayerTimes!.dhuhr,
      'Asr': _prayerTimes!.asr,
      'Maghrib': _prayerTimes!.maghrib,
      'Isha': _prayerTimes!.isha,
    };

    int alarmId = 0;
    final now = DateTime.now();

    for (var entry in currentPrayers.entries) {
      final prayerName = entry.key;
      final prayerTime = entry.value;

      // Check if the specific prayer is enabled in settings
      bool isEnabled = false;
      switch (prayerName) {
        case 'Fajr':
          isEnabled = settings.fajrEnabled;
          break;
        case 'Dhuhr':
          isEnabled = settings.dhuhrEnabled;
          break;
        case 'Asr':
          isEnabled = settings.asrEnabled;
          break;
        case 'Maghrib':
          isEnabled = settings.maghribEnabled;
          break;
        case 'Isha':
          isEnabled = settings.ishaEnabled;
          break;
      }

      if (isEnabled && prayerTime.isAfter(now)) {
        debugPrint('✅ Scheduling $prayerName at $prayerTime');
        await NotificationService.scheduleAdhan(
            alarmId, prayerName, prayerTime);
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
  // Gregorian is returned for stability unless a package is added.
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
    // Note: To support real Hijri dates, the 'hijri' or 'jhijri' package is needed.
    // Returning Gregorian date for now to prevent errors.
    return DateFormat.yMMMMd('ar').format(DateTime.now());
  }
}
