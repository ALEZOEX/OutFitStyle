import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/auth_provider.dart';

class AuthWrapper extends ConsumerWidget {
  final Widget child;
  const AuthWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(authStateProvider);
    if (!isAuthenticated) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }
    return child;
  }
}
