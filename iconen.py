#!/usr/bin/env python3
"""Tekent de vijand-iconen en schrijft ze als SVG-pad in Orbslayer/Arena.swift.

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


def poly(points: list[tuple[float, float]], hole: bool = False) -> str:
    # De richting waarin de punten toevallig staan mag niet uitmaken: we draaien
    # ze zo nodig om, zodat 'hole' altijd echt een gat oplevert.
    opp = _oppervlak(points)
    pts = list(reversed(points)) if (opp > 0) == hole else list(points)
    d = f"M{_f(pts[0][0])} {_f(pts[0][1])}"
    for x, y in pts[1:]:
        d += f"L{_f(x)} {_f(y)}"
    return d + "Z"


def bar(x1: float, y1: float, x2: float, y2: float, w: float, hole: bool = False) -> str:
    """Balk tussen twee punten, bruikbaar voor poten en ledematen."""
    dx, dy = x2 - x1, y2 - y1
    ln = math.hypot(dx, dy) or 1
    nx, ny = -dy / ln * w / 2, dx / ln * w / 2
    return poly(
        [(x1 + nx, y1 + ny), (x2 + nx, y2 + ny), (x2 - nx, y2 - ny), (x1 - nx, y1 - ny)],
        hole,
    )


def raw(d: str) -> str:
    return d


def spider_legs() -> str:
    """Vier poten per kant, van het lijf naar buiten en dan omlaag."""
    d = ""
    for i, (hy, ky, ex, ey) in enumerate(
        [(40, 22, 8, 40), (48, 30, 4, 54), (56, 44, 6, 70), (62, 58, 14, 84)]
    ):
        for sign in (-1, 1):
            hx = 50 + sign * 12
            kx = 50 + sign * 30
            d += bar(hx, hy, kx, ky, 5)
            d += bar(kx, ky, 50 + sign * (50 - ex), ey, 4)
    return d


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
    # 2 Zombies — hap uit de schedel, scheve ogen, gerafelde mond
    "Zombies": (
        raw(
            "M50 8C68 8 82 20 85 36L69 31L76 47C80 67 68 91 50 91"
            "C30 91 13 70 13 46C13 24 30 8 50 8Z"
        )
        + circle(36, 46, 9, hole=True)
        + circle(63, 49, 4, hole=True)
        + poly([(29, 65), (38, 72), (46, 65), (54, 72), (62, 65), (70, 72),
                (66, 81), (33, 81)], hole=True)
    ),
    # 3 Spinnen — lijf, kop en acht poten
    "Spinnen": (
        spider_legs()
        + ellipse(50, 58, 18, 16)
        + ellipse(50, 34, 12, 10)
        + circle(45, 32, 3, hole=True)
        + circle(55, 32, 3, hole=True)
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
    # 8 Weerwolven — huilende wolvenkop van opzij
    "Weerwolven": (
        raw(
            "M16 30L26 10L38 28C44 24 52 23 58 25L70 6L76 26"
            "C84 34 86 46 82 56L96 62L78 69C74 81 60 88 46 86"
            "C30 84 18 70 16 52Z"
        )
        + poly([(46, 41), (59, 46), (46, 50)], hole=True)
        + poly([(64, 59), (93, 62), (88, 71), (66, 71)], hole=True)
        + poly([(69, 71), (71, 62), (74, 71)])
        + poly([(80, 70), (82, 62), (85, 70)])
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
    (HIER / "Orbslayer" / "ModeIcons.swift").write_text("\n".join(regels))

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
    (HIER / "Orbslayer" / "RankIcons.swift").write_text("\n".join(regels))


def patch_arena_swift() -> int:
    pad = HIER / "Orbslayer" / "Arena.swift"
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
    return uit


if __name__ == "__main__":
    if "--preview" in sys.argv:
        print("overzicht geschreven:", preview().name)
    else:
        aantal = patch_arena_swift()
        schrijf_mode_icons()
        schrijf_rang_icons()
        print(f"{aantal} iconen in Arena.swift gezet, "
              f"{len(MODE_ICONEN)} modus-iconen, {len(RANG_ICONEN)} rangtekens")
