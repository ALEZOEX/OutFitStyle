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

// Recommendations and Wardrobe providers are defined in their respective feature modules
