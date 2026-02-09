// app/providers/achievement_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/injection.dart';
import '../../features/achievements/presentation/controllers/achievement_controller.dart';

final achievementControllerProvider =
    StateNotifierProvider<AchievementController, AchievementState>((ref) {
  final repository = ref.watch(achievementRepositoryProvider);
  return AchievementController(repository);
});