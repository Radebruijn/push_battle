#!/usr/bin/env python3
"""Tekent de vijand-iconen en schrijft ze als SVG-pad in spelgegevens/Arena.swift.

Elk icoon is één pad in een vierkant van 100x100 (y loopt naar beneden).
Vulregel is nonzero: subpaden met de klok mee vullen, tegen de klok in maken
gaten (ogen, monden). De helpers hieronder zorgen voor de juiste richting.

Gebruik:  python3 iconen.py            # schrijft naar Arena.swift
          python3 iconen.py --preview  # maakt overzicht.html om te bekijken
"""
from __future__ import annotations

import math
import re
import sys
from pathlib import Path

HIER = Path(__file__).parent
K = 0.5523  # cubische benadering van een kwartcirkel


def _f(v: float) -> str:
    return f"{v:.1f}".rstrip("0").rstrip(".")


def ellipse(cx: float, cy: float, rx: float, ry: float, hole: bool = False) -> str:
    ox, oy = rx * K, ry * K
    if hole:  # tegen de klok in
        return (
            f"M{_f(cx - rx)} {_f(cy)}"
            f"C{_f(cx - rx)} {_f(cy + oy)} {_f(cx - ox)} {_f(cy + ry)} {_f(cx)} {_f(cy + ry)}"
            f"C{_f(cx + ox)} {_f(cy + ry)} {_f(cx + rx)} {_f(cy + oy)} {_f(cx + rx)} {_f(cy)}"
            f"C{_f(cx + rx)} {_f(cy - oy)} {_f(cx + ox)} {_f(cy - ry)} {_f(cx)} {_f(cy - ry)}"
            f"C{_f(cx - ox)} {_f(cy - ry)} {_f(cx - rx)} {_f(cy - oy)} {_f(cx - rx)} {_f(cy)}Z"
        )
    return (
        f"M{_f(cx - rx)} {_f(cy)}"
        f"C{_f(cx - rx)} {_f(cy - oy)} {_f(cx - ox)} {_f(cy - ry)} {_f(cx)} {_f(cy - ry)}"
        f"C{_f(cx + ox)} {_f(cy - ry)} {_f(cx + rx)} {_f(cy - oy)} {_f(cx + rx)} {_f(cy)}"
        f"C{_f(cx + rx)} {_f(cy + oy)} {_f(cx + ox)} {_f(cy + ry)} {_f(cx)} {_f(cy + ry)}"
        f"C{_f(cx - ox)} {_f(cy + ry)} {_f(cx - rx)} {_f(cy + oy)} {_f(cx - rx)} {_f(cy)}Z"
    )


def circle(cx: float, cy: float, r: float, hole: bool = False) -> str:
    return ellipse(cx, cy, r, r, hole)


def _oppervlak(pts: list[tuple[float, float]]) -> float:
    """Shoelace-oppervlak; positief = vullende richting, negatief = gat."""
    return sum(
        pts[i][0] * pts[(i + 1) % len(pts)][1] - pts[(i + 1) % len(pts)][0] * pts[i][1]
        for i in range(len(pts))
    )


# Hoe rond alles staat. Nul geeft de oude, hoekige vormen terug; hoger maakt
# de figuren zachter. Zes is uitgeprobeerd tegen vier en acht: bij vier zie je
# de hoeken nog, bij acht verliezen de mantel van de vampier en de armen van de
# golem hun vorm. Zes rondt alles af en houdt elk silhouet herkenbaar.
ROND = 6.0


def poly(points: list[tuple[float, float]], hole: bool = False,
         rond: float | None = None) -> str:
    """Veelhoek met afgeronde hoeken. Elke hoek wordt een stukje ingekort en
    met een boogje overbrugd, zodat de monsters uit ronde vormen bestaan in
    plaats van uit scherpe punten. De inkorting is nooit meer dan de helft van
    de kortste zijde eromheen, anders zou een smalle vorm dichtklappen."""
    # De richting waarin de punten toevallig staan mag niet uitmaken: we draaien
    # ze zo nodig om, zodat 'hole' altijd echt een gat oplevert.
    opp = _oppervlak(points)
    pts = list(reversed(points)) if (opp > 0) == hole else list(points)
    straal = ROND if rond is None else rond
    if straal <= 0 or len(pts) < 3:
        d = f"M{_f(pts[0][0])} {_f(pts[0][1])}"
        for x, y in pts[1:]:
            d += f"L{_f(x)} {_f(y)}"
        return d + "Z"

    n = len(pts)
    stukken = []
    for i in range(n):
        vx, vy = pts[i - 1]
        x, y = pts[i]
        nx, ny = pts[(i + 1) % n]
        d1 = math.hypot(vx - x, vy - y) or 1
        d2 = math.hypot(nx - x, ny - y) or 1
        k = min(straal, d1 / 2, d2 / 2)
        binnen = (x + (vx - x) / d1 * k, y + (vy - y) / d1 * k)
        buiten = (x + (nx - x) / d2 * k, y + (ny - y) / d2 * k)
        stukken.append((binnen, (x, y), buiten))

    d = f"M{_f(stukken[0][0][0])} {_f(stukken[0][0][1])}"
    for i, (binnen, hoek, buiten) in enumerate(stukken):
        if i:
            d += f"L{_f(binnen[0])} {_f(binnen[1])}"
        d += f"Q{_f(hoek[0])} {_f(hoek[1])} {_f(buiten[0])} {_f(buiten[1])}"
    return d + "Z"


def bar(x1: float, y1: float, x2: float, y2: float, w: float,
        hole: bool = False) -> str:
    """Ledemaat tussen twee punten: een balk met ronde koppen, zoals een arm of
    een poot ook eindigt. De koppen zijn kwartcirkels benaderd met een boogje;
    dat scheelt gedoe met draairichtingen en ziet er op dit formaat hetzelfde
    uit als een echte halve cirkel."""
    dx, dy = x2 - x1, y2 - y1
    ln = math.hypot(dx, dy) or 1
    ux, uy = dx / ln, dy / ln
    r = w / 2
    nx, ny = -uy * r, ux * r
    hoeken = [(x1 + nx, y1 + ny), (x2 + nx, y2 + ny),
              (x2 - nx, y2 - ny), (x1 - nx, y1 - ny)]
    # Dezelfde draairichting-correctie als bij poly, zodat 'hole' klopt. Welke
    # kant we ook op lopen, we komen eerst langs het uiteinde bij punt twee en
    # daarna langs dat bij punt één.
    if (_oppervlak(hoeken) > 0) == hole:
        hoeken = list(reversed(hoeken))
    koppen = [(x2, y2, ux, uy), (x1, y1, -ux, -uy)]

    # Het stuurpunt ligt twee stralen voorbij het midden; dan raakt het midden
    # van de kromme precies de cirkel en is de kop netjes rond.
    d = f"M{_f(hoeken[0][0])} {_f(hoeken[0][1])}"
    for i, (kx, ky, rx, ry) in enumerate(koppen):
        stuur = (kx + rx * r * 2, ky + ry * r * 2)
        eind = hoeken[(i * 2 + 2) % 4]
        d += (f"L{_f(hoeken[i * 2 + 1][0])} {_f(hoeken[i * 2 + 1][1])}"
              f"Q{_f(stuur[0])} {_f(stuur[1])} {_f(eind[0])} {_f(eind[1])}")
    return d + "Z"


