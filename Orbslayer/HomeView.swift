import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: GameStore
    @State private var showFight = false
    @State private var showDuel = false
    @State private var showModes = false
    @State private var showSettings = false
    @State private var showCalibration = false
    @StateObject private var tracker = HeadTracker()
    @State private var showResetAlert = false
    @State private var pulse = false
    /// Naam van de arena waar je op tikte terwijl hij nog op slot zit.
    @State private var lockedNotice: String?

    /// Zoveel arena's vooruit mag je zien; alles daarna blijft een vraagteken.
    private static let previewCount = 3
    /// Zoveel vraagtekens erachter, zodat de rij lang genoeg is om door te scrollen.
    private static let mysteryCount = 15

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            RadialGradient(
                colors: [store.arena.color.opacity(0.18), .clear],
                center: .top, startRadius: 20, endRadius: 520
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    languagePicker
                    header
                    currentArenaCard.padding(.top, 22)
                    roadAhead.padding(.top, 26)
                    statsGrid.padding(.top, 26)
                    fightButton.padding(.top, 26)

                    Button(store.t(.reset_progress)) { showResetAlert = true }
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.dimText.opacity(0.6))
                        .padding(.top, 16)
                        .padding(.bottom, 30)
                }
            }

            if let lockedNotice {
                Text(lockedNotice)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(Color.white.opacity(0.12)))
                    .padding(.horizontal, 30)
                    .transition(.opacity.combined(with: .scale))
                    .allowsHitTesting(false)
            }
        }
        .onAppear { pulse = true }
        .fullScreenCover(isPresented: $showFight) {
            FightView().environmentObject(store)
        }
        .fullScreenCover(isPresented: $showDuel) {
            DuelView().environmentObject(store)
        }
        .sheet(isPresented: $showSettings) {
            settingsSheet
                .environmentObject(store)
                .presentationDetents([.height(380)])
        }
        .sheet(isPresented: $showCalibration) {
            CalibrationView(tracker: tracker) { top, bottom in
                store.setCalibration(top: top, bottom: bottom)
            }
            .environmentObject(store)
            .onDisappear { tracker.stop() }
        }
        .sheet(isPresented: $showModes) {
            modeSheet
                .environmentObject(store)
                .presentationDetents([.height(320)])
        }
        .alert(store.t(.reset_title), isPresented: $showResetAlert) {
            Button(store.t(.reset_confirm), role: .destructive) { store.resetProgress() }
            Button(store.t(.cancel), role: .cancel) {}
        } message: {
            Text(store.t(.reset_msg))
        }
    }

    // MARK: Onderdelen

    private var languagePicker: some View {
        HStack(spacing: 6) {
            Button { showModes = true } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
                    .frame(width: 50, height: 46)
                    .background(RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.07)))
            }
            Button { showSettings = true } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
                    .frame(width: 50, height: 46)
                    .background(RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.07)))
            }
            Spacer()
            ForEach(Lang.allCases, id: \.self) { lang in
                Button {
                    store.setLanguage(lang)
                } label: {
                    Text(lang.short)
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundStyle(store.language == lang ? .black : Theme.dimText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule().fill(store.language == lang
                                           ? Theme.gold : Color.white.opacity(0.08))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
    }

    /// Instellingen: hoe diep je moet zakken, en opnieuw kalibreren.
    private var settingsSheet: some View {
        VStack(spacing: 0) {
            Text(store.t(.settings).uppercased())
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .tracking(3)
                .foregroundStyle(Theme.dimText)
                .padding(.top, 22)

            Text(store.t(.depth).uppercased())
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .tracking(3)
                .foregroundStyle(Theme.dimText)
                .padding(.top, 26)

            Text(store.t(.depth_value, "\(Int((depth * 100).rounded()))"))
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(Theme.gold)
                .padding(.top, 2)

            Slider(value: $depth, in: 0.3...0.85, step: 0.05)
                .tint(Theme.gold)
                .padding(.horizontal, 4)
                .padding(.top, 10)
                .onChange(of: depth) { _, new in store.setRepDepth(new) }

            Text(store.t(.depth_hint))
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(Theme.dimText)
                .multilineTextAlignment(.center)
                .padding(.top, 8)

            Button {
                showSettings = false
                // Kalibreren kan alleen met beeld, dus de camera gaat eerst aan.
                tracker.depth = depth
                tracker.start()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { showCalibration = true }
            } label: {
                Text(store.t(.calibrate_now))
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        Capsule().fill(LinearGradient(colors: [Theme.gold, Theme.flame],
                                                      startPoint: .top, endPoint: .bottom))
                    )
            }
            .padding(.top, 22)

            Button(store.t(.close)) { showSettings = false }
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.dimText)
                .padding(.top, 12)

            Spacer()
        }
        .padding(.horizontal, 22)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background)
        .onAppear { depth = store.profile.repDepth }
    }

    @State private var depth: Double = 0.6

    /// Het burgermenu: kiezen tussen de eindeloze arena en het duel.
    private var modeSheet: some View {
        VStack(spacing: 12) {
            Text(store.t(.menu_modes).uppercased())
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .tracking(3)
                .foregroundStyle(Theme.dimText)
                .padding(.top, 22)
                .padding(.bottom, 4)

            modeCard(icon: ModeIcons.arena, title: store.t(.mode_arena),
                     subtitle: store.t(.mode_arena_sub), highlighted: true) {
                showModes = false
            }
            modeCard(icon: ModeIcons.duel, title: store.t(.mode_duel),
                     subtitle: store.t(.mode_duel_sub), highlighted: false) {
                showModes = false
                // Even wachten tot het paneel dicht is voordat we het duel openen.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { showDuel = true }
            }

            Button(store.t(.cancel)) { showModes = false }
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.dimText)
                .padding(.top, 4)

            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background)
    }

    private func modeCard(icon: String, title: String, subtitle: String,
                          highlighted: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                IconShape(d: icon)
                    .fill(highlighted ? Theme.gold : Color.white.opacity(0.55))
                    .frame(width: 46, height: 46)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 19, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(Theme.dimText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(highlighted ? Theme.gold.opacity(0.1) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(highlighted ? Theme.gold.opacity(0.6)
                                                      : Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text("PUSH BATTLE")
                .font(.system(size: 38, weight: .black, design: .rounded))
                .tracking(6)
                .foregroundStyle(.white)
                .shadow(color: store.arena.color.opacity(0.8), radius: pulse ? 26 : 12)
                .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: pulse)

            Text(store.t(.rank_level, store.playerTitle, "\(store.playerLevel)"))
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.gold)

            xpBar.padding(.horizontal, 40).padding(.top, 12)
        }
        .padding(.top, 24)
    }

    private var xpBar: some View {
        let progress = store.levelProgress
        let fraction = Double(progress.current) / Double(max(1, progress.needed))
        return VStack(spacing: 5) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.1))
                    Capsule()
                        .fill(LinearGradient(colors: [store.arena.color, Theme.gold],
                                             startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * min(fraction, 1))
                }
            }
            .frame(height: 8)

            Text(store.t(.xp_of, "\(progress.current)", "\(progress.needed)"))
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.dimText)
        }
    }

    private var currentArenaCard: some View {
        let arena = store.arena
        let isBossNext = store.enemy.isBoss
        return VStack(spacing: 10) {
            Text(store.t(.arena_n_race, "\(store.profile.arenaIndex)", arena.race.text(store.language).uppercased()))
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .tracking(2.5)
                .foregroundStyle(Theme.dimText)

            Text(arena.name.text(store.language))
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(arena.color)
                .multilineTextAlignment(.center)

            EnemyView(arena: arena,
                      healthFraction: store.enemy.healthFraction,
                      isBoss: isBossNext,
                      hitPulse: 0)
                .frame(height: 190)

            Text(isBossNext ? store.t(.boss_named, store.enemyName) : store.enemyName)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(isBossNext ? Theme.bloodRed : .white)
                .multilineTextAlignment(.center)

            Text(store.t(.hp_short, "\(store.enemy.hp)"))
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.dimText)

            HStack(spacing: 5) {
                ForEach(0..<10, id: \.self) { i in
                    Circle()
                        .fill(i < store.profile.killsThisArena ? arena.color
                              : (i == 9 ? Theme.bloodRed.opacity(0.5) : Color.white.opacity(0.15)))
                        .frame(width: 7, height: 7)
                }
            }
            .padding(.top, 2)
        }
        .padding(.horizontal, 20)
    }

    /// De weg vooruit: drie arena's die je al mag zien, daarna vraagtekens.
    private var roadAhead: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(store.t(.up_next))
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .tracking(3)
                .foregroundStyle(Theme.dimText)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(1...Self.previewCount, id: \.self) { offset in
                        let index = store.profile.arenaIndex + offset
                        lockedCard(arena: Arena.at(index), index: index)
                    }
                    ForEach(0..<Self.mysteryCount, id: \.self) { i in
                        let index = store.profile.arenaIndex + Self.previewCount + 1 + i
                        lockedCard(arena: nil, index: index)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func lockedCard(arena: Arena?, index: Int) -> some View {
        Button {
            let melding = arena.map {
                store.t(.locked_known, $0.name.text(store.language), "\(index - 1)")
            } ?? store.t(.locked_unknown)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { lockedNotice = melding }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation(.easeOut(duration: 0.3)) { lockedNotice = nil }
            }
        } label: {
            VStack(spacing: 8) {
                ArenaBadge(arena: arena, size: 62, dimmed: true)

                Text(arena?.name.text(store.language) ?? store.t(.unknown_arena))
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(arena == nil ? Theme.dimText : .white.opacity(0.75))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(height: 28)

                Text(arena?.race.text(store.language) ?? store.t(.unknown_race))
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.dimText.opacity(0.8))

                Image(systemName: "lock.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(Theme.dimText.opacity(0.6))
            }
            .frame(width: 92)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.04))
            )
        }
        .buttonStyle(.plain)
    }

    private var statsGrid: some View {
        HStack(spacing: 0) {
            stat("\(store.effectiveStreak)", store.t(.stat_streak), Theme.flame)
            stat("\(store.profile.totalReps)", store.t(.stat_pushups), .white)
            stat("\(store.profile.totalKills)", store.t(.stat_kills), .white)
            stat("\(store.profile.bossKills)", store.t(.stat_arenas), Theme.bloodRed)
        }
        .padding(.horizontal, 16)
    }

    private func stat(_ value: String, _ label: String, _ color: Color) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.dimText)
        }
        .frame(maxWidth: .infinity)
    }

    private var fightButton: some View {
        Button { showFight = true } label: {
            Text(store.t(.fight))
                .font(.system(size: 20, weight: .black, design: .rounded))
                .tracking(3)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    Capsule().fill(
                        LinearGradient(colors: [Theme.gold, Theme.flame],
                                       startPoint: .top, endPoint: .bottom)
                    )
                )
                .shadow(color: Theme.flame.opacity(0.5), radius: 20)
        }
        .padding(.horizontal, 32)
    }
}
