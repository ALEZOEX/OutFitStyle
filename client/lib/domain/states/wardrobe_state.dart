import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:outfitstyle_client/domain/entities/wardrobe_item.dart';

part 'wardrobe_state.freezed.dart';

@freezed
class WardrobeState with _$WardrobeState {
  const factory WardrobeState.initial() = WardrobeInitial;
  const factory WardrobeState.loading() = WardrobeLoading;
  const factory WardrobeState.loaded(List<WardrobeItem> items) = WardrobeLoaded;
  const factory WardrobeState.error(String error) = WardrobeError;
}