import SwiftUI

/// Tekent de vijand-silhouetten uit `Arena.icon`.
///
/// De iconen zijn SVG-paden uit `iconen.py` en gebruiken alleen absolute
/// M/L/C/Q/Z-commando's. Meer hoeven we niet te ondersteunen; de generator
/// schrijft niets anders. De vulregel is nonzero, wat SwiftUI standaard doet:
/// subpaden die tegen de klok in lopen worden daardoor gaten (ogen, monden).
struct IconShape: Shape {
    let d: String
    /// Zijde van het vierkant waarin het pad getekend is.
    var viewBox: CGFloat = 100

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let scale = min(rect.width, rect.height) / viewBox
        let originX = rect.midX - viewBox * scale / 2
        let originY = rect.midY - viewBox * scale / 2

        func point(_ x: Double, _ y: Double) -> CGPoint {
            CGPoint(x: originX + CGFloat(x) * scale, y: originY + CGFloat(y) * scale)
        }

        var command: Character = " "
        var numbers: [Double] = []
        var buffer = ""

        func takeNumber() {
            guard !buffer.isEmpty else { return }
            if let value = Double(buffer) { numbers.append(value) }
            buffer = ""
        }

        func runCommand() {
            switch command {
            case "M":
                // Extra paren na een M gedragen zich als lijnen, zoals in SVG.
                var i = 0
                while i + 1 < numbers.count {
                    let p = point(numbers[i], numbers[i + 1])
                    if i == 0 { path.move(to: p) } else { path.addLine(to: p) }
                    i += 2
                }
            case "L":
                var i = 0
                while i + 1 < numbers.count {
                    path.addLine(to: point(numbers[i], numbers[i + 1]))
                    i += 2
                }
            case "C":
                var i = 0
                while i + 5 < numbers.count {
                    path.addCurve(
                        to: point(numbers[i + 4], numbers[i + 5]),
                        control1: point(numbers[i], numbers[i + 1]),
                        control2: point(numbers[i + 2], numbers[i + 3])
                    )
                    i += 6
                }
            case "Q":
                var i = 0
                while i + 3 < numbers.count {
                    path.addQuadCurve(
                        to: point(numbers[i + 2], numbers[i + 3]),
                        control: point(numbers[i], numbers[i + 1])
                    )
                    i += 4
                }
            case "Z":
                path.closeSubpath()
            default:
                break
            }
            numbers = []
        }

        for character in d {
            if character.isLetter {
                takeNumber()
                runCommand()
                command = character
                if character == "Z" || character == "z" { runCommand() }
            } else if character == "-" && !buffer.isEmpty {
                takeNumber()
                buffer = "-"
            } else if character == " " || character == "," {
                takeNumber()
            } else {
                buffer.append(character)
            }
        }
        takeNumber()
        runCommand()

        return path
    }
}
