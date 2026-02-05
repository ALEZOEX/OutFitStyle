import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/wardrobe_entity.dart';

part 'wardrobe_state.freezed.dart';

@freezed
class WardrobeState with _$WardrobeState {
  const factory WardrobeState({
    @Default(AsyncValue.loading())
    AsyncValue<List<WardrobeEntry>> wardrobeItems,
    @Default(false) bool isLoading,
    String? error,
  }) = _WardrobeState;

  const WardrobeState._();
}