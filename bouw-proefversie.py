#!/usr/bin/env python3
"""Bouwt proefversie.html: leest de arena's uit Orbslayer/Arena.swift en vult ze in het sjabloon.

Zo blijven de browserversie en de iOS-app dezelfde arena's, namen en kleuren gebruiken.
Gebruik:  python3 bouw-proefversie.py [pad/naar/sjabloon.tpl]
"""
import json
import re
import sys
from pathlib import Path

from telwoord import telwoord

HIER = Path(__file__).parent
TALEN = ["nl", "en", "fr"]
SJABLOON = Path(sys.argv[1]) if len(sys.argv) > 1 else HIER / "proefversie.tpl"
UIT = HIER / "proefversie.html"

PATROON = re.compile(
    r'Arena\(\s*name: L3\("([^"]*)", "([^"]*)", "([^"]*)"\),\s*'
    r'race: L3\("([^"]*)", "([^"]*)", "([^"]*)"\),\s*'
    r'rgb: RGB\(([\d.]+), ([\d.]+), ([\d.]+)\),\s*'
    r'icon: "([^"]+)",\s*'
    r'minionName: L3\("([^"]*)", "([^"]*)", "([^"]*)"\),\s*'
    r'bossName: L3\("([^"]*)", "([^"]*)", "([^"]*)"\),\s*'
    r'intro: L3\("([^"]*)", "([^"]*)", "([^"]*)"\)'
)


def lees_arenas() -> list[dict]:
    bron = (HIER / "Orbslayer" / "Arena.swift").read_text()
    blok = bron.split("static let all: [Arena] = [", 1)[1].split("\n    ]", 1)[0]
    arenas = [
        {
            "name": {"nl": m.group(1), "en": m.group(2), "fr": m.group(3)},
            "race": {"nl": m.group(4), "en": m.group(5), "fr": m.group(6)},
            "rgb": [float(m.group(7)), float(m.group(8)), float(m.group(9))],
            "icon": m.group(10),
            "minion": {"nl": m.group(11), "en": m.group(12), "fr": m.group(13)},
            "boss": {"nl": m.group(14), "en": m.group(15), "fr": m.group(16)},
            "intro": {"nl": m.group(17), "en": m.group(18), "fr": m.group(19)},
        }
        for m in PATROON.finditer(blok)
    ]
    if not arenas:
        raise SystemExit("Geen arena's gevonden in Arena.swift")
    return arenas


def lees_rang_icons() -> dict[str, list[str]]:
    bron = (HIER / "Orbslayer" / "RankIcons.swift").read_text()
    blokken = bron.split("static let")
    paden = re.findall(r'"([^"]+)"', blokken[1])
    kleuren = re.findall(r'"(#[0-9a-fA-F]{6})"', blokken[2])
    return {"paths": paden, "colors": kleuren}


def lees_arena_art() -> dict[str, list[list[str]]]:
    """Leest de tekeningen in lagen uit ArenaArt.swift: ras -> [[pad, rol], ...]."""
    bron = (HIER / "Orbslayer" / "ArenaArt.swift")
    if not bron.exists():
        return {}
    uit: dict[str, list[list[str]]] = {}
    for ras, stuk in re.findall(r'"([^"]+)": "([^"]+)"', bron.read_text()):
        uit[ras] = [laag.split("|") for laag in stuk.split(";")]
    return uit


def lees_mode_icons() -> dict[str, str]:
    bron = (HIER / "Orbslayer" / "ModeIcons.swift").read_text()
    return dict(re.findall(r'static let (\w+) = "([^"]+)"', bron))


