import 'package:deen_audio/core/database/app_database.dart';
import 'package:deen_audio/core/database/device_settings_repository.dart';
import 'package:deen_audio/core/database/legacy_cleanup.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/memory_file_store.dart';
import 'support/test_database.dart';

const _legacyFiles = [
  'deen_audio.isar',
  'deen_audio.isar.lock',
  'quran_font_size.txt',
  'prayer_location.json',
  'last_quran_position.txt',
  'last_library_folder.txt',
  'quran_data_version.txt',
];

void main() {
  late AppDatabase db;
  late DeviceSettingsRepository device;
  late MemoryFileStore files;

  setUp(() {
    db = testDatabase();
    device = DeviceSettingsRepository(db);
    files = MemoryFileStore();
  });
  tearDown(() => db.close());

  test('deletes every legacy file, keeps others and sets the marker', () async {
    for (final f in _legacyFiles) {
      files.files[f] = [1, 2, 3];
    }
    files.files['downloads/keep.mp3'] = [9];

    await runLegacyCleanupOnce(device: device, appSupport: files);

    for (final f in _legacyFiles) {
      expect(await files.exists(f), isFalse, reason: f);
    }
    expect(await files.exists('downloads/keep.mp3'), isTrue);
    expect(await device.read(legacyCleanedKey), '1');
  });

  test('missing files are fine and still set the marker', () async {
    await runLegacyCleanupOnce(device: device, appSupport: files);
    expect(await device.read(legacyCleanedKey), '1');
  });

  test('does nothing once the marker exists', () async {
    await runLegacyCleanupOnce(device: device, appSupport: files);
    files.files['quran_font_size.txt'] = [1];

    await runLegacyCleanupOnce(device: device, appSupport: files);

    expect(await files.exists('quran_font_size.txt'), isTrue);
  });

  test('a failing file store is logged, not thrown, and leaves no marker',
      () async {
    files.files['deen_audio.isar'] = [1];
    final logged = <String>[];

    await runLegacyCleanupOnce(
      device: device,
      appSupport: _ThrowingDeleteStore(files),
      log: logged.add,
    );

    expect(logged, isNotEmpty);
    expect(await device.read(legacyCleanedKey), isNull);
  });

  test('a failing settings read is logged, not thrown', () async {
    files.files['deen_audio.isar'] = [1];
    final logged = <String>[];

    await runLegacyCleanupOnce(
      device: _ThrowingDeviceSettings(db),
      appSupport: files,
      log: logged.add,
    );

    expect(logged, isNotEmpty);
    expect(await files.exists('deen_audio.isar'), isTrue);
  });
}

/// Delegates to a [MemoryFileStore] but fails every delete.
class _ThrowingDeleteStore extends MemoryFileStore {
  _ThrowingDeleteStore(this._inner);
  final MemoryFileStore _inner;

  @override
  Future<bool> exists(String rel) => _inner.exists(rel);

  @override
  Future<void> delete(String rel) async =>
      throw StateError('disk is read-only');
}

/// Fails every read, as a broken database would.
class _ThrowingDeviceSettings extends DeviceSettingsRepository {
  _ThrowingDeviceSettings(super.db);

  @override
  Future<String?> read(String key) async => throw StateError('db is broken');
}
