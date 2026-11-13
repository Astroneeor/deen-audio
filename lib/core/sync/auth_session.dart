/// Who is using the app on this installation.
abstract class AuthSession {
  /// UUID of this installation; stamped on every user-data write.
  String get deviceId;

  /// Account id once one is attached; null for the local user.
  String? get userId;
}

/// The permanent local user. There are no accounts yet, so [userId] is always
/// null; [deviceId] comes from `DeviceSettingsRepository.deviceId()`.
class LocalAuthSession implements AuthSession {
  const LocalAuthSession({required this.deviceId});

  @override
  final String deviceId;

  @override
  String? get userId => null;
}
