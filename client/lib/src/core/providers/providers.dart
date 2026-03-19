// app/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

// Core providers
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// Define a simple enum for auth state to avoid import errors
enum AuthState { initial, authenticated, unauthenticated }

// Auth providers
final authStateProvider = StateProvider((ref) => AuthState.initial);

// Home providers
final currentIndexProvider = StateProvider((ref) => 0);

// Recommendations providers
final recommendationsProvider = FutureProvider((ref) async {
  // Implementation will depend on the actual repository
  return [];
});

// Wardrobe providers
final wardrobeItemsProvider = FutureProvider((ref) async {
  // Implementation will depend on the actual repository
  return [];
});

// Provider for DI container (will be implemented in di.dart)
final diContainerProvider = Provider(
  (ref) =>
      throw UnimplementedError(
        'DI Container provider must be implemented in main or app widget',
      ),
);
