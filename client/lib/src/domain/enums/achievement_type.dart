import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum AchievementType {
  progress('progress'),
  milestone('milestone'),
  challenge('challenge'),
  seasonal('seasonal');

  const AchievementType(this.value);
  final String value;

  static AchievementType fromValue(String? value) {
    if (value == null) return AchievementType.values.first;
    return AchievementType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AchievementType.values.first,
    );
  }
}
