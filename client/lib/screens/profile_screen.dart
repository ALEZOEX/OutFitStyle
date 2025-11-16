import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_settings.dart';
import '../providers/theme_provider.dart';
import '../services/onboarding_service.dart';
import '../theme/app_theme.dart';
import '../widgets/onboarding_dialog.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

// Временно импортируем заглушки для экранов, которые еще не созданы
// import 'history_screen.dart';
// import 'favorites_screen.dart';
// import 'achievements_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserSettings> _settingsFuture;

  @override
  void initState() {
    super.initState();
    _settingsFuture = UserSettings.load();
  }

  void _refreshSettings() {
    setState(() {
      _settingsFuture = UserSettings.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : const Color(0xFFF0F2F5),
      body: FutureBuilder<UserSettings>(
        future: _settingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text('Не удалось загрузить профиль: ${snapshot.error}'),
            );
          }

          final settings = snapshot.data!;

          return CustomScrollView(
            slivers: [
              // App Bar с профилем
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor:
                    isDark ? AppTheme.cardDark : const Color(0xFF007bff),
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? AppTheme.primaryGradient
                          : const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF007bff), Color(0xFF0056b3)],
                            ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30), // Уменьшен отступ
                          // Avatar
                          Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 48,
                                  backgroundColor: Colors.white,
                                  backgroundImage:
                                      (settings.avatarUrl != null &&
                                              settings.avatarUrl!.isNotEmpty)
                                          ? NetworkImage(settings.avatarUrl!)
                                          : null,
                                  child: (settings.avatarUrl == null ||
                                          settings.avatarUrl!.isEmpty)
                                      ? Text(
                                          settings.name.isNotEmpty
                                              ? settings.name[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF007bff),
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF28a745),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Name
                          Text(
                            settings.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Email
                          Text(
                            settings.email,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      // Stats cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                                '47', 'Рекомендаций', Icons.checkroom, isDark),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                                '12', 'Сохранено', Icons.bookmark, isDark),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                                '4.8', 'Средний рейтинг', Icons.star, isDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Preferences section
                      _buildSectionTitle('Мои предпочтения', isDark),
                      const SizedBox(height: 12),
                      _buildPreferenceCard(
                          'Стиль',
                          _getStyleName(settings.stylePreference),
                          Icons.style,
                          isDark,
                          () => _navigateToEditProfile(settings)),
                      const SizedBox(height: 8),
                      _buildPreferenceCard(
                          'Чувствительность к температуре',
                          _getSensitivityName(settings.temperatureSensitivity),
                          Icons.thermostat,
                          isDark,
                          () => _navigateToEditProfile(settings)),
                      const SizedBox(height: 8),
                      _buildPreferenceCard(
                          'Возрастная группа',
                          settings.ageRange,
                          Icons.calendar_today,
                          isDark,
                          () => _navigateToEditProfile(settings)),
                      const SizedBox(height: 24),

                      // Actions section
                      _buildSectionTitle('Разделы', isDark),
                      const SizedBox(height: 12),
                      _buildActionCard('Редактировать профиль', Icons.edit,
                          isDark, () => _navigateToEditProfile(settings)),
                      const SizedBox(height: 8),
                      _buildActionCard('Настройки приложения', Icons.settings,
                          isDark, () => _navigateToSettings(settings)),
                      const SizedBox(height: 8),
                      _buildActionCard('История рекомендаций', Icons.history,
                          isDark, _showComingSoon),
                      const SizedBox(height: 8),
                      _buildActionCard('Сохраненные комплекты',
                          Icons.bookmark_border, isDark, _showComingSoon),
                      const SizedBox(height: 8),
                      _buildActionCard('Достижения', Icons.emoji_events, isDark,
                          _showComingSoon),
                      const SizedBox(height: 8),
                      _buildActionCard(
                        'Пройти обучение снова',
                        Icons.school,
                        isDark,
                        () async {
                          await OnboardingService.resetOnboarding();
                          if (mounted) {
                            OnboardingDialog.showIfNeeded(context);
                          }
                        },
                      ),
                      const SizedBox(height: 24),

                      // Danger zone
                      _buildSectionTitle('Опасная зона', isDark),
                      const SizedBox(height: 12),
                      _buildActionCard(
                        'Удалить аккаунт',
                        Icons.delete_forever,
                        isDark,
                        _showDeleteAccountDialog,
                        isDestructive: true,
                      ),
                      const SizedBox(height: 32),

                      // Version
                      Text(
                        'OutfitStyle v1.0.0',
                        style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppTheme.textSecondary
                                : Colors.grey[600]),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
      String value, String label, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? Border.all(color: AppTheme.primary.withOpacity(0.3))
            : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2))
              ],
      ),
      child: Column(
        children: [
          Icon(icon,
              color: isDark ? AppTheme.primary : const Color(0xFF007bff),
              size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.textPrimary : Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
                fontSize: 11,
                color: isDark ? AppTheme.textSecondary : Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.textPrimary : Colors.black87),
      ),
    );
  }

  Widget _buildPreferenceCard(String title, String value, IconData icon,
      bool isDark, VoidCallback onTap) {
    return _buildActionCard(
      title,
      icon,
      isDark,
      onTap,
      trailing: Text(
        value,
        style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.primary : const Color(0xFF007bff)),
      ),
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, bool isDark, VoidCallback onTap,
      {Widget? trailing, bool isDestructive = false}) {
    final color = isDestructive
        ? AppTheme.danger
        : (isDark ? AppTheme.primary : const Color(0xFF007bff));
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isDark ? Border.all(color: color.withOpacity(0.3)) : null,
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2))
                  ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDestructive
                        ? AppTheme.danger
                        : (isDark ? AppTheme.textPrimary : Colors.black87),
                  ),
                ),
              ),
              trailing ??
                  Icon(Icons.chevron_right,
                      color:
                          isDark ? AppTheme.textSecondary : Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  String _getStyleName(String style) {
    switch (style) {
      case 'casual':
        return 'Повседневный';
      case 'business':
        return 'Деловой';
      case 'sporty':
        return 'Спортивный';
      case 'elegant':
        return 'Элегантный';
      default:
        return style;
    }
  }

  String _getSensitivityName(String sensitivity) {
    switch (sensitivity) {
      case 'cold':
        return 'Мерзну';
      case 'normal':
        return 'Нормально';
      case 'warm':
        return 'Жарко';
      default:
        return sensitivity;
    }
  }

  void _navigateToEditProfile(UserSettings settings) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditProfileScreen(settings: settings)),
    );
    if (result == true) {
      _refreshSettings();
    }
  }

  void _navigateToSettings(UserSettings settings) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SettingsScreen(settings: settings)),
    );
    if (result == true) {
      _refreshSettings();
    }
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 12),
            Text('Этот раздел скоро появится!'),
          ],
        ),
        backgroundColor: const Color(0xFF007bff),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить аккаунт?'),
        content: const Text(
            'Это действие необратимо. Все ваши данные будут удалены навсегда.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAccount();
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    await UserSettings.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Аккаунт удален'),
            ],
          ),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}
