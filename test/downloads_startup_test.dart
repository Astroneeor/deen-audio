// Starting the download service at launch: a broken catalog is reported to
// the failure callback, not thrown into the app.
import 'package:deen_audio/core/providers/foundation_providers.dart';
import 'package:deen_audio/features/downloads/data/catalog.dart';
import 'package:deen_audio/features/downloads/data/catalog_loader.dart';
import 'package:deen_audio/features/downloads/providers/download_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_download_server.dart';
import 'support/memory_file_store.dart';

class _BrokenLoader implements CatalogLoader {
  @override
  Future<Catalog> load() async => Catalog.parse('{"packs": 3}');
}

void main() {
  testWidgets('a catalog that fails to parse is reported, not thrown', (
    tester,
  ) async {
    final failures = <Object>[];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogLoaderProvider.overrideWithValue(_BrokenLoader()),
          fileStoreProvider.overrideWithValue(MemoryFileStore()),
          downloadHttpClientProvider.overrideWithValue(
            FakeDownloadServer({}).client,
          ),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            startDownloadService(ref, onFailure: (e, _) => failures.add(e));
            return const SizedBox();
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(failures.single, isA<FormatException>());
  });
}
