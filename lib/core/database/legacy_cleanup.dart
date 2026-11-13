import 'package:flutter/foundation.dart';

import '../storage/file_store.dart';
import 'device_settings_repository.dart';

/// device_settings key set once the pre-SQLite files have been removed.
const legacyCleanedKey = 'legacy.cleaned';

/// Files left in the app-support directory by versions before the SQLite
/// database: the Isar database and the per-setting text/JSON files whose
/// contents now live in SQLite.
const legacyFiles = [
  'deen_audio.isar',
  'deen_audio.isar.lock',
  'quran_font_size.txt',
  'prayer_location.json',
  'last_quran_position.txt',
  'last_library_folder.txt',
  'quran_data_version.txt',
];

/// Deletes [legacyFiles] from [appSupport] once, then records
/// [legacyCleanedKey] so later launches skip it.
///
/// Never throws: any failure is passed to [log] (debugPrint by default) and
/// the marker is left unset, so the next launch tries again.
Future<void> runLegacyCleanupOnce({
  required DeviceSettingsRepository device,
  required FileStore appSupport,
  void Function(String message)? log,
}) async {
  try {
    if (await device.read(legacyCleanedKey) != null) return;
    for (final name in legacyFiles) {
      if (await appSupport.exists(name)) await appSupport.delete(name);
    }
    await device.write(legacyCleanedKey, '1');
  } catch (e) {
    (log ?? debugPrint)('Legacy file cleanup failed (will retry): $e');
  }
}