def werk_documentatie_bij(arenas: list[dict]) -> None:
    """Vult het aantal werelden (en de eerste en laatste naam) in de
    documentatie in, zodat APPSTORE.md en README.md meegroeien met
    Arena.swift zonder dat iemand eraan hoeft te denken."""
    woord = telwoord(len(arenas), "nl")
    eerste = arenas[0]["name"]["nl"]
    laatste = arenas[-1]["name"]["nl"]
    plekken = [
        (HIER / "APPSTORE.md",
         re.compile(r"Vecht je door \S+ werelden heen, van [^,.]+ naar [^,.]+\."),
         f"Vecht je door {woord} werelden heen, van {eerste} naar {laatste}."),
        (HIER / "README.md",
         re.compile(r"waarin je alle \S+ naast elkaar ziet"),
         f"waarin je alle {woord} naast elkaar ziet"),
    ]
    for pad, patroon, nieuw in plekken:
        oud = pad.read_text()
        vervangen, geraakt = patroon.subn(nieuw, oud)
        if geraakt != 1:
            raise SystemExit(
                f"Zin over het aantal werelden {geraakt}× gevonden in {pad.name}, verwacht 1×"
            )
        if vervangen != oud:
            pad.write_text(vervangen)
            print(f"{pad.name}: aantal werelden bijgewerkt naar {woord}")


def bouw_promo(arenas: list[dict], woorden: dict[str, str],
               icoon_data: str, icons: dict[str, str]) -> str:
    """Bouwt de promopagina (de voorpagina van de site) uit promo.tpl.
    De teksten komen uit de aparte 'promo'-sectie van taal.json, zodat ze
    niet in Strings.swift van de app belanden."""
    sjabloon = (HIER / "promo.tpl").read_text()
    promo = json.loads((HIER / "taal.json").read_text()).get("promo")
    if not promo:
        raise SystemExit("taal.json mist de 'promo'-sectie")
    for sleutel, waarden in promo.items():
        if len(waarden) != len(TALEN):
            raise SystemExit(f"promo '{sleutel}' heeft {len(waarden)} vertalingen")
    promo = {
        sleutel: [w.replace("{AANTAL_ARENAS}", woorden[TALEN[i]]) for i, w in enumerate(waarden)]
        for sleutel, waarden in promo.items()
    }

    vervangingen = {
        "__PROMO_TEKSTEN__": (1, json.dumps(promo, ensure_ascii=False)),
        "__ARENAS__": (1, json.dumps(arenas, ensure_ascii=False).replace("\n", "")),
        "__MODEICONEN__": (1, json.dumps(icons, ensure_ascii=False)),
        "__ICOON180__": (3, icoon_data),
        "__AANTAL_ARENAS__": (1, woorden["nl"]),
    }
    pagina = sjabloon
    for plek, (aantal, waarde) in vervangingen.items():
        if sjabloon.count(plek) != aantal:
            raise SystemExit(f"promo.tpl moet {plek} precies {aantal}× bevatten, "
                             f"gevonden: {sjabloon.count(plek)}")
        pagina = pagina.replace(plek, waarde)
    return pagina


