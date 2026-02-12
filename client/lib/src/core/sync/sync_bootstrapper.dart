import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncBootstrapper extends ConsumerWidget {
  final Widget child;
  const SyncBootstrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Инициализирует SyncManager с необходимыми зависимостями
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // TODO: Implement sync manager initialization when ready
    });

    return child;
  }
}