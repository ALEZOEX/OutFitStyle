import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/user_preference.dart';
import '../../domain/entities/recommendation.dart';
import '../../presentation/providers/presentation_providers_exports.dart';
import 'presentation/widgets/statistics_card.dart';
import 'presentation/widgets/recommendation_history_item.dart';
import 'presentation/widgets/user_statistics_widget.dart';
import 'presentation/widgets/settings_section.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authState = ref.read(authStateNotifierProvider);
      final userId = authState.currentUser?.uid;
      if (userId != null) {
        ref.read(profileStateNotifierProvider.notifier).loadUserProfile(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateNotifierProvider);
    final profileState = ref.watch(profileStateNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit profile
            },
          ),
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'settings') {
                // Navigate to settings
              }
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'settings',
                    child: ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Настройки'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'help',
                    child: ListTile(
                      leading: Icon(Icons.help),
                      title: Text('Помощь'),
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final userId = authState.currentUser?.uid;
          if (userId != null) {
            await ref
                .read(profileStateNotifierProvider.notifier)
                .loadUserProfile(userId);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Profile header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColorDark,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          backgroundImage: () {
                            final avatarUrl =
                                profileState.userProfile?.avatarUrl;
                            if (avatarUrl != null && avatarUrl.isNotEmpty) {
                              return NetworkImage(avatarUrl);
                            }
                            return null;
                          }(),
                          child:
                              profileState.userProfile?.avatarUrl == null
                                  ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  )
                                  : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profileState.userProfile?.name ?? 'Пользователь',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      profileState.userProfile?.email ?? 'email@example.com',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.white70,
                        ),
                        Text(
                          profileState.userProfile?.location ?? 'Не указано',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Stats cards
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    StatisticsCard(
                      title: 'Создано образов',
                      value:
                          (profileState.userProfile?.outfitsCreated ?? 0)
                              .toString(),
                      icon: Icons.auto_awesome,
                    ),
                    StatisticsCard(
                      title: 'Лайков',
                      value:
                          (profileState.userProfile?.outfitsLiked ?? 0)
                              .toString(),
                      icon: Icons.favorite,
                    ),
                    StatisticsCard(
                      title: 'Стильные очки',
                      value:
                          (profileState.userProfile?.stylePoints ?? 0)
                              .toString(),
                      icon: Icons.star,
                    ),
                  ],
                ),
              ),

              // Social stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSocialStat(
                      'Подписчики',
                      (profileState.userProfile?.followers ?? 0).toString(),
                    ),
                    _buildSocialStat(
                      'Подписан',
                      (profileState.userProfile?.following ?? 0).toString(),
                    ),
                    _buildSocialStat(
                      'Стильность',
                      '${((profileState.userProfile?.stylePoints ?? 0) ~/ 10)}%',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Settings sections
              SettingsSection(
                title: 'Настройки приложения',
                items: [
                  SettingsItem(
                    title: 'Тема',
                    subtitle: 'Светлая/Темная/Системная',
                    icon: Icons.brightness_6,
                    trailing: PopupMenuButton<String>(
                      initialValue: 'system',
                      onSelected: (String value) {
                        // Handle theme selection
                      },
                      itemBuilder:
                          (BuildContext context) => const [
                            PopupMenuItem(
                              value: 'light',
                              child: Text('Светлая'),
                            ),
                            PopupMenuItem(value: 'dark', child: Text('Темная')),
                            PopupMenuItem(
                              value: 'system',
                              child: Text('Системная'),
                            ),
                          ],
                    ),
                  ),
                  SettingsItem(
                    title: 'Язык',
                    subtitle: 'Русский',
                    icon: Icons.language,
                    trailing: PopupMenuButton<String>(
                      initialValue: 'ru',
                      onSelected: (String value) {
                        // Handle language selection
                      },
                      itemBuilder:
                          (BuildContext context) => const [
                            PopupMenuItem(value: 'ru', child: Text('Русский')),
                            PopupMenuItem(value: 'en', child: Text('English')),
                          ],
                    ),
                  ),
                  SettingsItem(
                    title: 'Уведомления',
                    subtitle: 'Включены',
                    icon: Icons.notifications,
                    trailing: Switch(
                      value: true,
                      onChanged: (bool value) {
                        // Handle notification toggle
                      },
                    ),
                  ),
                ],
              ),

              SettingsSection(
                title: 'Информация',
                items: [
                  SettingsItem(
                    title: 'Личная информация',
                    subtitle: 'Имя, email, номер телефона',
                    icon: Icons.person,
                    onTap: () {},
                  ),
                  SettingsItem(
                    title: 'Предпочтения стиля',
                    subtitle: 'Цвета, бренды, размеры',
                    icon: Icons.palette,
                    onTap: () {},
                  ),
                  SettingsItem(
                    title: 'Местоположение',
                    subtitle:
                        profileState.userProfile?.location ?? 'Не указано',
                    icon: Icons.location_on,
                    onTap: () {},
                  ),
                ],
              ),

              SettingsSection(
                title: 'Безопасность',
                items: [
                  SettingsItem(
                    title: 'Безопасность',
                    subtitle: 'Пароль, двухфакторная аутентификация',
                    icon: Icons.lock,
                    onTap: () {},
                  ),
                  SettingsItem(
                    title: 'Конфиденциальность',
                    subtitle: 'Настройки приватности',
                    icon: Icons.privacy_tip,
                    onTap: () {},
                  ),
                ],
              ),

              // Recommendation History Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'История рекомендаций',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    ...List<RecommendationHistoryItem>.from(
                      profileState.recommendationHistory
                          .take(5)
                          .map(
                            (recommendation) => RecommendationHistoryItem(
                              recommendation: recommendation,
                              onTap: () {
                                // Handle recommendation tap
                              },
                            ),
                          ),
                    ),
                    if (profileState.recommendationHistory.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: Text('Рекомендации отсутствуют')),
                      ),
                  ],
                ),
              ),

              // User Statistics
              UserStatisticsWidget(statistics: profileState.statistics),

              // Logout button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(authStateNotifierProvider.notifier).signOut();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Выйти',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialStat(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(title, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
