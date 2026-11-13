// packViewOf: which actions and failure reason a pack card shows.
import 'package:deen_audio/features/downloads/data/download_models.dart';
import 'package:deen_audio/features/downloads/providers/pack_view.dart';
import 'package:flutter_test/flutter_test.dart';

DownloadItem _row(int n, DownloadStatus status, {String? error}) =>
    DownloadItem(
      fileId: 'f$n',
      packId: 'p',
      status: status,
      relativePath: 'audio/p/$n.mp3',
      error: error,
    );

const _total = 4;

void main() {
  test('nothing started: Download all only', () {
    final v = packViewOf(total: _total, items: const []);
    expect(v.actions, [PackAction.downloadAll]);
    expect(v.failure, isNull);
  });

  test('failed and never-started files: Retry and Download all', () {
    final v = packViewOf(
      total: _total,
      items: [_row(1, DownloadStatus.failed, error: 'Offline')],
    );
    expect(v.actions, [PackAction.retry, PackAction.downloadAll]);
    expect(v.failure, 'Offline');
  });

  test('paused and never-started files: Resume and Download all', () {
    final v = packViewOf(
      total: _total,
      items: [_row(1, DownloadStatus.paused), _row(2, DownloadStatus.done)],
    );
    expect(v.actions, [PackAction.resume, PackAction.downloadAll]);
  });

  test('one running, the rest never started: Pause and Download all', () {
    final v = packViewOf(
      total: _total,
      items: [_row(1, DownloadStatus.running)],
    );
    expect(v.actions, [PackAction.pause, PackAction.downloadAll]);
  });

  test('every file has a row: no Download all', () {
    final v = packViewOf(
      total: _total,
      items: [
        _row(1, DownloadStatus.done),
        _row(2, DownloadStatus.done),
        _row(3, DownloadStatus.queued),
        _row(4, DownloadStatus.failed),
      ],
    );
    expect(v.actions, [PackAction.pause]);
  });

  test('a complete pack has no action', () {
    final v = packViewOf(
      total: 2,
      items: [_row(1, DownloadStatus.done), _row(2, DownloadStatus.done)],
    );
    expect(v.actions, isEmpty);
  });

  test('a failure without a reason still has a message', () {
    final v = packViewOf(total: 1, items: [_row(1, DownloadStatus.failed)]);
    expect(v.failure, 'Unknown error');
  });
}