def raw(d: str) -> str:
    return d


def spider_legs() -> str:
    """Acht poten met de knie hoog boven het lijf — zo staat een spin echt."""
    d = ""
    for hy, kx, ky, ex, ey in [
        (42, 34, 12, 4, 38),
        (48, 42, 24, 0, 60),
        (54, 44, 44, 4, 82),
        (58, 40, 60, 14, 96),
    ]:
        for sign in (-1, 1):
            heup_x = 50 + sign * 10
            knie_x = 50 + sign * kx
            voet_x = 50 + sign * (50 - ex)
            d += bar(heup_x, hy, knie_x, ky, 5)
            d += bar(knie_x, ky, voet_x, ey, 4)
    return d


def schaal(d: str, factor: float, cx: float = 50, cy: float = 50) -> str:
    """Vergroot een pad om het midden. Alle getallen in zo'n pad zijn
    coördinaten die om en om x en y zijn, dus dat kan in één keer."""
    beurt = [0]

    def om(m):
        waarde = float(m.group())
        as_ = cx if beurt[0] % 2 == 0 else cy
        beurt[0] += 1
        return _f(as_ + (waarde - as_) * factor)

    return re.sub(r"-?\d+(?:\.\d+)?", om, d)


ICONEN: dict[str, str] = {
    # 1 Orks — brede kop met puntoren en opstekende slagtanden
    "Orks": (
        raw(
            "M50 8C72 8 86 22 86 42L86 54C86 72 70 88 50 88"
            "C30 88 14 72 14 54L14 42C14 22 28 8 50 8Z"
        )
        + poly([(15, 36), (1, 24), (17, 54)])
        + poly([(85, 36), (99, 24), (83, 54)])
        + poly([(28, 42), (46, 50), (28, 57)], hole=True)
        + poly([(72, 42), (54, 50), (72, 57)], hole=True)
        + poly([(31, 65), (69, 65), (69, 79), (31, 79)], hole=True)
        + poly([(35, 79), (39, 67), (43, 79)])
        + poly([(57, 79), (61, 67), (65, 79)])
    ),
    # 2 Oorlogsorks — dezelfde kop, maar met helm, hoorns en zwaardere tanden
    "Oorlogsorks": (
        raw(
            "M50 22C70 22 84 36 84 54L84 62C84 78 69 92 50 92"
            "C31 92 16 78 16 62L16 54C16 36 30 22 50 22Z"
        )
        + poly([(14, 40), (86, 40), (86, 26), (14, 26)])
        + poly([(14, 32), (0, 8), (24, 24)])
        + poly([(86, 32), (100, 8), (76, 24)])
        + poly([(45, 40), (55, 40), (55, 60), (45, 60)])
        + poly([(24, 48), (41, 55), (24, 62)], hole=True)
        + poly([(76, 48), (59, 55), (76, 62)], hole=True)
        + poly([(28, 70), (72, 70), (72, 85), (28, 85)], hole=True)
        + poly([(33, 85), (38, 66), (43, 85)])
        + poly([(57, 85), (62, 66), (67, 85)])
    ),
    # 3 Spinnen — zwaar achterlijf, kopborststuk met acht ogen en tasters
    "Spinnen": (
        spider_legs()
        + bar(45, 46, 22, 66, 6)
        + bar(55, 46, 78, 66, 6)
        + ellipse(50, 66, 21, 22)
        + ellipse(50, 40, 13, 12)
        + circle(44, 36, 3.2, hole=True)
        + circle(56, 36, 3.2, hole=True)
        + circle(38, 41, 2, hole=True)
        + circle(62, 41, 2, hole=True)
        + circle(46, 31, 1.8, hole=True)
        + circle(54, 31, 1.8, hole=True)
    ),
    # 4 Skeletten — schedel met kaak en tanden
    "Skeletten": (
        raw(
            "M50 9C72 9 87 26 87 46C87 58 81 66 75 70L75 84"
            "C75 88 71 91 67 91L33 91C29 91 25 88 25 84L25 70"
            "C19 66 13 58 13 46C13 26 28 9 50 9Z"
        )
        + circle(35, 44, 10, hole=True)
        + circle(65, 44, 10, hole=True)
        + poly([(50, 55), (57, 67), (43, 67)], hole=True)
        + poly([(38, 74), (43, 74), (43, 88), (38, 88)], hole=True)
        + poly([(47, 74), (53, 74), (53, 88), (47, 88)], hole=True)
        + poly([(57, 74), (62, 74), (62, 88), (57, 88)], hole=True)
    ),
    # 5 Trollen — kleine ronde kop op zware, lage schouders
    "Trollen": (
        poly([(34, 20), (21, 6), (37, 26)])
        + poly([(66, 20), (79, 6), (63, 26)])
        + circle(50, 30, 20)
        + raw(
            "M32 44C16 50 6 64 6 80L6 94L94 94L94 80C94 64 84 50 68 44"
            "C63 52 57 56 50 56C43 56 37 52 32 44Z"
        )
        + circle(42, 27, 3.5, hole=True)
        + circle(58, 27, 3.5, hole=True)
        + poly([(40, 34), (60, 34), (60, 41), (40, 41)], hole=True)
        + poly([(43, 41), (45, 32), (47, 41)])
        + poly([(53, 41), (55, 32), (57, 41)])
    ),
    # 6 Katjes — pluizige kop met puntoren, snorharen en plukjes
    "Katjes": (
        "".join(
            poly([(50 + 30 * math.cos(math.radians(h - 9)), 56 + 30 * math.sin(math.radians(h - 9))),
                  (50 + 39 * math.cos(math.radians(h)), 56 + 39 * math.sin(math.radians(h))),
                  (50 + 30 * math.cos(math.radians(h + 9)), 56 + 30 * math.sin(math.radians(h + 9)))])
            for h in range(24, 337, 18)
        )
        + circle(50, 56, 30)
        + poly([(25, 40), (16, 6), (47, 27)])
        + poly([(75, 40), (84, 6), (53, 27)])
        + poly([(30, 35), (25, 17), (41, 30)], hole=True)
        + poly([(70, 35), (75, 17), (59, 30)], hole=True)
        + circle(39, 52, 5.5, hole=True)
        + circle(61, 52, 5.5, hole=True)
        + poly([(44, 63), (56, 63), (50, 71)], hole=True)
        + bar(24, 62, 2, 56, 3)
        + bar(24, 70, 2, 76, 3)
        + bar(76, 62, 98, 56, 3)
        + bar(76, 70, 98, 76, 3)
    ),
    # 6 Geesten — golvende onderkant
    "Geesten": (
        raw(
            "M50 10C70 10 83 26 83 47L83 90L71 79L59 90L47 79L35 90L23 79L17 90L17 47"
            "C17 26 30 10 50 10Z"
        )
        + ellipse(38, 43, 6.5, 9, hole=True)
        + ellipse(62, 43, 6.5, 9, hole=True)
    ),
    # 7 Vampiers — vleermuiskop met wijde vleugels
    "Vampiers": (
        raw(
            "M50 34L26 16L30 36L6 32L20 52L38 56L50 70L62 56L80 52L94 32L70 36L74 16Z"
        )
        + ellipse(50, 40, 15, 14)
        + poly([(38, 20), (44, 32), (32, 32)])
        + poly([(62, 20), (68, 32), (56, 32)])
        + circle(43, 38, 3.5, hole=True)
        + circle(57, 38, 3.5, hole=True)
        + poly([(42, 50), (48, 50), (45, 62)])
        + poly([(52, 50), (58, 50), (55, 62)])
    ),
    # 8 Weerwolven — kop van voren met een zware manenkraag eromheen
    "Weerwolven": (
        "".join(
            poly([
                (50 + 31 * math.cos(math.radians(h - 11)), 54 + 30 * math.sin(math.radians(h - 11))),
                (50 + 48 * math.cos(math.radians(h)), 54 + 45 * math.sin(math.radians(h))),
                (50 + 31 * math.cos(math.radians(h + 11)), 54 + 30 * math.sin(math.radians(h + 11))),
            ])
            for h in range(22, 339, 22)
        )
        + poly([(24, 36), (13, 2), (45, 26)])
        + poly([(76, 36), (87, 2), (55, 26)])
        + poly([(20, 42), (30, 24), (44, 32), (56, 32), (70, 24), (80, 42),
                (74, 64), (58, 78), (50, 88), (42, 78), (26, 64)])
        + poly([(30, 44), (46, 52), (30, 58)], hole=True)
        + poly([(70, 44), (54, 52), (70, 58)], hole=True)
        + poly([(43, 62), (57, 62), (50, 70)], hole=True)
        + poly([(38, 74), (62, 74), (50, 84)], hole=True)
        + poly([(41, 76), (44, 82), (46, 76)])
        + poly([(54, 76), (56, 82), (59, 76)])
    ),
    # 9 Golems — blokkige rotsgestalte met scheur
    "Golems": (
        poly([(28, 8), (72, 8), (80, 24), (72, 38), (28, 38), (20, 24)])
        + poly([(34, 18), (46, 16), (46, 27), (34, 25)], hole=True)
        + poly([(66, 18), (66, 25), (54, 27), (54, 16)], hole=True)
        + poly([(14, 44), (86, 44), (80, 94), (20, 94)])
        + bar(16, 50, 5, 82, 13)
        + bar(84, 50, 95, 82, 13)
        + poly([(48, 50), (57, 60), (46, 70), (55, 86), (49, 90), (39, 70),
                (50, 60), (42, 52)], hole=True)
    ),
    # 10 Demonen — zware horens en spitse kin
    "Demonen": (
        raw(
            "M30 30C26 18 18 8 6 2C6 18 12 32 24 42L34 34Z"
        )
        + raw(
            "M70 30C74 18 82 8 94 2C94 18 88 32 76 42L66 34Z"
        )
        + raw(
            "M50 22C67 22 80 35 80 52C80 60 78 66 74 72L50 96L26 72"
            "C22 66 20 60 20 52C20 35 33 22 50 22Z"
        )
        + poly([(30, 46), (46, 53), (30, 59)], hole=True)
        + poly([(70, 46), (54, 53), (70, 59)], hole=True)
        + poly([(39, 68), (61, 68), (50, 82)], hole=True)
    ),
    # 11 IJsreuzen — kop met ijskroon en bevroren baard
    "IJsreuzen": (
        raw(
            "M26 40L16 12L34 28L42 6L50 24L58 6L66 28L84 12L74 40"
            "C82 48 84 62 78 72L64 93L36 93L22 72C16 62 18 48 26 40Z"
        )
        + poly([(31, 50), (46, 57), (31, 63)], hole=True)
        + poly([(69, 50), (54, 57), (69, 63)], hole=True)
        + poly([(38, 73), (62, 73), (56, 87), (44, 87)], hole=True)
    ),
    # 12 Zeeduivels — hengelvis met lokkertje en tanden
    "Zeeduivels": (
        circle(24, 22, 7)
        + bar(24, 22, 34, 48, 4)
        + raw(
            "M34 48C48 36 74 38 86 52C94 62 92 76 82 84L92 90L74 88"
            "C60 92 42 88 34 78C28 70 28 58 34 48Z"
        )
        + circle(52, 56, 5, hole=True)
        + poly([(44, 72), (52, 66), (58, 74), (66, 66), (72, 74), (80, 68),
                (82, 78), (46, 80)], hole=True)
    ),
    # 13 Bliksemgeesten — bliksemschicht in een ring
    "Bliksemgeesten": (
        circle(50, 50, 44)
        + circle(50, 50, 35, hole=True)
        + poly([(56, 8), (30, 52), (46, 52), (40, 92), (70, 44), (52, 44)])
    ),
    # 14 Slangenvolk — cobra met brede kap en gespleten tong
    "Slangenvolk": (
        poly([(50, 34), (86, 44), (96, 68), (78, 92), (58, 96), (50, 88),
              (42, 96), (22, 92), (4, 68), (14, 44)])
        + ellipse(50, 30, 16, 20)
        + poly([(38, 24), (49, 30), (38, 36)], hole=True)
        + poly([(62, 24), (51, 30), (62, 36)], hole=True)
        + bar(50, 46, 50, 64, 5, hole=True)
        + poly([(40, 78), (50, 60), (60, 78), (53, 76), (50, 68), (47, 76)], hole=True)
    ),
    # 15 Draken — kop van opzij met horen, kaak en tanden
    "Draken": (
        poly([(26, 18), (2, 4), (32, 12)])
        + raw(
            "M12 42C12 25 26 12 44 12L40 0L58 10C77 12 91 25 93 41"
            "C95 53 89 63 79 69L97 77L70 77C62 85 48 89 36 85"
            "C20 79 12 63 12 47Z"
        )
        + poly([(50, 32), (68, 39), (50, 45)], hole=True)
        + poly([(40, 58), (91, 55), (87, 68), (46, 71)], hole=True)
        + poly([(50, 71), (52, 60), (56, 71)])
        + poly([(72, 67), (74, 57), (78, 67)])
    ),
    # 16 Titanen — kolossale kop met gebroken kroon
    "Titanen": (
        poly([(18, 30), (28, 10), (40, 26), (50, 6), (60, 26), (72, 10), (82, 30)])
        + raw(
            "M20 34L80 34C84 34 86 38 84 42L74 90C73 93 70 95 68 95"
            "L32 95C30 95 27 93 26 90L16 42C14 38 16 34 20 34Z"
        )
        + poly([(29, 48), (46, 55), (29, 61)], hole=True)
        + poly([(71, 48), (54, 55), (71, 61)], hole=True)
        + poly([(40, 70), (60, 70), (56, 85), (44, 85)], hole=True)
    ),
    # 17 Verdoemden — gehulde gestalte met leeg gezicht
    "Verdoemden": (
        raw(
            "M50 6C71 6 86 23 86 46C86 57 84 67 80 76L90 95L10 95L20 76"
            "C16 67 14 57 14 46C14 23 29 6 50 6Z"
        )
        + ellipse(50, 48, 21, 27, hole=True)
        + circle(42, 45, 5)
        + circle(58, 45, 5)
    ),
    # 18 Gevallen Engelen — halo met één gerafelde vleugel
    "Gevallen Engelen": (
        ellipse(50, 12, 19, 6.5)
        + ellipse(50, 12, 12, 2.5, hole=True)
        + poly([(44, 30), (54, 30), (53, 96), (47, 96)])
        + raw("M45 32C33 30 19 38 11 50C5 60 3 74 5 88L45 62Z")
        + poly([(55, 32), (74, 38), (63, 46), (82, 50), (67, 58), (86, 66),
                (64, 68), (79, 80), (55, 70)])
    ),
    # 19 Sterrensmeden — hamer over een ster
    "Sterrensmeden": (
        poly([(50, 4), (59, 30), (86, 30), (64, 46), (72, 72), (50, 56),
              (28, 72), (36, 46), (14, 30), (41, 30)])
        + bar(30, 66, 86, 94, 11)
        + poly([(16, 56), (44, 56), (44, 76), (16, 76)])
    ),
    # 20 Het Naamloze — leegte met oog en tentakels
    "Het Naamloze": (
        circle(50, 46, 38)
        + ellipse(50, 46, 22, 14, hole=True)
        + circle(50, 46, 7)
        + bar(26, 76, 14, 96, 7)
        + bar(38, 82, 32, 98, 6)
        + bar(50, 84, 50, 98, 7)
        + bar(62, 82, 68, 98, 6)
        + bar(74, 76, 86, 96, 7)
    ),
}


