import 'package:equatable/equatable.dart';
import '../../../models/dhikr.dart';

class MisbahaState extends Equatable {
  final int count;
  final Dhikr currentDhikr;

  const MisbahaState({
    required this.count,
    required this.currentDhikr,
  });

  factory MisbahaState.initial() {
    return MisbahaState(
      count: 0,
      currentDhikr: Dhikr.presets[0], // Default to first preset
    );
  }

  MisbahaState copyWith({
    int? count,
    Dhikr? currentDhikr,
  }) {
    return MisbahaState(
      count: count ?? this.count,
      currentDhikr: currentDhikr ?? this.currentDhikr,
    );
  }

  @override
  List<Object> get props => [count, currentDhikr];
}
