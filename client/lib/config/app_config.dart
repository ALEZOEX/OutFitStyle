import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;

class AppConfig {
  static String get apiHost {
    if (!kDebugMode) return 'https://api.outfitstyle.com'; // prod URL without /api/v1

    if (kIsWeb) return 'http://localhost:8080';

    if (Platform.isAndroid) {
      // For emulator, use 10.0.2.2; for real device, use your local network IP
      const _useRealDevice = false; // Change this based on your setup
      const _localNetworkIp = '192.168.1.100'; // Replace with your actual IP
      return _useRealDevice ? 'http://$_localNetworkIp:8080' : 'http://10.0.2.2:8080';
    } else if (Platform.isIOS) {
      // For iOS simulator, you might need to use your local network IP
      const _useRealDevice = false;
      const _localNetworkIp = '192.168.1.100'; // Replace with your actual IP
      return _useRealDevice ? 'http://$_localNetworkIp:8080' : 'http://localhost:8080';
    }

    return 'http://localhost:8080';
  }
}