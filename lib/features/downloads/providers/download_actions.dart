import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/download_service.dart';
import 'download_providers.dart';

/// What the Downloads screen can ask for. Each call waits for the restored
/// [DownloadService]; failures are logged, since the outcome shows up in the
/// `download_items` rows the screen watches.
class DownloadActions {
  DownloadActions(this._service);

  final Future<DownloadService> Function() _service;

  Future<void> downloadPack(String packId) =>
      _run((s) => s.enqueuePack(packId));
  Future<void> downloadFile(String fileId) =>
      _run((s) => s.enqueueFile(fileId));
  Future<void> pausePack(String packId) => _run((s) => s.pausePack(packId));
  Future<void> pauseFile(String fileId) => _run((s) => s.pause(fileId));
  Future<void> resumePack(String packId) => _run((s) => s.resumePack(packId));
  Future<void> resumeFile(String fileId) => _run((s) => s.resume(fileId));
  Future<void> deletePack(String packId) => _run((s) => s.deletePack(packId));
  Future<void> deleteFile(String fileId) => _run((s) => s.deleteFile(fileId));

  Future<void> _run(Future<void> Function(DownloadService) action) async {
    try {
      await action(await _service());
    } catch (e, st) {
      developer.log(
        'Download action failed',
        name: 'downloads',
        error: e,
        stackTrace: st,
      );
    }
  }
}

/// Provides the user-facing download actions (start, pause, resume, delete).
final downloadActionsProvider = Provider<DownloadActions>(
  (ref) => DownloadActions(() => ref.read(downloadServiceProvider.future)),
);