# Iconen voor de spelmodi. Een burchtpoort voor de arena met haar twintig
# werelden, een stopwatch voor het duel van zestig seconden, twee mensen met
# een bliksem ertussen voor het online duel, en een knop met aanwijzer voor
# de clicker.
MODE_ICONEN: dict[str, str] = {
    "arena": (
        poly([(12, 20), (26, 20), (26, 30), (42, 30), (42, 20), (58, 20),
              (58, 30), (74, 30), (74, 20), (88, 20), (88, 40), (12, 40)])
        + poly([(18, 40), (82, 40), (82, 92), (18, 92)])
        + poly([(40, 92), (40, 66), (50, 54), (60, 66), (60, 92)], hole=True)
        + poly([(28, 48), (36, 48), (36, 56), (28, 56)], hole=True)
        + poly([(64, 48), (72, 48), (72, 56), (64, 56)], hole=True)
    ),
    "duel": (
        circle(50, 58, 36)
        + circle(50, 58, 27, hole=True)
        + poly([(38, 4), (62, 4), (62, 16), (38, 16)])
        + bar(50, 20, 50, 30, 9)
        + bar(78, 22, 88, 32, 9)
        + bar(50, 58, 50, 38, 6)
        + bar(50, 58, 66, 66, 5)
        + circle(50, 58, 5)
    ),
    "online": (
        circle(21, 27, 13)
        + poly([(4, 88), (4, 66), (11, 52), (31, 52), (38, 66), (38, 88)])
        + circle(79, 27, 13)
        + poly([(62, 88), (62, 66), (69, 52), (89, 52), (96, 66), (96, 88)])
        + poly([(58, 10), (43, 52), (51, 52), (44, 92), (61, 46), (52, 46)])
    ),
    # Wereldboss: een grote kop met een wereldbol erachter.
    "boss": (
        circle(50, 50, 44)
        + circle(50, 50, 35, hole=True)
        + bar(6, 50, 94, 50, 5)
        + poly([(28, 30), (72, 30), (78, 62), (50, 84), (22, 62)])
        + poly([(32, 40), (46, 46), (32, 52)], hole=True)
        + poly([(68, 40), (54, 46), (68, 52)], hole=True)
        + poly([(38, 60), (62, 60), (58, 70), (42, 70)], hole=True)
    ),
    # Op de maat: een noot met een golf ernaast.
    "muziek": (
        ellipse(30, 74, 18, 14)
        + bar(46, 74, 46, 14, 8)
        + poly([(44, 8), (86, 18), (86, 34), (44, 24)])
        + bar(70, 46, 70, 62, 5)
        + bar(80, 38, 80, 70, 5)
        + bar(90, 50, 90, 58, 5)
    ),
    # De clicker: een grote knop met een aanwijzer erop.
    "klik": (
        circle(44, 50, 36)
        + circle(44, 50, 26, hole=True)
        + poly([(56, 40), (56, 94), (69, 81), (78, 98), (88, 93), (79, 76), (94, 74)])
    ),
}

