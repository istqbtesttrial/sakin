import 'package:hive/hive.dart';

part 'location_info.g.dart';

/// Supported location modes.
@HiveType(typeId: 2)
enum LocationMode {
  /// Location is cached locally.
  @HiveField(0)
  cached,

  /// Location is fetched directly via GPS.
  @HiveField(1)
  live,

  /// Location entered manually.
  @HiveField(2)
  manual,
}

/// Location information model.
/// Stores coordinates, address, and update status.
@HiveType(typeId: 3)
class LocationInfo {
  @HiveField(0)
  final double latitude;

  @HiveField(1)
  final double longitude;

  @HiveField(2)
  final String address;

  @HiveField(3)
  final LocationMode mode;

  @HiveField(4)
  final DateTime lastUpdated;

  LocationInfo({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.mode,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  /// Create a new instance with optional field updates.
  LocationInfo copyWith({
    double? latitude,
    double? longitude,
    String? address,
    LocationMode? mode,
    DateTime? lastUpdated,
  }) {
    return LocationInfo(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      mode: mode ?? this.mode,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Convert to [Map] for storage.
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'mode': mode.name,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Create from [Map].
  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      mode: LocationMode.values.byName(json['mode'] ?? 'cached'),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}
