import 'package:flutter/services.dart';

class HapticsService {
  static Future<void> triggerSelection() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  static Future<void> triggerLightImpact() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  static Future<void> triggerMediumImpact() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  static Future<void> triggerCriticalAnomalyAlarm() async {
    try {
      // Urgent double-pulse tactile alarm for clinical anomaly
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 140));
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 140));
      await HapticFeedback.vibrate();
    } catch (_) {}
  }
}
