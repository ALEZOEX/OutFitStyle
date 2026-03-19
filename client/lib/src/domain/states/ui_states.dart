import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'ui_states.freezed.dart';

@freezed
abstract class AdminState with _$AdminState {
  const factory AdminState({
    @Default(AsyncValue.loading()) AsyncValue<Map<String, dynamic>> adminData,
    @Default(false) bool isLoading,
    String? error,
  }) = _AdminState;

  const AdminState._();
}
