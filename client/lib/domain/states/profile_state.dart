import 'package:freezed_annotation/freezed_annotation.dart';
import 'async_state.dart';

part 'profile_state.freezed.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default(AsyncLoading<Map<String, dynamic>>())
    AsyncState<Map<String, dynamic>> profileData,
    @Default(false) bool isLoading,
    String? error,
  }) = _ProfileState;

  const ProfileState._();
}