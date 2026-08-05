#!/usr/bin/env python3
"""Schrijft een getal voluit in het Nederlands, Engels of Frans.

Wordt gebruikt door taal.py en bouw-proefversie.py om het aantal werelden in
de teksten te vullen. Zo groeit dat aantal automatisch mee met het aantal
arena's in Orbslayer/Arena.swift, in plaats van dat het ergens hard in een
zin staat en veroudert.
"""

NL_KLEIN = ["nul", "een", "twee", "drie", "vier", "vijf", "zes", "zeven",
            "acht", "negen", "tien", "elf", "twaalf", "dertien", "veertien",
            "vijftien", "zestien", "zeventien", "achttien", "negentien"]
NL_TIENTALLEN = {20: "twintig", 30: "dertig", 40: "veertig", 50: "vijftig",
                 60: "zestig", 70: "zeventig", 80: "tachtig", 90: "negentig"}

EN_KLEIN = ["zero", "one", "two", "three", "four", "five", "six", "seven",
            "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen",
            "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"]
EN_TIENTALLEN = {20: "twenty", 30: "thirty", 40: "forty", 50: "fifty",
                 60: "sixty", 70: "seventy", 80: "eighty", 90: "ninety"}

FR_KLEIN = ["zéro", "un", "deux", "trois", "quatre", "cinq", "six", "sept",
            "huit", "neuf", "dix", "onze", "douze", "treize", "quatorze",
            "quinze", "seize", "dix-sept", "dix-huit", "dix-neuf"]
FR_TIENTALLEN = {20: "vingt", 30: "trente", 40: "quarante", 50: "cinquante",
                 60: "soixante"}


def _nl(n: int) -> str:
    if n < 20:
        return NL_KLEIN[n]
    tiental, rest = n - n % 10, n % 10
    if rest == 0:
        return NL_TIENTALLEN[tiental]
    # twee en drie eindigen op een klinker, dan wordt "en" "ën": drieëntwintig.
    koppel = "ën" if NL_KLEIN[rest].endswith("e") else "en"
    return NL_KLEIN[rest] + koppel + NL_TIENTALLEN[tiental]


def _en(n: int) -> str:
    if n < 20:
        return EN_KLEIN[n]
    tiental, rest = n - n % 10, n % 10
    if rest == 0:
        return EN_TIENTALLEN[tiental]
    return EN_TIENTALLEN[tiental] + "-" + EN_KLEIN[rest]


def _fr(n: int) -> str:
    if n < 20:
        return FR_KLEIN[n]
    if n < 70:
        tiental, rest = n - n % 10, n % 10
        if rest == 0:
            return FR_TIENTALLEN[tiental]
        if rest == 1:
            return FR_TIENTALLEN[tiental] + " et un"
        return FR_TIENTALLEN[tiental] + "-" + FR_KLEIN[rest]
    if n < 80:
        # 70-79 telt door op zestig: soixante-dix, soixante et onze, …
        rest = n - 60
        if rest == 11:
            return "soixante et onze"
        return "soixante-" + FR_KLEIN[rest]
    # 80-99 telt door op quatre-vingt: quatre-vingts, quatre-vingt-un, …
    rest = n - 80
    if rest == 0:
        return "quatre-vingts"
    return "quatre-vingt-" + FR_KLEIN[rest]


def telwoord(n: int, taal: str) -> str:
    if not 0 <= n <= 99:
        raise ValueError(f"telwoord kan 0 t/m 99 aan, kreeg {n}")
    schrijvers = {"nl": _nl, "en": _en, "fr": _fr}
    if taal not in schrijvers:
        raise ValueError(f"Onbekende taal: {taal}")
    return schrijvers[taal](n)


if __name__ == "__main__":
    for proef in (8, 20, 21, 22, 23, 31, 47, 71, 80, 81, 91):
        print(proef, "·", telwoord(proef, "nl"), "·",
              telwoord(proef, "en"), "·", telwoord(proef, "fr"))
