#!/usr/bin/env python3
"""Genereert Orbslayer/Strings.swift uit taal.json.

De browserversie leest dezelfde taal.json via bouw-proefversie.py, zodat de app
en de proefversie nooit uit elkaar lopen.

Gebruik:  python3 taal.py
"""
import json
from pathlib import Path

from telwoord import telwoord

HIER = Path(__file__).parent
TALEN = ["nl", "en", "fr"]


def aantal_arenas() -> int:
    bron = (HIER / "Orbslayer" / "Arena.swift").read_text()
    blok = bron.split("static let all: [Arena] = [", 1)[1].split("\n    ]", 1)[0]
    aantal = blok.count("Arena(")
    if aantal == 0:
        raise SystemExit("Geen arena's gevonden in Arena.swift")
    return aantal


def lees() -> dict[str, list[str]]:
    data = json.loads((HIER / "taal.json").read_text())["teksten"]
    for sleutel, waarden in data.items():
        if len(waarden) != len(TALEN):
            raise SystemExit(f"'{sleutel}' heeft {len(waarden)} vertalingen, verwacht {len(TALEN)}")
    # {AANTAL_ARENAS} wordt het aantal arena's uit Arena.swift, voluit in de
    # taal van de tekst. Zo blijft dat aantal overal kloppen als er een
    # wereld bij komt of af gaat.
    woorden = [telwoord(aantal_arenas(), taal) for taal in TALEN]
    return {
        sleutel: [w.replace("{AANTAL_ARENAS}", woorden[i]) for i, w in enumerate(waarden)]
        for sleutel, waarden in data.items()
    }


def swift_string(s: str) -> str:
    return s.replace("\\", "\\\\").replace('"', '\\"')


def main() -> None:
    teksten = lees()
    sleutels = list(teksten)

    regels = [
        "// Automatisch gegenereerd door taal.py — bewerk taal.json, niet dit bestand.",
        "",
        "import Foundation",
        "",
        "enum Lang: String, Codable, CaseIterable {",
        "    case nl, en, fr",
        "",
        "    var label: String {",
        "        switch self {",
        '        case .nl: return "Nederlands"',
        '        case .en: return "English"',
        '        case .fr: return "Français"',
        "        }",
        "    }",
        "",
        "    var short: String { rawValue.uppercased() }",
        "",
        "    /// De taal van het toestel, als we die ondersteunen.",
        "    static var systemDefault: Lang {",
        "        let code = Locale.preferredLanguages.first?.prefix(2).lowercased() ?? \"nl\"",
        "        return Lang(rawValue: String(code)) ?? .en",
        "    }",
        "}",
        "",
        "/// Sleutels van alle interfaceteksten.",
        "enum Tk: String {",
    ]
    for sleutel in sleutels:
        regels.append(f"    case {sleutel}")
    regels += [
        "}",
        "",
        "enum Strings {",
        "    private static let table: [String: [String]] = [",
    ]
    for sleutel in sleutels:
        waarden = ", ".join(f'"{swift_string(v)}"' for v in teksten[sleutel])
        regels.append(f'        "{sleutel}": [{waarden}],')
    regels += [
        "    ]",
        "",
        "    /// Haalt een tekst op en vult {0}, {1}, … met de meegegeven waarden.",
        "    static func text(_ key: Tk, _ lang: Lang, _ args: [String] = []) -> String {",
        "        guard let row = table[key.rawValue] else { return key.rawValue }",
        "        let index = Lang.allCases.firstIndex(of: lang) ?? 0",
        "        var result = index < row.count ? row[index] : row[0]",
        "        for (i, arg) in args.enumerated() {",
        '            result = result.replacingOccurrences(of: "{\\(i)}", with: arg)',
        "        }",
        "        return result",
        "    }",
        "}",
        "",
    ]

    uit = HIER / "Orbslayer" / "Strings.swift"
    uit.write_text("\n".join(regels))
    print(f"Strings.swift geschreven — {len(sleutels)} teksten × {len(TALEN)} talen")


if __name__ == "__main__":
    main()
