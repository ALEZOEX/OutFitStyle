import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/achievement.dart';
import '../providers/achievements_providers.dart';

class AchievementCardWidget extends ConsumerWidget {
  final Achievement achievement;
  final VoidCallback? onTap;

  const AchievementCardWidget({Key? key, required this.achievement, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUnlocked = achievement.isUnlocked;
    final progress = achievement.currentProgress;
    final target = achievement.targetValue;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          onTap?.call();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Иконка ачивки
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? Colors.amber.shade200
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isUnlocked ? Colors.amber : Colors.grey,
                    width: 2,
                  ),
                ),
                child: Icon(
                  isUnlocked ? Icons.star : Icons.star_border,
                  color: isUnlocked ? Colors.amber : Colors.grey,
                  size: 30,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            achievement.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isUnlocked
                                  ? Colors.black87
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                        if (isUnlocked)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green, width: 1),
                            ),
                            child: const Text(
                              'Разблокировано',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      achievement.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isUnlocked
                            ? Colors.black54
                            : Colors.grey.shade500,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Прогресс бар
                    if (!isUnlocked)
                      Column(
                        children: [
                          LinearProgressIndicator(
                            value: progress / target,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$progress/$target',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '${((progress / target) * 100).round()}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
