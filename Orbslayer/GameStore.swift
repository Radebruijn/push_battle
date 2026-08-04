import Foundation
import SwiftUI

// MARK: - Modellen

struct Enemy {
    var maxHP: Int
    var hp: Int
    var isBoss: Bool
    var arenaIndex: Int

    var healthFraction: Double { Double(hp) / Double(max(1, maxHP)) }
}

struct Profile: Codable {
    var totalReps = 0
    var totalKills = 0
    var bossKills = 0
    var totalXP = 0
    /// Welke arena je nu bevecht (1-gebaseerd). Stijgt na elke verslagen boss.
    var arenaIndex = 1
    /// Aantal minions verslagen in de huidige arena (0-9; de 10e vijand is de boss).
    var killsThisArena = 0
    /// Schade aan de huidige minion blijft bewaard. Bosses bewaren nooit schade.
    var savedMinionHP: Int? = nil
    var streak = 0
    var lastKillDay: Date? = nil
    /// Gezichtshoogte-kalibratie (genormaliseerd 0-1 in camerabeeld).
    var calTop: Double? = nil
    var calBottom: Double? = nil
    /// Hoeveel van je bereik je moet afleggen voordat een rep telt (0,3–0,85).
    var repDepth: Double = 0.6
    /// nil = nog nooit gekozen, dan volgen we de taal van het toestel.
    var language: Lang? = nil
    /// Duelmodus: gewonnen duels, beste score per niveau, laatst gekozen niveau.
    var duelsWon = 0
    var duelBest: [String: Int] = [:]
    var duelLevel = 50
}

enum GameMode: String, CaseIterable {
    case arena, duel
}

struct RepOutcome {
    var damage = 1
    var wasCrit = false
    var killedEnemy = false
    var xpGained = 0
    var defeatedBoss = false
    var playerLeveledUp = false
    var newEnemyIsBoss = false
    /// Gevuld wanneer de kill een nieuwe arena opent.
    var enteredArena: Arena? = nil
}

// MARK: - Store

@MainActor
final class GameStore: ObservableObject {
    @Published private(set) var profile: Profile
    @Published private(set) var enemy: Enemy
    @Published private(set) var comboCount = 0
    @Published var language: Lang = .nl

    private var lastRepAt: Date? = nil

    static let comboWindow: TimeInterval = 3.0
    static let critCombo = 10
    private static let saveKey = "orbslayer.profile.v2"

    init() {
        let loaded = Self.loadProfile()
        self.profile = loaded
        self.enemy = Enemy(maxHP: 1, hp: 1, isBoss: false, arenaIndex: 1)
        self.language = loaded.language ?? Lang.systemDefault
        spawnEnemy()
    }

    // MARK: Balans-formules

    static func minionMaxHP(arena: Int) -> Int { 5 + Int(Double(arena - 1) * 1.5) }
    static func bossMaxHP(arena: Int) -> Int { minionMaxHP(arena: arena) * 5 }
    static func minionXP(arena: Int) -> Int { 15 + (arena - 1) * 5 }
    static func bossXP(arena: Int) -> Int { minionXP(arena: arena) * 5 }
    static func xpNeeded(forLevel level: Int) -> Int { 100 + (level - 1) * 75 }

    // MARK: Duel-balans
    //
    // Het niveau loopt van 1 tot 100 procent. Onderaan is je tegenstander mild, bovenaan
    // doet hij honderd push-ups in één minuut — dat is opzettelijk bijna
    // onhaalbaar. De beloning stijgt sneller dan het niveau, zodat een zwaar
    // duel echt de moeite waard is.

    static let duelSeconds: Int = 60

    /// Het doel dat je tegenstander gemiddeld haalt op dit niveau.
    static func opponentBase(level: Int) -> Int {
        Int((4 + pow(Double(level) / 100, 1.35) * 96).rounded())
    }

    /// Hoeveel het per poging mag schelen, zodat hetzelfde percentage niet elke
    /// keer exact hetzelfde duel oplevert.
    static func opponentSpread(level: Int) -> Int {
        min(4, max(1, Int((Double(opponentBase(level: level)) * 0.06).rounded())))
    }

