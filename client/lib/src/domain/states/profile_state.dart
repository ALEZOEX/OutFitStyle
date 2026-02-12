import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_state.freezed.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = _Initial;
  const factory ProfileState.loading() = _Loading;
  const factory ProfileState.loaded({
    required Map<String, dynamic> profile,
  }) = _Loaded;
  const factory ProfileState.updating() = _Updating;
  const factory ProfileState.updated() = _Updated;
  const factory ProfileState.error({
    required String message,
  }) = _Error;
}