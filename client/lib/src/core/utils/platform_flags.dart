import 'dart:io' show Platform;

/// Флаг платформы Android
bool get isAndroid => Platform.isAndroid;

/// Флаг платформы iOS
bool get isIOS => Platform.isIOS;

/// Флаг платформы Windows
bool get isWindows => Platform.isWindows;

/// Флаг платформы macOS
bool get isMacOS => Platform.isMacOS;

/// Флаг платформы Linux
bool get isLinux => Platform.isLinux;

/// Флаг платформы Fuchsia
bool get isFuchsia => Platform.isFuchsia;
