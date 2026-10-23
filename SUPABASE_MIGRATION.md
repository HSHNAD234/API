# MongoDB → Supabase migration

Target project: `chthhamnnvssjeymqxhy` (HSHNAD234's Project).

## Safety status

This branch is preparatory. It does **not** switch production traffic away from MongoDB. Do not remove `MONGO_URI` or deploy a cutover until the remaining Mongoose document operations have been migrated and tested.

## Target mapping

| Existing Mongoose field | PostgreSQL field | Storage |
| --- | --- | --- |
| `steamId` | `steam_id` | text primary key |
| `auth` | `auth` | jsonb |
| `session_token` | `session_token` | text |
| `profile` | `profile` | jsonb |
| `coin`, `amethyst`, `amulet` | same snake_case | bigint |
| `characterSlot` | `character_slot` | jsonb |
| `role` | `role` | text |
| `banStatus` | `ban_status` | jsonb |
| `playerRecord` | `player_record` | jsonb |
| `stickerSlot` | `sticker_slot` | jsonb |
| `inventory` | `inventory` | jsonb |
| `immortalData` | `immortal_data` | jsonb |
| `isOnline`, `lastOnline` | `is_online`, `last_online` | boolean / timestamptz |
| Mongoose timestamps | `created_at`, `updated_at` | timestamptz |

Nested game structures are JSONB initially to preserve the existing API response shape; they can be normalized into related tables later without blocking the first migration.

## Required remaining work before cutover

1. Replace Mongoose model semantics (`findOne`, document mutation, `save()`, schema methods and query operators) with a repository that maps PostgreSQL rows to the legacy camelCase player shape.
2. Migrate every controller/service that imports the Mongoose model, including auth/session validation, player template creation, inventory, character slots, stickers, bans and immortal progress.
3. Add integration tests for Steam auth, session replacement, banned users, inventory reads/writes, profile edits, character-slot validation, sticker edits and immortal progress.
4. Export MongoDB data, transform camelCase fields into the mappings above, import into the target Supabase project, and compare row counts plus per-player balances/inventory before cutover.
5. Wire Admin to the same API/database using server-side credentials only. Never expose the Supabase service-role key in browser code.
6. Deploy to staging and smoke-test the game client before switching production.

## Environment variables

- `SUPABASE_URL`: Supabase project URL.
- `SUPABASE_SERVICE_ROLE_KEY`: server-only secret; never use in frontend/public environment variables.

The Supabase client is deliberately not imported by the existing startup path yet, so this preparatory branch does not change the currently running MongoDB service.
