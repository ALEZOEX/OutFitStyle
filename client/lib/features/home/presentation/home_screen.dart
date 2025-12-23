import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/atoms/haptics.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeControllerProvider.notifier).bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final todayRec = ref.watch(homeTodayRecProvider);
    final err = ref.watch(homeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OutfitStyle'),
        actions: [
          IconButton(
            onPressed: () {
              Haptics.selection();
              ref.read(homeControllerProvider.notifier).bootstrap();
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        children: [
          if (err != null) ...[
            Text(
              'Ошибка синхронизации: $err',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 8),
          ],

          // Weather widget
          todayRec.when(
            loading: () => const SkeletonBox(width: double.infinity, height: 110),
            error: (e, _) => _InlineError(text: e.toString()),
            data: (rec) {
              if (rec == null) return const SkeletonBox(width: double.infinity, height: 110);
              final ctl = ref.read(homeControllerProvider.notifier);
              final weather = ctl.parseWeather(rec);
              return WeatherCard(weather: weather);
            },
          ),

          const SizedBox(height: 14),

          // Outfit of day (60% ощущения — крупная карточка)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: todayRec.when(
              loading: () => const SkeletonBox(width: double.infinity, height: double.infinity),
              error: (e, _) => _InlineError(text: e.toString()),
              data: (rec) {
                if (rec == null) {
                  return const SkeletonBox(width: double.infinity, height: double.infinity);
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

          // Timeline strip
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