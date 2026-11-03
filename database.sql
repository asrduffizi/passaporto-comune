-- Passaporto Comune: tabella dei passaporti, uno per utente.
-- Incolla tutto in Supabase → SQL Editor → New query, poi premi Run.

create table if not exists public.passports (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  home       text        not null default 'IT',
  places     jsonb       not null default '{}'::jsonb,
  spots      jsonb       not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

-- Se avevi già creato la tabella con la versione precedente, aggiunge la colonna dei luoghi.
alter table public.passports add column if not exists spots jsonb not null default '{}'::jsonb;

-- Sicurezza per riga: ogni utente vede e modifica solo il proprio passaporto.
alter table public.passports enable row level security;

drop policy if exists "leggo solo il mio"     on public.passports;
drop policy if exists "creo solo il mio"      on public.passports;
drop policy if exists "modifico solo il mio"  on public.passports;
drop policy if exists "cancello solo il mio"  on public.passports;

create policy "leggo solo il mio" on public.passports
  for select to authenticated using (auth.uid() = user_id);

create policy "creo solo il mio" on public.passports
  for insert to authenticated with check (auth.uid() = user_id);

create policy "modifico solo il mio" on public.passports
  for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "cancello solo il mio" on public.passports
  for delete to authenticated using (auth.uid() = user_id);

grant select, insert, update, delete on public.passports to authenticated;
