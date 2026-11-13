import 'package:flutter/services.dart';

import 'catalog.dart';

/// Where the download catalog comes from. This step ships the bundled one
/// only; a later version can fetch a newer catalog from the owner's server.
abstract class CatalogLoader {
  Future<Catalog> load();
}

/// Loads the catalog bundled at [assetPath].
class AssetCatalogLoader implements CatalogLoader {
  const AssetCatalogLoader({
    this.assetPath = 'assets/catalog/catalog.json',
    this.bundle,
  });

  final String assetPath;

  /// Defaults to [rootBundle].
  final AssetBundle? bundle;

  @override
  Future<Catalog> load() async =>
      Catalog.parse(await (bundle ?? rootBundle).loadString(assetPath));
}