# De grote knop in de clicker: iemand in plankhouding boven de vloer.
PLANK_ICOON = (
    circle(19, 38, 11)
    + poly([(26, 34), (76, 46), (74, 61), (24, 49)])
    + bar(33, 50, 27, 82, 10)
    + bar(72, 54, 93, 82, 11)
    + poly([(4, 86), (96, 86), (96, 95), (4, 95)])
)


# ---------------------------------------------------------------------------
# Tekeningen in stripstijl: geen silhouet meer maar een heel figuur, opgebouwd
# uit lagen met elk een eigen kleurrol. De rollen worden pas in het spel
# ingevuld, zodat elke arena zijn eigen kleur houdt:
#   lijf   de kleur van de arena          licht  lichtere versie (hoogsel)
#   diep   donkerder (schaduw, achterste)  wit    ogen en tanden
#   kleding stof                           zwart  pupillen, mond
#   broek  donkere stof
# Elke laag krijgt in het spel een donkere omlijning; dat maakt de stripstijl.
# ---------------------------------------------------------------------------


def hand(cx: float, cy: float, r: float = 6.5) -> str:
    return circle(cx, cy, r)


ART: dict[str, list[tuple[str, str]]] = {}


def romp(kleding_rol: str = "kleding", broek_rol: str = "broek") -> list[tuple[str, str]]:
    """Het standaardlijf: achterste arm en been, dan benen, broek en hemd.
    Elke tweevoeter wordt hierop gebouwd, zodat ze familie van elkaar blijven."""
    return [
        (bar(37, 56, 22, 76, 12) + hand(21, 78, 8), "diep"),
        (bar(44, 74, 34, 92, 14), "diep"),
        (poly([(22, 88), (38, 86), (39, 97), (21, 97)]), "diep"),
        (bar(58, 74, 68, 90, 14), "lijf"),
        (poly([(60, 86), (80, 88), (81, 97), (59, 97)]), "lijf"),
        (poly([(36, 68), (64, 68), (70, 82), (58, 82), (56, 74),
               (44, 74), (42, 82), (30, 82)]), broek_rol),
        (poly([(34, 50), (66, 50), (72, 72), (28, 72)]), kleding_rol),
        (poly([(34, 50), (41, 50), (37, 72), (28, 72)]), "diep"),
    ]


def voorarm(rol: str = "lijf") -> list[tuple[str, str]]:
    """De arm die naar voren steekt; die tekenen we altijd als laatste."""
    return [(bar(66, 54, 88, 62, 13) + hand(89, 64, 9), rol)]


def ogen(y: float = 26, r: float = 8, spreiding: float = 10) -> list[tuple[str, str]]:
    return [
        (circle(50 - spreiding, y, r), "wit"),
        (circle(50 + spreiding, y, r), "wit"),
        (circle(50 - spreiding + 2, y + 1.5, r * 0.42), "zwart"),
        (circle(50 + spreiding + 2, y + 1.5, r * 0.42), "zwart"),
    ]


def bek(boven: float = 39, onder: float = 49, breed: float = 17,
        tanden: bool = True) -> list[tuple[str, str]]:
    lagen = [(poly([(50 - breed, boven), (50 + breed, boven),
                    (50 + breed - 4, onder), (50 - breed + 4, onder)]), "zwart")]
    if tanden:
        lagen += [
            (poly([(50 - breed + 3, boven + 1), (50 - breed + 10, onder + 2),
                   (50 - breed + 12, boven + 1)]), "wit"),
            (poly([(50 + breed - 12, boven + 1), (50 + breed - 10, onder + 2),
                   (50 + breed - 3, boven + 1)]), "wit"),
        ]
    return lagen


