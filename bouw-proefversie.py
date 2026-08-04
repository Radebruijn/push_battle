#!/usr/bin/env python3
"""Bouwt proefversie.html: leest de arena's uit Orbslayer/Arena.swift en vult ze in het sjabloon.

Zo blijven de browserversie en de iOS-app dezelfde arena's, namen en kleuren gebruiken.
Gebruik:  python3 bouw-proefversie.py [pad/naar/sjabloon.tpl]
"""
import json
import re
import sys
from pathlib import Path

HIER = Path(__file__).parent
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


def lees_mode_icons() -> dict[str, str]:
    bron = (HIER / "Orbslayer" / "ModeIcons.swift").read_text()
    return dict(re.findall(r'static let (\w+) = "([^"]+)"', bron))


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

    teksten = json.loads((HIER / "taal.json").read_text())["teksten"]
    if sjabloon.count("__TEKSTEN__") != 1:
        raise SystemExit("Sjabloon moet precies één __TEKSTEN__ bevatten")
    pagina = pagina.replace(
        "__TEKSTEN__", json.dumps(teksten, ensure_ascii=False).replace("\n", "")
    )
    icoon = HIER / "website" / "icon-180.png"
    if sjabloon.count("__ICOON180__") != 2:
        raise SystemExit("Sjabloon moet precies twee keer __ICOON180__ bevatten")
    if icoon.exists():
        import base64
        data = base64.b64encode(icoon.read_bytes()).decode()
        pagina = pagina.replace("__ICOON180__", "data:image/png;base64," + data)
    else:
        raise SystemExit("website/icon-180.png ontbreekt — draai eerst appicoon.py")

    icons = lees_mode_icons()
    if sjabloon.count("__MODEICONEN__") != 1:
        raise SystemExit("Sjabloon moet precies één __MODEICONEN__ bevatten")
    pagina = pagina.replace("__MODEICONEN__", json.dumps(icons, ensure_ascii=False))

    if sjabloon.count("__RANGICONEN__") != 1:
        raise SystemExit("Sjabloon moet precies één __RANGICONEN__ bevatten")
    pagina = pagina.replace("__RANGICONEN__",
                            json.dumps(lees_rang_icons(), ensure_ascii=False))

    if any(p in pagina for p in ("__ARENAS__", "__TEKSTEN__", "__MODEICONEN__",
                                 "__ICOON180__", "__RANGICONEN__")):
        raise SystemExit("Placeholder niet volledig vervangen")
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
    # index.html is dezelfde pagina onder de naam die webhosters verwachten.
    (HIER / "index.html").write_text(pagina)
    # website/ is de map die je op een hoster sleept.
    (HIER / "website").mkdir(exist_ok=True)
    (HIER / "website" / "index.html").write_text(pagina)
    # privacy.html hoort bij de site; Apple eist een werkende privacylink.
    for naam in ("robots.txt", "sitemap.xml"):
        bron = HIER / "website" / naam
        if not bron.exists():
            raise SystemExit(f"website/{naam} ontbreekt")

    privacy = HIER / "privacy.html"
    if privacy.exists():
        (HIER / "website" / "privacy.html").write_text(privacy.read_text())
    print(f"{UIT.name} + index.html gebouwd — {len(arenas)} arena's, {len(pagina)} tekens")


if __name__ == "__main__":
    main()
