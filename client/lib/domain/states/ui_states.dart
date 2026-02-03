import 'package:freezed_annotation/freezed_annotation.dart';
import '../entities/recommendation_entity.dart';
import '../entities/wardrobe_entity.dart';
import 'async_state.dart';

part 'ui_states.freezed.dart';

@freezed
class AdminState with _$AdminState {
  const factory AdminState({
    @Default(AsyncLoading<Map<String, dynamic>>())
    AsyncState<Map<String, dynamic>> adminData,
    @Default(false) bool isLoading,
    String? error,
  }) = _AdminState;

  const AdminState._();
}