ART = {
    # 1 Orks — grote kop, puntoren, twee slagtanden
    "Orks": romp() + [
        (ellipse(50, 28, 27, 24), "lijf"),
        (poly([(26, 24), (6, 12), (28, 38)]), "lijf"),
        (poly([(74, 24), (94, 12), (72, 38)]), "lijf"),
        (ellipse(50, 20, 20, 9), "licht"),
    ] + ogen(24, 9) + bek(39, 49, 17) + voorarm(),

    # 2 Oorlogsorks — dezelfde bouw, maar met helm, hoorns en schouderstukken
    "Oorlogsorks": romp("kleding", "broek") + [
        (ellipse(30, 52, 12, 9), "kleding"),
        (ellipse(70, 52, 12, 9), "kleding"),
        (poly([(44, 50), (56, 50), (56, 72), (44, 72)]), "licht"),
        (ellipse(50, 30, 26, 22), "lijf"),
        (poly([(27, 26), (9, 16), (28, 38)]), "lijf"),
        (poly([(73, 26), (91, 16), (72, 38)]), "lijf"),
        (poly([(23, 26), (77, 26), (79, 13), (21, 13)]), "kleding"),
        (poly([(46, 26), (54, 26), (53, 36), (47, 36)]), "kleding"),
        (poly([(25, 20), (12, 4), (34, 12)]), "licht"),
        (poly([(75, 20), (88, 4), (66, 12)]), "licht"),
    ] + ogen(30, 8) + bek(41, 50, 17) + voorarm(),

    # 3 Spinnen — dik achterlijf, acht poten, vier ogen
    "Spinnen": [
        *[(bar(50 + s * 12, hy, 50 + s * kx, ky, 6) + bar(50 + s * kx, ky, 50 + s * ex, ey, 5), laag)
          for hy, kx, ky, ex, ey, laag in [
              (58, 34, 24, 46, 52, "diep"), (62, 38, 40, 48, 74, "diep"),
              (54, 30, 18, 44, 40, "lijf"), (66, 34, 52, 46, 92, "lijf")]
          for s in (-1, 1)],
        (ellipse(50, 66, 24, 25), "lijf"),
        (poly([(50, 46), (60, 60), (50, 74), (40, 60)]), "licht"),
        (ellipse(50, 38, 16, 14), "diep"),
        (circle(43, 34, 6), "wit"),
        (circle(57, 34, 6), "wit"),
        (circle(44, 35, 2.6), "zwart"),
        (circle(58, 35, 2.6), "zwart"),
        (circle(36, 40, 3), "wit"),
        (circle(64, 40, 3), "wit"),
        (poly([(43, 48), (46, 58), (48, 48)]), "wit"),
        (poly([(52, 48), (54, 58), (57, 48)]), "wit"),
    ],

    # 4 Skeletten — botten in plaats van vlees, ribben op de borst
    "Skeletten": romp("licht", "diep") + [
        (poly([(38, 54), (62, 54), (62, 58), (38, 58)]), "diep"),
        (poly([(38, 61), (62, 61), (62, 65), (38, 65)]), "diep"),
        (poly([(47, 52), (53, 52), (53, 70), (47, 70)]), "diep"),
        (ellipse(50, 28, 24, 22), "licht"),
        (poly([(34, 40), (66, 40), (64, 50), (36, 50)]), "licht"),
        (circle(40, 26, 8), "zwart"),
        (circle(60, 26, 8), "zwart"),
        (poly([(47, 34), (53, 34), (50, 41)]), "zwart"),
        (poly([(40, 42), (43, 42), (43, 50), (40, 50)]), "zwart"),
        (poly([(48, 42), (52, 42), (52, 50), (48, 50)]), "zwart"),
        (poly([(57, 42), (60, 42), (60, 50), (57, 50)]), "zwart"),
    ] + voorarm("licht"),

    # 5 Trollen — kleine kop op een zware buik, tanden naar boven
    "Trollen": romp("lijf", "broek") + [
        (ellipse(50, 62, 30, 22), "lijf"),
        (ellipse(50, 66, 18, 13), "licht"),
        (ellipse(50, 28, 22, 19), "lijf"),
        (poly([(30, 26), (16, 16), (31, 36)]), "lijf"),
        (poly([(70, 26), (84, 16), (69, 36)]), "lijf"),
    ] + ogen(24, 6, 9) + [
        (poly([(36, 36), (64, 36), (61, 44), (39, 44)]), "zwart"),
        (poly([(40, 44), (43, 30), (46, 44)]), "wit"),
        (poly([(54, 44), (57, 30), (60, 44)]), "wit"),
    ] + voorarm(),

    # 6 Katjes — klein en pluizig, met staart
    "Katjes": [
        (bar(70, 76, 92, 58, 9) + circle(93, 56, 5), "diep"),
        (bar(40, 74, 34, 92, 12), "diep"),
        (ellipse(36, 94, 9, 5), "diep"),
        (bar(60, 74, 66, 92, 12), "lijf"),
        (ellipse(68, 94, 9, 5), "lijf"),
        (ellipse(50, 66, 22, 20), "lijf"),
        (ellipse(50, 70, 12, 12), "licht"),
        (ellipse(50, 34, 25, 22), "lijf"),
        (poly([(28, 30), (20, 6), (46, 22)]), "lijf"),
        (poly([(72, 30), (80, 6), (54, 22)]), "lijf"),
        (poly([(32, 27), (27, 13), (41, 23)]), "licht"),
        (poly([(68, 27), (73, 13), (59, 23)]), "licht"),
    ] + ogen(32, 7, 10) + [
        (poly([(46, 42), (54, 42), (50, 48)]), "zwart"),
        (bar(28, 40, 6, 34, 3), "diep"),
        (bar(28, 46, 6, 52, 3), "diep"),
        (bar(72, 40, 94, 34, 3), "diep"),
        (bar(72, 46, 94, 52, 3), "diep"),
    ],

    # 7 Geesten — zwevend laken zonder benen
    "Geesten": [
        (raw("M50 8C70 8 82 24 82 44L82 92L72 82L62 92L50 82L38 92L28 82L18 92L18 44C18 24 30 8 50 8Z"),
         "licht"),
        (raw("M50 14C64 14 72 26 72 42L72 74L64 68L54 76L50 70L50 14Z"), "lijf"),
        (circle(40, 40, 9), "zwart"),
        (circle(60, 40, 9), "zwart"),
        (ellipse(50, 60, 8, 11), "zwart"),
    ],

    # 8 Vampiers — bleke kop, zwarte kraag, hoektanden
    "Vampiers": [
        (poly([(22, 52), (78, 52), (94, 96), (6, 96)]), "diep"),
        (poly([(34, 54), (66, 54), (74, 96), (26, 96)]), "kleding"),
        (poly([(42, 54), (58, 54), (58, 96), (42, 96)]), "licht"),
        (poly([(26, 44), (50, 60), (74, 44), (78, 58), (50, 72), (22, 58)]), "diep"),
        (ellipse(50, 28, 23, 22), "licht"),
        (poly([(27, 22), (30, 4), (50, 16), (70, 4), (73, 22), (50, 14)]), "zwart"),
    ] + ogen(28, 7, 9) + [
        (poly([(40, 40), (60, 40), (57, 46), (43, 46)]), "zwart"),
        (poly([(43, 40), (45, 50), (47, 40)]), "wit"),
        (poly([(53, 40), (55, 50), (57, 40)]), "wit"),
    ],

    # 9 Weerwolven — breed, met snuit, oren en klauwen
    "Weerwolven": [
        (bar(40, 74, 30, 92, 15), "diep"),
        (poly([(18, 88), (36, 86), (37, 97), (17, 97)]), "diep"),
        (bar(60, 74, 70, 92, 15), "lijf"),
        (poly([(62, 86), (82, 88), (83, 97), (61, 97)]), "lijf"),
        (bar(66, 62, 92, 74, 10) + poly([(88, 66), (99, 80), (86, 80)]), "diep"),
        (poly([(30, 48), (70, 48), (76, 78), (24, 78)]), "lijf"),
        (poly([(42, 54), (58, 54), (62, 78), (38, 78)]), "licht"),
        (bar(30, 52, 14, 72, 13), "lijf"),
        (poly([(8, 70), (20, 70), (18, 80), (6, 78)]), "lijf"),
        (poly([(6, 78), (2, 86), (10, 82)]), "wit"),
        (poly([(12, 80), (10, 89), (17, 84)]), "wit"),
        (bar(70, 52, 86, 70, 13), "lijf"),
        (poly([(80, 68), (92, 68), (94, 78), (82, 80)]), "lijf"),
        (poly([(94, 76), (98, 84), (90, 82)]), "wit"),
        (poly([(88, 78), (90, 87), (83, 84)]), "wit"),
        (ellipse(50, 30, 25, 21), "lijf"),
        (poly([(28, 22), (18, 2), (40, 16)]), "lijf"),
        (poly([(72, 22), (82, 2), (60, 16)]), "lijf"),
        (poly([(32, 19), (27, 10), (37, 15)]), "diep"),
        (poly([(68, 19), (73, 10), (63, 15)]), "diep"),
        (ellipse(50, 42, 15, 11), "licht"),
        (circle(50, 38, 5), "zwart"),
    ] + ogen(27, 7, 10) + bek(46, 53, 12),

    # 10 Golems — blokken steen met een scheur
    "Golems": [
        (poly([(28, 74), (44, 74), (44, 96), (26, 96)]), "diep"),
        (poly([(56, 74), (72, 74), (74, 96), (56, 96)]), "lijf"),
        (poly([(14, 46), (30, 44), (32, 76), (16, 78)]), "diep"),
        (poly([(70, 44), (86, 46), (84, 78), (68, 76)]), "lijf"),
        (poly([(28, 40), (72, 40), (76, 78), (24, 78)]), "lijf"),
        (poly([(50, 40), (56, 54), (48, 62), (54, 78), (44, 78), (48, 60), (42, 52)]), "diep"),
        (poly([(30, 12), (70, 12), (74, 38), (26, 38)]), "lijf"),
        (poly([(34, 20), (46, 20), (46, 28), (34, 28)]), "licht"),
        (poly([(54, 20), (66, 20), (66, 28), (54, 28)]), "licht"),
    ],

    # 11 Demonen — hoorns, staart en een grijns
    "Demonen": [
        (bar(68, 76, 92, 62, 8) + poly([(88, 56), (99, 62), (88, 68)]), "diep"),
    ] + romp("lijf", "diep") + [
        (ellipse(50, 28, 24, 21), "lijf"),
        (poly([(28, 20), (14, 0), (38, 14)]), "licht"),
        (poly([(72, 20), (86, 0), (62, 14)]), "licht"),
        (poly([(36, 20), (48, 26), (34, 30)]), "zwart"),
        (poly([(64, 20), (52, 26), (66, 30)]), "zwart"),
        (circle(41, 26, 7), "wit"),
        (circle(59, 26, 7), "wit"),
        (circle(42, 27, 3), "zwart"),
        (circle(60, 27, 3), "zwart"),
        (poly([(34, 38), (66, 38), (58, 50), (42, 50)]), "zwart"),
        (poly([(37, 39), (42, 47), (45, 39)]), "wit"),
        (poly([(55, 39), (58, 47), (63, 39)]), "wit"),
    ] + voorarm(),

    # 12 IJsreuzen — zware kop met baard en ijspegels
    "IJsreuzen": romp("kleding", "broek") + [
        (ellipse(30, 52, 13, 10), "kleding"),
        (ellipse(70, 52, 13, 10), "kleding"),
        (poly([(32, 44), (68, 44), (74, 74), (26, 74)]), "wit"),
        (ellipse(50, 26, 25, 22), "lijf"),
        (poly([(26, 30), (74, 30), (70, 52), (58, 44), (50, 56), (42, 44), (30, 52)]), "wit"),
    ] + ogen(24, 7, 10) + [
        (poly([(30, 8), (36, 26), (42, 8)]), "licht"),
        (poly([(58, 8), (64, 26), (70, 8)]), "licht"),
    ] + voorarm(),

    # 13 Zeeduivels — brede bek met lokkertje
    "Zeeduivels": [
        (poly([(14, 40), (30, 56), (14, 74)]), "diep"),
        (poly([(86, 40), (70, 56), (86, 74)]), "diep"),
        (poly([(50, 76), (70, 92), (30, 92)]), "diep"),
        (ellipse(50, 56, 32, 28), "lijf"),
        (ellipse(50, 62, 20, 16), "licht"),
        (poly([(24, 60), (76, 60), (70, 76), (30, 76)]), "zwart"),
        (poly([(27, 61), (33, 74), (37, 61)]), "wit"),
        (poly([(41, 61), (46, 74), (50, 61)]), "wit"),
        (poly([(55, 61), (60, 74), (64, 61)]), "wit"),
        (circle(38, 44, 8), "wit"),
        (circle(62, 44, 8), "wit"),
        (circle(39, 45, 3.5), "zwart"),
        (circle(63, 45, 3.5), "zwart"),
        (bar(50, 30, 62, 10, 4), "diep"),
        (circle(64, 8, 8), "licht"),
    ],

    # 14 Bliksemgeesten — een schicht met ogen
    "Bliksemgeesten": [
        (poly([(56, 4), (26, 50), (44, 50), (32, 96), (74, 40), (54, 40), (74, 4)]), "lijf"),
        (poly([(54, 14), (36, 46), (48, 46), (40, 82), (66, 44), (52, 44), (64, 14)]), "licht"),
        (circle(45, 34, 7), "wit"),
        (circle(59, 30, 7), "wit"),
        (circle(46, 35, 3), "zwart"),
        (circle(60, 31, 3), "zwart"),
    ],

    # 15 Slangenvolk — kap, staart in plaats van benen
    "Slangenvolk": [
        (raw("M50 62C24 62 12 74 12 84C12 92 20 96 32 96L84 96C90 96 92 92 92 88C92 84 88 82 82 82L36 82C30 82 30 76 36 76L60 76Z"),
         "diep"),
        (poly([(36, 46), (64, 46), (70, 70), (30, 70)]), "lijf"),
        (poly([(20, 26), (50, 12), (80, 26), (76, 44), (50, 34), (24, 44)]), "diep"),
        (ellipse(50, 32, 20, 20), "lijf"),
        (ellipse(50, 42, 12, 10), "licht"),
    ] + ogen(30, 7, 9) + [
        (poly([(44, 46), (47, 56), (50, 46)]), "wit"),
        (poly([(50, 46), (53, 56), (56, 46)]), "wit"),
        (bar(50, 50, 50, 66, 3), "zwart"),
    ],

    # 16 Draken — kop met hoorns, vleugels erachter
    "Draken": [
        (poly([(30, 30), (2, 14), (8, 60), (32, 62)]), "diep"),
        (poly([(70, 30), (98, 14), (92, 60), (68, 62)]), "diep"),
        (bar(50, 74, 84, 90, 10) + poly([(80, 84), (96, 92), (78, 96)]), "diep"),
        (poly([(34, 48), (66, 48), (72, 80), (28, 80)]), "lijf"),
        (poly([(44, 54), (56, 54), (60, 80), (40, 80)]), "licht"),
        (ellipse(50, 28, 24, 20), "lijf"),
        (poly([(30, 18), (20, 0), (44, 12)]), "licht"),
        (poly([(70, 18), (80, 0), (56, 12)]), "licht"),
        (ellipse(50, 40, 16, 12), "licht"),
        (circle(44, 40, 3), "zwart"),
        (circle(56, 40, 3), "zwart"),
    ] + ogen(26, 7, 10) + [
        (poly([(36, 44), (64, 44), (60, 52), (40, 52)]), "zwart"),
        (poly([(39, 45), (42, 54), (45, 45)]), "wit"),
        (poly([(55, 45), (58, 54), (61, 45)]), "wit"),
    ],

    # 17 Titanen — enorme schouders, kleine kop, barsten
    "Titanen": [
        (poly([(24, 76), (44, 76), (44, 96), (22, 96)]), "diep"),
        (poly([(56, 76), (76, 76), (78, 96), (56, 96)]), "lijf"),
        (poly([(6, 38), (30, 34), (34, 80), (10, 82)]), "diep"),
        (poly([(70, 34), (94, 38), (90, 82), (66, 80)]), "lijf"),
        (poly([(22, 32), (78, 32), (84, 80), (16, 80)]), "lijf"),
        (poly([(46, 32), (54, 48), (44, 58), (52, 80), (42, 80), (48, 56), (40, 46)]), "diep"),
        (ellipse(50, 20, 16, 14), "lijf"),
        (poly([(40, 16), (46, 16), (46, 24), (40, 24)]), "licht"),
        (poly([(54, 16), (60, 16), (60, 24), (54, 24)]), "licht"),
    ],

    # 18 Verdoemden — kap zonder gezicht
    "Verdoemden": [
        (poly([(24, 48), (76, 48), (88, 96), (12, 96)]), "diep"),
        (poly([(34, 52), (66, 52), (72, 96), (28, 96)]), "kleding"),
        (raw("M50 6C70 6 82 22 82 42L82 58L68 50C62 58 56 60 50 60C44 60 38 58 32 50L18 58L18 42C18 22 30 6 50 6Z"),
         "lijf"),
        (raw("M50 16C64 16 72 28 72 42L72 50C64 54 58 56 50 56C42 56 36 54 28 50L28 42C28 28 36 16 50 16Z"),
         "zwart"),
        (circle(41, 38, 5), "licht"),
        (circle(59, 38, 5), "licht"),
    ],

    # 19 Gevallen Engelen — vleugels en een gebroken kring
    "Gevallen Engelen": [
        (raw("M34 34C18 24 6 30 2 44C10 42 16 44 20 48C10 52 4 60 6 72C14 62 24 60 34 62Z"), "wit"),
        (raw("M66 34C82 24 94 30 98 44C90 42 84 44 80 48C90 52 96 60 94 72C86 62 76 60 66 62Z"), "wit"),
    ] + romp("licht", "diep") + [
        (ellipse(50, 28, 22, 20), "lijf"),
        (poly([(28, 24), (32, 8), (50, 18), (68, 8), (72, 24), (50, 16)]), "diep"),
        (poly([(30, 6), (48, 2), (48, 8), (34, 11)]), "licht"),
        (poly([(52, 2), (70, 6), (66, 11), (52, 8)]), "licht"),
    ] + ogen(28, 7, 9) + [
        (poly([(42, 40), (58, 40), (56, 46), (44, 46)]), "zwart"),
    ] + voorarm("licht"),

    # 20 Sterrensmeden — schort, hamer en een ster op de borst
    "Sterrensmeden": romp("kleding", "diep") + [
        (poly([(38, 50), (62, 50), (66, 78), (34, 78)]), "broek"),
        (poly([(50, 54), (54, 62), (62, 62), (56, 68), (58, 76), (50, 71),
               (42, 76), (44, 68), (38, 62), (46, 62)]), "licht"),
        (ellipse(50, 28, 23, 20), "lijf"),
        (poly([(28, 34), (72, 34), (68, 52), (32, 52)]), "wit"),
    ] + ogen(26, 7, 9) + [
        (bar(76, 60, 88, 26, 7), "diep"),
        (poly([(72, 26), (96, 20), (98, 34), (74, 38)]), "kleding"),
    ],

    # 21 Het Naamloze — één oog in een massa met tentakels
    "Het Naamloze": [
        *[(bar(50, 62, 50 + dx, dy, 9) + circle(50 + dx, dy, 5), "diep")
          for dx, dy in [(-40, 92), (-24, 98), (0, 99), (24, 98), (40, 92)]],
        (raw("M50 8C74 8 92 26 92 50C92 74 74 92 50 92C26 92 8 74 8 50C8 26 26 8 50 8Z"), "lijf"),
        (raw("M50 20C66 20 78 32 78 48C78 64 66 76 50 76C34 76 22 64 22 48C22 32 34 20 50 20Z"), "diep"),
        (ellipse(50, 48, 22, 20), "wit"),
        (circle(50, 48, 11), "lijf"),
        (circle(50, 48, 5), "zwart"),
    ],
}


