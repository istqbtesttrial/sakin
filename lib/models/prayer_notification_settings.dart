import 'package:adhan/adhan.dart';
import 'package:hive/hive.dart';

part 'prayer_notification_settings.g.dart';

/// Notification settings model for each prayer.
/// Manages independent notification toggles for each prayer.
@HiveType(typeId: 1)
class PrayerNotificationSettings {
  @HiveField(0)
  final bool fajrEnabled;

  @HiveField(1)
  final bool dhuhrEnabled;

  @HiveField(2)
  final bool asrEnabled;

  @HiveField(3)
  final bool maghribEnabled;

  @HiveField(4)
  final bool ishaEnabled;

  const PrayerNotificationSettings({
    this.fajrEnabled = true,
    this.dhuhrEnabled = true,
    this.asrEnabled = true,
    this.maghribEnabled = true,
    this.ishaEnabled = true,
  });

  /// Check if notification is enabled for a specific prayer.
  bool isPrayerEnabled(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return fajrEnabled;
      case Prayer.dhuhr:
        return dhuhrEnabled;
      case Prayer.asr:
        return asrEnabled;
      case Prayer.maghrib:
        return maghribEnabled;
      case Prayer.isha:
        return ishaEnabled;
      default:
        return false;
    }
  }

  /// Convert settings to [Map].
  Map<String, dynamic> toJson() {
    return {
      'fajr': fajrEnabled,
      'dhuhr': dhuhrEnabled,
      'asr': asrEnabled,
      'maghrib': maghribEnabled,
      'isha': ishaEnabled,
    };
  }

  /// Create from [Map].
  factory PrayerNotificationSettings.fromJson(Map<String, dynamic> json) {
    return PrayerNotificationSettings(
      fajrEnabled: json['fajr'] ?? true,
      dhuhrEnabled: json['dhuhr'] ?? true,
      asrEnabled: json['asr'] ?? true,
      maghribEnabled: json['maghrib'] ?? true,
      ishaEnabled: json['isha'] ?? true,
    );
  }

  /// Create a new copy with modified fields to maintain immutability.
  PrayerNotificationSettings copyWith({
    bool? fajrEnabled,
    bool? dhuhrEnabled,
    bool? asrEnabled,
    bool? maghribEnabled,
    bool? ishaEnabled,
  }) {
    return PrayerNotificationSettings(
      fajrEnabled: fajrEnabled ?? this.fajrEnabled,
      dhuhrEnabled: dhuhrEnabled ?? this.dhuhrEnabled,
      asrEnabled: asrEnabled ?? this.asrEnabled,
      maghribEnabled: maghribEnabled ?? this.maghribEnabled,
      ishaEnabled: ishaEnabled ?? this.ishaEnabled,
    );
  }
}
