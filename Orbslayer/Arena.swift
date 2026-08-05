import SwiftUI

/// Kleur als losse componenten, zodat we hem kunnen mengen met bloedrood
/// naarmate een vijand doodgaat.
struct RGB {
    let r: Double
    let g: Double
    let b: Double

    init(_ r: Double, _ g: Double, _ b: Double) {
        self.r = r
        self.g = g
        self.b = b
    }

    var color: Color { Color(red: r, green: g, blue: b) }
}

/// Een tekst in de drie talen die het spel spreekt.
struct L3 {
    let nl: String
    let en: String
    let fr: String

    init(_ nl: String, _ en: String, _ fr: String) {
        self.nl = nl
        self.en = en
        self.fr = fr
    }

    func text(_ lang: Lang) -> String {
        switch lang {
        case .nl: return nl
        case .en: return en
        case .fr: return fr
        }
    }
}

/// Een arena is een themawereld met eigen vijanden, boss en kleur.
/// Ze volgen elkaar op zodra je de boss van de vorige arena velt.
///
/// Vijanden heten gewoon naar wat ze zijn: een Ork, een Zombie, een Skelet.
struct Arena {
    let name: L3
    let race: L3
    let rgb: RGB
    /// Silhouet van dit ras als SVG-pad in een vak van 100x100.
    /// Gegenereerd door iconen.py — niet met de hand aanpassen.
    let icon: String
    /// Naam van een gewone vijand hier, bijvoorbeeld "Ork" of "Zombie".
    let minionName: L3
    let bossName: L3
    /// Korte zin die bij het betreden van de arena in beeld komt.
    let intro: L3

    var color: Color { rgb.color }

