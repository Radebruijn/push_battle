-- De stad, tweede opzet. Push-ups verdien je overal in het spel; daarmee koop
-- je een mijn en een houtvester, die per push-up goud en hout opleveren (met
-- een daglimiet). Huizen geven plek aan soldaten: aanvallers vechten mee bij
-- overvallen, verdedigers bewaken je stad. Alles wordt op de server gerekend.
--
-- Toepassen: plak dit hele bestand in de SQL-editor van het Supabase-project
-- 'orbslayer' en voer het in één keer uit. Het ruimt een eventuele eerdere
-- versie van de stad zelf op.

drop function if exists public.stad_overval(text, uuid, integer);
drop function if exists public.stad_doelwit(text);
drop function if exists public.stad_bouw(text, text);
drop function if exists public.stad_goud_erbij(text, integer);
drop function if exists public.stad_reps(text, integer);
drop function if exists public.stad_koop(text, text);
drop function if exists public.stad_mijn(text);
drop function if exists public.stad_naam(uuid);
drop function if exists public.stad_verdediging(jsonb);
drop function if exists public.stad_bescherming(jsonb);
drop table if exists public.steden;

create table public.steden (
  user_id    uuid not null references auth.users(id) on delete cascade,
  sport      text not null check (sport in ('pushup', 'situp', 'squat')),
  pushups    numeric not null default 0,
  hout       numeric not null default 0,
  goud       numeric not null default 0,
  -- {mijn, houtvester, huis, aanval, verdediging}
  spullen    jsonb   not null default '{}'::jsonb,
  dag        date,
  dag_reps   integer not null default 0,
  schild_tot timestamptz,
  log        jsonb   not null default '[]'::jsonb,
  bijgewerkt timestamptz not null default now(),
  primary key (user_id, sport)
);
alter table public.steden enable row level security;

-- Hoe sterk een stad zich verweert: tien basis plus acht per verdediger.
create or replace function public.stad_verdediging(s jsonb)
returns integer language sql immutable as $$
  select 10 + coalesce((s->>'verdediging')::int, 0) * 8
$$;

-- De spelernaam, met hetzelfde filter als het klassement.
create or replace function public.stad_naam(p_id uuid)
returns text language sql stable security definer set search_path to 'public' as $$
  select case
    when naam_verboden(p.profile->>'naam')
      then 'Speler ' || upper(substr(replace(p.user_id::text, '-', ''), 1, 4))
    else coalesce(nullif(trim(p.profile->>'naam'), ''),
                  'Speler ' || upper(substr(replace(p.user_id::text, '-', ''), 1, 4)))
    end
  from public.progress p where p.user_id = p_id
$$;

-- Je eigen stad ophalen; bestaat hij nog niet, dan wordt hij aangelegd.
create or replace function public.stad_mijn(p_sport text)
returns jsonb language plpgsql security definer set search_path to 'public' as $$
declare s public.steden;
begin
  if auth.uid() is null then raise exception 'niet ingelogd'; end if;
  insert into public.steden (user_id, sport) values (auth.uid(), p_sport)
    on conflict (user_id, sport) do nothing;
  select * into s from public.steden where user_id = auth.uid() and sport = p_sport;
  return jsonb_build_object(
    'pushups', floor(s.pushups), 'hout', floor(s.hout), 'goud', floor(s.goud),
    'spullen', s.spullen, 'schild_tot', s.schild_tot, 'log', s.log,
    'verdediging', stad_verdediging(s.spullen),
    'dag_over', greatest(0, 300 - case when s.dag = current_date then s.dag_reps else 0 end));
end $$;

-- Echte herhalingen, gebundeld aangeleverd, waar in het spel ze ook gedaan
-- zijn. Elke herhaling is een push-up in de pot; de eerste driehonderd per
-- dag leveren daarbovenop hout (per houtvesterniveau) en goud (per
-- mijnniveau) op. Die daglimiet houdt de economie op tempo: trainen blijft
-- lonen, maar niemand groeit in één avond de lucht in.
create or replace function public.stad_reps(p_sport text, p_aantal integer)
returns jsonb language plpgsql security definer set search_path to 'public' as $$
declare
  s public.steden;
  n integer;
  productief integer;
begin
  if auth.uid() is null then raise exception 'niet ingelogd'; end if;
  insert into public.steden (user_id, sport) values (auth.uid(), p_sport)
    on conflict (user_id, sport) do nothing;
  select * into s from public.steden
   where user_id = auth.uid() and sport = p_sport for update;
  n := least(greatest(p_aantal, 0), 60);
  if s.dag is distinct from current_date then
    s.dag := current_date;
    s.dag_reps := 0;
  end if;
  productief := least(n, greatest(0, 300 - s.dag_reps));
  update public.steden set
    pushups = pushups + n,
    hout = hout + productief * coalesce((s.spullen->>'houtvester')::int, 0),
    goud = goud + productief * coalesce((s.spullen->>'mijn')::int, 0),
    dag = s.dag, dag_reps = s.dag_reps + n, bijgewerkt = now()
   where user_id = auth.uid() and sport = p_sport;
  return public.stad_mijn(p_sport);
end $$;

