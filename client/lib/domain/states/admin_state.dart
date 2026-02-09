import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_state.freezed.dart';

@freezed
class AdminState with _$AdminState {
  const factory AdminState.initial() = AdminInitial;
  const factory AdminState.loading() = AdminLoading;
  const factory AdminState.loaded(Map<String, dynamic> stats) = AdminLoaded;
  const factory AdminState.error(String error) = AdminError;
}