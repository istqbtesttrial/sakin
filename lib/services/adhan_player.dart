import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

/// Service to play Adhan audio
class AdhanPlayer {
  static final AdhanPlayer _instance = AdhanPlayer._internal();
  factory AdhanPlayer() => _instance;
  AdhanPlayer._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  /// Play Adhan audio
  Future<void> playAdhan() async {
    try {
      if (_isPlaying) {
        // Stop currently playing Adhan first
        await stopAdhan();
      }

      // Load Adhan file from assets
      await _player.setAsset('assets/audio/adhan.mp3');

      // Set volume to maximum
      await _player.setVolume(1.0);

      // Start playback
      _isPlaying = true;
      await _player.play();

      // Listen for playback completion
      _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _isPlaying = false;
        }
      });
    } catch (e) {
      debugPrint('Error playing Adhan: $e');
      _isPlaying = false;
    }
  }

  /// Stop Adhan audio
  Future<void> stopAdhan() async {
    try {
      await _player.stop();
      _isPlaying = false;
    } catch (e) {
      debugPrint('Error stopping Adhan: $e');
    }
  }

  /// Check playback status
  bool get isPlaying => _isPlaying;

  /// Dispose of audio resources
  Future<void> dispose() async {
    await _player.dispose();
  }
}
