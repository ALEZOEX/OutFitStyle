// lib/features/auth/presentation/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di.dart';
import '../../../app/session/session_controller.dart';
import '../../../ui/atoms/haptics.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);

  final _loginEmail = TextEditingController();
  final _loginPass = TextEditingController();

  final _regName = TextEditingController();
  final _regEmail = TextEditingController();
  final _regPass = TextEditingController();

  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _tabs.dispose();
    _loginEmail.dispose();
    _loginPass.dispose();
    _regName.dispose();
    _regEmail.dispose();
    _regPass.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    if (_busy) return;
    setState(() { _busy = true; _error = null; });

    try {
      await ref.read(authRepositoryProvider).login(
        email: _loginEmail.text.trim(),
        password: _loginPass.text,
      );
      Haptics.success();
      await ref.read(sessionProvider.notifier).refreshSession();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _doRegister() async {
    if (_busy) return;
    setState(() { _busy = true; _error = null; });

    try {
      await ref.read(authRepositoryProvider).register(
        name: _regName.text.trim(),
        email: _regEmail.text.trim(),
        password: _regPass.text,
      );
      Haptics.success();
      await ref.read(sessionProvider.notifier).refreshSession();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Вход'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Войти'),
            Tab(text: 'Регистрация'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _buildLogin(),
          _buildRegister(),
        ],
      ),
    );
  }

  Widget _buildLogin() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_error != null) _ErrorBox(_error!),
        TextField(
          controller: _loginEmail,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_rounded),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _loginPass,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Пароль',
            prefixIcon: Icon(Icons.lock_rounded),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _busy ? null : _doLogin,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: _busy
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Войти', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }

  Widget _buildRegister() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_error != null) _ErrorBox(_error!),
        TextField(
          controller: _regName,
          decoration: const InputDecoration(
            labelText: 'Имя',
            prefixIcon: Icon(Icons.person_rounded),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _regEmail,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_rounded),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _regPass,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Пароль',
            prefixIcon: Icon(Icons.lock_rounded),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _busy ? null : _doRegister,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: _busy
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Создать аккаунт', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String text;
  const _ErrorBox(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text),
    );
  }
}