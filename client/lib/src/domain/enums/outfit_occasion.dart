import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum OutfitOccasion {
  casual('casual'),
  formal('formal'),
  business('business'),
  party('party'),
  dateNight('date_night'),
  wedding('wedding'),
  funeral('funeral'),
  interview('interview'),
  vacation('vacation'),
  exercise('exercise'),
  shopping('shopping'),
  school('school'),
  work('work'),
  sportingEvent('sporting_event'),
  outdoorActivity('outdoor_activity'),
  home('home');

  const OutfitOccasion(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case OutfitOccasion.casual:
        return 'Повседневный';
      case OutfitOccasion.formal:
        return 'Формальный';
      case OutfitOccasion.business:
        return 'Деловой';
      case OutfitOccasion.party:
        return 'Вечеринка';
      case OutfitOccasion.dateNight:
        return 'Свидание';
      case OutfitOccasion.wedding:
        return 'Свадьба';
      case OutfitOccasion.funeral:
        return 'Похороны';
      case OutfitOccasion.interview:
        return 'Собеседование';
      case OutfitOccasion.vacation:
        return 'Отпуск';
      case OutfitOccasion.exercise:
        return 'Тренировка';
      case OutfitOccasion.shopping:
        return 'Шопинг';
      case OutfitOccasion.school:
        return 'Школа';
      case OutfitOccasion.work:
        return 'Работа';
      case OutfitOccasion.sportingEvent:
        return 'Спортивное событие';
      case OutfitOccasion.outdoorActivity:
        return 'На открытом воздухе';
      case OutfitOccasion.home:
        return 'Дома';
    }
  }

  static OutfitOccasion fromValue(String value) {
    return OutfitOccasion.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OutfitOccasion.casual,
    );
  }
}
