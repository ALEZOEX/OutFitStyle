import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_storage.dart';
import '../providers/profile_provider.dart';
import '../utils/onboarding_rules.dart';

class SplashGateScreen extends StatefulWidget {
  const SplashGateScreen({super.key});

  @override
  State<SplashGateScreen> createState() => _SplashGateScreenState();
}

class _SplashGateScreenState extends State<SplashGateScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    if (_navigated) return;

    final storage = context.read<AuthStorage>();
    final token = await storage.readAccessToken();

    if (!mounted) return;

    if (token == null || token.isEmpty) {
      _navigated = true;
      Navigator.pushNamedAndRemoveUntil(context, '/auth', (r) => false);
      return;
    }

    // Есть токен → пробуем профиль (ApiService сам обновит токен при 401)
    final profileProvider = context.read<ProfileProvider>();
    await profileProvider.load();

    if (!mounted) return;

    final prof = profileProvider.profile;
    if (onboardingIncomplete(prof)) {
      _navigated = true;
      Navigator.pushNamedAndRemoveUntil(context, '/onboarding', (r) => false);
      return;
    }

    _navigated = true;
    Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}