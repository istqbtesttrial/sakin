import 'package:hive_flutter/hive_flutter.dart';

class MisbahaRepository {
  static const String _boxName = 'misbaha_data';
  static const String _countKey = 'count';
  static const String _dhikrIndexKey = 'dhikr_index';

  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  int getCount() {
    return _box.get(_countKey, defaultValue: 0);
  }

  int getDhikrIndex() {
    return _box.get(_dhikrIndexKey, defaultValue: 0);
  }

  Future<void> saveCount(int count) async {
    await _box.put(_countKey, count);
  }

  Future<void> saveDhikrIndex(int index) async {
    await _box.put(_dhikrIndexKey, index);
  }

  Future<void> reset() async {
    await _box.put(_countKey, 0);
    // Note: We don't reset the index on general reset, only count.
  }
}
