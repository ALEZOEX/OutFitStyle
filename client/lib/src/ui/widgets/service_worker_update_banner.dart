import 'package:flutter/material.dart';
import 'package:outfitstyle_client/src/services/service_worker_update_service.dart';

/// Service Worker Update Banner Widget
///
/// Validates: Requirements 2.4
///
/// Displays a banner when a new version of the app is available,
/// allowing users to manually trigger the update.
class ServiceWorkerUpdateBanner extends StatefulWidget {
  final Widget child;

  const ServiceWorkerUpdateBanner({
    super.key,
    required this.child,
  });

  @override
  State<ServiceWorkerUpdateBanner> createState() => _ServiceWorkerUpdateBannerState();
}

class _ServiceWorkerUpdateBannerState extends State<ServiceWorkerUpdateBanner> {
  final _updateService = ServiceWorkerUpdateService();
  bool _showBanner = false;

  @override
  void initState() {
    super.initState();
    _updateService.initialize();

    // Listen for updates
    _updateService.updateAvailable.listen((isAvailable) {
      if (mounted && isAvailable) {
        setState(() {
          _showBanner = true;
        });
      }
    });
  }

  void _applyUpdate() {
    _updateService.applyUpdate();
  }

  void _dismissBanner() {
    setState(() {
      _showBanner = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showBanner)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              elevation: 4,
              color: Theme.of(context).colorScheme.primaryContainer,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.system_update,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Доступна новая версия приложения',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _applyUpdate,
                        child: const Text('Обновить'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _dismissBanner,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
