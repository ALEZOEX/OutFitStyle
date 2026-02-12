import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_state.freezed.dart';

@freezed
class AdminState with _$AdminState {
  const factory AdminState.initial() = _Initial;
  const factory AdminState.loading() = _Loading;
  const factory AdminState.dashboard({
    required Map<String, dynamic> stats,
  }) = _Dashboard;
  const factory AdminState.users({
    required List<Map<String, dynamic>> users,
  }) = _Users;
  const factory AdminState.error({
    required String message,
  }) = _Error;
}