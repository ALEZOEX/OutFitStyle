// lib/src/core/network/network_info.dart

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // Простая реализация, позже можно добавить connectivity_plus
    return true;
  }
}