-- Kopen en verbeteren. De prijzen staan hier en nergens anders:
--   mijn        niveau n->n+1: 20 x 3^n push-ups + 30 x n hout, hoogstens 5
--   houtvester  niveau n->n+1: 20 x 3^n push-ups, hoogstens 5
--   huis        20 push-ups + 40 hout per stuk, hoogstens 6; plek voor 2 soldaten
--   aanval      30 goud per soldaat, zolang er plek is
--   verdediging 30 goud per verdediger, zolang er plek is
create or replace function public.stad_koop(p_sport text, p_wat text)
returns jsonb language plpgsql security definer set search_path to 'public' as $$
declare
  s public.steden;
  n integer;
  kost_p numeric := 0;
  kost_h numeric := 0;
  kost_g numeric := 0;
  huizen integer;
  soldaten integer;
begin
  if auth.uid() is null then raise exception 'niet ingelogd'; end if;
  select * into s from public.steden
   where user_id = auth.uid() and sport = p_sport for update;
  if not found then raise exception 'geen stad'; end if;
  n := coalesce((s.spullen->>p_wat)::int, 0);
  huizen := coalesce((s.spullen->>'huis')::int, 0);
  soldaten := coalesce((s.spullen->>'aanval')::int, 0)
            + coalesce((s.spullen->>'verdediging')::int, 0);
  if p_wat = 'mijn' then
    if n >= 5 then raise exception 'hoogste niveau'; end if;
    kost_p := 20 * power(3, n); kost_h := 30 * n;
  elsif p_wat = 'houtvester' then
    if n >= 5 then raise exception 'hoogste niveau'; end if;
    kost_p := 20 * power(3, n);
  elsif p_wat = 'huis' then
    if n >= 6 then raise exception 'hoogste niveau'; end if;
    kost_p := 20; kost_h := 40;
  elsif p_wat in ('aanval', 'verdediging') then
    if soldaten >= huizen * 2 then raise exception 'geen plek'; end if;
    kost_g := 30;
  else
    raise exception 'onbekend';
  end if;
  if s.pushups < kost_p or s.hout < kost_h or s.goud < kost_g then
    raise exception 'te duur';
  end if;
  update public.steden set
    pushups = pushups - kost_p, hout = hout - kost_h, goud = goud - kost_g,
    spullen = jsonb_set(s.spullen, array[p_wat], to_jsonb(n + 1)),
    bijgewerkt = now()
   where user_id = auth.uid() and sport = p_sport;
  return public.stad_mijn(p_sport);
end $$;

-- Een doelwit zoeken: een andere speler, zelfde oefening, geen schild.
create or replace function public.stad_doelwit(p_sport text)
returns jsonb language plpgsql security definer set search_path to 'public' as $$
declare d public.steden;
begin
  if auth.uid() is null then raise exception 'niet ingelogd'; end if;
  select * into d from public.steden
   where sport = p_sport and user_id <> auth.uid()
     and (schild_tot is null or schild_tot < now())
   order by random() limit 1;
  if not found then return null; end if;
  return jsonb_build_object(
    'doel', d.user_id,
    'naam', stad_naam(d.user_id),
    'verdediging', stad_verdediging(d.spullen),
    'buit_tot', floor(least(d.goud * 0.2, 250)));
end $$;

-- De overval: jouw kracht is je herhalingen (hoogstens 80 in een minuut)
-- plus vijf per aanvalssoldaat. Bij een doorbraak verhuist twintig procent
-- van het goud (hoogstens 250); de verdediger krijgt twaalf uur een schild
-- en een regel in zijn logboek.
create or replace function public.stad_overval(p_sport text, p_doel uuid, p_reps integer)
returns jsonb language plpgsql security definer set search_path to 'public' as $$
declare
  ik public.steden;
  d public.steden;
  kracht numeric;
  buit numeric := 0;
  gewonnen boolean;
  regel jsonb;
begin
  if auth.uid() is null then raise exception 'niet ingelogd'; end if;
  if p_doel = auth.uid() then raise exception 'niet jezelf'; end if;
  select * into ik from public.steden
   where user_id = auth.uid() and sport = p_sport for update;
  select * into d from public.steden
   where user_id = p_doel and sport = p_sport for update;
  if not found then raise exception 'geen doelwit'; end if;
  kracht := least(greatest(p_reps, 0), 80)
            + coalesce((ik.spullen->>'aanval')::int, 0) * 5;
  gewonnen := kracht >= stad_verdediging(d.spullen);
  if gewonnen then
    buit := floor(least(d.goud * 0.2, 250));
    update public.steden set goud = goud + buit, bijgewerkt = now()
     where user_id = auth.uid() and sport = p_sport;
  end if;
  regel := jsonb_build_object(
    'wanneer', extract(epoch from now()) * 1000,
    'wie', stad_naam(auth.uid()),
    'gewonnen', gewonnen, 'buit', buit);
  update public.steden
     set goud = goud - buit,
         schild_tot = now() + interval '12 hours',
         log = (select jsonb_agg(x) from (
                  select x from jsonb_array_elements(d.log || jsonb_build_array(regel)) x
                  order by (x->>'wanneer')::numeric desc limit 10) t),
         bijgewerkt = now()
   where user_id = p_doel and sport = p_sport;
  return jsonb_build_object('gewonnen', gewonnen, 'buit', buit,
                            'kracht', floor(kracht),
                            'verdediging', stad_verdediging(d.spullen));
end $$;

grant execute on function public.stad_mijn(text) to authenticated;
grant execute on function public.stad_reps(text, integer) to authenticated;
grant execute on function public.stad_koop(text, text) to authenticated;
grant execute on function public.stad_doelwit(text) to authenticated;
grant execute on function public.stad_overval(text, uuid, integer) to authenticated;

-- Vertel de API-laag meteen dat er nieuwe functies zijn.
notify pgrst, 'reload schema';
