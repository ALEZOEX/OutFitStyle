import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di.dart';
import '../../../domain/states/async_state.dart' as app_state;

final meProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  try {
    return await repo.getMe();
  } catch (e) {
    // Если ошибка получения профиля, возвращаем null
    return null;
  }
});

final isAdminProvider = FutureProvider.autoDispose<bool>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  try {
    return await repo.isAdmin();
  } catch (e) {
    // Если ошибка проверки админки, считаем, что не админ
    return false;
  }
});

final profileControllerProvider =
    AutoDisposeNotifierProvider<ProfileController, app_state.AsyncState<String?>>(
  ProfileController.new,
);

class ProfileController extends AutoDisposeNotifier<app_state.AsyncState<String?>> {
  @override
  app_state.AsyncState<String?> build() {
    // Состояние контроллера — поверх стрима. Экран при этом подписан на streamProvider.
    return const app_state.AsyncLoading();
  }

  Future<void> refreshProfile() async {
    final repo = ref.read(profileRepositoryProvider);

    try {
      // Обновляем профиль (best effort)
      await repo.getMe();
      // Не выставляем success руками — данные придут через stream.
    } catch (e) {
      // Не показываем ошибку пользователю, т.к. у нас есть локальные данные
      // ignore: avoid_print
      // print('Profile sync error: $e'); // Logging would be handled by error handler
    }
  }
}