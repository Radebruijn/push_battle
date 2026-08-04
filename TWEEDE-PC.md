# Push Battle op een tweede computer

Dit project staat op GitHub (`Radebruijn/push_battle`), dus je kunt er op elke
computer aan werken. Eenmalig inrichten kost een minuut of tien; daarna is het
alleen nog ophalen en terugsturen.

## Eenmalig inrichten

**1. Installeer Claude Code** — de app of de CLI, net wat je prettig vindt.

**2. Maak een SSH-sleutel voor deze computer** en laat hem aan GitHub zien.
Open een terminal (of vraag het Claude):

```bash
ssh-keygen -t ed25519 -C "ruuddebruijn@me.com" -f ~/.ssh/id_ed25519 -N ""
cat ~/.ssh/id_ed25519.pub
```

Kopieer de regel die verschijnt (begint met `ssh-ed25519`) en plak hem op
<https://github.com/settings/ssh/new>. Let op: dat is de pagina van je
*account*, niet van een repository — na het toevoegen hoort de test
`ssh -T git@github.com` te zeggen **"Hi Radebruijn!"** zonder repositorynaam
erachter.

**3. Haal het project op:**

```bash
git clone git@github.com:Radebruijn/push_battle.git
```

**4. Vertel het Claude.** De map `.claude/` met instellingen reist niet mee via
GitHub. Zeg tegen Claude op de nieuwe computer:

> Richt dit project in zoals beschreven in TWEEDE-PC.md: maak een
> launch-configuratie voor de preview (python3 http.server op de projectmap)
> en zet toestemming klaar om automatisch te committen en pushen.

## De gewoonte die alles goed houdt

- **Vóór je begint:** `git pull` — haal op wat de andere computer heeft gedaan.
- **Als je klaar bent:** committen en pushen (Claude doet dit automatisch als
  je die toestemming hebt gegeven).

Werk niet op twee computers tegelijk in het project zonder tussendoor te
pushen; dan krijg je samenvoegconflicten. Push voordat je van stoel wisselt,
pull als je gaat zitten — dan gaat het altijd goed.

## Goed om te weten

- **Pushen naar `main` = publiceren.** Netlify zet elke push binnen een minuut
  live op <https://pushbattle.netlify.app>.
- **Na aanpassen van teksten of arena's:** draai
  `python3 taal.py && python3 bouw-proefversie.py` vóór het committen, zodat
  de gegenereerde bestanden meelopen (zie README voor uitleg).
- **Wat je verder nodig hebt op de nieuwe computer:** alleen Python 3 (staat op
  elke Mac; op Windows even installeren via python.org). Geen npm, geen
  pakketten — het spel is één zelfstandig HTML-bestand.
