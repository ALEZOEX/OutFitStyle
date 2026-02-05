import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:outfitstyle_client/data/repositories/wardrobe_repository.dart';
import 'package:outfitstyle_client/domain/entities/wardrobe_entity.dart' as domain;
import 'package:outfitstyle_client/app/di.dart';

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
        .thenAnswer((_) => Stream.value(<domain.WardrobeEntry>[]));

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
      expect(state.wardrobeItems, const AsyncValue<List<domain.WardrobeEntry>>.loading());
    });

    test('sync calls syncFromServer', () async {
      when(() => mockRepository.syncFromServer()).thenAnswer((_) async {});

      await container.read(wardrobeControllerProvider.notifier).sync();

      verify(() => mockRepository.syncFromServer()).called(1);
    });

    test('toggleFavorite updates item in repository', () async {
      final item = _entry('1');
      when(() => mockRepository.updateOne(any())).thenAnswer((_) async {});

      await container
          .read(wardrobeControllerProvider.notifier)
          .toggleFavorite(item);

      verify(() => mockRepository.updateOne(any())).called(1);
    });

    test('toggleArchived updates item in repository', () async {
      final item = _entry('1');
      when(() => mockRepository.updateOne(any())).thenAnswer((_) async {});

      await container
          .read(wardrobeControllerProvider.notifier)
          .toggleArchived(item);

      verify(() => mockRepository.updateOne(any())).called(1);
    });

    test('markWorn updates item in repository', () async {
      final item = _entry('1');
      when(() => mockRepository.updateOne(any())).thenAnswer((_) async {});

      await container.read(wardrobeControllerProvider.notifier).markWorn(item);

      verify(() => mockRepository.updateOne(any())).called(1);
    });

    test('prefetchImages calls with limit 40', () async {
      when(() =>
              mockRepository.prefetchMissingImages(limit: any(named: 'limit')))
          .thenAnswer((_) async {});

      await container
          .read(wardrobeControllerProvider.notifier)
          .prefetchImages([]);

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

domain.WardrobeEntry _entry(
  String id, {
  String category = 'tops',
  bool isFavorite = false,
}) {
  return domain.WardrobeEntry(
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
    rainOk: false,
    snowOk: false,
    windOk: false,
    createdAt: DateTime.now(),
  );
}
