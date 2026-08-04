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
            name: L3("De Orkvelden", "The Orc Fields", "Les Champs d'Orques"),
            race: L3("Orks", "Orcs", "Orques"),
            rgb: RGB(0.38, 0.78, 0.24),
            icon: "M50 8C72 8 86 22 86 42L86 54C86 72 70 88 50 88C30 88 14 72 14 54L14 42C14 22 28 8 50 8ZM17 54L1 24L15 36ZM85 36L99 24L83 54ZM28 57L46 50L28 42ZM72 42L54 50L72 57ZM31 79L69 79L69 65L31 65ZM35 79L39 67L43 79ZM57 79L61 67L65 79Z",
            minionName: L3("Ork", "Orc", "Orque"),
            bossName: L3("Grote Ork", "Great Orc", "Grand Orque"),
            intro: L3("Modder, rook en het gebrul van orks.", "Mud, smoke, and the roar of orcs.", "Boue, fumée et le rugissement des orques.")
        ),
        Arena(
            name: L3("De Rottende Weiden", "The Rotting Meadows", "Les Prés Pourris"),
            race: L3("Zombies", "Zombies", "Zombies"),
            rgb: RGB(0.62, 0.72, 0.18),
            icon: "M50 8C68 8 82 20 85 36L69 31L76 47C80 67 68 91 50 91C30 91 13 70 13 46C13 24 30 8 50 8ZM27 46C27 51 31 55 36 55C41 55 45 51 45 46C45 41 41 37 36 37C31 37 27 41 27 46ZM59 49C59 51.2 60.8 53 63 53C65.2 53 67 51.2 67 49C67 46.8 65.2 45 63 45C60.8 45 59 46.8 59 49ZM33 81L66 81L70 72L62 65L54 72L46 65L38 72L29 65Z",
            minionName: L3("Zombie", "Zombie", "Zombie"),
            bossName: L3("Grote Zombie", "Great Zombie", "Grand Zombie"),
            intro: L3("Ze staan altijd weer op. Sla harder.", "They always get back up. Hit harder.", "Ils se relèvent toujours. Frappe plus fort.")
        ),
        Arena(
            name: L3("Het Wevernest", "The Weaver's Nest", "Le Nid du Tisseur"),
            race: L3("Spinnen", "Spiders", "Araignées"),
            rgb: RGB(0.56, 0.34, 0.78),
            icon: "M36.2 41.8L18.2 23.8L21.8 20.2L39.8 38.2ZM21.7 23.1L9.7 41.1L6.3 38.9L18.3 20.9ZM60.2 38.2L78.2 20.2L81.8 23.8L63.8 41.8ZM81.7 20.9L93.7 38.9L90.3 41.1L78.3 23.1ZM36.2 49.8L18.2 31.8L21.8 28.2L39.8 46.2ZM21.7 31.1L5.7 55.1L2.3 52.9L18.3 28.9ZM60.2 46.2L78.2 28.2L81.8 31.8L63.8 49.8ZM81.7 28.9L97.7 52.9L94.3 55.1L78.3 31.1ZM36.6 58.1L18.6 46.1L21.4 41.9L39.4 53.9ZM21.8 44.9L7.8 70.9L4.2 69.1L18.2 43.1ZM60.6 53.9L78.6 41.9L81.4 46.1L63.4 58.1ZM81.8 43.1L95.8 69.1L92.2 70.9L78.2 44.9ZM37.5 64.4L19.5 60.4L20.5 55.6L38.5 59.6ZM21.9 58.4L15.9 84.4L12.1 83.6L18.1 57.6ZM61.5 59.6L79.5 55.6L80.5 60.4L62.5 64.4ZM81.9 57.6L87.9 83.6L84.1 84.4L78.1 58.4ZM32 58C32 49.2 40.1 42 50 42C59.9 42 68 49.2 68 58C68 66.8 59.9 74 50 74C40.1 74 32 66.8 32 58ZM38 34C38 28.5 43.4 24 50 24C56.6 24 62 28.5 62 34C62 39.5 56.6 44 50 44C43.4 44 38 39.5 38 34ZM42 32C42 33.7 43.3 35 45 35C46.7 35 48 33.7 48 32C48 30.3 46.7 29 45 29C43.3 29 42 30.3 42 32ZM52 32C52 33.7 53.3 35 55 35C56.7 35 58 33.7 58 32C58 30.3 56.7 29 55 29C53.3 29 52 30.3 52 32Z",
            minionName: L3("Spin", "Spider", "Araignée"),
            bossName: L3("Grote Spin", "Great Spider", "Grande Araignée"),
            intro: L3("Alles hier plakt. Jij ook.", "Everything here sticks. You too.", "Ici tout colle. Toi aussi.")
        ),
        Arena(
            name: L3("De Knekelkrocht", "The Bone Crypt", "La Crypte des Os"),
            race: L3("Skeletten", "Skeletons", "Squelettes"),
            rgb: RGB(0.78, 0.84, 0.95),
            icon: "M50 9C72 9 87 26 87 46C87 58 81 66 75 70L75 84C75 88 71 91 67 91L33 91C29 91 25 88 25 84L25 70C19 66 13 58 13 46C13 26 28 9 50 9ZM25 44C25 49.5 29.5 54 35 54C40.5 54 45 49.5 45 44C45 38.5 40.5 34 35 34C29.5 34 25 38.5 25 44ZM55 44C55 49.5 59.5 54 65 54C70.5 54 75 49.5 75 44C75 38.5 70.5 34 65 34C59.5 34 55 38.5 55 44ZM43 67L57 67L50 55ZM38 88L43 88L43 74L38 74ZM47 88L53 88L53 74L47 74ZM57 88L62 88L62 74L57 74Z",
            minionName: L3("Skelet", "Skeleton", "Squelette"),
            bossName: L3("Groot Skelet", "Great Skeleton", "Grand Squelette"),
            intro: L3("Het rammelt in het donker.", "Something rattles in the dark.", "Ça cliquette dans le noir.")
        ),
        Arena(
            name: L3("De Bloedmoerassen", "The Blood Marshes", "Les Marais de Sang"),
            race: L3("Trollen", "Trolls", "Trolls"),
            rgb: RGB(0.44, 0.58, 0.32),
            icon: "M37 26L21 6L34 20ZM66 20L79 6L63 26ZM30 30C30 19 39 10 50 10C61 10 70 19 70 30C70 41 61 50 50 50C39 50 30 41 30 30ZM32 44C16 50 6 64 6 80L6 94L94 94L94 80C94 64 84 50 68 44C63 52 57 56 50 56C43 56 37 52 32 44ZM38.5 27C38.5 28.9 40.1 30.5 42 30.5C43.9 30.5 45.5 28.9 45.5 27C45.5 25.1 43.9 23.5 42 23.5C40.1 23.5 38.5 25.1 38.5 27ZM54.5 27C54.5 28.9 56.1 30.5 58 30.5C59.9 30.5 61.5 28.9 61.5 27C61.5 25.1 59.9 23.5 58 23.5C56.1 23.5 54.5 25.1 54.5 27ZM40 41L60 41L60 34L40 34ZM43 41L45 32L47 41ZM53 41L55 32L57 41Z",
            minionName: L3("Trol", "Troll", "Troll"),
            bossName: L3("Grote Trol", "Great Troll", "Grand Troll"),
            intro: L3("Iets zwaars komt door het water.", "Something heavy is coming through the water.", "Quelque chose de lourd traverse l'eau.")
        ),
        Arena(
            name: L3("Het Schimmenrijk", "The Wraith Realm", "Le Royaume des Ombres"),
            race: L3("Geesten", "Ghosts", "Fantômes"),
            rgb: RGB(0.36, 0.86, 0.92),
            icon: "M50 10C70 10 83 26 83 47L83 90L71 79L59 90L47 79L35 90L23 79L17 90L17 47C17 26 30 10 50 10ZM31.5 43C31.5 48 34.4 52 38 52C41.6 52 44.5 48 44.5 43C44.5 38 41.6 34 38 34C34.4 34 31.5 38 31.5 43ZM55.5 43C55.5 48 58.4 52 62 52C65.6 52 68.5 48 68.5 43C68.5 38 65.6 34 62 34C58.4 34 55.5 38 55.5 43Z",
            minionName: L3("Geest", "Ghost", "Fantôme"),
            bossName: L3("Grote Geest", "Great Ghost", "Grand Fantôme"),
            intro: L3("Ze hebben geen lichaam. Wel honger.", "They have no bodies. They do have hunger.", "Ils n'ont pas de corps. Mais ils ont faim.")
        ),
        Arena(
            name: L3("De Duistere Kathedraal", "The Dark Cathedral", "La Cathédrale Sombre"),
            race: L3("Vampiers", "Vampires", "Vampires"),
            rgb: RGB(0.78, 0.14, 0.34),
            icon: "M50 34L26 16L30 36L6 32L20 52L38 56L50 70L62 56L80 52L94 32L70 36L74 16ZM35 40C35 32.3 41.7 26 50 26C58.3 26 65 32.3 65 40C65 47.7 58.3 54 50 54C41.7 54 35 47.7 35 40ZM38 20L44 32L32 32ZM62 20L68 32L56 32ZM39.5 38C39.5 39.9 41.1 41.5 43 41.5C44.9 41.5 46.5 39.9 46.5 38C46.5 36.1 44.9 34.5 43 34.5C41.1 34.5 39.5 36.1 39.5 38ZM53.5 38C53.5 39.9 55.1 41.5 57 41.5C58.9 41.5 60.5 39.9 60.5 38C60.5 36.1 58.9 34.5 57 34.5C55.1 34.5 53.5 36.1 53.5 38ZM42 50L48 50L45 62ZM52 50L58 50L55 62Z",
            minionName: L3("Vampier", "Vampire", "Vampire"),
            bossName: L3("Grote Vampier", "Great Vampire", "Grand Vampire"),
            intro: L3("Alle ramen zijn zwart geverfd.", "Every window is painted black.", "Toutes les fenêtres sont peintes en noir.")
        ),
        Arena(
            name: L3("Het Weerwoud", "The Werewood", "La Forêt Garou"),
            race: L3("Weerwolven", "Werewolves", "Loups-garous"),
            rgb: RGB(0.58, 0.44, 0.28),
            icon: "M16 30L26 10L38 28C44 24 52 23 58 25L70 6L76 26C84 34 86 46 82 56L96 62L78 69C74 81 60 88 46 86C30 84 18 70 16 52ZM46 50L59 46L46 41ZM66 71L88 71L93 62L64 59ZM69 71L71 62L74 71ZM80 70L82 62L85 70Z",
            minionName: L3("Weerwolf", "Werewolf", "Loup-garou"),
            bossName: L3("Grote Weerwolf", "Great Werewolf", "Grand Loup-garou"),
            intro: L3("De maan staat vol boven de bomen.", "The moon hangs full above the trees.", "La lune est pleine au-dessus des arbres.")
        ),
        Arena(
            name: L3("De Steengroeve", "The Quarry", "La Carrière"),
            race: L3("Golems", "Golems", "Golems"),
            rgb: RGB(0.62, 0.62, 0.64),
            icon: "M28 8L72 8L80 24L72 38L28 38L20 24ZM34 25L46 27L46 16L34 18ZM54 16L54 27L66 25L66 18ZM14 44L86 44L80 94L20 94ZM22.1 52.1L11.1 84.1L-1.1 79.9L9.9 47.9ZM90.1 47.9L101.1 79.9L88.9 84.1L77.9 52.1ZM42 52L50 60L39 70L49 90L55 86L46 70L57 60L48 50Z",
            minionName: L3("Golem", "Golem", "Golem"),
            bossName: L3("Grote Golem", "Great Golem", "Grand Golem"),
            intro: L3("Steen wordt nooit moe. Jij wel.", "Stone never tires. You do.", "La pierre ne fatigue jamais. Toi si.")
        ),
        Arena(
            name: L3("De Aspoort", "The Ash Gate", "La Porte de Cendre"),
            race: L3("Demonen", "Demons", "Démons"),
            rgb: RGB(1.0, 0.42, 0.12),
            icon: "M30 30C26 18 18 8 6 2C6 18 12 32 24 42L34 34ZM70 30C74 18 82 8 94 2C94 18 88 32 76 42L66 34ZM50 22C67 22 80 35 80 52C80 60 78 66 74 72L50 96L26 72C22 66 20 60 20 52C20 35 33 22 50 22ZM30 59L46 53L30 46ZM70 46L54 53L70 59ZM50 82L61 68L39 68Z",
            minionName: L3("Demon", "Demon", "Démon"),
            bossName: L3("Grote Demon", "Great Demon", "Grand Démon"),
            intro: L3("De grond is te heet om te knielen.", "The ground is too hot to kneel on.", "Le sol est trop brûlant pour s'agenouiller.")
        ),
        Arena(
            name: L3("De Vriesburcht", "The Frost Keep", "La Forteresse de Givre"),
            race: L3("IJsreuzen", "Frost Giants", "Géants de Givre"),
            rgb: RGB(0.42, 0.78, 1.0),
            icon: "M26 40L16 12L34 28L42 6L50 24L58 6L66 28L84 12L74 40C82 48 84 62 78 72L64 93L36 93L22 72C16 62 18 48 26 40ZM31 63L46 57L31 50ZM69 50L54 57L69 63ZM44 87L56 87L62 73L38 73Z",
            minionName: L3("IJsreus", "Frost Giant", "Géant de Givre"),
            bossName: L3("Grote IJsreus", "Great Frost Giant", "Grand Géant de Givre"),
            intro: L3("Blijf bewegen of je bevriest.", "Keep moving or you freeze.", "Bouge ou tu gèles.")
        ),
        Arena(
            name: L3("De Verzwolgen Diepte", "The Swallowed Deep", "Les Abysses Englouties"),
            race: L3("Zeeduivels", "Sea Devils", "Diables des Mers"),
            rgb: RGB(0.14, 0.5, 0.68),
            icon: "M17 22C17 18.1 20.1 15 24 15C27.9 15 31 18.1 31 22C31 25.9 27.9 29 24 29C20.1 29 17 25.9 17 22ZM25.9 21.3L35.9 47.3L32.1 48.7L22.1 22.7ZM34 48C48 36 74 38 86 52C94 62 92 76 82 84L92 90L74 88C60 92 42 88 34 78C28 70 28 58 34 48ZM47 56C47 58.8 49.2 61 52 61C54.8 61 57 58.8 57 56C57 53.2 54.8 51 52 51C49.2 51 47 53.2 47 56ZM46 80L82 78L80 68L72 74L66 66L58 74L52 66L44 72Z",
            minionName: L3("Zeeduivel", "Sea Devil", "Diable des Mers"),
            bossName: L3("Grote Zeeduivel", "Great Sea Devil", "Grand Diable des Mers"),
            intro: L3("Het licht komt hier niet meer.", "The light no longer reaches here.", "La lumière n'arrive plus jusqu'ici.")
        ),
        Arena(
            name: L3("De Stormtoren", "The Storm Tower", "La Tour de l'Orage"),
            race: L3("Bliksemgeesten", "Storm Spirits", "Esprits de Foudre"),
            rgb: RGB(0.95, 0.9, 0.35),
            icon: "M6 50C6 25.7 25.7 6 50 6C74.3 6 94 25.7 94 50C94 74.3 74.3 94 50 94C25.7 94 6 74.3 6 50ZM15 50C15 69.3 30.7 85 50 85C69.3 85 85 69.3 85 50C85 30.7 69.3 15 50 15C30.7 15 15 30.7 15 50ZM52 44L70 44L40 92L46 52L30 52L56 8Z",
            minionName: L3("Bliksemgeest", "Storm Spirit", "Esprit de Foudre"),
            bossName: L3("Grote Bliksemgeest", "Great Storm Spirit", "Grand Esprit de Foudre"),
            intro: L3("Je haren staan al overeind.", "Your hair is already standing up.", "Tes cheveux se dressent déjà.")
        ),
        Arena(
            name: L3("De Verzonken Tempel", "The Sunken Temple", "Le Temple Englouti"),
            race: L3("Slangenvolk", "Serpentfolk", "Peuple-Serpent"),
            rgb: RGB(0.28, 0.76, 0.56),
            icon: "M50 34L86 44L96 68L78 92L58 96L50 88L42 96L22 92L4 68L14 44ZM34 30C34 19 41.2 10 50 10C58.8 10 66 19 66 30C66 41 58.8 50 50 50C41.2 50 34 41 34 30ZM38 36L49 30L38 24ZM62 24L51 30L62 36ZM47.5 46L47.5 64L52.5 64L52.5 46ZM47 76L50 68L53 76L60 78L50 60L40 78Z",
            minionName: L3("Slangenman", "Serpentman", "Homme-Serpent"),
            bossName: L3("Grote Slangenman", "Great Serpentman", "Grand Homme-Serpent"),
            intro: L3("Elke steen is bedekt met schubben.", "Every stone is covered in scales.", "Chaque pierre est couverte d'écailles.")
        ),
        Arena(
            name: L3("De Drakenkuil", "The Dragon Pit", "La Fosse aux Dragons"),
            race: L3("Draken", "Dragons", "Dragons"),
            rgb: RGB(1.0, 0.76, 0.2),
            icon: "M26 18L2 4L32 12ZM12 42C12 25 26 12 44 12L40 0L58 10C77 12 91 25 93 41C95 53 89 63 79 69L97 77L70 77C62 85 48 89 36 85C20 79 12 63 12 47ZM50 45L68 39L50 32ZM46 71L87 68L91 55L40 58ZM50 71L52 60L56 71ZM72 67L74 57L78 67Z",
            minionName: L3("Draak", "Dragon", "Dragon"),
            bossName: L3("Grote Draak", "Great Dragon", "Grand Dragon"),
            intro: L3("Hier eindigen de meeste helden.", "This is where most heroes end.", "C'est ici que finissent la plupart des héros.")
        ),
        Arena(
            name: L3("Het Titanenkerkhof", "The Titan Graveyard", "Le Cimetière des Titans"),
            race: L3("Titanen", "Titans", "Titans"),
            rgb: RGB(0.72, 0.66, 0.5),
            icon: "M18 30L28 10L40 26L50 6L60 26L72 10L82 30ZM20 34L80 34C84 34 86 38 84 42L74 90C73 93 70 95 68 95L32 95C30 95 27 93 26 90L16 42C14 38 16 34 20 34ZM29 61L46 55L29 48ZM71 48L54 55L71 61ZM44 85L56 85L60 70L40 70Z",
            minionName: L3("Titaan", "Titan", "Titan"),
            bossName: L3("Grote Titaan", "Great Titan", "Grand Titan"),
            intro: L3("Zelfs hun botten zijn bergen.", "Even their bones are mountains.", "Même leurs os sont des montagnes.")
        ),
        Arena(
            name: L3("De Zwarte Zon", "The Black Sun", "Le Soleil Noir"),
            race: L3("Verdoemden", "The Damned", "Les Damnés"),
            rgb: RGB(0.46, 0.1, 0.16),
            icon: "M50 6C71 6 86 23 86 46C86 57 84 67 80 76L90 95L10 95L20 76C16 67 14 57 14 46C14 23 29 6 50 6ZM29 48C29 62.9 38.4 75 50 75C61.6 75 71 62.9 71 48C71 33.1 61.6 21 50 21C38.4 21 29 33.1 29 48ZM37 45C37 42.2 39.2 40 42 40C44.8 40 47 42.2 47 45C47 47.8 44.8 50 42 50C39.2 50 37 47.8 37 45ZM53 45C53 42.2 55.2 40 58 40C60.8 40 63 42.2 63 45C63 47.8 60.8 50 58 50C55.2 50 53 47.8 53 45Z",
            minionName: L3("Verdoemde", "Damned One", "Damné"),
            bossName: L3("Grote Verdoemde", "Great Damned One", "Grand Damné"),
            intro: L3("Er valt geen schaduw meer.", "Nothing casts a shadow anymore.", "Plus rien ne projette d'ombre.")
        ),
        Arena(
            name: L3("Het Sterrenhof", "The Star Court", "La Cour des Étoiles"),
            race: L3("Gevallen Engelen", "Fallen Angels", "Anges Déchus"),
            rgb: RGB(0.96, 0.92, 0.78),
            icon: "M31 12C31 8.4 39.5 5.5 50 5.5C60.5 5.5 69 8.4 69 12C69 15.6 60.5 18.5 50 18.5C39.5 18.5 31 15.6 31 12ZM38 12C38 13.4 43.4 14.5 50 14.5C56.6 14.5 62 13.4 62 12C62 10.6 56.6 9.5 50 9.5C43.4 9.5 38 10.6 38 12ZM44 30L54 30L53 96L47 96ZM45 32C33 30 19 38 11 50C5 60 3 74 5 88L45 62ZM55 32L74 38L63 46L82 50L67 58L86 66L64 68L79 80L55 70Z",
            minionName: L3("Gevallen Engel", "Fallen Angel", "Ange Déchu"),
            bossName: L3("Grote Gevallen Engel", "Great Fallen Angel", "Grand Ange Déchu"),
            intro: L3("Ze zingen terwijl ze je aanvallen.", "They sing while they attack you.", "Ils chantent en t'attaquant.")
        ),
        Arena(
            name: L3("De Kosmische Smidse", "The Cosmic Forge", "La Forge Cosmique"),
            race: L3("Sterrensmeden", "Star Smiths", "Forgerons d'Étoiles"),
            rgb: RGB(1.0, 0.6, 0.32),
            icon: "M50 4L59 30L86 30L64 46L72 72L50 56L28 72L36 46L14 30L41 30ZM32.5 61.1L88.5 89.1L83.5 98.9L27.5 70.9ZM16 56L44 56L44 76L16 76Z",
            minionName: L3("Sterrensmid", "Star Smith", "Forgeron d'Étoiles"),
            bossName: L3("Grote Sterrensmid", "Great Star Smith", "Grand Forgeron d'Étoiles"),
            intro: L3("Hier worden werelden gegoten.", "Worlds are cast here.", "C'est ici qu'on coule les mondes.")
        ),
        Arena(
            name: L3("De Leegte", "The Void", "Le Vide"),
            race: L3("Het Naamloze", "The Nameless", "L'Innommable"),
            rgb: RGB(0.88, 0.24, 0.92),
            icon: "M12 46C12 25 29 8 50 8C71 8 88 25 88 46C88 67 71 84 50 84C29 84 12 67 12 46ZM28 46C28 53.7 37.8 60 50 60C62.2 60 72 53.7 72 46C72 38.3 62.2 32 50 32C37.8 32 28 38.3 28 46ZM43 46C43 42.1 46.1 39 50 39C53.9 39 57 42.1 57 46C57 49.9 53.9 53 50 53C46.1 53 43 49.9 43 46ZM29 77.8L17 97.8L11 94.2L23 74.2ZM40.8 83.1L34.8 99.1L29.2 96.9L35.2 80.9ZM53.5 84L53.5 98L46.5 98L46.5 84ZM64.8 80.9L70.8 96.9L65.2 99.1L59.2 83.1ZM77 74.2L89 94.2L83 97.8L71 77.8Z",
            minionName: L3("Naamloze", "Nameless One", "Innommable"),
            bossName: L3("Grote Naamloze", "Great Nameless One", "Grand Innommable"),
            intro: L3("Er is geen grond meer onder je.", "There is no ground beneath you anymore.", "Il n'y a plus de sol sous toi.")
        )
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