    /// Trekt het doel voor één duel: de basis plus of min de spreiding.
    static func drawOpponentTarget(level: Int) -> Int {
        let spread = opponentSpread(level: level)
        return max(1, opponentBase(level: level) + Int.random(in: -spread...spread))
    }

    /// Acht moeilijkheidsbanden, elk met een eigen woord en kleur.
    static func difficultyBand(level: Int) -> Int {
        switch level {
        case ..<16: return 1
        case ..<31: return 2
        case ..<46: return 3
        case ..<61: return 4
        case ..<76: return 5
        case ..<89: return 6
        case ..<98: return 7
        default:    return 8
        }
    }

    static func difficultyKey(level: Int) -> Tk {
        [Tk.band_1, .band_2, .band_3, .band_4,
         .band_5, .band_6, .band_7, .band_8][difficultyBand(level: level) - 1]
    }

    static func difficultyColor(level: Int) -> Color {
        [Color(red: 0.29, green: 0.87, blue: 0.50),
         Color(red: 0.64, green: 0.90, blue: 0.21),
         Color(red: 0.98, green: 0.80, blue: 0.08),
         Theme.gold,
         Color(red: 1.00, green: 0.58, blue: 0.15),
         Theme.flame,
         Theme.bloodRed,
         Color(red: 0.69, green: 0.05, blue: 0.11)][difficultyBand(level: level) - 1]
    }

    static func duelWinXP(level: Int) -> Int {
        Int((20 + pow(Double(level) / 100, 1.5) * 480).rounded())
    }

    static func duelLoseXP(level: Int) -> Int {
        max(1, Int((Double(duelWinXP(level: level)) * 0.06).rounded()))
    }

    // MARK: Afgeleide waarden

    var arena: Arena { Arena.at(profile.arenaIndex) }

    // MARK: Taal

    /// Korte naam voor een interfacetekst in de gekozen taal.
    func t(_ key: Tk, _ args: String...) -> String {
        Strings.text(key, language, args)
    }

    func setLanguage(_ lang: Lang) {
        language = lang
        profile.language = lang
        save()
    }

    /// Vijanden heten naar wat ze zijn, in de gekozen taal.
    var enemyName: String {
        (enemy.isBoss ? arena.bossName : arena.minionName).text(language)
    }

    var playerLevel: Int {
        var xp = profile.totalXP
        var level = 1
        while xp >= Self.xpNeeded(forLevel: level) {
            xp -= Self.xpNeeded(forLevel: level)
            level += 1
        }
        return level
    }

    var levelProgress: (current: Int, needed: Int) {
        var xp = profile.totalXP
        var level = 1
        while xp >= Self.xpNeeded(forLevel: level) {
            xp -= Self.xpNeeded(forLevel: level)
            level += 1
        }
        return (xp, Self.xpNeeded(forLevel: level))
    }

    var playerTitle: String {
        let key: Tk
        switch playerLevel {
        case ..<3: key = .rank_1
        case ..<5: key = .rank_2
        case ..<8: key = .rank_3
        case ..<12: key = .rank_4
        case ..<16: key = .rank_5
        case ..<20: key = .rank_6
        case ..<30: key = .rank_7
        default: key = .rank_8
        }
        return Strings.text(key, language)
    }

    /// Streak telt alleen als de laatste kill vandaag of gisteren was.
    var effectiveStreak: Int {
        guard let last = profile.lastKillDay else { return 0 }
        let cal = Calendar.current
        if cal.isDateInToday(last) || cal.isDateInYesterday(last) { return profile.streak }
        return 0
    }

    var streakMultiplier: Double {
        let s = effectiveStreak
        if s >= 30 { return 1.5 }
        if s >= 14 { return 1.35 }
        if s >= 7 { return 1.25 }
        if s >= 3 { return 1.1 }
        return 1.0
    }

    var critActive: Bool { comboCount >= Self.critCombo }

    // MARK: Acties

