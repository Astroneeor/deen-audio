import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;

/// Locates the Isar core binary that ships inside the `isar_flutter_libs`
/// package (resolved through .dart_tool/package_config.json) so repository
/// tests can run against a real, temporary Isar database without a device.
///
/// Returns false when no binary is available for the host platform; callers
/// should skip their tests in that case.
Future<bool> initIsarForTests() async {
  final config = File(p.join('.dart_tool', 'package_config.json'));
  if (!config.existsSync()) return false;

  final packages = (jsonDecode(config.readAsStringSync())
      as Map<String, dynamic>)['packages'] as List<dynamic>;
  final entry = packages.cast<Map<String, dynamic>>().where(
        (e) => e['name'] == 'isar_flutter_libs',
      );
  if (entry.isEmpty) return false;

  final root = Uri.parse(entry.first['rootUri'] as String);
  final rootPath = root.isAbsolute
      ? root.toFilePath()
      : p.normalize(p.join('.dart_tool', root.toFilePath()));

  final String relative;
  if (Platform.isLinux) {
    relative = p.join('linux', 'libisar.so');
  } else if (Platform.isMacOS) {
    relative = p.join('macos', 'libisar.dylib');
  } else if (Platform.isWindows) {
    relative = p.join('windows', 'isar.dll');
  } else {
    return false;
  }

  final lib = File(p.join(rootPath, relative));
  if (!lib.existsSync()) return false;

  await Isar.initializeIsarCore(libraries: {Abi.current(): lib.absolute.path});
  return true;
}
