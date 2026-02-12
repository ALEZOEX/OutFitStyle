import 'package:freezed_annotation/freezed_annotation.dart';
import '../entities/wardrobe.dart';

part 'wardrobe_state.freezed.dart';

@freezed
class WardrobeState with _$WardrobeState {
  const factory WardrobeState.initial() = _Initial;
  const factory WardrobeState.loading() = _Loading;
  const factory WardrobeState.loaded({
    required List<WardrobeItem> items,
  }) = _Loaded;
  const factory WardrobeState.error({
    required String message,
  }) = _Error;
  const factory WardrobeState.detail({
    required WardrobeItem item,
  }) = _Detail;
  const factory WardrobeState.editing({
    required WardrobeItem item,
  }) = _Editing;
}