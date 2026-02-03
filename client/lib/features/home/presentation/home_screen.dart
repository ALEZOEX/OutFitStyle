import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di.dart';
import '../../../ui/atoms/haptics.dart';
import '../../../ui/atoms/outfit_app_bar.dart';
import '../../../ui/atoms/skeleton.dart';
import 'home_controller.dart';
import 'widgets/weather_card.dart';
import 'widgets/outfit_of_day_card.dart';
import 'widgets/timeline_strip.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(homeControllerProvider.notifier).bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final todayRecAsync = ref.watch(homeTodayRecProvider);
    final error = ref.watch(homeControllerProvider);

    return Scaffold(
      appBar: OutfitAppBar(
        title: 'Главная',
        actions: [
          IconButton(
            onPressed: () async {
              Haptics.selection();
              await ref.read(homeControllerProvider.notifier).bootstrap();
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          if (error != null) ...[
            Text(
              'Ошибка синхронизации: $error',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 8),
          ],

          // Погода
          todayRecAsync.when(
            loading: () =>
                const SkeletonBox(width: double.infinity, height: 110),
            error: (e, _) => _InlineError(text: e.toString()),
            data: (rec) {
              if (rec == null)
                return const SkeletonBox(width: double.infinity, height: 110);
              final ctl = ref.read(homeControllerProvider.notifier);
              final weather = ctl.parseWeather(rec);
              return WeatherCard(weather: weather);
            },
          ),

          const SizedBox(height: 14),

          // Образ дня (60% ощущения — крупная карточка)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: todayRecAsync.when(
              loading: () => const SkeletonBox(
                  width: double.infinity, height: double.infinity),
              error: (e, _) => _InlineError(text: e.toString()),
              data: (rec) {
                if (rec == null) {
                  return const SkeletonBox(
                      width: double.infinity, height: double.infinity);
                }
                final ctl = ref.read(homeControllerProvider.notifier);
                final outfit = ctl.parseOutfit(rec);

                return OutfitOfDayCard(
                  recommendation: rec,
                  outfitData: outfit,
                  onLike: () async {
                    Haptics.selection();
                    await ctl.toggleFavorite(rec);
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 14),

          // Лента событий
          TimelineStrip(
            onSelect: (day) {
              Haptics.selection();
              // В идеале: "завтра" -> генерация с прогнозом.
              // Здесь пока UI-слой выбора даты готов.
            },
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String text;
  const _InlineError({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text),
    );
  }
}
