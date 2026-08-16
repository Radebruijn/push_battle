-- De stad: per speler en per oefening een vesting. Goud verdien je met echte
-- herhalingen en met overvallen; gebouwen bepalen verdediging, bescherming en
-- aanvalskracht. RLS staat aan zonder policies: alles loopt via SECURITY
-- DEFINER-functies, net als bij de online duels.
--
-- Toepassen: plak dit bestand in de SQL-editor van het Supabase-project
-- 'orbslayer' (of laat Claude het doen zodra de databasekoppeling weer
-- schrijfrechten heeft) en voer het in één keer uit.

create table if not exists public.steden (
  user_id    uuid not null references auth.users(id) on delete cascade,
  sport      text not null check (sport in ('pushup', 'situp', 'squat')),
  goud       numeric not null default 0,
  gebouwen   jsonb   not null default '{}'::jsonb,
  schild_tot timestamptz,
  log        jsonb   not null default '[]'::jsonb,
  bijgewerkt timestamptz not null default now(),
  primary key (user_id, sport)
);
alter table public.steden enable row level security;

-- Wat één stad waard is in het veld: muur en toren tellen op.
create or replace function public.stad_verdediging(g jsonb)
returns integer language sql immutable as $$
  select 10 + coalesce((g->>'muur')::int, 0) * 10 + coalesce((g->>'toren')::int, 0) * 15
$$;

-- Welk deel van het goud veilig ligt: 20% + 10% per schatkamerniveau, max 70%.
create or replace function public.stad_bescherming(g jsonb)
returns numeric language sql immutable as $$
  select least(0.7, 0.2 + coalesce((g->>'schatkamer')::int, 0) * 0.1)
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
    'goud', floor(s.goud), 'gebouwen', s.gebouwen,
    'schild_tot', s.schild_tot, 'log', s.log,
    'verdediging', stad_verdediging(s.gebouwen),
    'bescherming', stad_bescherming(s.gebouwen));
end $$;

-- Goud uit trainen, gebundeld aangeleverd. De rem zit op de bundelgrootte:
-- meer dan 60 herhalingen per verzoek is geen training meer.
create or replace function public.stad_goud_erbij(p_sport text, p_aantal integer)
returns numeric language plpgsql security definer set search_path to 'public' as $$
declare nieuw numeric;
begin
  if auth.uid() is null then raise exception 'niet ingelogd'; end if;
  update public.steden
     set goud = goud + least(greatest(p_aantal, 0), 60), bijgewerkt = now()
   where user_id = auth.uid() and sport = p_sport
   returning floor(goud) into nieuw;
  return nieuw;
end $$;

-- Bouwen: de prijs is basis maal het nieuwe niveau in het kwadraat, en niets
-- mag boven het stadhuis uitkomen (het stadhuis zelf tot 5).
create or replace function public.stad_bouw(p_sport text, p_gebouw text)
returns jsonb language plpgsql security definer set search_path to 'public' as $$
declare
  s public.steden;
  basis integer;
  niveau integer;
  stadhuis integer;
  prijs numeric;
begin
  if auth.uid() is null then raise exception 'niet ingelogd'; end if;
  basis := case p_gebouw when 'muur' then 30 when 'toren' then 45
                         when 'schatkamer' then 40 when 'smederij' then 50
                         when 'stadhuis' then 100 else null end;
  if basis is null then raise exception 'onbekend gebouw'; end if;
  select * into s from public.steden
   where user_id = auth.uid() and sport = p_sport for update;
  if not found then raise exception 'geen stad'; end if;
  niveau := coalesce((s.gebouwen->>p_gebouw)::int, 0);
  stadhuis := coalesce((s.gebouwen->>'stadhuis')::int, 0);
  if p_gebouw = 'stadhuis' then
    if niveau >= 5 then raise exception 'hoogste niveau'; end if;
  elsif niveau >= greatest(stadhuis, 1) then
    raise exception 'eerst het stadhuis';
  end if;
  prijs := basis * (niveau + 1) * (niveau + 1);
  if s.goud < prijs then raise exception 'te weinig goud'; end if;
  update public.steden
     set goud = goud - prijs,
         gebouwen = jsonb_set(s.gebouwen, array[p_gebouw], to_jsonb(niveau + 1)),
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
    'verdediging', stad_verdediging(d.gebouwen),
    'buit_tot', floor(least(d.goud * (1 - stad_bescherming(d.gebouwen)) * 0.15, 200)));
end $$;

-- De overval zelf: de server rekent, schrijft bij beide steden en zet een
-- regel in het logboek van de verdediger. Twaalf uur schild na afloop.
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
  -- Meer dan 80 herhalingen in één minuut bestaat niet.
  kracht := least(greatest(p_reps, 0), 80)
            * (1 + coalesce((ik.gebouwen->>'smederij')::int, 0) * 0.1);
  gewonnen := kracht >= stad_verdediging(d.gebouwen);
  if gewonnen then
    buit := floor(least(d.goud * (1 - stad_bescherming(d.gebouwen)) * 0.15, 200));
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
                            'verdediging', stad_verdediging(d.gebouwen));
end $$;

grant execute on function public.stad_mijn(text) to authenticated;
grant execute on function public.stad_goud_erbij(text, integer) to authenticated;
grant execute on function public.stad_bouw(text, text) to authenticated;
grant execute on function public.stad_doelwit(text) to authenticated;
grant execute on function public.stad_overval(text, uuid, integer) to authenticated;
