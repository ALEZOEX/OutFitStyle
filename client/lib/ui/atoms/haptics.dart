import 'package:flutter/services.dart';

class Haptics {
  static void selection() => HapticFeedback.selectionClick();
  static void light() => HapticFeedback.lightImpact();
  static void success() => HapticFeedback.mediumImpact();
}