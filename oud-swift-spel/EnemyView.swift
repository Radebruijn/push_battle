import SwiftUI

/// De vijand: het silhouet van zijn ras, gloeiend en ademend, en steeds
/// bloediger naarmate hij sterft.
struct EnemyView: View {
    var arena: Arena
    var healthFraction: Double
    var isBoss: Bool
    var hitPulse: Int

    @State private var breathe = false
    @State private var hitScale: CGFloat = 1

    private var color: Color { Theme.orbColor(healthFraction: healthFraction, arena: arena.rgb) }
    private var size: CGFloat { isBoss ? 240 : 175 }

    var body: some View {
        ZStack {
            // Gloed achter het silhouet
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.4), color.opacity(0)],
                        center: .center,
                        startRadius: size * 0.15,
                        endRadius: size * 0.8
                    )
                )
                .frame(width: size * 1.9, height: size * 1.9)
                .blur(radius: 14)

            if isBoss {
                Circle()
                    .strokeBorder(Theme.bloodRed.opacity(0.45),
                                  style: StrokeStyle(lineWidth: 2, dash: [6, 10]))
                    .frame(width: size * 1.25, height: size * 1.25)
                    .rotationEffect(.degrees(breathe ? 360 : 0))
                    .animation(.linear(duration: 24).repeatForever(autoreverses: false), value: breathe)
            }

            IconShape(d: arena.icon)
                .fill(
                    LinearGradient(
                        colors: [color, color.opacity(0.62)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: size, height: size)
                .shadow(color: color.opacity(0.9), radius: 26)
                .shadow(color: color.opacity(0.5), radius: 60)
        }
        .scaleEffect(hitScale * (breathe ? 1.03 : 0.97))
        .animation(.easeInOut(duration: isBoss ? 2.4 : 1.8).repeatForever(autoreverses: true), value: breathe)
        .onAppear { breathe = true }
        .onChange(of: hitPulse) { _, _ in
            withAnimation(.easeOut(duration: 0.08)) { hitScale = 0.9 }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.45).delay(0.08)) { hitScale = 1 }
        }
    }
}

/// Klein icoon voor het menu: alleen het silhouet, eventueel gedempt of als
/// vraagteken wanneer de arena nog onbekend is.
struct ArenaBadge: View {
    var arena: Arena?
    var size: CGFloat = 56
    var dimmed = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.26)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.26)
                        .strokeBorder((arena?.color ?? Theme.dimText).opacity(dimmed ? 0.2 : 0.5),
                                      lineWidth: 1)
                )

            if let arena {
                IconShape(d: arena.icon)
                    .fill(arena.color.opacity(dimmed ? 0.45 : 1))
                    .frame(width: size * 0.66, height: size * 0.66)
                    .shadow(color: arena.color.opacity(dimmed ? 0 : 0.7), radius: 10)
            } else {
                Text("?")
                    .font(.system(size: size * 0.46, weight: .black, design: .rounded))
                    .foregroundStyle(Theme.dimText.opacity(0.7))
            }
        }
        .frame(width: size, height: size)
    }
}

/// Damage-getal dat vanaf de vijand omhoog spat en vervaagt.
struct DamageNumber: Identifiable {
    let id = UUID()
    let value: Int
    let isCrit: Bool
    let xOffset: CGFloat
}

struct DamageNumberView: View {
    let number: DamageNumber
    @State private var rise: CGFloat = 0
    @State private var opacity: Double = 1
    @State private var scale: CGFloat = 0.4

    var body: some View {
        Text("-\(number.value)")
            .font(.system(size: number.isCrit ? 54 : 36, weight: .black, design: .rounded))
            .foregroundStyle(number.isCrit ? Theme.gold : Theme.bloodRed)
            .shadow(color: (number.isCrit ? Theme.gold : Theme.bloodRed).opacity(0.8), radius: 12)
            .scaleEffect(scale)
            .offset(x: number.xOffset, y: rise)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.5)) { scale = 1 }
                withAnimation(.easeOut(duration: 1.0)) { rise = -130 }
                withAnimation(.easeIn(duration: 0.55).delay(0.45)) { opacity = 0 }
            }
    }
}
