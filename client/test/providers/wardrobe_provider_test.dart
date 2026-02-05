import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:outfitstyle_client/app/di.dart';
import 'package:outfitstyle_client/domain/entities/wardrobe_entity.dart' as domain;
import 'package:outfitstyle_client/data/repositories/wardrobe_repository.dart';

class MockWardrobeRepository extends Mock implements WardrobeRepository {}

class FakeWardrobeEntry extends Fake implements domain.WardrobeEntry {}

void main() {
  late ProviderContainer container;
  late MockWardrobeRepository repo;

  setUpAll(() {
    registerFallbackValue(FakeWardrobeEntry());
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
    expect(state.wardrobeItems, const AsyncValue<List<domain.WardrobeEntry>>.loading());
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

domain.WardrobeEntry _entry(String id) => domain.WardrobeEntry(
      id: id,
      name: 'Item $id',
      category: 'tops',
      subcategory: 'shirts',
      style: '',
      iconEmoji: '👕',
      isFavorite: false,
      isArchived: false,
      wearCount: 0,
      updatedAt: DateTime(2024, 1, 1),
      dirty: false,
      lastSyncedAt: null,
      imageUrl: null,
      localImagePath: null,
      blurHash: null,
      rainOk: false,
      snowOk: false,
      windOk: false,
      createdAt: DateTime(2024, 1, 1),
    );
