# Sync readiness

Deen Audio has no accounts and no server today. This note records how the
local SQLite database is laid out so that adding sync later is an addition,
not a migration. **Nothing here is built yet** apart from the local columns and
the no-op interfaces listed under "What exists today".

Design source: `docs/superpowers/specs/2026-11-13-data-foundation-and-downloads-design.md`,
section "Sync-ready records".

## What exists today

Every **user-data** table (`lib/core/database/tables/user_tables.dart`)
carries the same five columns (`lib/core/database/sync_columns.dart`):

| Column | Meaning |
|---|---|
| `id` | UUID text primary key, generated on the device |
| `updated_at` | UTC time of the last write (stored as UTC milliseconds) |
| `deleted_at` | null, or the UTC time the row was deleted. Rows are hidden, not removed, so a deletion can travel to other devices |
| `device_id` | UUID of the installation that last wrote the row |
| `user_id` | null while the app runs as the local user; set once an account is attached |

User-data tables: `bookmarks`, `settings`, `playlists`, `playlist_items`,
`track_states`, `reading_sessions`.

Tables with a natural key declare it unique (`bookmarks (surah_number,
ayah_number)`, `settings (key)`, `track_states (track_key)`), so re-adding
something that was soft-deleted revives the same row and id instead of
creating a second one. `playlist_items (playlist_id, position)` is indexed for
ordering only and is deliberately not unique: soft-deleted rows keep their old
position and reordering passes through transient duplicates.

Not synced, ever:

- Content tables (`surahs`, `ayahs`): seeded from the bundled Quran JSON on
  each device and identical everywhere. Quran text is never edited or
  uploaded.
- Device tables (`tracks`, `download_items`, `device_settings`): file paths,
  download progress, the device id and other per-installation facts.

Supporting code:

- `SyncStamper` (`lib/core/sync/sync_stamper.dart`) is the one place writes
  get a new id, the UTC write time, `device_id` and `user_id`, so no
  repository forgets to stamp a row.
- `AuthSession` (`lib/core/sync/auth_session.dart`): today
  `LocalAuthSession`, a permanent local user (`userId == null`) whose device
  id lives in `device_settings`.
- `SyncService` (`lib/core/sync/sync_service.dart`): `push()`, `pull()`,
  `status`. Today `NoopSyncService`. Repositories never call it.

## Intended server mapping (future, Supabase / Postgres)

- **One Postgres table per user-data table**, with the same columns and the
  same names (`id uuid primary key`, `updated_at timestamptz`,
  `deleted_at timestamptz null`, `device_id uuid`, `user_id uuid`), plus the
  table's own columns and the same unique natural keys scoped by user
  (for example `unique (user_id, surah_number, ayah_number)` on `bookmarks`).
- **Row-level security** on every table: a user can select, insert and update
  only rows where `user_id = auth.uid()`. Rows are never hard-deleted by
  clients; deletion is `deleted_at = now()`.
- **Conflict rule: last write wins on `updated_at`.** When the same row (same
  `id`, or the same natural key) changed on two devices, the later
  `updated_at` is kept. All times are UTC, so comparison is a plain ordering.
- **Change tracking:** a coordinator (not the repositories) pushes local rows
  with `updated_at` after the last successful sync and pulls remote rows
  changed since then. Soft-deleted rows are pushed like any other change.
- **Attaching an account:** when a user signs in for the first time, local
  rows with `user_id IS NULL` are stamped with the new user id and pushed.
  `AuthSession` gains a signed-in implementation; nothing else changes.

Whether sync is hand-written against Supabase or done by a sync engine (for
example PowerSync, which pairs SQLite with Postgres) is left open; both work
with this layout.

## Rules for new tables

1. User data that should follow the user between devices: add `SyncColumns`,
   write through `SyncStamper`, soft-delete instead of deleting, and give it a
   unique natural key if it has one.
2. Anything device-specific (paths, caches, progress): a plain table in
   `device_tables.dart`, never synced.
3. Store every timestamp with `UtcDateTimeConverter`.
