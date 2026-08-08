import SwiftUI
import AVFoundation

struct FightView: View {
    @EnvironmentObject var store: GameStore
    @Environment(\.dismiss) private var dismiss
    @StateObject private var tracker = HeadTracker()

    @State private var damageNumbers: [DamageNumber] = []
    @State private var hitPulse = 0
    @State private var shake: CGFloat = 0
    @State private var flashKill = false
    @State private var banner: String?
    @State private var arenaIntro: Arena?
    @State private var sessionReps = 0
    @State private var sessionKills = 0
    @State private var showCalibration = false
    @State private var showConsent = false

    /// De simulator heeft geen camera, dus daar tik je op het scherm om een rep te doen.
    private var cameraAvailable: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return true
        #endif
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            bossAura

            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    topBar
                    Spacer(minLength: 0)
                    enemyStage
                    Spacer(minLength: 0)
                    bottomBar
                }
                .frame(maxWidth: .infinity)

                HeightBar(
                    height: tracker.headHeight,
                    upThreshold: tracker.upThreshold,
                    downThreshold: tracker.downThreshold,
                    isDown: tracker.phase == .down,
                    seesHead: tracker.seesHead || !cameraAvailable,
                    upLabel: store.t(.bar_up),
                    downLabel: store.t(.bar_down)
                )
                .padding(.vertical, 60)
                .padding(.trailing, 8)
            }

            if flashKill {
                Color.white.opacity(0.25).ignoresSafeArea().allowsHitTesting(false)
            }

            if let banner {
                Text(banner)
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(Theme.gold)
                    .multilineTextAlignment(.center)
                    .shadow(color: Theme.gold.opacity(0.7), radius: 20)
                    .transition(.scale.combined(with: .opacity))
                    .allowsHitTesting(false)
            }

            if let arenaIntro {
                arenaIntroOverlay(arenaIntro)
            }
        }
        .modifier(ShakeEffect(animatableData: shake))
        .contentShape(Rectangle())
        .onTapGesture { if !cameraAvailable { doRep() } }
        .statusBarHidden()
        .overlay(alignment: .topLeading) {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Theme.dimText)
                    .padding(12)
            }
            .padding(.leading, 8)
        }
        .fullScreenCover(isPresented: $showConsent) {
            CameraConsentView { toegestaan in
                showConsent = false
                guard toegestaan else { return }
                tracker.start()
                if store.profile.calTop == nil { showCalibration = true }
            }
            .environmentObject(store)
        }
        .sheet(isPresented: $showCalibration) {
            CalibrationView(tracker: tracker) { top, bottom in
                store.setCalibration(top: top, bottom: bottom)
            }
            .environmentObject(store)
        }
        .onAppear { startSession() }
        .onDisappear {
            tracker.stop()
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }

    // MARK: Onderdelen

    /// Achtergrondgloed in de kleur van de arena, feller tijdens een boss.
    private var bossAura: some View {
        RadialGradient(
            colors: [
                (store.enemy.isBoss ? Theme.bloodRed : store.arena.color)
                    .opacity(store.enemy.isBoss ? 0.22 : 0.10),
                .clear
            ],
            center: .center, startRadius: 60, endRadius: 460
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.8), value: store.enemy.isBoss)
    }

    private var topBar: some View {
        VStack(spacing: 10) {
            HStack {
                Label("\(store.effectiveStreak)", systemImage: "flame.fill")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.flame)
                Spacer()
                VStack(spacing: 1) {
                    Text(store.arena.name.text(store.language).uppercased())
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .tracking(2)
                        .foregroundStyle(store.arena.color)
                    Text(store.t(.arena_n, "\(store.profile.arenaIndex)"))
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .tracking(1.5)
                        .foregroundStyle(Theme.dimText)
                }
                Spacer()
                Text(store.t(.reps_n, "\(sessionReps)"))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.dimText)
            }

            xpStrip

            HStack(spacing: 5) {
                ForEach(0..<10, id: \.self) { i in
                    Capsule()
                        .fill(pipColor(i))
                        .frame(height: 4)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    /// Je level en XP-voortgang, zichtbaar terwijl je push-ups doet.
    private var xpStrip: some View {
        let progress = store.levelProgress
        let fraction = Double(progress.current) / Double(max(1, progress.needed))
        return HStack(spacing: 8) {
            Text("\(store.playerLevel)")
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(.black)
                .frame(width: 20, height: 20)
                .background(Circle().fill(Theme.gold))

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.1))
                    Capsule()
                        .fill(LinearGradient(colors: [store.arena.color, Theme.gold],
                                             startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * min(fraction, 1))
                        .animation(.spring(response: 0.4, dampingFraction: 0.8),
                                   value: store.profile.totalXP)
                }
            }
            .frame(height: 6)

            Text(store.t(.xp_of, "\(progress.current)", "\(progress.needed)"))
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.dimText)
        }
    }

    private func pipColor(_ i: Int) -> Color {
        if i == 9 { return store.enemy.isBoss ? Theme.bloodRed : Theme.bloodRed.opacity(0.35) }
        return i < store.profile.killsThisArena ? store.arena.color : Color.white.opacity(0.12)
    }

    private var enemyStage: some View {
        VStack(spacing: 18) {
            VStack(spacing: 4) {
                if store.enemy.isBoss {
                    Text(store.t(.boss))
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .tracking(4)
                        .foregroundStyle(Theme.bloodRed)
                }
                Text(store.enemyName)
                    .font(.system(size: store.enemy.isBoss ? 26 : 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                if !store.enemy.isBoss {
                    Text(store.arena.race.text(store.language))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.dimText)
                }
            }

            ZStack {
                EnemyView(
                    arena: store.arena,
                    healthFraction: store.enemy.healthFraction,
                    isBoss: store.enemy.isBoss,
                    hitPulse: hitPulse
                )
                ForEach(damageNumbers) { DamageNumberView(number: $0) }
            }
            .frame(height: 300)

            healthBar
        }
    }

    private var healthBar: some View {
        VStack(spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.1))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Theme.bloodRed,
                                    Theme.orbColor(healthFraction: store.enemy.healthFraction,
                                                   arena: store.arena.rgb)
                                ],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * store.enemy.healthFraction)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: store.enemy.hp)
                }
            }
            .frame(height: 12)

            Text(store.t(.hp_of, "\(store.enemy.hp)", "\(store.enemy.maxHP)"))
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.dimText)
        }
        .padding(.horizontal, 28)
    }

    private var bottomBar: some View {
        VStack(spacing: 12) {
            if store.comboCount > 1 {
                Text(store.critActive ? store.t(.crit_n, "\(store.comboCount)") : store.t(.combo_n, "\(store.comboCount)"))
                    .font(.system(size: store.critActive ? 24 : 18, weight: .black, design: .rounded))
                    .foregroundStyle(store.critActive ? Theme.gold : .white.opacity(0.8))
                    .shadow(color: Theme.gold.opacity(store.critActive ? 0.8 : 0), radius: 14)
            }

            if !cameraAvailable {
                Text(store.t(.hint_sim))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.dimText)
            } else if let error = tracker.errorMessage {
                Text(store.t(error))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.bloodRed)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            } else if !tracker.seesHead {
                Text(store.t(.hint_searching))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.dimText)
            }

            Button(store.t(.cal_again)) { showCalibration = true }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.dimText)
        }
        .padding(.bottom, 24)
        .animation(.easeOut(duration: 0.2), value: store.comboCount)
    }

    private func arenaIntroOverlay(_ arena: Arena) -> some View {
        ZStack {
            Color.black.opacity(0.82).ignoresSafeArea()
            RadialGradient(colors: [arena.color.opacity(0.3), .clear],
                           center: .center, startRadius: 20, endRadius: 400)
                .ignoresSafeArea()

            VStack(spacing: 14) {
                Text(store.t(.arena_n, "\(store.profile.arenaIndex)"))
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .tracking(5)
                    .foregroundStyle(Theme.dimText)

                Text(arena.name.text(store.language))
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(arena.color)
                    .multilineTextAlignment(.center)
                    .shadow(color: arena.color.opacity(0.8), radius: 24)

                Rectangle()
                    .fill(arena.color.opacity(0.6))
                    .frame(width: 90, height: 1)

                Text(arena.race.text(store.language).uppercased())
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(.white)

                Text(arena.intro.text(store.language))
                    .font(.system(size: 14, design: .rounded))
                    .italic()
                    .foregroundStyle(Theme.dimText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 4)
            }
        }
        .transition(.opacity)
        .allowsHitTesting(false)
    }

    // MARK: Logica

    private func startSession() {
        UIApplication.shared.isIdleTimerDisabled = true
        tracker.onRep = { doRep() }
        tracker.depth = store.profile.repDepth
        if let top = store.profile.calTop, let bottom = store.profile.calBottom {
            tracker.applyCalibration(top: top, bottom: bottom)
        }
        if cameraAvailable {
            if CameraConsentView.alreadyAnswered {
                tracker.start()
                if store.profile.calTop == nil { showCalibration = true }
            } else {
                showConsent = true
            }
        }
    }

    private func doRep() {
        let wasBoss = store.enemy.isBoss
        let outcome = store.performRep()

        sessionReps += 1
        hitPulse += 1

        let number = DamageNumber(
            value: outcome.damage,
            isCrit: outcome.wasCrit,
            xOffset: CGFloat.random(in: -60...60)
        )
        damageNumbers.append(number)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            damageNumbers.removeAll { $0.id == number.id }
        }

        withAnimation(.linear(duration: outcome.wasCrit ? 0.35 : 0.2)) {
            shake += outcome.wasCrit ? 1.4 : 0.7
        }
        UIImpactFeedbackGenerator(style: outcome.wasCrit ? .heavy : .light).impactOccurred()

        if outcome.killedEnemy {
            sessionKills += 1
            flashKill = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { flashKill = false }
            UINotificationFeedbackGenerator().notificationOccurred(.success)

            var text = store.t(.xp_gain, "\(outcome.xpGained)")
            if wasBoss { text = store.t(.boss_defeated) + "\n" + text }
            if outcome.playerLeveledUp { text += "\n" + store.t(.level_up, "\(store.playerLevel)") }
            if outcome.newEnemyIsBoss { text += "\n" + store.t(.boss_incoming) }
            showBanner(text)

            if let entered = outcome.enteredArena {
                // Even wachten zodat de XP-melding niet over de arena-intro heen valt.
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                    withAnimation(.easeOut(duration: 0.5)) { arenaIntro = entered }
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        withAnimation(.easeIn(duration: 0.5)) { arenaIntro = nil }
                    }
                }
            }
        }
    }

    private func showBanner(_ text: String) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) { banner = text }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation(.easeOut(duration: 0.3)) { banner = nil }
        }
    }
}