    static let all: [Arena] = [
        Arena(
            name: L3("Orkenrijk", "Orc Realm", "Royaume des Orques"),
            race: L3("Orks", "Orcs", "Orques"),
            rgb: RGB(0.38, 0.78, 0.24),
            icon: "M50 8C72 8 86 22 86 42L86 54C86 72 70 88 50 88C30 88 14 72 14 54L14 42C14 22 28 8 50 8ZM17 54L1 24L15 36ZM85 36L99 24L83 54ZM28 57L46 50L28 42ZM72 42L54 50L72 57ZM31 79L69 79L69 65L31 65ZM35 79L39 67L43 79ZM57 79L61 67L65 79Z",
            minionName: L3("Ork", "Orc", "Orque"),
            bossName: L3("Grote Ork", "Great Orc", "Grand Orque"),
            intro: L3("Modder, rook en het gebrul van orks.", "Mud, smoke, and the roar of orcs.", "Boue, fumée et le rugissement des orques.")
        ),
        Arena(
            name: L3("Oorlogshorde", "War Horde", "Horde de Guerre"),
            race: L3("Oorlogsorks", "War Orcs", "Orques de Guerre"),
            rgb: RGB(0.72, 0.55, 0.16),
            icon: "M50 22C70 22 84 36 84 54L84 62C84 78 69 92 50 92C31 92 16 78 16 62L16 54C16 36 30 22 50 22ZM14 26L86 26L86 40L14 40ZM14 32L0 8L24 24ZM76 24L100 8L86 32ZM45 40L55 40L55 60L45 60ZM24 62L41 55L24 48ZM76 48L59 55L76 62ZM28 85L72 85L72 70L28 70ZM33 85L38 66L43 85ZM57 85L62 66L67 85Z",
            minionName: L3("Oorlogsork", "War Orc", "Orque de Guerre"),
            bossName: L3("Grote Oorlogsork", "Great War Orc", "Grand Orque de Guerre"),
            intro: L3("Deze dragen ijzer, en ze weten hoe ze het moeten gebruiken.", "These ones wear iron, and they know how to use it.", "Ceux-là portent le fer, et savent s'en servir.")
        ),
        Arena(
            name: L3("Spinnenkuil", "Spider Pit", "Fosse aux Araignées"),
            race: L3("Spinnen", "Spiders", "Araignées"),
            rgb: RGB(0.56, 0.34, 0.78),
            icon: "M38 43.6L14 13.6L18 10.4L42 40.4ZM17.8 12.8L5.8 38.8L2.2 37.2L14.2 11.2ZM58 40.4L82 10.4L86 13.6L62 43.6ZM85.8 11.2L97.8 37.2L94.2 38.8L82.2 12.8ZM38.5 50L6.5 26L9.5 22L41.5 46ZM10 24.4L2 60.4L-2 59.6L6 23.6ZM58.5 46L90.5 22L93.5 26L61.5 50ZM94 23.6L102 59.6L98 60.4L90 24.4ZM39.3 56.4L5.3 46.4L6.7 41.6L40.7 51.6ZM8 44.1L6 82.1L2 81.9L4 43.9ZM59.3 51.6L93.3 41.6L94.7 46.4L60.7 56.4ZM96 43.9L98 81.9L94 82.1L92 44.1ZM40.2 60.5L10.2 62.5L9.8 57.5L39.8 55.5ZM12 59.8L16 95.8L12 96.2L8 60.2ZM60.2 55.5L90.2 57.5L89.8 62.5L59.8 60.5ZM92 60.2L88 96.2L84 95.8L88 59.8ZM47 48.3L24 68.3L20 63.7L43 43.7ZM57 43.7L80 63.7L76 68.3L53 48.3ZM29 66C29 53.8 38.4 44 50 44C61.6 44 71 53.8 71 66C71 78.2 61.6 88 50 88C38.4 88 29 78.2 29 66ZM37 40C37 33.4 42.8 28 50 28C57.2 28 63 33.4 63 40C63 46.6 57.2 52 50 52C42.8 52 37 46.6 37 40ZM40.8 36C40.8 37.8 42.2 39.2 44 39.2C45.8 39.2 47.2 37.8 47.2 36C47.2 34.2 45.8 32.8 44 32.8C42.2 32.8 40.8 34.2 40.8 36ZM52.8 36C52.8 37.8 54.2 39.2 56 39.2C57.8 39.2 59.2 37.8 59.2 36C59.2 34.2 57.8 32.8 56 32.8C54.2 32.8 52.8 34.2 52.8 36ZM36 41C36 42.1 36.9 43 38 43C39.1 43 40 42.1 40 41C40 39.9 39.1 39 38 39C36.9 39 36 39.9 36 41ZM60 41C60 42.1 60.9 43 62 43C63.1 43 64 42.1 64 41C64 39.9 63.1 39 62 39C60.9 39 60 39.9 60 41ZM44.2 31C44.2 32 45 32.8 46 32.8C47 32.8 47.8 32 47.8 31C47.8 30 47 29.2 46 29.2C45 29.2 44.2 30 44.2 31ZM52.2 31C52.2 32 53 32.8 54 32.8C55 32.8 55.8 32 55.8 31C55.8 30 55 29.2 54 29.2C53 29.2 52.2 30 52.2 31Z",
            minionName: L3("Spin", "Spider", "Araignée"),
            bossName: L3("Grote Spin", "Great Spider", "Grande Araignée"),
            intro: L3("Alles hier plakt. Jij ook.", "Everything here sticks. You too.", "Ici tout colle. Toi aussi.")
        ),
        Arena(
            name: L3("Bottenburcht", "Bone Fortress", "Forteresse d'Os"),
            race: L3("Skeletten", "Skeletons", "Squelettes"),
            rgb: RGB(0.78, 0.84, 0.95),
            icon: "M50 9C72 9 87 26 87 46C87 58 81 66 75 70L75 84C75 88 71 91 67 91L33 91C29 91 25 88 25 84L25 70C19 66 13 58 13 46C13 26 28 9 50 9ZM25 44C25 49.5 29.5 54 35 54C40.5 54 45 49.5 45 44C45 38.5 40.5 34 35 34C29.5 34 25 38.5 25 44ZM55 44C55 49.5 59.5 54 65 54C70.5 54 75 49.5 75 44C75 38.5 70.5 34 65 34C59.5 34 55 38.5 55 44ZM43 67L57 67L50 55ZM38 88L43 88L43 74L38 74ZM47 88L53 88L53 74L47 74ZM57 88L62 88L62 74L57 74Z",
            minionName: L3("Skelet", "Skeleton", "Squelette"),
            bossName: L3("Groot Skelet", "Great Skeleton", "Grand Squelette"),
            intro: L3("Het rammelt in het donker.", "Something rattles in the dark.", "Ça cliquette dans le noir.")
        ),
        Arena(
            name: L3("Trollenmoeras", "Troll Mire", "Marais des Trolls"),
            race: L3("Trollen", "Trolls", "Trolls"),
            rgb: RGB(0.44, 0.58, 0.32),
            icon: "M37 26L21 6L34 20ZM66 20L79 6L63 26ZM30 30C30 19 39 10 50 10C61 10 70 19 70 30C70 41 61 50 50 50C39 50 30 41 30 30ZM32 44C16 50 6 64 6 80L6 94L94 94L94 80C94 64 84 50 68 44C63 52 57 56 50 56C43 56 37 52 32 44ZM38.5 27C38.5 28.9 40.1 30.5 42 30.5C43.9 30.5 45.5 28.9 45.5 27C45.5 25.1 43.9 23.5 42 23.5C40.1 23.5 38.5 25.1 38.5 27ZM54.5 27C54.5 28.9 56.1 30.5 58 30.5C59.9 30.5 61.5 28.9 61.5 27C61.5 25.1 59.9 23.5 58 23.5C56.1 23.5 54.5 25.1 54.5 27ZM40 41L60 41L60 34L40 34ZM43 41L45 32L47 41ZM53 41L55 32L57 41Z",
            minionName: L3("Trol", "Troll", "Troll"),
            bossName: L3("Grote Trol", "Great Troll", "Grand Troll"),
            intro: L3("Iets zwaars komt door het water.", "Something heavy is coming through the water.", "Quelque chose de lourd traverse l'eau.")
        ),
        Arena(
            name: L3("Pluizige Pussy", "Fluffy Kittens", "Chatons Pelucheux"),
            race: L3("Katjes", "Kittens", "Chatons"),
            rgb: RGB(0.98, 0.62, 0.76),
            icon: "M79 63.8L85.6 71.9L75.2 72.3ZM75.2 72.3L79 82.1L68.9 79.3ZM68.9 79.3L69.5 89.8L60.8 84ZM60.8 84L58.1 94.1L51.6 86ZM51.6 86L45.9 94.8L42.2 85ZM42.2 85L34.1 91.6L33.7 81.2ZM33.7 81.2L23.9 85L26.7 74.9ZM26.7 74.9L16.2 75.5L22 66.8ZM22 66.8L11.9 64.1L20 57.6ZM20 57.6L11.2 51.9L21 48.2ZM21 48.2L14.4 40.1L24.8 39.7ZM24.8 39.7L21 29.9L31.1 32.7ZM31.1 32.7L30.5 22.2L39.2 28ZM39.2 28L41.9 17.9L48.4 26ZM48.4 26L54.1 17.2L57.8 27ZM57.8 27L65.9 20.4L66.3 30.8ZM66.3 30.8L76.1 27L73.3 37.1ZM73.3 37.1L83.8 36.5L78 45.2ZM20 56C20 39.4 33.4 26 50 26C66.6 26 80 39.4 80 56C80 72.6 66.6 86 50 86C33.4 86 20 72.6 20 56ZM25 40L16 6L47 27ZM53 27L84 6L75 40ZM41 30L25 17L30 35ZM70 35L75 17L59 30ZM33.5 52C33.5 55 36 57.5 39 57.5C42 57.5 44.5 55 44.5 52C44.5 49 42 46.5 39 46.5C36 46.5 33.5 49 33.5 52ZM55.5 52C55.5 55 58 57.5 61 57.5C64 57.5 66.5 55 66.5 52C66.5 49 64 46.5 61 46.5C58 46.5 55.5 49 55.5 52ZM50 71L56 63L44 63ZM23.6 63.4L1.6 57.4L2.4 54.6L24.4 60.6ZM24.4 71.4L2.4 77.4L1.6 74.6L23.6 68.6ZM75.6 60.6L97.6 54.6L98.4 57.4L76.4 63.4ZM76.4 68.6L98.4 74.6L97.6 77.4L75.6 71.4Z",
            minionName: L3("Katje", "Kitten", "Chaton"),
            bossName: L3("Grote Kat", "Great Cat", "Grand Chat"),
            intro: L3("Duizend pluizige katjes. Ze zijn schattig, en ze komen allemaal tegelijk.", "A thousand fluffy kittens. They are adorable, and they all come at once.", "Mille chatons tout doux. Ils sont adorables, et ils arrivent tous ensemble.")
        ),
        Arena(
            name: L3("Zielenmist", "Soul Mist", "Brume des Âmes"),
            race: L3("Geesten", "Ghosts", "Fantômes"),
            rgb: RGB(0.36, 0.86, 0.92),
            icon: "M50 10C70 10 83 26 83 47L83 90L71 79L59 90L47 79L35 90L23 79L17 90L17 47C17 26 30 10 50 10ZM31.5 43C31.5 48 34.4 52 38 52C41.6 52 44.5 48 44.5 43C44.5 38 41.6 34 38 34C34.4 34 31.5 38 31.5 43ZM55.5 43C55.5 48 58.4 52 62 52C65.6 52 68.5 48 68.5 43C68.5 38 65.6 34 62 34C58.4 34 55.5 38 55.5 43Z",
            minionName: L3("Geest", "Ghost", "Fantôme"),
            bossName: L3("Grote Geest", "Great Ghost", "Grand Fantôme"),
            intro: L3("Ze hebben geen lichaam. Wel honger.", "They have no bodies. They do have hunger.", "Ils n'ont pas de corps. Mais ils ont faim.")
        ),
        Arena(
            name: L3("Bloedkathedraal", "Blood Cathedral", "Cathédrale de Sang"),
            race: L3("Vampiers", "Vampires", "Vampires"),
            rgb: RGB(0.78, 0.14, 0.34),
            icon: "M50 34L26 16L30 36L6 32L20 52L38 56L50 70L62 56L80 52L94 32L70 36L74 16ZM35 40C35 32.3 41.7 26 50 26C58.3 26 65 32.3 65 40C65 47.7 58.3 54 50 54C41.7 54 35 47.7 35 40ZM38 20L44 32L32 32ZM62 20L68 32L56 32ZM39.5 38C39.5 39.9 41.1 41.5 43 41.5C44.9 41.5 46.5 39.9 46.5 38C46.5 36.1 44.9 34.5 43 34.5C41.1 34.5 39.5 36.1 39.5 38ZM53.5 38C53.5 39.9 55.1 41.5 57 41.5C58.9 41.5 60.5 39.9 60.5 38C60.5 36.1 58.9 34.5 57 34.5C55.1 34.5 53.5 36.1 53.5 38ZM42 50L48 50L45 62ZM52 50L58 50L55 62Z",
            minionName: L3("Vampier", "Vampire", "Vampire"),
            bossName: L3("Grote Vampier", "Great Vampire", "Grand Vampire"),
            intro: L3("Alle ramen zijn zwart geverfd.", "Every window is painted black.", "Toutes les fenêtres sont peintes en noir.")
        ),
        Arena(
            name: L3("Grote Wolvenwoud", "Great Wolf Forest", "Grande Forêt des Loups"),
            race: L3("Weerwolven", "Werewolves", "Loups-garous"),
            rgb: RGB(0.34, 0.6, 0.3),
            icon: "M80.4 59.7L94.5 70.9L76 70.3ZM76 70.3L84.5 85.3L67.8 78.6ZM67.8 78.6L69.5 95.1L57 83.2ZM57 83.2L51.7 99L45.2 83.6ZM45.2 83.6L33.6 96.3L34 79.7ZM34 79.7L17.9 87.4L25.2 72.1ZM25.2 72.1L6.9 73.7L20.1 61.8ZM20.1 61.8L2.1 57.1L19.2 50.3ZM19.2 50.3L4.3 40.1L22.9 39.5ZM22.9 39.5L13.2 25.1L30.5 30.7ZM30.5 30.7L27.5 14.3L40.9 25.3ZM40.9 25.3L45 9.2L52.7 24.1ZM52.7 24.1L63.2 10.7L64.1 27.3ZM64.1 27.3L79.6 18.5L73.4 34.3ZM73.4 34.3L91.6 31.5L79.3 44.2ZM24 36L13 2L45 26ZM55 26L87 2L76 36ZM20 42L30 24L44 32L56 32L70 24L80 42L74 64L58 78L50 88L42 78L26 64ZM30 58L46 52L30 44ZM70 44L54 52L70 58ZM50 70L57 62L43 62ZM50 84L62 74L38 74ZM46 76L44 82L41 76ZM59 76L56 82L54 76Z",
            minionName: L3("Weerwolf", "Werewolf", "Loup-garou"),
            bossName: L3("Grote Weerwolf", "Great Werewolf", "Grand Loup-garou"),
            intro: L3("De maan staat vol boven de bomen.", "The moon hangs full above the trees.", "La lune est pleine au-dessus des arbres.")
        ),
        Arena(
            name: L3("Golemgroeve", "Golem Quarry", "Carrière des Golems"),
            race: L3("Golems", "Golems", "Golems"),
            rgb: RGB(0.62, 0.62, 0.64),
            icon: "M28 8L72 8L80 24L72 38L28 38L20 24ZM34 25L46 27L46 16L34 18ZM54 16L54 27L66 25L66 18ZM14 44L86 44L80 94L20 94ZM22.1 52.1L11.1 84.1L-1.1 79.9L9.9 47.9ZM90.1 47.9L101.1 79.9L88.9 84.1L77.9 52.1ZM42 52L50 60L39 70L49 90L55 86L46 70L57 60L48 50Z",
            minionName: L3("Golem", "Golem", "Golem"),
            bossName: L3("Grote Golem", "Great Golem", "Grand Golem"),
            intro: L3("Steen wordt nooit moe. Jij wel.", "Stone never tires. You do.", "La pierre ne fatigue jamais. Toi si.")
        ),
        Arena(
            name: L3("Demonenpoort", "Demon Gate", "Porte des Démons"),
            race: L3("Demonen", "Demons", "Démons"),
            rgb: RGB(1.0, 0.42, 0.12),
            icon: "M30 30C26 18 18 8 6 2C6 18 12 32 24 42L34 34ZM70 30C74 18 82 8 94 2C94 18 88 32 76 42L66 34ZM50 22C67 22 80 35 80 52C80 60 78 66 74 72L50 96L26 72C22 66 20 60 20 52C20 35 33 22 50 22ZM30 59L46 53L30 46ZM70 46L54 53L70 59ZM50 82L61 68L39 68Z",
            minionName: L3("Demon", "Demon", "Démon"),
            bossName: L3("Grote Demon", "Great Demon", "Grand Démon"),
            intro: L3("De grond is te heet om te knielen.", "The ground is too hot to kneel on.", "Le sol est trop brûlant pour s'agenouiller.")
        ),
        Arena(
            name: L3("IJsreuzenburcht", "Frost Giants' Keep", "Donjon des Géants de Glace"),
            race: L3("IJsreuzen", "Frost Giants", "Géants de Givre"),
            rgb: RGB(0.42, 0.78, 1.0),
            icon: "M26 40L16 12L34 28L42 6L50 24L58 6L66 28L84 12L74 40C82 48 84 62 78 72L64 93L36 93L22 72C16 62 18 48 26 40ZM31 63L46 57L31 50ZM69 50L54 57L69 63ZM44 87L56 87L62 73L38 73Z",
            minionName: L3("IJsreus", "Frost Giant", "Géant de Givre"),
            bossName: L3("Grote IJsreus", "Great Frost Giant", "Grand Géant de Givre"),
            intro: L3("Blijf bewegen of je bevriest.", "Keep moving or you freeze.", "Bouge ou tu gèles.")
        ),
        Arena(
            name: L3("Duivelsdiep", "Devil's Deep", "Abîme du Diable"),
            race: L3("Zeeduivels", "Sea Devils", "Diables des Mers"),
            rgb: RGB(0.14, 0.5, 0.68),
            icon: "M17 22C17 18.1 20.1 15 24 15C27.9 15 31 18.1 31 22C31 25.9 27.9 29 24 29C20.1 29 17 25.9 17 22ZM25.9 21.3L35.9 47.3L32.1 48.7L22.1 22.7ZM34 48C48 36 74 38 86 52C94 62 92 76 82 84L92 90L74 88C60 92 42 88 34 78C28 70 28 58 34 48ZM47 56C47 58.8 49.2 61 52 61C54.8 61 57 58.8 57 56C57 53.2 54.8 51 52 51C49.2 51 47 53.2 47 56ZM46 80L82 78L80 68L72 74L66 66L58 74L52 66L44 72Z",
            minionName: L3("Zeeduivel", "Sea Devil", "Diable des Mers"),
            bossName: L3("Grote Zeeduivel", "Great Sea Devil", "Grand Diable des Mers"),
            intro: L3("Het licht komt hier niet meer.", "The light no longer reaches here.", "La lumière n'arrive plus jusqu'ici.")
        ),
        Arena(
            name: L3("Bliksemtoren", "Lightning Tower", "Tour de Foudre"),
            race: L3("Bliksemgeesten", "Storm Spirits", "Esprits de Foudre"),
            rgb: RGB(0.95, 0.9, 0.35),
            icon: "M6 50C6 25.7 25.7 6 50 6C74.3 6 94 25.7 94 50C94 74.3 74.3 94 50 94C25.7 94 6 74.3 6 50ZM15 50C15 69.3 30.7 85 50 85C69.3 85 85 69.3 85 50C85 30.7 69.3 15 50 15C30.7 15 15 30.7 15 50ZM52 44L70 44L40 92L46 52L30 52L56 8Z",
            minionName: L3("Bliksemgeest", "Storm Spirit", "Esprit de Foudre"),
            bossName: L3("Grote Bliksemgeest", "Great Storm Spirit", "Grand Esprit de Foudre"),
            intro: L3("Je haren staan al overeind.", "Your hair is already standing up.", "Tes cheveux se dressent déjà.")
        ),
        Arena(
            name: L3("Slangentempel", "Serpent Temple", "Temple des Serpents"),
            race: L3("Slangenvolk", "Serpentfolk", "Peuple-Serpent"),
            rgb: RGB(0.28, 0.76, 0.56),
            icon: "M50 34L86 44L96 68L78 92L58 96L50 88L42 96L22 92L4 68L14 44ZM34 30C34 19 41.2 10 50 10C58.8 10 66 19 66 30C66 41 58.8 50 50 50C41.2 50 34 41 34 30ZM38 36L49 30L38 24ZM62 24L51 30L62 36ZM47.5 46L47.5 64L52.5 64L52.5 46ZM47 76L50 68L53 76L60 78L50 60L40 78Z",
            minionName: L3("Slangenman", "Serpentman", "Homme-Serpent"),
            bossName: L3("Grote Slangenman", "Great Serpentman", "Grand Homme-Serpent"),
            intro: L3("Elke steen is bedekt met schubben.", "Every stone is covered in scales.", "Chaque pierre est couverte d'écailles.")
        ),
        Arena(
            name: L3("Drakennest", "Dragon Nest", "Nid des Dragons"),
            race: L3("Draken", "Dragons", "Dragons"),
            rgb: RGB(1.0, 0.76, 0.2),
            icon: "M26 18L2 4L32 12ZM12 42C12 25 26 12 44 12L40 0L58 10C77 12 91 25 93 41C95 53 89 63 79 69L97 77L70 77C62 85 48 89 36 85C20 79 12 63 12 47ZM50 45L68 39L50 32ZM46 71L87 68L91 55L40 58ZM50 71L52 60L56 71ZM72 67L74 57L78 67Z",
            minionName: L3("Draak", "Dragon", "Dragon"),
            bossName: L3("Grote Draak", "Great Dragon", "Grand Dragon"),
            intro: L3("Hier eindigen de meeste helden.", "This is where most heroes end.", "C'est ici que finissent la plupart des héros.")
        ),
        Arena(
            name: L3("Titanengraf", "Titan Grave", "Tombeau des Titans"),
            race: L3("Titanen", "Titans", "Titans"),
            rgb: RGB(0.72, 0.66, 0.5),
            icon: "M18 30L28 10L40 26L50 6L60 26L72 10L82 30ZM20 34L80 34C84 34 86 38 84 42L74 90C73 93 70 95 68 95L32 95C30 95 27 93 26 90L16 42C14 38 16 34 20 34ZM29 61L46 55L29 48ZM71 48L54 55L71 61ZM44 85L56 85L60 70L40 70Z",
            minionName: L3("Titaan", "Titan", "Titan"),
            bossName: L3("Grote Titaan", "Great Titan", "Grand Titan"),
            intro: L3("Zelfs hun botten zijn bergen.", "Even their bones are mountains.", "Même leurs os sont des montagnes.")
        ),
        Arena(
            name: L3("Rijk der Verdoemden", "Realm of the Damned", "Royaume des Damnés"),
            race: L3("Verdoemden", "The Damned", "Les Damnés"),
            rgb: RGB(0.46, 0.1, 0.16),
            icon: "M50 6C71 6 86 23 86 46C86 57 84 67 80 76L90 95L10 95L20 76C16 67 14 57 14 46C14 23 29 6 50 6ZM29 48C29 62.9 38.4 75 50 75C61.6 75 71 62.9 71 48C71 33.1 61.6 21 50 21C38.4 21 29 33.1 29 48ZM37 45C37 42.2 39.2 40 42 40C44.8 40 47 42.2 47 45C47 47.8 44.8 50 42 50C39.2 50 37 47.8 37 45ZM53 45C53 42.2 55.2 40 58 40C60.8 40 63 42.2 63 45C63 47.8 60.8 50 58 50C55.2 50 53 47.8 53 45Z",
            minionName: L3("Verdoemde", "Damned One", "Damné"),
            bossName: L3("Grote Verdoemde", "Great Damned One", "Grand Damné"),
            intro: L3("Er valt geen schaduw meer.", "Nothing casts a shadow anymore.", "Plus rien ne projette d'ombre.")
        ),
        Arena(
            name: L3("Val der Engelen", "Fall of Angels", "Chute des Anges"),
            race: L3("Gevallen Engelen", "Fallen Angels", "Anges Déchus"),
            rgb: RGB(0.96, 0.92, 0.78),
            icon: "M31 12C31 8.4 39.5 5.5 50 5.5C60.5 5.5 69 8.4 69 12C69 15.6 60.5 18.5 50 18.5C39.5 18.5 31 15.6 31 12ZM38 12C38 13.4 43.4 14.5 50 14.5C56.6 14.5 62 13.4 62 12C62 10.6 56.6 9.5 50 9.5C43.4 9.5 38 10.6 38 12ZM44 30L54 30L53 96L47 96ZM45 32C33 30 19 38 11 50C5 60 3 74 5 88L45 62ZM55 32L74 38L63 46L82 50L67 58L86 66L64 68L79 80L55 70Z",
            minionName: L3("Gevallen Engel", "Fallen Angel", "Ange Déchu"),
            bossName: L3("Grote Gevallen Engel", "Great Fallen Angel", "Grand Ange Déchu"),
            intro: L3("Ze zingen terwijl ze je aanvallen.", "They sing while they attack you.", "Ils chantent en t'attaquant.")
        ),
        Arena(
            name: L3("Sterrensmidse", "Star Forge", "Forge des Étoiles"),
            race: L3("Sterrensmeden", "Star Smiths", "Forgerons d'Étoiles"),
            rgb: RGB(1.0, 0.6, 0.32),
            icon: "M50 4L59 30L86 30L64 46L72 72L50 56L28 72L36 46L14 30L41 30ZM32.5 61.1L88.5 89.1L83.5 98.9L27.5 70.9ZM16 56L44 56L44 76L16 76Z",
            minionName: L3("Sterrensmid", "Star Smith", "Forgeron d'Étoiles"),
            bossName: L3("Grote Sterrensmid", "Great Star Smith", "Grand Forgeron d'Étoiles"),
            intro: L3("Hier worden werelden gegoten.", "Worlds are cast here.", "C'est ici qu'on coule les mondes.")
        ),
        Arena(
            name: L3("Naamloze Diep", "Nameless Deep", "Gouffre sans Nom"),
            race: L3("Het Naamloze", "The Nameless", "L'Innommable"),
            rgb: RGB(0.88, 0.24, 0.92),
            icon: "M12 46C12 25 29 8 50 8C71 8 88 25 88 46C88 67 71 84 50 84C29 84 12 67 12 46ZM28 46C28 53.7 37.8 60 50 60C62.2 60 72 53.7 72 46C72 38.3 62.2 32 50 32C37.8 32 28 38.3 28 46ZM43 46C43 42.1 46.1 39 50 39C53.9 39 57 42.1 57 46C57 49.9 53.9 53 50 53C46.1 53 43 49.9 43 46ZM29 77.8L17 97.8L11 94.2L23 74.2ZM40.8 83.1L34.8 99.1L29.2 96.9L35.2 80.9ZM53.5 84L53.5 98L46.5 98L46.5 84ZM64.8 80.9L70.8 96.9L65.2 99.1L59.2 83.1ZM77 74.2L89 94.2L83 97.8L71 77.8Z",
            minionName: L3("Naamloze", "Nameless One", "Innommable"),
            bossName: L3("Grote Naamloze", "Great Nameless One", "Grand Innommable"),
            intro: L3("Er is geen grond meer onder je.", "There is no ground beneath you anymore.", "Il n'y a plus de sol sous toi.")
        ),
    ]

    /// Arena's zijn oneindig: na de laatste begint de reeks opnieuw, maar zwaarder
    /// en met een cijfer erachter (De Orkvelden II, III, …).
    static func at(_ index: Int) -> Arena {
        let i = max(0, index - 1)
        let arena = all[i % all.count]
        let cycle = i / all.count
        guard cycle > 0 else { return arena }

        let suffix = " " + romanNumeral(cycle + 1)
        return Arena(
            name: L3(arena.name.nl + suffix, arena.name.en + suffix, arena.name.fr + suffix),
            race: arena.race,
            rgb: arena.rgb,
            icon: arena.icon,
            minionName: arena.minionName,
            bossName: L3(arena.bossName.nl + suffix,
                         arena.bossName.en + suffix,
                         arena.bossName.fr + suffix),
            intro: arena.intro
        )
    }

    private static func romanNumeral(_ n: Int) -> String {
        let table: [(Int, String)] = [(10, "X"), (9, "IX"), (5, "V"), (4, "IV"), (1, "I")]
        var remainder = n
        var result = ""
        for (value, symbol) in table {
            while remainder >= value {
                result += symbol
                remainder -= value
            }
        }
        return result
    }
}