def schrijf_arena_art() -> None:
    """Zet de tekeningen als 'pad|rol;pad|rol' in ArenaArt.swift."""
    regels = [
        "// Automatisch gegenereerd door iconen.py — bewerk daar de tekeningen.",
        "",
        "/// Tekeningen van de vijanden in lagen: elk stuk een pad met een kleurrol.",
        "enum ArenaArt {",
        "    static let art: [String: String] = [",
    ]
    for ras, lagen in ART.items():
        stuk = ";".join(f"{d}|{rol}" for d, rol in lagen)
        regels.append(f'        "{ras}": "{stuk}",')
    regels += ["    ]", "}", ""]
    (HIER / "spelgegevens" / "ArenaArt.swift").write_text("\n".join(regels))


def schrijf_mode_icons() -> None:
    regels = [
        "// Automatisch gegenereerd door iconen.py — bewerk daar de vormen.",
        "",
        "/// Silhouetten voor de spelmodi, in hetzelfde vak van 100x100 als de vijanden.",
        "enum ModeIcons {",
    ]
    for naam, d in MODE_ICONEN.items():
        regels.append(f'    static let {naam} = "{d}"')
    regels.append(f'    static let plank = "{PLANK_ICOON}"')
    regels += ["}", ""]
    (HIER / "spelgegevens" / "ModeIcons.swift").write_text("\n".join(regels))

