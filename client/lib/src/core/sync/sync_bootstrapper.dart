import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/sync/sync_worker.dart';

/// Провайдер SyncWorker
final syncWorkerProvider = Provider<SyncWorker>((ref) {
  throw UnimplementedError('Используйте syncWorkerProvider.override для инициализации');
});

/// Bootstrapper для инициализации синхронизации
class SyncBootstrapper extends ConsumerWidget {
  final Widget child;
  const SyncBootstrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Инициализирует SyncManager с необходимыми зависимостями
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // Получаем SyncWorker из провайдера
        final syncWorker = ref.read(syncWorkerProvider);
        // Запускаем начальную синхронизацию
        await syncWorker.sync();
      } catch (e) {
        // Логируем ошибку инициализации синхронизации
      }
    });

    return child;
  }
}