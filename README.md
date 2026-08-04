# Orbslayer

Push-up game voor iOS. De camera volgt de hoogte van je hoofd; elke push-up is een aanval op het monster voor je.

## De website

`index.html` is het hele spel in één bestand. Het heeft niets nodig om te draaien: geen server, geen installatie, geen account. Dubbelklikken werkt, maar voor de camera moet het via `https` of `localhost` geopend worden — dat is een beveiligingsregel van elke browser.

**De site staat live op [pushbattle.netlify.app](https://pushbattle.netlify.app).** Netlify is gekoppeld aan de GitHub-repository [Radebruijn/push_battle](https://github.com/Radebruijn/push_battle) en publiceert automatisch de map `website/` bij elke push naar `main`. Alles doet het daar, inclusief de camera en het hoofdherkenningsmodel.

Wil je iets aanpassen: draai `python3 bouw-proefversie.py`, commit, en push — Netlify zet het binnen een minuut live.

Alternatieven die net zo goed werken: GitHub Pages of Cloudflare Pages.

**Lokaal draaien:**

```bash
cd "/Users/frenkdebruijn/puch up" && python3 -m http.server 8765
```

Ga daarna naar **http://localhost:8765/**.

## Toestemming voor de camera

Voordat de camera opengaat, krijg je één keer per apparaat een scherm dat uitlegt waarom hij nodig is en wat er met het beeld gebeurt. Pas als je op **Camera toestaan** drukt, verschijnt de vraag van je browser of telefoon.

Dat antwoord hoort bij het apparaat, niet bij je account. Log je op een nieuwe telefoon in met hetzelfde account, dan komt je voortgang mee maar vraagt die telefoon opnieuw om de camera. Weiger je, of kies je **Zonder camera spelen**, dan wordt er niets onthouden en vraagt hij de volgende keer weer.

Er is nog een reden voor die knop: browsers op de telefoon openen de camera alleen als je net iets hebt aangeraakt. Automatisch starten wordt door Safari geweigerd. Het spel probeert het nog steeds vanzelf — dat werkt op een laptop — maar lukt dat niet, dan verschijnt dit scherm zodat één tik hem alsnog opent.

Gaat er iets mis, dan zie je dat: de melding verschijnt midden in beeld en blijft zes seconden staan. Weiger je de camera, dan onthoudt het spel dat niet als toestemming, zodat je het gewoon opnieuw kunt proberen.

Het beeld wordt alleen op je eigen toestel bekeken. Er gaat geen enkel beeld naar een server — ook niet als je ingelogd bent.

## Als er iets laadt

Op de momenten die even kunnen duren komt er een laadscherm met een draaiende ring en een regel die vertelt wát er gebeurt: de camera starten, de herkenning laden, inloggen, een account maken of je voortgang ophalen. Duurt het langer dan vier seconden, dan komt er een geruststellende regel onder: *dit kan even duren op een trage verbinding*.

Het zwaarste moment is de eerste keer dat de camera aangaat. Dan wordt het herkenningsmodel binnengehaald, en dat is een paar megabyte. Daarna zit het in de cache van je browser en gaat het snel.

## Hoe de camera je volgt

Het spel probeert eerst een houdingsmodel te downloaden dat de losse punten van je hoofd herkent — neus, ogen, oren. Lukt dat niet, bijvoorbeeld omdat de omgeving geen downloads toestaat of je offline bent, dan schakelt hij vanzelf over op silhouet-herkenning: hij vergelijkt het beeld met een langzaam meelopende achtergrond en volgt de bovenste rand van wat beweegt. Dat is jouw hoofd of schouders, en het werkt zonder ook maar iets te downloaden.

In beide gevallen zie je linksboven een camerabeeldje met de gevonden hoogte erin getekend, zodat je kunt controleren of hij je goed volgt.

## Talen

Het spel spreekt Nederlands, Engels en Frans. De keuze staat bij de instellingen, achter het tandwiel. Bij de eerste start volgt hij de taal van je toestel; kies je zelf iets, dan onthoudt hij dat. Arenanamen, rassen, bossen en de sfeerzinnen zijn allemaal vertaald — alleen de namen van de minions blijven overal gelijk, want dat zijn eigennamen.

Alle interfaceteksten staan in `taal.json`. Pas je daar iets aan, draai dan:

```bash
python3 taal.py && python3 bouw-proefversie.py
```

Dat schrijft `Orbslayer/Strings.swift` voor de app en zet dezelfde teksten in de browserversie, zodat die twee niet uit elkaar kunnen lopen. De vertalingen van de arena's zelf staan bij de arena's in `Orbslayer/Arena.swift`.

## Account en voortgang

Zonder account speel je gewoon door; je voortgang staat dan in de browser waarin je speelt. Log je in met de knop rechtsboven, dan gaat alles mee naar elk apparaat waarop je inlogt — je telefoon en je laptop delen dezelfde voortgang.

Op het accountscherm staan al je cijfers bij elkaar: push-ups, kills, uitgespeelde arena's, gewonnen duels, je streak en je level.

Bij het inloggen kijkt hij welke voortgang het verst is, die van de server of die van dit apparaat, en houdt de verste aan. Zo raak je nooit iets kwijt door in te loggen.

**Aanmelden zonder mail.** Supabase wil standaard een bevestigingsmail sturen bij elke aanmelding, en de ingebouwde mailserver staat maar een paar mails per uur toe — daar liep het spel op vast. Aanmelden gaat daarom via een eigen serverfunctie (`aanmelden`), die het account meteen bruikbaar maakt. Je hoeft geen mail te bevestigen en er is geen limiet.

**Eisen aan je wachtwoord.** Het moet met een hoofdletter beginnen, een cijfer bevatten, een leesteken bevatten en langer zijn dan zes tekens. Terwijl je typt zie je welke eisen je al haalt. Dezelfde controle draait ook op de server, zodat de regels niet te omzeilen zijn.

De gegevens staan in het Supabase-project `orbslayer` in tabel `progress`. Elke rij hoort bij één account, en de databaseregels zorgen dat niemand anders die kan lezen of wijzigen — dat is getest.

## De rondleiding

Open je het spel voor het eerst zonder account, dan begint een rondleiding van zes schermen die het hele scherm vult. Zolang die loopt kun je niets anders doen: alleen **Overslaan** rechtsboven en de knop onderaan reageren. De zes schermen leggen uit wat het spel is, hoe je je telefoon neerzet, hoe er geteld wordt, waarom kalibreren nodig is, welke spelmodi er zijn en wat een account oplevert. Elk scherm heeft een eigen tekening.

Linksboven staan drie knopjes voor de taal: NL, EN en FR. Je kunt dus meteen bij het eerste scherm overschakelen, zonder eerst de instellingen te zoeken. De hele rondleiding schakelt direct mee, tot de labels in de tekeningen aan toe, en die keuze blijft daarna gelden voor het hele spel.

Log je in met een bestaand account, dan krijg je hem niet — dan heb je het spel al eens gezien. Of je hem gehad hebt wordt per tabblad onthouden, niet per apparaat. Open je een nieuw tabblad of een andere browser, dan ben je voor het spel een nieuwe speler en krijg je hem opnieuw. Binnen hetzelfde tabblad herhaalt hij zich niet, ook niet als je ververst.

Je kunt hem altijd terughalen: bij de instellingen achter het tandwiel staat **Rondleiding opnieuw**. Ook handig als je wel bent ingelogd, want dan komt hij niet vanzelf.

Twee dingen die pas later kunnen gebeuren blijven kleine kaartjes onderin, omdat ze alleen op het moment zelf betekenis hebben: dat een boss in één keer neer moet, en dat tien herhalingen op rij dubbel raken.

## Klassement

De beker rechtsboven opent het klassement: iedereen met een account, hoogste level bovenaan. Elke speler krijgt het rangteken dat bij zijn level hoort, van een simpel streepje bij Rekruut tot een gevleugelde ster bij Onsterfelijke. Je eigen rij is goudomrand.

Tik op iemand en je ziet zijn cijfers: push-ups, kills, uitgespeelde arena's, gewonnen duels, streak en XP.

**Wat er nooit in staat, is een e-mailadres.** De server geeft alleen spelgegevens terug; e-mailadressen komen er niet in voor. Spelers verschijnen onder de naam die ze zelf kiezen, en wie er geen kiest krijgt iets als *Speler 9BBF*.

**Je naam kiezen.** Bovenaan het accountscherm staat een veld met een knop ernaast. Je mag er alles in zetten wat je wilt, tot vierentwintig tekens, inclusief spaties en emoji. De knop wordt pas actief zodra je iets verandert, en Enter werkt ook. Tik je in het klassement op je eigen rij, dan sta je meteen bij dat veld.

Je kunt de naam ook alvast kiezen zonder account; hij gaat dan mee zodra je er een maakt.

De acht rangen: Rekruut (streep), Vuistvechter (strepen), Orbjager (zwaard), Slachter (gekruiste zwaarden), Orbslayer (schild), Bossbreker (kroon), Legende (vlam) en Onsterfelijke (gevleugelde ster). Ze lopen ook in kleur op, van brons naar wit.

## Menu

Je begint in het menu. Bovenaan staan je rang, level en XP, daaronder de arena waar je nu in zit met de vijand die op je wacht en hoeveel minions je in deze arena al gevloerd hebt.

Onder **Hierna** staat een rij die je opzij kunt scrollen. De eerste drie kaartjes tonen de arena's die na deze komen: hun naam, hun ras en hun icoon, maar op slot. Je kunt er niet naartoe springen — ze gaan alleen open door de boss van de arena ervoor te verslaan. Daarachter loopt de rij door met vijftien vraagtekens, zodat je ziet hoever de weg nog reikt zonder te weten wat je te wachten staat.

Naast het burgermenu zit een tandwiel met de **instellingen**: je taal (Nederlands, Engels, Frans) en een schuifbalk voor hoe ver je moet zakken voordat een push-up telt, uitgedrukt als percentage van je gekalibreerde bereik. Standaard 60 procent; hoger is strenger, lager vergevingsgezinder. Daaronder zit de knop om opnieuw te kalibreren — die zet zo nodig eerst de camera aan.

De knop **Vechten** brengt je in het gevecht; linksboven ga je weer terug naar het menu. Let op: teruggaan zet een boss weer op volle HP.

## Spelmodi

Linksboven in het menu zit een burgermenu (☰). Daar kies je tussen vier modi.

**Arena** is de eindeloze modus die hierboven beschreven staat: minions, bosses en arena's.

**Duel** is een sprint van zestig seconden tegen een tegenstander. Je zet met een schuifbalk het niveau tussen 1 en 100 procent. Hoeveel push-ups hij gaat doen krijg je vooraf niet te horen — je ziet alleen hoe zwaar het niveau is, in woord en kleur:

| Niveau | Heet | Kleur | Winst | Verlies |
|---|---|---|---|---|
| 1–15% | Warmlopen | groen | 20–43 XP | 1–3 XP |
| 16–30% | Makkelijk | limoen | 44–99 XP | 3–6 XP |
| 31–45% | Stevig | geel | 100–165 XP | 6–10 XP |
| 46–60% | Pittig | goud | 170–243 XP | 10–15 XP |
| 61–75% | Zwaar | oranje | 248–332 XP | 15–20 XP |
| 76–88% | Brutaal | vuur | 338–417 XP | 20–25 XP |
| 89–97% | Meedogenloos | rood | 424–479 XP | 25–29 XP |
| 98–100% | Onmogelijk | bloedrood | 486–500 XP | 29–30 XP |

Zijn doel wisselt per poging een paar push-ups, ook al kies je hetzelfde percentage: op 50% ligt het rond de 42, maar het kan 39 of 45 worden. Zo voelt geen duel precies hetzelfde.

Tijdens de minuut lopen twee tellers met balken naast elkaar: die van jou en die van je tegenstander, zodat je op elk moment ziet of je voor of achter ligt. De camera loopt gewoon door, met dezelfde knop om hem aan te zetten en opnieuw te kalibreren als in de arena; onderin staat of hij je ziet. Haal je hem, dan win je en krijg je de volle XP; blijf je eronder, dan houd je ongeveer zes procent over. Honderd push-ups in één minuut is opzettelijk bijna onhaalbaar.

Je beste score per niveau wordt onthouden, en een gewonnen duel telt mee voor je dagelijkse streak. De XP komt in dezelfde pot als de arena, dus beide modi laten je speler-level groeien.

**Online** is hetzelfde duel van zestig seconden, maar dan tegen een echt mens. Je hebt er een account voor nodig — je speelt onder de naam die ook in het klassement staat — en je ziet er hoeveel spelers er op dit moment actief zijn en hoe je ervoor staat: gewonnen en verloren.

Er zijn twee manieren om een tegenstander te krijgen:

- **Zoek tegenstander** zet je in de rij. Staat er al iemand te wachten, dan begint het duel meteen; anders wacht je tot iemand anders op dezelfde knop drukt. Na vijfenzeventig seconden zonder tegenstander stopt het zoeken vanzelf.
- **Tegen een vriend spelen** geeft je een code van vier tekens. Geef die door; zodra je vriend hem invult, beginnen jullie samen. De code blijft een kwartier geldig en werkt ook in kleine letters.

Zodra jullie gekoppeld zijn telt de server af, en beide kanten beginnen op precies hetzelfde moment. Tijdens de minuut lopen de twee tellers naast elkaar, net als in het gewone duel — je tegenstander is groen in plaats van paars, zodat je ziet dat er iemand van vlees en bloed meedoet. De camera wordt in het beginscherm al gevraagd, want als je eenmaal gekoppeld bent loopt de klok.

Winnen levert XP op alsof je tegen een duel van jouw eigen tempo speelde: honderd push-ups in een minuut is ook hier het plafond. Verliezen geeft de gebruikelijke troostprijs, gelijkspel veertig procent. Een gewonnen online duel telt mee voor je streak en voor je duelteller op het accountscherm.

**Weglopen telt als verlies.** Middenin stoppen boekt de winst voor de ander; sluit je het tabblad, dan geeft de pagina dat nog net door. Lukt dat niet, dan merkt je tegenstander binnen vijftien seconden dat er niemand meer meedoet en wint hij alsnog.

**Hoe het onder water werkt.** Er is geen spelserver. De twee browsers wisselen elke negen tienden van een seconde hun stand uit via de database, en de server bepaalt het startmoment en de eindstand. Elk antwoord bevat de klok van de server, zodat beide spelers tegelijk beginnen en eindigen — ook als de ene telefoon een halve minuut voorloopt. Dat is ruim genoeg voor een race waarin je hooguit twee push-ups per seconde doet, en het houdt `index.html` één zelfstandig bestand zonder extra bibliotheken.

De duels staan in de tabellen `spelers` en `online_duels`. Niemand kan daar rechtstreeks bij: alles loopt via databasefuncties die als eigenaar draaien en zelf opzoeken wie je bent. Je kunt dus geen andermans score aanpassen, niet meekijken in een duel waar je niet in zit, en na de eindstand neemt de server niets meer aan.

## Clicker

**Clicker** is het spel dat op je push-ups draait, en er valt niets te tikken. Eén echte push-up is één push-up — de camera moet hem zien. Dat kan in dit scherm zelf met de knop **Trainen** (dan verschijnt de hoogtebalk en telt de camera mee), en het gebeurt vanzelf in de arena, het duel en online: die herhalingen betalen hier ook uit.

Daarna tellen je helpers vanzelf door, maar traag. Ze staan in **per uur**, niet per seconde, en de eerste verdient zichzelf pas in een dag terug. Zo blijft het een spel dat je met je lijf speelt en niet met je duim.

| Helper | Prijs | Levert op | Verdient zichzelf terug in |
|---|---|---|---|
| Extra Arm | 25 | 1 per uur | een dag |
| Jimbro | 300 | 5 per uur | 2,5 dag |
| Yogamatje | 2.400 | 20 per uur | 5 dagen |
| Halterbank | 19.200 | 80 per uur | 10 dagen |
| Sportschool | 120.000 | 300 per uur | 17 dagen |
| Bootcamp | 840.000 | 1.200 per uur | 29 dagen |
| Kazerne | 5,5 mln | 5.000 per uur | 46 dagen |
| Stadion | 34 mln | 20.000 per uur | 71 dagen |
| Push-upfabriek | 200 mln | 80.000 per uur | 104 dagen |
| Ruimtestation | 1,08 mld | 300.000 per uur | 150 dagen |
| Planeet Plank | 6 mld | 1,2 mln per uur | 208 dagen |
| De Oerpush-up | 35 mld | 5 mln per uur | 292 dagen |

Elke volgende van dezelfde soort is een vijfde duurder. Stapelen loont dus maar even; daarna moet je door naar de volgende soort. Met veertig push-ups per dag zit je na een week rond de tien per uur, na een maand rond de tweehonderd, na een jaar rond de negenduizend — en dan heb je nog niet eens de helft van de soorten gezien. Het spel is met opzet niet uit te spelen.

**Wat te koop is, zie je pas als je het kunt betalen.** Tot die tijd staat er alleen een prijs met een vraagteken erachter, net als de arena's die nog op slot staan. Zodra je er ooit genoeg voor had, blijft het zichtbaar — ook als je het weer uitgeeft.

**Er staat altijd bij wat iets doet**, in gewone getallen: *levert 5 per uur op*, *elke push-up gaat van 2 naar 4*, *Jimbro gaat van 25 per uur naar 50 per uur*.

**Twee soorten upgrades.** Verdubbelingen van een helper verschijnen pas als je er vijf van hebt, en kosten vijftien keer de stukprijs — die zijn er om naar toe te werken. Daarnaast is er een reeks die je met je lijf verdient: elke trap verdubbelt wat één push-up oplevert, en gaat pas open bij 50, 150, 400, 1.000 herhalingen enzovoort, tot een kwart miljoen.

**De winkel** is verbruik. De prijs staat in uren productie met een bodem eronder, dus hij groeit mee met je imperium en blijft op elk moment even zwaar.

| Wat | Effect | Prijs |
|---|---|---|
| Dubbele XP | 30 minuten dubbele XP in arena, duel en online | 3 uur productie, minstens 300 |
| Dubbele push-ups | 10 minuten alles dubbel | 1,5 uur, minstens 120 |
| Woede | 60 seconden telt elke push-up zeven keer | 5 uur, minstens 500 |
| Krachtvoer | je volgende 25 push-ups leveren vijf keer zoveel op | 8 uur, minstens 800 |

Woede is dus geen tikwedstrijd meer maar een oefening: één minuut, alles telt zevenvoudig.

**De gouden push-up** zweeft elke anderhalf tot vier minuten over het scherm, twaalf seconden lang. Meestal krijg je Woede, anders een greep push-ups ineens.

**Terwijl je weg bent** tellen je helpers door, op halve kracht en tot maximaal twaalf uur.

Alles staat in je profiel en gaat dus met je account mee. Tijdens het spelen wordt er alleen lokaal bewaard; de server krijgt je stand als je iets koopt of het scherm verlaat. Wordt de balans omgegooid, dan gaat `KLIK_VERSIE` omhoog en begint de clicker opnieuw — je vertelt dat één keer met een melding.

## Iconen

Vijanden heten naar wat ze zijn: in De Orkvelden vecht je tegen een Ork, in De Rottende Weiden tegen een Zombie, en de boss van een arena is de Grote variant daarvan. Elk soort heeft een eigen silhouet: een ork met slagtanden, een schedel, een spin, een vleermuis, een bliksemschicht in een ring, een oog in de leegte. Dat icoon is de vijand die je slaat — hij ademt, krimpt bij elke klap en verkleurt van de arenakleur naar bloedrood naarmate hij doodgaat. In het menu zie je dezelfde iconen klein terug op de kaartjes van komende arena's.

De iconen worden getekend door `iconen.py` en als SVG-pad in `Orbslayer/Arena.swift` gezet. Wil je er een aanpassen, bewerk dan de vorm in `iconen.py` en draai:

```bash
python3 iconen.py && python3 bouw-proefversie.py
```

Met `python3 iconen.py --preview` krijg je `overzicht-iconen.html`, waarin je alle twintig naast elkaar ziet.

## Gevonden worden

De pagina heeft een omschrijving, trefwoorden, een deelkaartje (het logo met een korte tekst als je de link deelt in WhatsApp of op sociale media) en gestructureerde gegevens die zoekmachines vertellen dat dit een gratis spel is. Er staat ook een korte, eerlijke omschrijving in de pagina zelf die zoekmachines kunnen lezen.

`robots.txt` en `sitemap.xml` staan in `website/`. De pagina die naar Netlify gaat is een volledig HTML-document met een taalinstelling en een echte kop; de artifactversie blijft zonder omhulsel, want die krijgt er zelf een.

Twee dingen die jij nog kunt doen zodra de site een vast adres heeft: meld hem aan bij [Google Search Console](https://search.google.com/search-console) zodat hij sneller wordt opgepikt, en vervang in `sitemap.xml` de relatieve adressen door je echte domein. Zoekmachines hebben meestal een paar dagen tot weken nodig voordat een nieuwe site opduikt.

## Naar de App Store

`APPSTORE.md` bevat alles wat Apple bij de inzending vraagt: de naam, ondertitel, beschrijving, trefwoorden, categorie, leeftijdsclassificatie en de antwoorden op de privacyvragen. Het app-icoon staat klaar en `privacy.html` is de privacypagina die Apple als werkende link eist.

Wat er nog nodig is en niet vanaf hier kan: Xcode installeren, lid worden van het Apple Developer Program (99 euro per jaar) en screenshots maken. De volledige stappen staan in `APPSTORE.md`.

## Het logo

Het logo is iemand in plankhouding met een ork die achter hem opdoemt — de held vooraan in goud, het monster erachter in gedempt groen. Het wordt getekend door `appicoon.py`, dat de orkvorm uit `Arena.swift` haalt en de figuur opbouwt met dezelfde tekenhelpers als de vijand-iconen. Er staat geen beeldprogramma op deze Mac, dus het script rastert zelf en schrijft de PNG met alleen zlib.

```bash
python3 appicoon.py
```

Dat maakt in één keer het app-icoon van 1024 pixels én de webiconen van 512, 192 en 180. Draai daarna `python3 bouw-proefversie.py`, want het icoon van 180 wordt als data-URI in `index.html` gebakken.

**Op je startscherm.** Open de site op je telefoon en kies *Zet op beginscherm*. Je krijgt dan dit logo als tegel, met de naam Orbslayer eronder, en hij opent zonder adresbalk — als een gewone app. Op Android regelt `manifest.json` hetzelfde.

## Openen

Open `Orbslayer.xcodeproj` in Xcode, kies je iPhone of een simulator en druk op Run.

Xcode 16 of nieuwer is nodig (het project gebruikt een gesynchroniseerde bronnenmap) en iOS 17 of nieuwer op je toestel.

Bij de eerste run op een echt toestel moet je in Xcode onder *Signing & Capabilities* je eigen Apple ID als team kiezen; de bundle identifier mag je vrij aanpassen.

## Hoe je speelt

Zet je telefoon rechtop naast je op de grond, tegen een muur of iets zwaars, zodat de frontcamera je van opzij ziet. Bij de eerste keer vragen we een kalibratie in twee stappen: één keer met gestrekte armen (bovenste stand) en één keer met je borst bijna op de grond (onderste stand). Daarna zie je rechts in beeld een balk met een bolletje dat live met je hoofd meebeweegt.

Gevolgd wordt **je hele hoofd**. Een houdingsmodel geeft losse punten voor je neus, je ogen en je oren, en daarvan nemen we het gemiddelde. Dat is bewust breder dan gezichtsherkenning: onderin een push-up kijk je naar de grond en is je gezicht niet meer te zien, maar je oor en achterhoofd wel. Zo blijf je juist op je laagste punt gevolgd, en maakt het niet uit of je omhoog of omlaag kijkt.

Een rep telt zodra die lijn onder de onderste streep is geweest en weer boven de bovenste komt. Waar die strepen liggen bepaal je zelf met de diepte-instelling in het menu; standaard moet je zestig procent van je bereik afleggen, zodat je niet tot op de millimeter hoeft te bewegen.

Boven in het gevechtsscherm blijft je XP-balk zichtbaar terwijl je pusht: links je level in een gouden rondje, daarnaast de balk die na elke kill vooruit springt. Zo zie je je voortgang zonder het gevecht te verlaten.

In de simulator is er geen camera; daar tik je op het scherm om een rep te doen.

## Regels

Elke rep doet 1 schade. Reps binnen drie seconden van elkaar bouwen een combo op; vanaf tien op rij doet elke rep dubbele schade. Een dode minion levert XP op, waarmee je speler-levels haalt. Elke tiende vijand is een boss met vijf keer zoveel HP.

Minions onthouden hun schade als je stopt. Een boss niet: sluit je de app of ga je terug naar het menu, dan staat hij de volgende keer weer op volle HP. Een boss moet dus in één sessie neer.

## Arena's

Elke arena is een eigen wereld met een eigen ras, kleur en boss. Versla je de boss, dan reis je door naar de volgende. Je speler-level en XP staan hier los van: die groeien gewoon door, in welke arena je ook bent.

| Arena | Wereld | Vijanden | Minion HP | Boss HP |
|---|---|---|---|---|
| 1 | De Orkvelden | Orks | 5 | 25 |
| 2 | De Rottende Weiden | Zombies | 6 | 30 |
| 3 | Het Wevernest | Spinnen | 8 | 40 |
| 4 | De Knekelkrocht | Skeletten | 9 | 45 |
| 5 | De Bloedmoerassen | Trollen | 11 | 55 |
| 6 | Het Schimmenrijk | Geesten | 12 | 60 |
| 7 | De Duistere Kathedraal | Vampiers | 14 | 70 |
| 8 | Het Weerwoud | Weerwolven | 15 | 75 |
| 9 | De Steengroeve | Golems | 17 | 85 |
| 10 | De Aspoort | Demonen | 18 | 90 |
| 11 | De Vriesburcht | IJsreuzen | 20 | 100 |
| 12 | De Verzwolgen Diepte | Zeeduivels | 21 | 105 |
| 13 | De Stormtoren | Bliksemgeesten | 23 | 115 |
| 14 | De Verzonken Tempel | Slangenvolk | 24 | 120 |
| 15 | De Drakenkuil | Draken | 26 | 130 |
| 16 | Het Titanenkerkhof | Titanen | 27 | 135 |
| 17 | De Zwarte Zon | Verdoemden | 29 | 145 |
| 18 | Het Sterrenhof | Gevallen Engelen | 30 | 150 |
| 19 | De Kosmische Smidse | Sterrensmeden | 32 | 160 |
| 20 | De Leegte | Het Naamloze | 33 | 165 |

Daarna begint de reeks opnieuw, maar zwaarder: arena 21 is De Orkvelden II met minions van 35 HP, daarna De Orkvelden III, enzovoort. Het houdt dus nooit op.

De hele interface kleurt mee met de arena waarin je zit, en bij het betreden van een nieuwe arena krijg je een korte intro in beeld.

Train je elke dag minstens één kill, dan groeit je streak. Vanaf drie dagen krijg je tien procent XP-bonus, vanaf zeven dagen vijfentwintig, vanaf dertig dagen vijftig.

Alles wordt lokaal opgeslagen. Er is geen account en er gaat niets naar een server; de camerabeelden worden alleen in het geheugen geanalyseerd en nooit bewaard.
