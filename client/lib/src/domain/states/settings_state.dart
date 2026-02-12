import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.freezed.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState.initial() = _Initial;
  const factory SettingsState.loaded() = _Loaded;
  const factory SettingsState.updating() = _Updating;
  const factory SettingsState.updated() = _Updated;
  const factory SettingsState.error({
    required String message,
  }) = _Error;
}