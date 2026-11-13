/// A user playlist (plain model; stored as `playlists` + `playlist_items`).
class Playlist {
  int id = 0;

  late String name;

  /// Track keys (see `Track.trackKey`), in playback order.
  List<String> trackKeys = [];

  DateTime createdAt = DateTime.now().toUtc();
}
