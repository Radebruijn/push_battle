import SwiftUI

enum Theme {
    static let background = Color.black
    static let orbPurple = Color(red: 0.55, green: 0.22, blue: 1.0)
    static let bloodRed = Color(red: 0.95, green: 0.15, blue: 0.22)
    static let gold = Color(red: 1.0, green: 0.78, blue: 0.25)
    static let flame = Color(red: 1.0, green: 0.45, blue: 0.1)
    static let dimText = Color.white.opacity(0.55)

    /// Verloopt van de kleur van de arena (volle HP) naar bloedrood (bijna dood).
    static func orbColor(healthFraction: Double, arena: RGB) -> Color {
        let f = min(max(healthFraction, 0), 1)
        func lerp(_ a: Double, _ b: Double) -> Double { b + (a - b) * f }
        return Color(
            red: lerp(arena.r, 0.95),
            green: lerp(arena.g, 0.15),
            blue: lerp(arena.b, 0.22)
        )
    }
}

/// Horizontal screen shake, driven by incrementing `animatableData`.
struct ShakeEffect: GeometryEffect {
    var travel: CGFloat = 9
    var shakesPerUnit: CGFloat = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let x = travel * sin(animatableData * .pi * shakesPerUnit * 2)
        return ProjectionTransform(CGAffineTransform(translationX: x, y: 0))
    }
}
