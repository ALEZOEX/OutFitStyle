import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:outfitstyle/features/wardrobe/data/repositories/wardrobe_repository.dart';
import 'package:outfitstyle/features/wardrobe/domain/models/wardrobe_item.dart';
import 'package:outfitstyle/features/wardrobe/presentation/providers/wardrobe_provider.dart';

class MockWardrobeRepository extends Mock implements WardrobeRepository {}
class MockWardrobeItem extends Mock implements WardrobeItem {}

void main() {
  group('WardrobeProvider', () {
    late ProviderContainer container;
    late MockWardrobeRepository mockRepository;

    setUp(() {
      mockRepository = MockWardrobeRepository();
      container = ProviderContainer(
        overrides: [
          wardrobeRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is loading', () {
      final state = container.read(wardrobeProvider);
      expect(state.status, equals(WardrobeStatus.loading));
    });

    test('loads wardrobe items successfully', () async {
      final testItems = [
        MockWardrobeItem(),
        MockWardrobeItem(),
      ];
      when(() => mockRepository.getWardrobe()).thenAnswer((_) async => testItems);

      final stateFuture = container.read(wardrobeProvider.future);
      final state = await stateFuture;

      expect(state.status, equals(WardrobeStatus.loaded));
      expect(state.items, equals(testItems));
    });

    test('handles error when loading fails', () async {
      when(() => mockRepository.getWardrobe()).thenThrow(Exception('Network error'));

      final stateFuture = container.read(wardrobeProvider.future);
      final state = await stateFuture;

      expect(state.status, equals(WardrobeStatus.error));
      expect(state.errorMessage, contains('Network error'));
    });

    test('adds item to wardrobe', () async {
      final newItem = MockWardrobeItem();
      when(() => newItem.id).thenReturn('new-item');
      when(() => mockRepository.getWardrobe()).thenAnswer((_) async => []);
      when(() => mockRepository.addItem(any())).thenAnswer((_) async {});

      // First, load empty wardrobe
      await container.read(wardrobeProvider.future);

      // Add new item
      await container.read(wardrobeProvider.notifier).addItem(newItem);

      // Verify item was added
      verify(() => mockRepository.addItem(newItem)).called(1);
    });

    test('removes item from wardrobe', () async {
      final existingItem = MockWardrobeItem();
      when(() => existingItem.id).thenReturn('existing-item');
      when(() => mockRepository.getWardrobe()).thenAnswer((_) async => [existingItem]);
      when(() => mockRepository.removeItem('existing-item')).thenAnswer((_) async {});

      // Load wardrobe with existing item
      await container.read(wardrobeProvider.future);

      // Remove item
      await container.read(wardrobeProvider.notifier).removeItem('existing-item');

      // Verify item was removed
      verify(() => mockRepository.removeItem('existing-item')).called(1);
    });
  });
}