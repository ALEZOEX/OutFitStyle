import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import '../di.dart';

enum SessionStatus { unknown, authed, guest }

final sessionProvider = NotifierProvider<SessionController, SessionStatus>(SessionController.new);

class SessionController extends Notifier<SessionStatus> {
  @override
  SessionStatus build() {
    _load();
    return SessionStatus.unknown;
  }

  Future<void> _load() async {
    final repo = ref.read(authRepositoryProvider);
    state = (await repo.isAuthed()) ? SessionStatus.authed : SessionStatus.guest;
  }

  Future<void> refreshSession() => _load();

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = SessionStatus.guest;
  }
}