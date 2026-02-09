import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:outfitstyle_client/app/di.dart';
import 'package:outfitstyle_client/domain/entities/wardrobe.dart' as domain;
import 'package:outfitstyle_client/data/repositories/wardrobe_repository.dart';

class MockWardrobeRepository extends Mock implements WardrobeRepository {}

class FakeWardrobeItem extends Fake implements domain.WardrobeItem {}

void main() {
  late ProviderContainer container;
  late MockWardrobeRepository repo;

  setUpAll(() {
    registerFallbackValue(FakeWardrobeItem());
  });

  setUp(() {
    repo = MockWardrobeRepository();

    when(() =>
            repo.watchWardrobe(includeArchived: any(named: 'includeArchived')))
        .thenAnswer((_) => const Stream.empty());

    container = ProviderContainer(
      overrides: [
        wardrobeRepositoryProvider.overrideWithValue(repo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('wardrobeControllerProvider: initial state is loading', () {
    final state = container.read(wardrobeControllerProvider);
    expect(state.wardrobeItems, const AsyncValue<List<domain.WardrobeItem>>.loading());
  });

  test('wardrobeStreamProvider: emits items from repository', () async {
    final items = [_entry('1'), _entry('2')];

    when(() => repo.watchWardrobe(includeArchived: false))
        .thenAnswer((_) => Stream.value(items));

    final result = await container.read(wardrobeStreamProvider.future);
    expect(result, items);

    verify(() => repo.watchWardrobe(includeArchived: false)).called(1);
  });

  test('wardrobeStreamProvider: propagates error from stream', () async {
    when(() => repo.watchWardrobe(includeArchived: false))
        .thenAnswer((_) => Stream.error(Exception('Network error')));

    await expectLater(
      container.read(wardrobeStreamProvider.future),
      throwsA(isA<Exception>()),
    );
  });

  test('toggleFavorite updates item in repository', () async {
    final e = _entry('1');
    when(() => repo.updateOne(any())).thenAnswer((_) async {});

    await container.read(wardrobeControllerProvider.notifier).toggleFavorite(e);

    verify(() => repo.updateOne(any())).called(1);
  });

  test('toggleArchived updates item in repository', () async {
    final e = _entry('1');
    when(() => repo.updateOne(any())).thenAnswer((_) async {});

    await container.read(wardrobeControllerProvider.notifier).toggleArchived(e);

    verify(() => repo.updateOne(any())).called(1);
  });

  test('markWorn updates item in repository', () async {
    final e = _entry('1');
    when(() => repo.updateOne(any())).thenAnswer((_) async {});

    await container.read(wardrobeControllerProvider.notifier).markWorn(e);

    verify(() => repo.updateOne(any())).called(1);
  });

  test('prefetchImages calls repo.prefetchMissingImages(limit: 40)', () async {
    when(() => repo.prefetchMissingImages(limit: any(named: 'limit')))
        .thenAnswer((_) async {});

    await container.read(wardrobeControllerProvider.notifier).prefetchImages([]);

    verify(() => repo.prefetchMissingImages(limit: 40)).called(1);
  });
}

domain.WardrobeItem _entry(String id) => domain.WardrobeItem(
      id: id,
      userId: 'test_user',
      clothingItemId: 'test_clothing_item',
      wearCount: 0,
      isFavorite: false,
      isArchived: false,
      condition: 'good',
      rainOk: false,
      snowOk: false,
      windOk: false,
      name: 'Item $id',
      category: 'tops',
      subcategory: 'shirts',
      style: '',
      iconEmoji: '👕',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      dirty: false,
      tags: [],
      purchaseDate: null,
      purchasePrice: null,
      purchaseCurrency: null,
      lastWornAt: null,
      minTemp: null,
      maxTemp: null,
      warmthLevel: null,
      imageUrl: null,
      blurHash: null,
      usage: null,
      materials: null,
      season: null,
      gender: null,
      fit: null,
      pattern: null,
      localImagePath: null,
      lastSyncedAt: null,
      customName: null,
      notes: null,
      serverId: null,
    );
