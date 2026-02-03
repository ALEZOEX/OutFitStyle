import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';
import 'dao/wardrobe_dao.dart';
import 'dao/recommendation_dao.dart';
import 'dao/sync_outbox_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [WardrobeEntries, Recommendations, SyncOutbox],
  daos: [WardrobeDao, RecommendationDao, SyncOutboxDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'outfitstyle_db'));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(syncOutbox);
          }
          if (from < 3) {
            await m.addColumn(recommendations, recommendations.origin);
            await m.addColumn(recommendations, recommendations.serverId);
          }
        },
      );
}
