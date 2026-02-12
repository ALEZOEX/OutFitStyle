// lib/src/domain/enums/achievement_status.dart
import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum AchievementStatus {
  locked('locked'),
  inProgress('in_progress'),
  unlocked('unlocked'),
  claimed('claimed');

  const AchievementStatus(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case AchievementStatus.locked:
        return 'Заблокировано';
      case AchievementStatus.inProgress:
        return 'В процессе';
      case AchievementStatus.unlocked:
        return 'Разблокировано';
      case AchievementStatus.claimed:
        return 'Получено';
    }
  }

  static AchievementStatus fromValue(String? value) {
    if (value == null) return AchievementStatus.values.first;
    return AchievementStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AchievementStatus.values.first,
    );
  }
}
