import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'profile_state.freezed.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default(AsyncValue.loading())
    AsyncValue<Map<String, dynamic>> profileData,
    @Default(false) bool isLoading,
    String? error,
  }) = _ProfileState;

  const ProfileState._();
}