import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// ✅ SoundService — inalia sauti ya notification/chat
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();

  /// Lia sauti ya notification (tone fupi)
  Future<void> playNotificationSound() async {
    try {
      // Tumia sauti iliyopo kwenye system (haptic + beep)
      await HapticFeedback.mediumImpact();
      await _player.play(
        AssetSource('sounds/notification.wav'),
        volume: 0.7,
      );
    } catch (_) {
      // Fallback: vibration tu
      try { await HapticFeedback.vibrate(); } catch (_) {}
    }
  }

  /// Lia sauti ya message (tone nyepesi)
  Future<void> playMessageSound() async {
    try {
      await HapticFeedback.lightImpact();
      await _player.play(
        AssetSource('sounds/message.wav'),
        volume: 0.5,
      );
    } catch (_) {
      try { await HapticFeedback.selectionClick(); } catch (_) {}
    }
  }

  void dispose() {
    _player.dispose();
  }
}
