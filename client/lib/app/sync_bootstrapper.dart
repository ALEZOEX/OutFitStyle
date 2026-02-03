import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'di.dart';

class SyncBootstrapper extends ConsumerWidget {
  final Widget child;
  const SyncBootstrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Запускаем синхронизацию при инициализации
    useEffect(() {
      // Запускаем синхронизацию при запуске приложения
      ref.read(syncWorkerProvider).startSync();

      return null;
    }, const []);

    return child;
  }
}
