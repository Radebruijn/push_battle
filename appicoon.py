#!/usr/bin/env python3
"""Tekent het logo: iemand die een push-up doet met een ork die achter hem opdoemt.

Er staat geen beeldbibliotheek op deze Mac, dus dit script rastert zelf: het
vlakt de bezierkrommen van de SVG-paden af tot lijnstukken, vult die met een
scanlijn-algoritme (nonzero, net als in het spel) en schrijft het resultaat als
PNG met alleen zlib uit de standaardbibliotheek.

Gebruik:  python3 appicoon.py
"""
from __future__ import annotations

import re
import struct
import zlib
from pathlib import Path

import iconen  # dezelfde tekenhelpers als de vijand-iconen

HIER = Path(__file__).parent
VIEWBOX = 100.0
STEEKPROEF = 3        # 3x3 monsters per pixel tegen kartelranden

# Wat er gemaakt wordt: (bestandspad, zijde in pixels)
UITVOER = [
    (HIER / "Orbslayer" / "Assets.xcassets" / "AppIcon.appiconset" / "AppIcon.png", 1024),
    (HIER / "website" / "icon-512.png", 512),
    (HIER / "website" / "icon-192.png", 192),
    (HIER / "website" / "icon-180.png", 180),
]


# --- pad inlezen, afvlakken en verplaatsen -----------------------------------

def _bezier(p0, p1, p2, p3, delen=18):
    punten = []
    for i in range(1, delen + 1):
        t = i / delen
        u = 1 - t
        punten.append((
            u * u * u * p0[0] + 3 * u * u * t * p1[0] + 3 * u * t * t * p2[0] + t * t * t * p3[0],
            u * u * u * p0[1] + 3 * u * u * t * p1[1] + 3 * u * t * t * p2[1] + t * t * t * p3[1],
        ))
    return punten


def pad_naar_subpaden(d: str) -> list[list[tuple[float, float]]]:
    """Zet een SVG-pad (M/L/C/Z, absoluut) om in gesloten polygonen."""
    tokens = re.findall(r"[MLCZmlcz]|-?\d*\.?\d+", d)
    subpaden: list[list[tuple[float, float]]] = []
    huidig: list[tuple[float, float]] = []
    i, cursor, commando = 0, (0.0, 0.0), ""
    while i < len(tokens):
        t = tokens[i]
        if t.upper() in "MLCZ":
            commando = t.upper()
            i += 1
            if commando == "Z":
                if huidig:
                    subpaden.append(huidig)
                    huidig = []
                continue
        getallen = []
        while i < len(tokens) and tokens[i].upper() not in "MLCZ":
            getallen.append(float(tokens[i]))
            i += 1
        if commando == "M":
            for j in range(0, len(getallen) - 1, 2):
                punt = (getallen[j], getallen[j + 1])
                if j == 0:
                    if huidig:
                        subpaden.append(huidig)
                    huidig = [punt]
                else:
                    huidig.append(punt)
                cursor = punt
        elif commando == "L":
            for j in range(0, len(getallen) - 1, 2):
                cursor = (getallen[j], getallen[j + 1])
                huidig.append(cursor)
        elif commando == "C":
            for j in range(0, len(getallen) - 5, 6):
                p1 = (getallen[j], getallen[j + 1])
                p2 = (getallen[j + 2], getallen[j + 3])
                p3 = (getallen[j + 4], getallen[j + 5])
                huidig.extend(_bezier(cursor, p1, p2, p3))
                cursor = p3
    if huidig:
        subpaden.append(huidig)
    return subpaden


def verplaats(subpaden, schaal, dx, dy):
    return [[(x * schaal + dx, y * schaal + dy) for x, y in p] for p in subpaden]


# --- vullen ------------------------------------------------------------------

