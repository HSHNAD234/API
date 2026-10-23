-- HSHO game API player storage.
-- Apply to project chthhamnnvssjeymqxhy only after reviewing existing schema.
-- Does not drop or rewrite existing tables.
create table if not exists public.players (
  steam_id text primary key check (steam_id ~ '^[0-9]{17}$'),
  auth jsonb not null default '[]'::jsonb,
  session_token text,
  profile jsonb not null default '{"display":"Profile_Default","displayName":"","lastNameUpdate":null,"updatedAt":null}'::jsonb,
  coin bigint not null default 250000 check (coin >= 0),
  amethyst bigint not null default 0 check (amethyst >= 0),
  amulet bigint not null default 0 check (amulet >= 0),
  character_slot jsonb not null default '{}'::jsonb,
  role text not null default 'survivor',
  ban_status jsonb not null default '{}'::jsonb,
  player_record jsonb not null default '{}'::jsonb,
  sticker_slot jsonb not null default '{}'::jsonb,
  inventory jsonb not null default '{}'::jsonb,
  immortal_data jsonb not null default '[]'::jsonb,
  is_online boolean not null default false,
  last_online timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists players_auth_ext_id_idx
  on public.players using gin (auth jsonb_path_ops);
create index if not exists players_is_online_idx on public.players (is_online);
create index if not exists players_last_online_idx on public.players (last_online desc);

alter table public.players enable row level security;
revoke all on public.players from anon, authenticated;
grant all on public.players to service_role;

-- Keep the game API's current JSON shape intact while the application layer
-- is migrated from Mongoose documents to plain PostgreSQL records.
