abstract class ISyncRepository {
  Future<void> syncWardrobe();
  Future<void> syncRecommendations();
  Future<void> syncProfile();
  Future<void> syncAchievements();
  Future<void> syncSettings();
  Future<void> syncAll();
  Future<bool> isSyncInProgress();
  Future<void> cancelSync();
  Future<Map<String, dynamic>> getSyncStatus();
  Future<void> forceSync();
  Future<void> scheduleSync();
  Future<void> unscheduleSync();
  Future<List<String>> getPendingSyncItems();
  Future<void> clearSyncQueue();
  Future<void> markAsSynced(String itemId, String entityType);
  Future<DateTime?> getLastSyncTime(String entityType);
  Future<void> setLastSyncTime(String entityType, DateTime time);
}