def dekking(subpaden, zijde):
    """Hoeveel elke pixel bedekt is (0-1), met nonzero-vulregel."""
    factor = zijde / VIEWBOX
    hoog = zijde * STEEKPROEF
    randen = []
    for punten in subpaden:
        for k in range(len(punten)):
            ax, ay = punten[k]
            bx, by = punten[(k + 1) % len(punten)]
            ax, ay = ax * factor * STEEKPROEF, ay * factor * STEEKPROEF
            bx, by = bx * factor * STEEKPROEF, by * factor * STEEKPROEF
            if ay != by:
                randen.append((ax, ay, bx, by))

    teller = [0] * (zijde * zijde)
    for rij in range(hoog):
        y = rij + 0.5
        kruisingen = [
            (ax + (y - ay) * (bx - ax) / (by - ay), 1 if by > ay else -1)
            for ax, ay, bx, by in randen
            if (ay <= y < by) or (by <= y < ay)
        ]
        if not kruisingen:
            continue
        kruisingen.sort()
        winding = 0
        doelrij = rij // STEEKPROEF
        for k in range(len(kruisingen) - 1):
            winding += kruisingen[k][1]
            if winding == 0:
                continue
            van = max(0, int(kruisingen[k][0]))
            tot = min(zijde * STEEKPROEF, int(kruisingen[k + 1][0]) + 1)
            for kolom in range(van, tot):
                if kruisingen[k][0] <= kolom + 0.5 < kruisingen[k + 1][0]:
                    teller[doelrij * zijde + kolom // STEEKPROEF] += 1

    deler = STEEKPROEF * STEEKPROEF
    return [min(1.0, n / deler) for n in teller]


# --- PNG schrijven -----------------------------------------------------------

def schrijf_png(pad: Path, zijde: int, pixels: bytearray) -> None:
    rijen = bytearray()
    for y in range(zijde):
        rijen.append(0)  # filtertype 'none'
        begin = y * zijde * 3
        rijen.extend(pixels[begin:begin + zijde * 3])

    def blok(soort: bytes, data: bytes) -> bytes:
        return (struct.pack(">I", len(data)) + soort + data
                + struct.pack(">I", zlib.crc32(soort + data) & 0xFFFFFFFF))

    pad.parent.mkdir(parents=True, exist_ok=True)
    pad.write_bytes(
        b"\x89PNG\r\n\x1a\n"
        + blok(b"IHDR", struct.pack(">IIBBBBB", zijde, zijde, 8, 2, 0, 0, 0))
        + blok(b"IDAT", zlib.compress(bytes(rijen), 9))
        + blok(b"IEND", b"")
    )


# --- het logo ----------------------------------------------------------------

def ork_pad() -> str:
    bron = (HIER / "Orbslayer" / "Arena.swift").read_text()
    blok = bron.split('race: L3("Orks"', 1)[1]
    return re.search(r'icon: "([^"]+)"', blok).group(1)


def held_pad() -> str:
    """Iemand in plankhouding, van opzij gezien — net als in het spel.

    Hoofd links, twee armen recht omlaag naar de vloer, een strak lichaam dat
    aflopend naar de tenen rechts gaat. De vloer eronder maakt duidelijk dat
    hij ligt en niet zweeft.
    """
    b = iconen.bar
    return (
        # vloer
        iconen.poly([(8, 90), (92, 90), (92, 95), (8, 95)])
        # achterste arm, half achter de romp
        + b(50, 66, 50, 90, 7)
        # been van heup naar enkel
        + b(65, 71, 85, 83, 9)
        # voet: smal contact met de vloer, geen brede wig
        + b(85, 83, 88, 90, 7)
        # romp: schouder naar heup, gelijkmatig dik
        + b(35, 63, 66, 71, 13)
        # voorste arm
        + b(37, 65, 37, 90, 10)
        # nek en hoofd
        + b(29, 61, 37, 64, 8)
        + iconen.circle(25, 59, 9)
    )


def maak_logo(zijde: int) -> bytearray:
    # De ork doemt op achter de held: groot, hoog in beeld, gedempt van kleur.
    ork = verplaats(pad_naar_subpaden(ork_pad()), 0.62, 19.0, -3.0)
    held = pad_naar_subpaden(held_pad())

    dek_ork = dekking(ork, zijde)
    dek_held = dekking(held, zijde)

    midden = zijde / 2
    straal = zijde * 0.62
    pixels = bytearray(zijde * zijde * 3)

    for y in range(zijde):
        for x in range(zijde):
            i = y * zijde + x
            afstand = (((x - midden) ** 2 + (y - midden) ** 2) ** 0.5) / straal
            gloed = max(0.0, 1.0 - afstand) ** 2.2

            r = 8 + 22 * gloed
            g = 10 + 62 * gloed
            b = 8 + 20 * gloed

            # De ork zit erachter: donkerder groen, zodat de held ervoor uitkomt.
            d = dek_ork[i]
            if d > 0:
                r = r + (46 - r) * d
                g = g + (122 - g) * d
                b = b + (36 - b) * d

            # De held vooraan in goud.
            d = dek_held[i]
            if d > 0:
                t = y / zijde
                r = r + ((255 - 22 * t) - r) * d
                g = g + ((199 - 40 * t) - g) * d
                b = b + ((64 - 20 * t) - b) * d

            p = i * 3
            pixels[p] = int(max(0, min(255, r)))
            pixels[p + 1] = int(max(0, min(255, g)))
            pixels[p + 2] = int(max(0, min(255, b)))
    return pixels


def main() -> None:
    for pad, zijde in UITVOER:
        schrijf_png(pad, zijde, maak_logo(zijde))
        print(f"{pad.relative_to(HIER)} — {zijde}x{zijde}, {pad.stat().st_size // 1024} kB")


if __name__ == "__main__":
    main()
