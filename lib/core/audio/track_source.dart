import 'package:just_audio/just_audio.dart';

/// Abstraction between a track reference and just_audio's [AudioSource].
/// Allows seamless future addition of remote (streaming) sources
/// without touching any playback or UI code — only this file changes.
abstract class TrackSource {
  const TrackSource();

  Future<AudioSource> toAudioSource();
}

/// A track sourced from the local filesystem.
class LocalTrackSource implements TrackSource {
  final String filePath;

  const LocalTrackSource(this.filePath);

  @override
  Future<AudioSource> toAudioSource() async {
    return AudioSource.uri(Uri.file(filePath));
  }
}

// ── Future additions (zero refactor of playback code required) ────────────────
// class RemoteTrackSource implements TrackSource {
//   final String url;
//   const RemoteTrackSource(this.url);
//   @override
//   Future<AudioSource> toAudioSource() async => AudioSource.uri(Uri.parse(url));
// }
