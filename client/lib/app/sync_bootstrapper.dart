import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/di.dart';

class SyncBootstrapper extends ConsumerStatefulWidget {
  final Widget child;
  const SyncBootstrapper({super.key, required this.child});

  @override
  ConsumerState<SyncBootstrapper> createState() => _SyncBootstrapperState();
}

class _SyncBootstrapperState extends ConsumerState<SyncBootstrapper>
    with WidgetsBindingObserver {
  StreamSubscription<List<ConnectivityResult>>? _sub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 1) пробуем синк на старте (если сети нет — просто ничего не выполнится успешно)
    // ignore: discarded_futures
    ref.read(syncWorkerProvider).startSync();

    // 2) слушаем сеть
    final conn = ref.read(connectivityProvider);
    _sub = conn.onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online) {
        // ignore: discarded_futures
        ref.read(syncWorkerProvider).startSync();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // ignore: discarded_futures
      ref.read(syncWorkerProvider).startSync();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}