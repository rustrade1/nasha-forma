create table if not exists public.family_settings (
  owner_id uuid primary key references auth.users(id) on delete cascade,
  start_date date not null,
  ruslan_start numeric(6,2) not null check (ruslan_start between 30 and 350),
  nastya_start numeric(6,2) not null check (nastya_start between 30 and 350),
  updated_at timestamptz not null default now()
);

create table if not exists public.daily_weights (
  owner_id uuid not null references auth.users(id) on delete cascade,
  person_idx smallint not null check (person_idx in (0,1)),
  entry_date date not null,
  weight_kg numeric(6,2) not null check (weight_kg between 30 and 350),
  updated_at timestamptz not null default now(),
  primary key (owner_id, person_idx, entry_date)
);

alter table public.family_settings enable row level security;
alter table public.daily_weights enable row level security;

create policy "family_settings_owner" on public.family_settings
  for all to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

create policy "daily_weights_owner" on public.daily_weights
  for all to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

grant select, insert, update, delete on public.family_settings to authenticated;
grant select, insert, update, delete on public.daily_weights to authenticated;

do $$
begin
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='family_settings') then
    alter publication supabase_realtime add table public.family_settings;
  end if;
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='daily_weights') then
    alter publication supabase_realtime add table public.daily_weights;
  end if;
end $$;
