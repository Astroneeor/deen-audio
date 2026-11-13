import 'package:uuid/uuid.dart';

import 'auth_session.dart';

/// The one place user-data writes get their sync stamps from: new row ids,
/// the UTC write time, and the device/user that wrote them.
class SyncStamper {
  SyncStamper({
    required AuthSession session,
    DateTime Function()? now,
    String Function()? newId,
  })  : _session = session,
        _now = now ?? DateTime.now,
        _newId = newId ?? const Uuid().v4;

  final AuthSession _session;
  final DateTime Function() _now;
  final String Function() _newId;

  /// A fresh UUID for a new row.
  String newId() => _newId();

  /// The current time, always in UTC.
  DateTime nowUtc() => _now().toUtc();

  String get deviceId => _session.deviceId;

  String? get userId => _session.userId;
}
