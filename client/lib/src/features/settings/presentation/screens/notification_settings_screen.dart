import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notification_settings_providers.dart';

/// Экран настроек уведомлений
///
/// Позволяет пользователю настроить предпочтения по типам уведомлений:
/// - Push уведомления
/// - Email уведомления
/// - SMS уведомления
class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Уведомления'),
        centerTitle: true,
        actions: [
          if (state.isSaving)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (state.hasUnsavedChanges)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveSettings,
              tooltip: 'Сохранить',
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Push уведомления
                _buildSection(
                  context,
                  title: 'Push-уведомления',
                  icon: Icons.notifications_active,
                  child: Column(
                    children: [
                      _buildGlobalToggle(
                        context,
                        title: 'Включить Push-уведомления',
                        subtitle: 'Разрешить push-уведомления от приложения',
                        value: state.settings.pushEnabled,
                        onChanged: (value) {
                          notifier.updatePushEnabled(value);
                        },
                      ),
                      if (state.settings.pushEnabled) ...[
                        const Divider(height: 24),
                        _buildToggle(
                          context,
                          icon: Icons.cloud,
                          title: 'Погодные предупреждения',
                          subtitle: 'Уведомления о неблагоприятной погоде',
                          value: state.settings.weatherAlerts,
                          onChanged: notifier.updateWeatherAlerts,
                        ),
                        _buildToggle(
                          context,
                          icon: Icons.auto_awesome,
                          title: 'Готовые рекомендации',
                          subtitle: 'Когда ИИ подготовил подборку образов',
                          value: state.settings.recommendationReady,
                          onChanged: notifier.updateRecommendationReady,
                        ),
                        _buildToggle(
                          context,
                          icon: Icons.new_releases,
                          title: 'Новые поступления',
                          subtitle: 'Обновления в вашем гардеробе',
                          value: state.settings.newArrivals,
                          onChanged: notifier.updateNewArrivals,
                        ),
                        _buildToggle(
                          context,
                          icon: Icons.emoji_events,
                          title: 'Достижения',
                          subtitle: 'Уведомления о полученных наградах',
                          value: state.settings.achievementUnlocked,
                          onChanged: notifier.updateAchievementUnlocked,
                        ),
                        _buildToggle(
                          context,
                          icon: Icons.flight_takeoff,
                          title: 'Поездки',
                          subtitle: 'Обновления и напоминания о поездках',
                          value: state.settings.tripUpdates,
                          onChanged: notifier.updateTripUpdates,
                        ),
                        _buildToggle(
                          context,
                          icon: Icons.calendar_today,
                          title: 'Напоминания',
                          subtitle: 'Напоминания о планировании образов',
                          value: state.settings.outfitReminders,
                          onChanged: notifier.updateOutfitReminders,
                        ),
                        _buildToggle(
                          context,
                          icon: Icons.card_membership,
                          title: 'Статус подписки',
                          subtitle: 'Информация о подписке и платежах',
                          value: state.settings.subscriptionStatus,
                          onChanged: notifier.updateSubscriptionStatus,
                        ),
                        const Divider(height: 24),
                        _buildToggle(
                          context,
                          icon: Icons.campaign,
                          title: 'Промо-уведомления',
                          subtitle: 'Акции, скидки и специальные предложения',
                          value: state.settings.promotional,
                          onChanged: notifier.updatePromotional,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Email уведомления
                _buildSection(
                  context,
                  title: 'Email-уведомления',
                  icon: Icons.email_outlined,
                  child: Column(
                    children: [
                      _buildGlobalToggle(
                        context,
                        title: 'Включить Email-уведомления',
                        subtitle: 'Получать уведомления на электронную почту',
                        value: state.settings.emailEnabled,
                        onChanged: (value) {
                          notifier.updateEmailEnabled(value);
                        },
                      ),
                      if (state.settings.emailEnabled) ...[
                        const Divider(height: 24),
                        _buildToggle(
                          context,
                          icon: Icons.cloud,
                          title: 'Погодные предупреждения',
                          subtitle: 'Email о неблагоприятной погоде',
                          value: state.settings.emailWeatherAlerts,
                          onChanged: notifier.updateEmailWeatherAlerts,
                        ),
                        _buildToggle(
                          context,
                          icon: Icons.auto_awesome,
                          title: 'Дайджест рекомендаций',
                          subtitle: 'Еженедельная подборка образов',
                          value: state.settings.emailRecommendationDigest,
                          onChanged: notifier.updateEmailRecommendationDigest,
                        ),
                        _buildToggle(
                          context,
                          icon: Icons.emoji_events,
                          title: 'Достижения',
                          subtitle: 'Email о полученных наградах',
                          value: state.settings.emailAchievements,
                          onChanged: notifier.updateEmailAchievements,
                        ),
                        _buildToggle(
                          context,
                          icon: Icons.card_membership,
                          title: 'Статус подписки',
                          subtitle: 'Информация о подписке и платежах',
                          value: state.settings.emailSubscriptionStatus,
                          onChanged: notifier.updateEmailSubscriptionStatus,
                        ),
                        const Divider(height: 24),
                        _buildToggle(
                          context,
                          icon: Icons.campaign,
                          title: 'Промо-Email',
                          subtitle: 'Акции, скидки и специальные предложения',
                          value: state.settings.emailPromotional,
                          onChanged: notifier.updateEmailPromotional,
                        ),
                        _buildToggle(
                          context,
                          icon: Icons.mail,
                          title: 'Newsletter',
                          subtitle: 'Новости и советы по стилю',
                          value: state.settings.emailNewsletter,
                          onChanged: notifier.updateEmailNewsletter,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // SMS уведомления
                _buildSection(
                  context,
                  title: 'SMS-уведомления',
                  icon: Icons.sms_outlined,
                  child: Column(
                    children: [
                      _buildGlobalToggle(
                        context,
                        title: 'Включить SMS-уведомления',
                        subtitle: 'Получать уведомления в виде SMS',
                        value: state.settings.smsEnabled,
                        onChanged: (value) {
                          notifier.updateSmsEnabled(value);
                        },
                      ),
                      if (state.settings.smsEnabled) ...[
                        const Divider(height: 24),
                        _buildToggle(
                          context,
                          icon: Icons.cloud,
                          title: 'Погодные предупреждения',
                          subtitle: 'SMS о критических погодных условиях',
                          value: state.settings.smsWeatherAlerts,
                          onChanged: notifier.updateSmsWeatherAlerts,
                        ),
                        _buildToggle(
                          context,
                          icon: Icons.calendar_today,
                          title: 'Срочные напоминания',
                          subtitle: 'Важные напоминания по SMS',
                          value: state.settings.smsReminders,
                          onChanged: notifier.updateSmsReminders,
                        ),
                        _buildToggle(
                          context,
                          icon: Icons.card_membership,
                          title: 'Статус подписки',
                          subtitle: 'Важная информация о подписке',
                          value: state.settings.smsSubscriptionStatus,
                          onChanged: notifier.updateSmsSubscriptionStatus,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Кнопка сохранения
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: state.hasUnsavedChanges ? _saveSettings : null,
                    icon: state.isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      state.hasUnsavedChanges ? 'Сохранить изменения' : 'Изменений нет',
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                if (state.error != null) ...[
                  const SizedBox(height: 16),
                  _buildErrorBanner(context, state.error!),
                ],
              ],
            ),
    );
  }

  /// Построить секцию с заголовком
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  /// Построить переключатель с иконкой
  Widget _buildToggle(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium,
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.5),
        activeThumbColor: theme.colorScheme.primary,
      ),
    );
  }

  /// Построить глобальный переключатель (для включения/выключения канала)
  Widget _buildGlobalToggle(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      dense: false,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: value
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          value ? Icons.check_circle : Icons.cancel,
          size: 20,
          color: value
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.5),
        activeThumbColor: theme.colorScheme.primary,
      ),
    );
  }

  /// Построить баннер ошибки
  Widget _buildErrorBanner(BuildContext context, String error) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              ref.read(notificationSettingsProvider.notifier).clearError();
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  /// Сохранить настройки
  Future<void> _saveSettings() async {
    final notifier = ref.read(notificationSettingsProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    final success = await notifier.saveSettings();

    if (!mounted) return;

    if (success) {
      messenger.showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Настройки сохранены'),
            ],
          ),
          backgroundColor: theme.colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(ref.read(notificationSettingsProvider).error ?? 'Ошибка сохранения'),
              ),
            ],
          ),
          backgroundColor: theme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}
