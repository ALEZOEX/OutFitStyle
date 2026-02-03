import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:outfitstyle_client/data/repositories/wardrobe_repository.dart';
import 'package:outfitstyle_client/data/local/app_database.dart';
import 'package:outfitstyle_client/features/wardrobe/presentation/wardrobe_controller.dart';
import 'package:outfitstyle_client/app/di.dart';
import 'package:outfitstyle_client/domain/states/async_state.dart' as app_state;

class MockWardrobeRepository extends Mock implements WardrobeRepository {}

void main() {
  late MockWardrobeRepository mockRepository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(_entry('fallback'));
  });

  setUp(() {
    mockRepository = MockWardrobeRepository();

    when(() => mockRepository.watchWardrobe(
            includeArchived: any(named: 'includeArchived')))
        .thenAnswer((_) => Stream.value(<WardrobeEntry>[]));

    container = ProviderContainer(
      overrides: [
        wardrobeRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('WardrobeController', () {
    test('initial state is AsyncLoading', () {
      final state = container.read(wardrobeControllerProvider);
      expect(state, isA<app_state.AsyncLoading>());
    });

    test('sync calls syncFromServer', () async {
      when(() => mockRepository.syncFromServer()).thenAnswer((_) async {});

      await container.read(wardrobeControllerProvider.notifier).sync();

      verify(() => mockRepository.syncFromServer()).called(1);
    });

    test('toggleFavorite delegates to repository', () async {
      final item = _entry('1');
      when(() => mockRepository.toggleFavorite(any())).thenAnswer((_) async {});

      await container
          .read(wardrobeControllerProvider.notifier)
          .toggleFavorite(item);

      verify(() => mockRepository.toggleFavorite(item)).called(1);
    });

    test('toggleArchived delegates to repository', () async {
      final item = _entry('1');
      when(() => mockRepository.toggleArchived(any())).thenAnswer((_) async {});

      await container
          .read(wardrobeControllerProvider.notifier)
          .toggleArchived(item);

      verify(() => mockRepository.toggleArchived(item)).called(1);
    });

    test('markWorn delegates to repository', () async {
      final item = _entry('1');
      when(() => mockRepository.markWorn(any())).thenAnswer((_) async {});

      await container.read(wardrobeControllerProvider.notifier).markWorn(item);

      verify(() => mockRepository.markWorn(item)).called(1);
    });

    test('prefetchImages calls with limit 40', () async {
      when(() =>
              mockRepository.prefetchMissingImages(limit: any(named: 'limit')))
          .thenAnswer((_) async {});

      await container
          .read(wardrobeControllerProvider.notifier)
          .prefetchImages();

      verify(() => mockRepository.prefetchMissingImages(limit: 40)).called(1);
    });
  });

  group('wardrobeStreamProvider', () {
    test('emits items from repository', () async {
      final items = [_entry('1'), _entry('2')];
      when(() => mockRepository.watchWardrobe(includeArchived: false))
          .thenAnswer((_) => Stream.value(items));

      final result = await container.read(wardrobeStreamProvider.future);

      expect(result, equals(items));
    });

    test('emits empty list', () async {
      when(() => mockRepository.watchWardrobe(includeArchived: false))
          .thenAnswer((_) => Stream.value([]));

      final result = await container.read(wardrobeStreamProvider.future);

      expect(result, isEmpty);
    });
  });
}

WardrobeEntry _entry(
  String id, {
  String category = 'tops',
  bool isFavorite = false,
}) {
  return WardrobeEntry(
    id: id,
    name: 'Item $id',
    category: category,
    subcategory: 'shirts',
    style: '',
    iconEmoji: '👕',
    isFavorite: isFavorite,
    isArchived: false,
    wearCount: 0,
    updatedAt: DateTime.now(),
    dirty: false,
    lastSyncedAt: null,
    imageUrl: null,
    localImagePath: null,
    blurHash: null,
  );
}
