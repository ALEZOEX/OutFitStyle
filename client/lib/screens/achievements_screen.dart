import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/achievement.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';
import '../theme/app_theme.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  late Future<List<Achievement>> _achievementsFuture;

  @override
  void initState() {
    super.initState();
    _achievementsFuture = Future.value(<Achievement>[]);
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final apiService = context.read<ApiService>();
    final authStorage = context.read<AuthStorage>();
    final userId = await authStorage.readUserId();

    if (!mounted) return;

    if (userId == null) {
      setState(() {
        _achievementsFuture = Future.value(<Achievement>[]);
      });
      return;
    }

    setState(() {
      _achievementsFuture = apiService.getAchievements(userId: userId);
    });

    await _achievementsFuture;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Достижения'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAchievements,
        color: theme.primaryColor,
        child: FutureBuilder<List<Achievement>>(
          future: _achievementsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Ошибка: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Нет достижений'));
            }

            final achievements = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                return _AchievementCard(achievement: achievements[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnlocked = achievement.isUnlocked;

    // Для заблокированных используем цвета темы, чтобы не было черного на тёмном
    final textColorPrimary = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final textColorSecondary =
        theme.textTheme.bodyMedium?.color?.withOpacity(0.8) ??
            Colors.grey[400]!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isUnlocked
            ? const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFBBF24)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        color: isUnlocked ? null : theme.cardColor,
        boxShadow: [
          if (isUnlocked)
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            achievement.icon,
            style: TextStyle(
              fontSize: 48,
              color: isUnlocked ? null : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            achievement.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isUnlocked ? Colors.black87 : textColorPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            achievement.description,
            style: TextStyle(
              fontSize: 11,
              color: isUnlocked ? Colors.black54 : textColorSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          if (!isUnlocked)
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: achievement.progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${achievement.currentCount} / ${achievement.requiredCount}',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
        ],
      ),
    );
  }
}