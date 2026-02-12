import 'package:flutter/services.dart';

class Haptics {
  static void lightImpact() => HapticFeedback.lightImpact();
  static void mediumImpact() => HapticFeedback.mediumImpact();
}