# Rangtekens: van een simpel streepje tot iets dat je verdiend moet hebben.
# Ze horen bij de acht rangen uit taal.json (rank_1 tot en met rank_8).
RANG_ICONEN: list[str] = [
    # 1 — enkele streep
    poly([(18, 54), (82, 54), (82, 66), (18, 66)]),
    # 2 — dubbele punt naar boven
    poly([(50, 26), (86, 52), (86, 66), (50, 40), (14, 66), (14, 52)])
    + poly([(50, 54), (86, 80), (86, 92), (50, 68), (14, 92), (14, 80)]),
    # 3 — zwaard rechtop, met punt en knop
    poly([(50, 3), (58, 17), (58, 59), (42, 59), (42, 17)])
    + poly([(27, 59), (73, 59), (73, 69), (27, 69)])
    + poly([(45, 69), (55, 69), (55, 87), (45, 87)])
    + circle(50, 91, 7),
    # 4 — gekruiste zwaarden
    bar(20, 88, 74, 20, 11)
    + poly([(78, 8), (82, 28), (62, 24)])
    + bar(80, 88, 26, 20, 11)
    + poly([(22, 8), (38, 24), (18, 28)]),
    # 5 — schild
    raw("M50 6L88 20V52C88 74 72 88 50 96C28 88 12 74 12 52V20Z")
    + poly([(50, 26), (58, 46), (78, 46), (62, 58), (68, 78), (50, 66), (32, 78), (38, 58), (22, 46), (42, 46)], hole=True),
    # 6 — kroon
    poly([(10, 78), (90, 78), (90, 92), (10, 92)])
    + poly([(10, 24), (30, 46), (50, 14), (70, 46), (90, 24), (90, 72), (10, 72)])
    + circle(50, 42, 7, hole=True),
    # 7 — vlam
    raw("M50 4C58 26 76 34 76 56C76 76 62 92 50 96C38 92 24 76 24 56C24 40 34 34 40 24C42 38 50 40 50 4Z")
    + raw("M50 46C55 58 62 62 62 72C62 82 56 88 50 90C44 88 38 82 38 72C38 64 44 58 50 46Z"),
    # 8 — gevleugelde ster
    poly([(50, 4), (60, 34), (92, 34), (66, 52), (76, 84), (50, 64), (24, 84), (34, 52), (8, 34), (40, 34)])
    + poly([(4, 60), (30, 68), (30, 78), (2, 74)])
    + poly([(96, 60), (98, 74), (70, 78), (70, 68)]),
]

