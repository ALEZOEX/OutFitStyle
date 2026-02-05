import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'di.dart';
import '../core/sync/sync_manager.dart';

class SyncBootstrapper extends ConsumerWidget {
  final Widget child;
  const SyncBootstrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Инициализирует SyncManager с необходимыми зависимостями
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final syncWorker = ref.read(syncWorkerProvider);
      final profileRepository = ref.read(profileRepositoryProvider);
      final wardrobeRepository = ref.read(wardrobeRepositoryProvider);
      final recommendationsRepository = ref.read(recommendationsRepositoryProvider);

      await SyncManager().initialize(
        syncWorker: syncWorker,
        profileRepository: profileRepository,
        wardrobeRepository: wardrobeRepository,
        recommendationsRepository: recommendationsRepository,
      );

      // Запускает начальную синхронизацию
      syncWorker.startSync();
    });

    return child;
  }
}