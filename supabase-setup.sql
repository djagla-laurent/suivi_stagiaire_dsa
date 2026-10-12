-- À coller dans Supabase > SQL Editor > New query, puis cliquer sur "Run".
-- Ce script peut être relancé sans risque (il remplace les anciennes règles).

-- 1. Table des stagiaires
create table if not exists public.stagiaires (
  id            uuid primary key default gen_random_uuid(),
  nom           text not null check (char_length(nom) between 1 and 100),
  prenoms       text not null check (char_length(prenoms) between 1 and 100),
  type_stage    text not null check (char_length(type_stage) between 1 and 100),
  date_jour     date not null,
  heure_arrivee time not null,
  heure_sortie  time,
  created_at    timestamptz not null default now()
);

-- Agent qui a fait la saisie (rempli automatiquement)
alter table public.stagiaires
  add column if not exists saisi_par uuid default auth.uid();

-- 2. Liste des administrateurs
create table if not exists public.administrateurs (
  user_id uuid primary key references auth.users(id) on delete cascade
);
alter table public.administrateurs enable row level security;

create or replace function public.est_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (select 1 from public.administrateurs where user_id = auth.uid());
$$;

-- 3. Règles d'accès
alter table public.stagiaires enable row level security;

drop policy if exists "saisie publique" on public.stagiaires;
drop policy if exists "admin lecture" on public.stagiaires;
drop policy if exists "admin modification" on public.stagiaires;
drop policy if exists "admin suppression" on public.stagiaires;
drop policy if exists "agent ajout" on public.stagiaires;
drop policy if exists "lecture" on public.stagiaires;
drop policy if exists "modification" on public.stagiaires;
drop policy if exists "suppression" on public.stagiaires;

-- Tout compte connecté (agent ou administrateur) peut ajouter un stagiaire.
create policy "agent ajout"
  on public.stagiaires for insert
  to authenticated
  with check (saisi_par = auth.uid());

-- Administrateur : voit tout. Agent : voit seulement ses saisies des dernières 24 h.
create policy "lecture"
  on public.stagiaires for select
  to authenticated
  using (
    public.est_admin()
    or (saisi_par = auth.uid() and created_at > now() - interval '24 hours')
  );

-- Administrateur : modifie tout. Agent : seulement ses saisies des dernières 24 h
-- (utile pour enregistrer l'heure de sortie).
create policy "modification"
  on public.stagiaires for update
  to authenticated
  using (
    public.est_admin()
    or (saisi_par = auth.uid() and created_at > now() - interval '24 hours')
  )
  with check (
    public.est_admin()
    or (saisi_par = auth.uid() and created_at > now() - interval '24 hours')
  );

-- Seul l'administrateur peut supprimer.
create policy "suppression"
  on public.stagiaires for delete
  to authenticated
  using (public.est_admin());