# Kleuren die meelopen met de rang: van dof brons naar stralend wit-goud.
RANG_KLEUREN = [
    "#a8814e", "#c0c0c0", "#8fd14f", "#4ec9f5",
    "#a86bff", "#ffc740", "#ff7326", "#ffffff",
]


def schrijf_rang_icons() -> None:
    regels = [
        "// Automatisch gegenereerd door iconen.py — bewerk daar de vormen.",
        "",
        "/// Rangtekens voor de acht spelerrangen, in hetzelfde vak van 100x100.",
        "enum RankIcons {",
        "    static let paths: [String] = [",
    ]
    for d in RANG_ICONEN:
        regels.append(f'        "{d}",')
    regels += [
        "    ]",
        "",
        "    static let colors: [String] = [",
    ]
    for k in RANG_KLEUREN:
        regels.append(f'        "{k}",')
    regels += ["    ]", "}", ""]
    (HIER / "spelgegevens" / "RankIcons.swift").write_text("\n".join(regels))


def patch_arena_swift() -> int:
    pad = HIER / "spelgegevens" / "Arena.swift"
    bron = pad.read_text()
    aantal = 0
    for race, d in ICONEN.items():
        patroon = re.compile(
            r'(race: L3\("' + re.escape(race) + r'",[^)]*\),\n(\s*)rgb: RGB\([^)]*\),\n)'
            r'(\s*icon: "[^"]*",\n)?'
        )
        m = patroon.search(bron)
        if not m:
            raise SystemExit(f"Kon arena met ras '{race}' niet vinden in Arena.swift")
        inspring = m.group(2)
        bron = bron[: m.start()] + m.group(1) + f'{inspring}icon: "{d}",\n' + bron[m.end():]
        aantal += 1
    pad.write_text(bron)
    return aantal


def preview() -> Path:
    alles = {**ICONEN, **{f"modus: {k}": v for k, v in MODE_ICONEN.items()},
             "plank": PLANK_ICOON,
             **{f"rang {i + 1}": d for i, d in enumerate(RANG_ICONEN)}}
    vakjes = "".join(
        f'<figure><svg viewBox="0 0 100 100"><path d="{d}"/></svg>'
        f"<figcaption>{race}</figcaption></figure>"
        for race, d in alles.items()
    )
    html = (
        '<meta charset="utf-8"><title>Iconen</title>'
        "<style>body{background:#0b0b0d;color:#eee;font-family:system-ui;margin:0;padding:24px}"
        "main{display:grid;grid-template-columns:repeat(5,1fr);gap:18px}"
        "figure{margin:0;text-align:center}"
        "svg{width:100%;background:#141418;border-radius:12px;fill:#ffc740}"
        "figcaption{font-size:11px;color:#999;margin-top:6px}</style>"
        f"<main>{vakjes}</main>"
    )
    uit = HIER / "overzicht-iconen.html"
    uit.write_text(html)
    poppetjes()
    return uit


# Grof dezelfde kleuren als in het spel, zodat het overzicht laat zien wat je
# straks ook echt ziet.
PREVIEW_KLEUR = {"lijf": "#6db354", "diep": "#41702f", "licht": "#9ad47f",
                 "kleding": "#8a8577", "broek": "#4a4f5c",
                 "wit": "#f4f1e8", "zwart": "#191a1f"}


def poppetjes() -> Path:
    """Alle vijanden in lagen naast elkaar. Handig om te zien of ze nog
    familie van elkaar zijn nadat je aan de vormen hebt gezeten."""
    vakjes = ""
    for ras, lagen in ART.items():
        stukken = "".join(
            f'<path d="{d}" fill="{PREVIEW_KLEUR.get(rol, "#888")}" stroke="#191a1f" '
            f'stroke-width="{1.6 if rol in ("wit", "zwart") else 2.8}" '
            f'stroke-linejoin="round"/>'
            for d, rol in lagen
        )
        vakjes += (f'<figure><svg viewBox="-4 -4 108 108">{stukken}</svg>'
                   f"<figcaption>{ras}</figcaption></figure>")
    html = (
        '<meta charset="utf-8"><title>Poppetjes</title>'
        "<style>body{background:#0b0b0d;color:#eee;font-family:system-ui;margin:0;padding:20px}"
        "main{display:grid;grid-template-columns:repeat(5,1fr);gap:14px}"
        "figure{margin:0;text-align:center}"
        "svg{width:100%;background:#15181a;border-radius:12px}"
        "figcaption{font-size:11px;color:#999;margin-top:4px}</style>"
        f"<main>{vakjes}</main>"
    )
    uit = HIER / "overzicht-poppetjes.html"
    uit.write_text(html)
    return uit


if __name__ == "__main__":
    if "--preview" in sys.argv:
        print("overzicht geschreven:", preview().name, "+ overzicht-poppetjes.html")
    else:
        aantal = patch_arena_swift()
        schrijf_mode_icons()
        schrijf_arena_art()
        schrijf_rang_icons()
        print(f"{aantal} iconen in Arena.swift gezet, "
              f"{len(MODE_ICONEN)} modus-iconen, {len(RANG_ICONEN)} rangtekens")
