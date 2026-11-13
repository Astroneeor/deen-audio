/// State of synchronisation with the (future) server.
enum SyncStatus { disabled, idle, syncing, error }

/// Pushes local changes to, and pulls remote changes from, a sync server.
/// Repositories never call this; a later coordinator will, reading rows
/// changed since the last sync by `updated_at`.
abstract class SyncService {
  Future<void> push();
  Future<void> pull();
  Stream<SyncStatus> get status;
}

/// Sync while there are no accounts: does nothing, always [SyncStatus.disabled].
class NoopSyncService implements SyncService {
  const NoopSyncService();

  @override
  Future<void> push() async {}

  @override
  Future<void> pull() async {}

  @override
  Stream<SyncStatus> get status => Stream.value(SyncStatus.disabled);
}