    @discardableResult
    func performRep() -> RepOutcome {
        let now = Date()
        if let last = lastRepAt, now.timeIntervalSince(last) <= Self.comboWindow {
            comboCount += 1
        } else {
            comboCount = 1
        }
        lastRepAt = now

        var outcome = RepOutcome()
        outcome.wasCrit = critActive
        outcome.damage = outcome.wasCrit ? 2 : 1

        profile.totalReps += 1
        enemy.hp = max(0, enemy.hp - outcome.damage)

        if enemy.hp == 0 {
            outcome.killedEnemy = true
            outcome.defeatedBoss = enemy.isBoss

            let levelBefore = playerLevel
            registerKillForStreak()

            let baseXP = enemy.isBoss
                ? Self.bossXP(arena: profile.arenaIndex)
                : Self.minionXP(arena: profile.arenaIndex)
            outcome.xpGained = Int(Double(baseXP) * streakMultiplier)
            profile.totalXP += outcome.xpGained
            profile.totalKills += 1

            if enemy.isBoss {
                profile.bossKills += 1
                profile.arenaIndex += 1
                profile.killsThisArena = 0
                outcome.enteredArena = Arena.at(profile.arenaIndex)
            } else {
                profile.killsThisArena += 1
            }
            profile.savedMinionHP = nil

            spawnEnemy()
            outcome.newEnemyIsBoss = enemy.isBoss
            outcome.playerLeveledUp = playerLevel > levelBefore
        }

        save()
        return outcome
    }

    /// Eén push-up in een duel: telt mee voor je totaal, niet voor schade.
    func registerDuelRep() {
        profile.totalReps += 1
    }

    struct DuelResult {
        var won = false
        var xp = 0
        var target = 0
    }

    @discardableResult
    func finishDuel(level: Int, reps: Int, target: Int) -> DuelResult {
        let won = reps >= target
        let xp = won ? Self.duelWinXP(level: level) : Self.duelLoseXP(level: level)

        profile.totalXP += xp
        if won {
            profile.duelsWon += 1
            registerTrainingDay()
        }
        let key = "\(level)"
        if reps > (profile.duelBest[key] ?? 0) { profile.duelBest[key] = reps }
        profile.duelLevel = level
        save()
        return DuelResult(won: won, xp: xp, target: target)
    }

    func rememberDuelLevel(_ level: Int) {
        profile.duelLevel = level
        save()
    }

    func setCalibration(top: Double, bottom: Double) {
        profile.calTop = top
        profile.calBottom = bottom
        save()
    }

    func setRepDepth(_ depth: Double) {
        profile.repDepth = min(0.85, max(0.3, depth))
        save()
    }

    func resetProgress() {
        let cal = (profile.calTop, profile.calBottom)
        let depth = profile.repDepth
        profile = Profile()
        profile.calTop = cal.0
        profile.calBottom = cal.1
        profile.language = language
        profile.repDepth = depth
        comboCount = 0
        lastRepAt = nil
        spawnEnemy()
        save()
    }

    // MARK: Intern

    private func registerKillForStreak() { registerTrainingDay() }

    /// Markeert vandaag als trainingsdag en verlengt daarmee de streak.
    private func registerTrainingDay() {
        let cal = Calendar.current
        if let last = profile.lastKillDay {
            if cal.isDateInToday(last) { return }
            if cal.isDateInYesterday(last) {
                profile.streak += 1
            } else {
                profile.streak = 1
            }
        } else {
            profile.streak = 1
        }
        profile.lastKillDay = Date()
    }

    private func spawnEnemy() {
        let index = profile.arenaIndex
        if profile.killsThisArena >= 9 {
            let hp = Self.bossMaxHP(arena: index)
            enemy = Enemy(maxHP: hp, hp: hp, isBoss: true, arenaIndex: index)
        } else {
            let maxHP = Self.minionMaxHP(arena: index)
            let hp = min(profile.savedMinionHP ?? maxHP, maxHP)
            enemy = Enemy(maxHP: maxHP, hp: max(1, hp), isBoss: false, arenaIndex: index)
        }
    }

    private func save() {
        // Boss-voortgang wordt bewust nooit bewaard: app sluiten = boss weer op vol.
        profile.savedMinionHP = (!enemy.isBoss && enemy.hp < enemy.maxHP) ? enemy.hp : nil
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: Self.saveKey)
        }
    }

    private static func loadProfile() -> Profile {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let profile = try? JSONDecoder().decode(Profile.self, from: data) else {
            return Profile()
        }
        return profile
    }
}
