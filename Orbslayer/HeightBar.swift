import SwiftUI

/// Verticale balk rechts in beeld met een bolletje dat live meebeweegt met de
/// hoogte van je hoofd. De twee streepjes zijn de drempels: onder de onderste
/// = "beneden", boven de bovenste = "boven", en die combinatie telt als één rep.
struct HeightBar: View {
    var height: Double          // 0 = vloer, 1 = bovenkant beeld
    var upThreshold: Double
    var downThreshold: Double
    var isDown: Bool
    var seesHead: Bool
    var upLabel: String
    var downLabel: String

    private let barWidth: CGFloat = 14

    var body: some View {
        GeometryReader { geo in
            let h = geo.size.height
            let clamped = min(max(height, 0), 1)

            ZStack(alignment: .bottom) {
                Capsule()
                    .fill(Color.white.opacity(0.07))
                    .frame(width: barWidth)

                // Gevulde zone tot je huidige neushoogte
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Theme.orbPurple.opacity(0.7), Theme.bloodRed.opacity(0.5)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: barWidth, height: h * clamped)

                marker(at: upThreshold, in: h, label: upLabel, active: !isDown)
                marker(at: downThreshold, in: h, label: downLabel, active: isDown)

                // Het bolletje dat je neus volgt
                Circle()
                    .fill(seesHead ? (isDown ? Theme.bloodRed : Theme.gold) : Color.gray)
                    .frame(width: 26, height: 26)
                    .shadow(color: (isDown ? Theme.bloodRed : Theme.gold).opacity(seesHead ? 0.9 : 0), radius: 10)
                    .overlay(Circle().strokeBorder(.white.opacity(0.7), lineWidth: 1.5))
                    .offset(y: -(h * clamped) + 13)
                    .animation(.interactiveSpring(response: 0.15, dampingFraction: 0.7), value: clamped)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(width: 78)
        .opacity(seesHead ? 1 : 0.45)
    }

    private func marker(at value: Double, in h: CGFloat, label: String, active: Bool) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(active ? .white : Theme.dimText)
            Rectangle()
                .fill(active ? Color.white : Color.white.opacity(0.3))
                .frame(width: 22, height: 2)
        }
        .frame(width: 78, alignment: .trailing)
        .offset(y: -(h * min(max(value, 0), 1)) + 1)
    }
}
