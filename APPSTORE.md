# Push Battle in de App Store

Alles wat Apple bij de inzending vraagt, staat hier klaar. Wat jij nog moet doen staat onderaan.

## Wat er al klaar is

| Onderdeel | Status |
|---|---|
| App-icoon 1024×1024 | `Orbslayer/Assets.xcassets/AppIcon.appiconset/AppIcon.png` — gegenereerd door `appicoon.py` |
| Bundle-ID | `com.frenkdebruijn.orbslayer` |
| Versie | 1.0 (build 1) |
| Minimale iOS-versie | 17.0 |
| Schermstand | Alleen staand |
| Uitleg cameragebruik | Staat in de projectinstellingen, wordt getoond bij de toestemmingsvraag |
| Talen | Nederlands, Engels, Frans |

## Naam en teksten

**Naam:** Push Battle

**Ondertitel (max 30 tekens):** Push-ups tellen als gevecht

**Promotietekst (max 170 tekens):**
Zet je telefoon naast je neer en push. De camera telt je herhalingen en elke push-up is een klap tegen het monster voor je.

**Beschrijving:**

Push Battle maakt van push-ups een gevecht.

Zet je telefoon rechtop naast je op de grond. De camera volgt de hoogte van je hoofd en telt elke volledige push-up. Je hoeft niets aan te raken en niets bij te houden — je zakt, je komt omhoog, en het monster voor je krijgt een klap.

ARENA
Vecht je door twintig werelden heen, van de Orkvelden naar de Leegte. Elke tiende vijand is een boss die je in één sessie moet neerhalen. Doe je tien herhalingen achter elkaar, dan slaat elke volgende dubbel zo hard.

DUEL
Zestig seconden tegen een tegenstander. Jij kiest hoe zwaar: van warmlopen tot onmogelijk. Hoeveel hij gaat doen hoor je niet vooraf — je ziet alleen hoe zwaar het niveau is, en tijdens de minuut of je voor of achter ligt.

WAT JE OPBOUWT
Elke verslagen vijand levert XP op. Train elke dag en je reeks groeit, wat je meer XP oplevert. Je voortgang, je beste duels en je reeks staan bij elkaar op je accountscherm.

PRIVACY
Het camerabeeld wordt alleen op je eigen toestel bekeken. Er gaat geen enkel beeld naar een server, en er wordt niets opgenomen of bewaard. Elk apparaat vraagt apart om toestemming voor de camera.

Je kunt zonder account spelen. Maak je er wel een, dan gaat je voortgang mee naar je andere apparaten.

**Trefwoorden (max 100 tekens):**
pushup,push-up,fitness,workout,training,kracht,thuis,spel,game,reps,teller,camera

**Categorie:** Gezondheid en fitness (tweede: Spellen)

**Leeftijdsclassificatie:** 4+ — geen geweld dat Apple als zodanig telt (silhouetten, geen bloed), geen aankopen, geen gebruikersinteractie.

## Privacyvragen van Apple

Bij *App Privacy* in App Store Connect:

- **Verzamel je gegevens?** Ja, één soort.
- **Contactgegevens → E-mailadres:** verzameld, gekoppeld aan de gebruiker, alleen voor *App-functionaliteit* (inloggen). Niet voor tracking, niet voor advertenties.
- **Gebruiksgegevens → Productinteractie:** verzameld, gekoppeld aan de gebruiker, alleen voor *App-functionaliteit* (je voortgang bewaren). Niet voor tracking.
- **Camera:** kies *niet verzameld*. Het beeld verlaat het toestel niet en wordt niet bewaard; het wordt alleen ter plekke geanalyseerd.
- **Tracking:** nee.

**Privacybeleid-URL:** de pagina `privacy.html` uit dit project, gezet op je Netlify-site. Dat is `https://pushbattle.netlify.app/privacy.html`. Apple eist een werkende link.

## Wat de beoordelaar moet weten

Vul dit in bij *App Review Information → Notes*:

> De app telt push-ups met de camera. Zet het toestel rechtop naast de gebruiker; de camera volgt de hoogte van het hoofd. In de simulator is er geen camera — tik dan op het scherm om een herhaling te tellen, zodat alle schermen bereikbaar zijn.
>
> Een account is niet nodig om te spelen. Wil je het inloggen testen, maak dan een account aan met een willekeurig e-mailadres; er wordt geen bevestigingsmail gebruikt.

## Wat jij nog moet doen

1. **Xcode installeren** uit de Mac App Store. Gratis, ongeveer tien gigabyte.
2. **Apple Developer Program** — 99 euro per jaar, via [developer.apple.com/programs](https://developer.apple.com/programs/). Zonder dit lidmaatschap kun je niets in de App Store zetten. Aanmelden en betalen moet je zelf doen; dat kan ik niet voor je.
3. **Screenshots maken.** Apple wil er minstens drie, van een iPhone met een 6,7-inch scherm (bijvoorbeeld de iPhone 15 Pro Max in de simulator). Zeg het als het zover is, dan draai ik de app in de simulator en maak ik ze.
4. **Inzenden.** In Xcode: *Product → Archive*, dan *Distribute App*. Daarna in App Store Connect de teksten hierboven invullen en op *Submit for Review* drukken.

De beoordeling duurt meestal één tot drie dagen. Wordt hij afgewezen, dan staat in App Store Connect precies waarom, en kan ik het oplossen.