def main() -> None:
    arenas = lees_arenas()
    sjabloon = SJABLOON.read_text()
    if sjabloon.count("__ARENAS__") != 1:
        raise SystemExit(
            f"Sjabloon moet precies één __ARENAS__ bevatten, gevonden: "
            f"{sjabloon.count('__ARENAS__')}"
        )
    data = json.dumps(arenas, ensure_ascii=False).replace("\n", "")
    pagina = sjabloon.replace("__ARENAS__", data)

    # Het aantal arena's, voluit geschreven: __AANTAL_ARENAS__ in het sjabloon
    # (Nederlandstalige SEO-tekst) en {AANTAL_ARENAS} in taal.json (per taal).
    woorden = {taal: telwoord(len(arenas), taal) for taal in TALEN}
    pagina = pagina.replace("__AANTAL_ARENAS__", woorden["nl"])

    teksten = json.loads((HIER / "taal.json").read_text())["teksten"]
    teksten = {
        sleutel: [w.replace("{AANTAL_ARENAS}", woorden[TALEN[i]]) for i, w in enumerate(waarden)]
        for sleutel, waarden in teksten.items()
    }
    if sjabloon.count("__TEKSTEN__") != 1:
        raise SystemExit("Sjabloon moet precies één __TEKSTEN__ bevatten")
    pagina = pagina.replace(
        "__TEKSTEN__", json.dumps(teksten, ensure_ascii=False).replace("\n", "")
    )
    icoon = HIER / "website" / "icon-180.png"
    if sjabloon.count("__ICOON180__") != 2:
        raise SystemExit("Sjabloon moet precies twee keer __ICOON180__ bevatten")
    if not icoon.exists():
        raise SystemExit("website/icon-180.png ontbreekt — draai eerst appicoon.py")
    import base64
    icoon_data = "data:image/png;base64," + base64.b64encode(icoon.read_bytes()).decode()
    pagina = pagina.replace("__ICOON180__", icoon_data)

    icons = lees_mode_icons()
    if sjabloon.count("__MODEICONEN__") != 1:
        raise SystemExit("Sjabloon moet precies één __MODEICONEN__ bevatten")
    pagina = pagina.replace("__MODEICONEN__", json.dumps(icons, ensure_ascii=False))

    if sjabloon.count("__ARENAART__") != 1:
        raise SystemExit("Sjabloon moet precies één __ARENAART__ bevatten")
    pagina = pagina.replace("__ARENAART__",
                            json.dumps(lees_arena_art(), ensure_ascii=False))

    if sjabloon.count("__RANGICONEN__") != 1:
        raise SystemExit("Sjabloon moet precies één __RANGICONEN__ bevatten")
    pagina = pagina.replace("__RANGICONEN__",
                            json.dumps(lees_rang_icons(), ensure_ascii=False))

    if any(p in pagina for p in ("__ARENAS__", "__TEKSTEN__", "__MODEICONEN__",
                                 "__ICOON180__", "__RANGICONEN__", "__ARENAART__",
                                 "__AANTAL_ARENAS__", "{AANTAL_ARENAS}")):
        raise SystemExit("Placeholder niet volledig vervangen")

    werk_documentatie_bij(arenas)
    # proefversie.html blijft zonder <html>-omhulsel: zo kan hij als artifact
    # gepubliceerd worden. De website krijgt wel een volledig document, want
    # zoekmachines lezen liever een pagina met een taal en een nette kop.
    kaal = pagina.replace("<!--KOP-EINDE-->\n", "")
    UIT.write_text(kaal)

    kop, _, romp = pagina.partition("<!--KOP-EINDE-->")
    document = (
        "<!doctype html>\n<html lang=\"nl\">\n<head>\n"
        + kop.strip()
        + "\n</head>\n<body>\n"
        + romp.strip()
        + "\n</body>\n</html>\n"
    )
    pagina = document
    # Het spel woont op /speel/; de voorpagina is de promopagina hieronder.
    # website/ is de map die de hoster publiceert; de kopie in de repo-wortel
    # is er zodat een lokale server dezelfde paden heeft.
    (HIER / "website").mkdir(exist_ok=True)
    for basis in (HIER, HIER / "website"):
        (basis / "speel").mkdir(exist_ok=True)
        (basis / "speel" / "index.html").write_text(pagina)

    promo = bouw_promo(arenas, woorden, icoon_data, icons)
    (HIER / "index.html").write_text(promo)
    (HIER / "website" / "index.html").write_text(promo)

    # privacy.html hoort bij de site; Apple eist een werkende privacylink.
    for naam in ("robots.txt", "sitemap.xml"):
        bron = HIER / "website" / naam
        if not bron.exists():
            raise SystemExit(f"website/{naam} ontbreekt")

    privacy = HIER / "privacy.html"
    if privacy.exists():
        (HIER / "website" / "privacy.html").write_text(privacy.read_text())
    print(f"{UIT.name} + speel/index.html + promopagina gebouwd — "
          f"{len(arenas)} arena's, {len(pagina)} tekens")


if __name__ == "__main__":
    main()
