import SwiftUI

/// Duelmodus: eerst een niveau kiezen, dan zestig seconden racen tegen een
/// tegenstander die zijn doel gelijkmatig over de minuut verdeelt. Winnen
/// levert XP op naar rato van het niveau, verliezen een schamele troostprijs.
///
/// Vooraf hoor je niet hoeveel hij gaat doen — alleen hoe zwaar het niveau is,
/// in woord en kleur. Tijdens de race zie je zijn teller wel meelopen, zodat je
/// weet of je voor of achter ligt.
struct DuelView: View {
    @EnvironmentObject var store: GameStore
    @Environment(\.dismiss) private var dismiss
    @StateObject private var tracker = HeadTracker()

    private enum Phase { case setup, countdown, running, finished }

    @State private var phase: Phase = .setup
    @State private var level: Double = 50
    @State private var myReps = 0
    @State private var opponentReps = 0
    @State private var secondsLeft = Double(GameStore.duelSeconds)
    @State private var countdown = 3
    @State private var result: GameStore.DuelResult?
    @State private var shake: CGFloat = 0
    @State private var showCalibration = false
    @State private var showConsent = false

    private let tick = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    private var levelInt: Int { Int(level.rounded()) }
    /// Het doel van deze poging; wordt bij de start getrokken.
    @State private var target = 0

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

