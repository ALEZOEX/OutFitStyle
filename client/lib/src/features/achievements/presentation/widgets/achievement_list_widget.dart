import 'package:flutter/material.dart';
import '../../../../domain/entities/achievement.dart';
import 'achievement_card_widget.dart';

class AchievementListWidget extends StatelessWidget {
  final List<Achievement> achievements;
  final String? userId;

  const AchievementListWidget({
    Key? key,
    required this.achievements,
    this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];

        return AchievementCardWidget(
          achievement: achievement,
          onTap: userId != null ? () {} : null,
        );
      },
    );
  }
}
