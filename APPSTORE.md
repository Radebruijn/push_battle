# Push Battle in de App Store

Alles wat Apple bij de inzending vraagt staat hier klaar. Wat jij nog moet doen staat onderaan.

## Wat de app is

De app is het spel zelf, niet een snelkoppeling naar de website. `Orbslayer/web/index.html` — dezelfde pagina die op pushbattle.netlify.app staat — reist mee in de app en wordt van binnenuit geserveerd. De app opent dus **zonder internet**, en er verandert niets aan het spel: alle zeven spelmodi, drie oefeningen, je account en je muziek doen het zoals je gewend bent.

Wat er om die pagina heen native is:

| Onderdeel | Waarom |
|---|---|
| `PushBattleApp.swift` | zet de audiosessie op *playback*, zodat het schuifje aan de zijkant het geluid niet stilzet |
| `SpelScherm.swift` | volledig scherm zonder adresbalk, geeft de camera vrij, opent externe links in Safari, en laat de telefoon meetrillen bij elke getelde push-up (een tik) en elke kill (een klap) |
| `LokaleServer.swift` | serveert de meegeleverde pagina op `http://127.0.0.1`, alleen op het toestel zelf |

**Waarom een servertje en niet gewoon het bestand openen?** Twee harde redenen. De camera werkt alleen in een *veilige context*; `file://` is dat niet, `http://127.0.0.1` wel — zonder server telt de camera geen enkele push-up. En op `file://` weigert WebKit localStorage en IndexedDB, en daar staat alles in: je voortgang, je instellingen, je eigen muziek.

Het bouwscript kopieert de pagina automatisch naar `Orbslayer/web/`, dus `python3 bouw-proefversie.py` houdt de app vanzelf gelijk aan de website.

De oude Swift-versie van het spel (arena en duel, met de hand nagebouwd in SwiftUI) staat in `oud-swift-spel/` en doet niet meer mee. De gegenereerde gegevensbestanden staan in `spelgegevens/`.

## Wat er al klaar is

| Onderdeel | Status |
|---|---|
| App-icoon 1024×1024 | `Orbslayer/Assets.xcassets/AppIcon.appiconset/AppIcon.png`, gegenereerd door `appicoon.py` |
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

DRIE OEFENINGEN
Push-ups, sit-ups en squats zijn drie aparte werelden, elk met eigen voortgang, eigen arena's en een eigen klassement.

ARENA
Vecht je door eenentwintig werelden heen, van Orkenrijk naar Naamloze Diep. Elke tiende vijand is een boss. Doe je tien herhalingen achter elkaar, dan slaat elke volgende dubbel zo hard.

DUEL EN ONLINE
Zestig seconden tegen de computer, of tegen een echt mens. Je ziet tijdens de minuut of je voor of achter ligt.

WERELDBOSS
Eén monster waar iedereen tegelijk op slaat. Zijn kracht hangt af van hoeveel spelers er meedoen, en je beloning is je aandeel in de schade.

OP DE MAAT
Push-ups op het ritme van een nummer. Kies er een van het spel of zet er een van jezelf bij; het spel zoekt het tempo erbij, of je tikt de maat zelf mee.

CLICKER EN SEIZOENSPAD
Je push-ups tellen door terwijl je weg bent, en elke arena geeft kleine beloningen die je zelf ophaalt.

PRIVACY
Het camerabeeld wordt alleen op je eigen toestel bekeken. Er gaat geen enkel beeld naar een server, en er wordt niets opgenomen of bewaard. Elk apparaat vraagt apart om toestemming voor de camera.

Je kunt zonder account spelen. Maak je er wel een, dan gaat je voortgang mee naar je andere apparaten.

**Trefwoorden (max 100 tekens):**
pushup,push-up,fitness,workout,training,kracht,thuis,spel,game,reps,teller,camera

**Categorie:** Gezondheid en fitness (tweede: Spellen)

**Leeftijdsclassificatie:** 4+ — geen geweld dat Apple als zodanig telt (getekende monsters, geen bloed), geen aankopen.

## Privacyvragen van Apple

Bij *App Privacy* in App Store Connect:

- **Verzamel je gegevens?** Ja, één soort.
- **Contactgegevens → E-mailadres:** verzameld, gekoppeld aan de gebruiker, alleen voor *App-functionaliteit* (inloggen). Niet voor tracking, niet voor advertenties.
- **Gebruiksgegevens → Productinteractie:** verzameld, gekoppeld aan de gebruiker, alleen voor *App-functionaliteit* (je voortgang bewaren). Niet voor tracking.
- **Camera:** kies *niet verzameld*. Het beeld verlaat het toestel niet en wordt niet bewaard; het wordt alleen ter plekke geanalyseerd.
- **Tracking:** nee.

**Privacybeleid-URL:** `https://pushbattle.netlify.app/privacy.html` — die staat live, en Apple eist een werkende link.

## Wat de beoordelaar moet weten

Vul dit in bij *App Review Information → Notes*:

> De app telt push-ups met de camera. Zet het toestel rechtop naast de gebruiker; de camera volgt de hoogte van het hoofd. In de simulator is er geen camera — tik dan op het scherm om een herhaling te tellen, zodat alle schermen bereikbaar zijn.
>
> Een account is niet nodig om te spelen. Wil je het inloggen testen, maak dan een account aan met een willekeurig e-mailadres; er wordt geen bevestigingsmail gebruikt.
>
> Het spel draait binnen de app zelf en werkt zonder internet. Het lokale servertje op 127.0.0.1 dient alleen om de meegeleverde bestanden aan de ingebouwde weergave te geven; er gaat geen verkeer naar buiten. Online spelen, het klassement en de wereldboss gebruiken wel internet.

## Het risico dat je moet kennen

Apple weegt bij richtlijn **4.2 (Minimum Functionality)** of een app meer is dan een website in een jasje. Dat er een webweergave in zit is niet verboden — het gaat erom wat de app doet. In ons voordeel: het spel zit ín de app en werkt zonder internet, de camera is een echte iOS-functie met eigen toestemmingsvraag, er is haptische terugkoppeling bij elke herhaling, en het is een compleet spel met zeven modi.

Wordt hij toch afgewezen op 4.2, dan staat de reden in App Store Connect en zijn dit de gebruikelijke volgende stappen: meer native maken (bijvoorbeeld de telling en de camera naar Swift halen) of onderdelen toevoegen die alleen een app kan bieden, zoals meldingen of Game Center. Zeg het als het zover komt.

## Wat jij nog moet doen

1. **Xcode installeren** uit de Mac App Store. Op deze Mac staan nu alleen de command line tools, dus er kan hier nog niets gebouwd worden. Gratis, ongeveer tien gigabyte.
2. **Team instellen.** Open `Orbslayer.xcodeproj`, ga naar *Signing & Capabilities* en kies je Apple Developer-team. De rest van de instellingen staat al goed.
3. **Uitproberen.** Zeg het zodra Xcode er is: dan draai ik de app in de simulator, kijk of alles werkt en los op wat er misgaat. De Swift-bestanden zijn nog niet één keer gecompileerd, dus reken op wat kleine correcties.
4. **Screenshots maken.** Apple wil er minstens drie van een 6,7-inch iPhone. Die maak ik in de simulator zodra hij draait.
5. **Inzenden.** In Xcode: *Product → Archive*, dan *Distribute App*. Daarna in App Store Connect de teksten hierboven invullen en op *Submit for Review* drukken.

De beoordeling duurt meestal één tot drie dagen.
