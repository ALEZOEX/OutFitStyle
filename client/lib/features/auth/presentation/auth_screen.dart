import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di.dart';
import '../../../ui/atoms/haptics.dart';
import '../../../ui/design_system/outfit_style_components.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with TickerProviderStateMixin {
  final _loginEmail = TextEditingController();
  final _loginPassword = TextEditingController();

  final _registerName = TextEditingController();
  final _registerEmail = TextEditingController();
  final _registerPassword = TextEditingController();

  bool _loggingIn = false;
  bool _registering = false;
  bool _loggingInWithGoogle = false;
  String? _error;

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmail.dispose();
    _loginPassword.dispose();
    _registerName.dispose();
    _registerEmail.dispose();
    _registerPassword.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_loggingIn) return;
    setState(() {
      _loggingIn = true;
      _error = null;
    });

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.login(
        email: _loginEmail.text.trim(),
        password: _loginPassword.text,
      );
      Haptics.success();
      ref.read(sessionProvider.notifier).refreshSession();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loggingIn = false);
    }
  }

  Future<void> _register() async {
    if (_registering) return;
    setState(() {
      _registering = true;
      _error = null;
    });

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.register(
        name: _registerName.text.trim(),
        email: _registerEmail.text.trim(),
        password: _registerPassword.text,
      );
      Haptics.success();
      ref.read(sessionProvider.notifier).refreshSession();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _registering = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    if (_loggingInWithGoogle) return;
    setState(() {
      _loggingInWithGoogle = true;
      _error = null;
    });

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.loginWithGoogle();
      Haptics.success();
      ref.read(sessionProvider.notifier).refreshSession();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loggingInWithGoogle = false);
    }
  }

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Вход'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Войти'),
            Tab(text: 'Регистрация'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
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
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _loginPassword,
          decoration: const InputDecoration(
            labelText: 'Пароль',
            prefixIcon: Icon(Icons.lock_rounded),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _loggingIn ? null : _login,
          style: OutfitStyleComponents.primaryButtonStyle(),
          child: _loggingIn
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Войти',
                  style: TextStyle(fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 16),
        // Разделитель
        const Row(children: [
          Expanded(child: Divider()),
          Padding(padding: EdgeInsets.all(8), child: Text("ИЛИ")),
          Expanded(child: Divider())
        ]),
        const SizedBox(height: 16),
        // Кнопка Google
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: Icon(Icons.g_mobiledata,
                color: Colors.red), // Используем встроенную иконку Google
            label: const Text('Войти через Google'),
            onPressed: _loggingInWithGoogle ? null : _loginWithGoogle,
            style: OutfitStyleComponents.secondaryButtonStyle(),
          ),
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
          controller: _registerName,
          decoration: const InputDecoration(
            labelText: 'Имя',
            prefixIcon: Icon(Icons.person_rounded),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _registerEmail,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_rounded),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _registerPassword,
          decoration: const InputDecoration(
            labelText: 'Пароль',
            prefixIcon: Icon(Icons.lock_rounded),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _registering ? null : _register,
          style: OutfitStyleComponents.primaryButtonStyle(),
          child: _registering
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Создать аккаунт',
                  style: TextStyle(fontWeight: FontWeight.w800)),
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
