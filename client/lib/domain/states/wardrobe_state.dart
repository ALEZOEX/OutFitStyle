import 'package:freezed_annotation/freezed_annotation.dart';
import '../entities/wardrobe_entity.dart';
import 'async_state.dart';

part 'wardrobe_state.freezed.dart';

@freezed
class WardrobeState with _$WardrobeState {
  const factory WardrobeState({
    @Default(AsyncLoading<List<WardrobeEntry>>())
    AsyncState<List<WardrobeEntry>> wardrobeItems,
    @Default(false) bool isLoading,
    String? error,
  }) = _WardrobeState;

  const WardrobeState._();
}