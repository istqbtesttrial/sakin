import 'package:hive/hive.dart';

part 'prayer_offsets.g.dart';

@HiveType(typeId: 4)
class PrayerOffsets {
  @HiveField(0)
  final int fajr;
  @HiveField(1)
  final int dhuhr;
  @HiveField(2)
  final int asr;
  @HiveField(3)
  final int maghrib;
  @HiveField(4)
  final int isha;

  PrayerOffsets({
    this.fajr = 0,
    this.dhuhr = 0,
    this.asr = 0,
    this.maghrib = 0,
    this.isha = 0,
  });

  /// Convert to [Map] for storage.
  Map<String, dynamic> toJson() {
    return {
      'fajr': fajr,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
    };
  }

  /// Create from [Map].
  factory PrayerOffsets.fromJson(Map<String, dynamic> json) {
    return PrayerOffsets(
      fajr: json['fajr'] ?? 0,
      dhuhr: json['dhuhr'] ?? 0,
      asr: json['asr'] ?? 0,
      maghrib: json['maghrib'] ?? 0,
      isha: json['isha'] ?? 0,
    );
  }

  /// Create a new instance with optional field updates.
  PrayerOffsets copyWith({
    int? fajr,
    int? dhuhr,
    int? asr,
    int? maghrib,
    int? isha,
  }) {
    return PrayerOffsets(
      fajr: fajr ?? this.fajr,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
    );
  }

  /// Get offset by index (0-4)
  int getOffsetByIndex(int index) {
    switch (index) {
      case 0:
        return fajr;
      case 2:
        return dhuhr; // Sunrise is 1, Dhuhr is 2 in adhanType
      case 3:
        return asr;
      case 4:
        return maghrib;
      case 5:
        return isha;
      default:
        return 0;
    }
  }
}
