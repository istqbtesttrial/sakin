import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import '../../../data/repositories/misbaha_repository.dart';
import '../../../models/dhikr.dart';
import 'misbaha_state.dart';

class MisbahaCubit extends Cubit<MisbahaState> {
  final MisbahaRepository _repository;

  MisbahaCubit(this._repository) : super(MisbahaState.initial()) {
    _loadState();
  }

  void _loadState() {
    final count = _repository.getCount();
    final dhikrIndex = _repository.getDhikrIndex();

    // Validate index range
    final int safeIndex =
        (dhikrIndex >= 0 && dhikrIndex < Dhikr.presets.length) ? dhikrIndex : 0;

    emit(state.copyWith(
      count: count,
      currentDhikr: Dhikr.presets[safeIndex],
    ));
  }

  void increment() {
    int newCount = state.count + 1;

    // Haptic feedback for normal tap
    HapticFeedback.lightImpact();

    if (state.currentDhikr.target > 0 && newCount > state.currentDhikr.target) {
      newCount = 0;
      // Haptic feedback for cycle completion
      HapticFeedback.heavyImpact();
    }

    emit(state.copyWith(count: newCount));
    _repository.saveCount(newCount);
  }

  void decrement() {
    if (state.count > 0) {
      int newCount = state.count - 1;

      // Haptic feedback for decrement
      HapticFeedback.lightImpact();

      emit(state.copyWith(count: newCount));
      _repository.saveCount(newCount);
    }
  }

  void changeDhikr(Dhikr newDhikr) {
    // Reset count immediately as per requirements
    emit(state.copyWith(
      currentDhikr: newDhikr,
      count: 0,
    ));

    HapticFeedback.lightImpact();

    // Persist changes
    _repository.saveCount(0);
    // Find index of newDhikr
    final index = Dhikr.presets.indexOf(newDhikr);
    if (index != -1) {
      _repository.saveDhikrIndex(index);
    }
  }

  void reset() {
    // Haptic feedback for reset
    HapticFeedback.selectionClick();

    emit(state.copyWith(count: 0));
    _repository.reset();
  }
}