            switch phase {
            case .setup:     setupScreen
            case .countdown: raceScreen.overlay(countdownOverlay)
            case .running:   raceScreen
            case .finished:  raceScreen.overlay(resultOverlay)
            }
        }
        .modifier(ShakeEffect(animatableData: shake))
        .contentShape(Rectangle())
        .onTapGesture { if !cameraAvailable { countRep() } }
        .statusBarHidden()
        .onAppear {
            level = Double(store.profile.duelLevel)
            tracker.onRep = { countRep() }
            tracker.depth = store.profile.repDepth
            if let top = store.profile.calTop, let bottom = store.profile.calBottom {
                tracker.applyCalibration(top: top, bottom: bottom)
            }
            if cameraAvailable {
                // Eerst uitleggen waarom we de camera willen; dit toestel
                // beslist zelf, los van je account.
                if CameraConsentView.alreadyAnswered {
                    tracker.start()
                    if store.profile.calTop == nil { showCalibration = true }
                } else {
                    showConsent = true
                }
            }
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            tracker.stop()
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .onReceive(tick) { _ in advance() }
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
    }

    // MARK: Instellen

    private var setupScreen: some View {
        VStack(spacing: 0) {
            Text(store.t(.mode_duel))
                .font(.system(size: 30, weight: .black, design: .rounded))
            Text(store.t(.mode_duel_sub))
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(Theme.dimText)
                .padding(.top, 4)

            Text(store.t(.difficulty).uppercased())
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .tracking(3)
                .foregroundStyle(Theme.dimText)
                .padding(.top, 34)

            Text("\(levelInt)%")
                .font(.system(size: 64, weight: .black, design: .rounded))
                .foregroundStyle(levelColor)
                .contentTransition(.numericText())

            Slider(value: $level, in: 1...100, step: 1)
                .tint(levelColor)
                .padding(.horizontal, 26)
                .padding(.top, 10)

            // Alleen het karakter van het niveau, niet het aantal.
            Text(store.t(GameStore.difficultyKey(level: levelInt)))
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(levelColor)
                .padding(.top, 8)

            Text(levelInt >= 95 ? store.t(.duel_warn_100) : " ")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.bloodRed)
                .padding(.top, 6)

            Text(store.t(.duel_best, bestText))
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(Theme.dimText)

            Button {
                startDuel()
            } label: {
                Text(store.t(.duel_start))
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(
                        Capsule().fill(LinearGradient(colors: [Theme.gold, Theme.flame],
                                                      startPoint: .top, endPoint: .bottom))
                    )
            }
            .padding(.horizontal, 26)
            .padding(.top, 28)

            Button(store.t(.duel_to_menu)) { dismiss() }
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.dimText)
                .padding(.top, 14)

            cameraStrip.padding(.top, 18)
        }
    }

    /// Laat zien of de camera je ziet, en biedt opnieuw kalibreren aan.
    private var cameraStrip: some View {
        VStack(spacing: 8) {
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
            } else if tracker.seesHead {
                Label(store.t(.hint_camera), systemImage: "checkmark.circle.fill")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(red: 0.29, green: 0.87, blue: 0.50))
            } else {
                Label(store.t(.hint_searching), systemImage: "viewfinder")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.dimText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            if cameraAvailable {
                Button(store.t(.cal_again)) { showCalibration = true }
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.dimText)
            }
        }
    }

    private var levelColor: Color { GameStore.difficultyColor(level: levelInt) }

    private var bestText: String {
        if let best = store.profile.duelBest["\(levelInt)"] { return "\(best)" }
        return store.t(.duel_none_yet)
    }

    // MARK: De race

    private var raceScreen: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                Text("\(store.t(GameStore.difficultyKey(level: levelInt))) · \(levelInt)%")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(levelColor)

                Text("\(Int(ceil(secondsLeft)))")
                    .font(.system(size: 62, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(secondsLeft <= 10 ? Theme.bloodRed : .white)

                Spacer()

                racer(label: store.t(.duel_you), count: myReps, showCount: true,
                      colors: [Theme.gold, Theme.flame], accent: Theme.gold)
                    .padding(.bottom, 26)

                VStack(alignment: .leading, spacing: 5) {
                    racer(label: store.t(.duel_ai), count: opponentReps, showCount: true,
                          colors: [Theme.orbPurple, Theme.bloodRed], accent: Theme.orbPurple)
                    Text(store.t(.duel_intro))
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(Theme.dimText)
                }

                Spacer()

                cameraStrip.padding(.bottom, 6)
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)

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
        }
    }

    private func racer(label: String, count: Int, showCount: Bool,
                       colors: [Color], accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(label)
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(accent)
                Spacer()
                if showCount {
                    Text("\(count)")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .monospacedDigit()
                }
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.09))
                    Capsule()
                        .fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * fraction(count))
                        .animation(.easeOut(duration: 0.2), value: count)
                }
            }
            .frame(height: 14)
        }
    }

    /// De balken schalen mee als je je tegenstander voorbijstreeft.
    private func fraction(_ count: Int) -> Double {
        let scale = Double(max(target, myReps, 1))
        return min(1, Double(count) / scale)
    }

    private var countdownOverlay: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            Text(countdown > 0 ? "\(countdown)" : store.t(.duel_go))
                .font(.system(size: 92, weight: .black, design: .rounded))
                .foregroundStyle(Theme.gold)
        }
        .allowsHitTesting(false)
    }

    private var resultOverlay: some View {
        ZStack {
            Color.black.opacity(0.93).ignoresSafeArea()
            VStack(spacing: 12) {
                Text(store.t(result?.won == true ? .duel_win : .duel_lose))
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(result?.won == true ? Theme.gold : Theme.bloodRed)

                Text(store.t(.duel_score, "\(myReps)", "\(target)"))
                    .font(.system(size: 18, weight: .bold, design: .rounded))

                Text(result?.won == true
                     ? store.t(.duel_reward, "\(result?.xp ?? 0)")
                     : store.t(.duel_consolation, "\(result?.xp ?? 0)"))
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(Theme.gold)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)

                Button {
                    phase = .setup
                    result = nil
                } label: {
                    Text(store.t(.duel_again))
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Capsule().fill(LinearGradient(colors: [Theme.gold, Theme.flame],
                                                          startPoint: .top, endPoint: .bottom))
                        )
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)

                Button(store.t(.duel_to_menu)) { dismiss() }
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.dimText)
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: Verloop

    private func startDuel() {
        store.rememberDuelLevel(levelInt)
        target = GameStore.drawOpponentTarget(level: levelInt)
        myReps = 0
        opponentReps = 0
        secondsLeft = Double(GameStore.duelSeconds)
        countdown = 3
        phase = .countdown
    }

    private func countRep() {
        guard phase == .running else { return }
        myReps += 1
        store.registerDuelRep()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.linear(duration: 0.18)) { shake += 0.5 }
    }

    /// Wordt tien keer per seconde aangeroepen door de timer.
    private func advance() {
        switch phase {
        case .countdown:
            countdownStep += 0.1
            if countdownStep >= 1 {
                countdownStep = 0
                countdown -= 1
                if countdown < 0 {
                    phase = .running
                    startedAt = Date()
                }
            }
        case .running:
            let elapsed = Date().timeIntervalSince(startedAt)
            secondsLeft = max(0, Double(GameStore.duelSeconds) - elapsed)
            // De tegenstander verdeelt zijn doel gelijkmatig over de minuut.
            opponentReps = min(target, Int(Double(target) * elapsed / Double(GameStore.duelSeconds)))
            if secondsLeft <= 0 {
                result = store.finishDuel(level: levelInt, reps: myReps, target: target)
                phase = .finished
                UINotificationFeedbackGenerator()
                    .notificationOccurred(result?.won == true ? .success : .warning)
            }
        default:
            break
        }
    }

    @State private var countdownStep: Double = 0
    @State private var startedAt = Date()
}
