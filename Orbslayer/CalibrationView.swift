import SwiftUI

/// Twee stappen: hoofdhoogte met gestrekte armen, en hoofdhoogte onderin.
struct CalibrationView: View {
    @EnvironmentObject var store: GameStore
    @ObservedObject var tracker: HeadTracker
    var onDone: (Double, Double) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var step = 0
    @State private var capturedTop: Double?
    @State private var countdown: Int?
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            HStack {
                VStack(spacing: 26) {
                    Text(store.t(.cal_step, step == 0 ? "1" : "2"))
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .tracking(3)
                        .foregroundStyle(Theme.dimText)

                    Text(store.t(step == 0 ? .cal_title_up : .cal_title_down))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(store.t(step == 0 ? .cal_text_up : .cal_text_down))
                        .font(.system(size: 15, design: .rounded))
                        .foregroundStyle(Theme.dimText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)

                    if let countdown {
                        Text("\(countdown)")
                            .font(.system(size: 68, weight: .black, design: .rounded))
                            .foregroundStyle(Theme.gold)
                    } else {
                        Button {
                            startCountdown()
                        } label: {
                            Text(store.t(tracker.seesHead ? .cal_capture : .cal_no_face))
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 34)
                                .padding(.vertical, 14)
                                .background(Capsule().fill(tracker.seesHead ? Theme.gold : Color.gray))
                        }
                        .disabled(!tracker.seesHead)
                    }

                    Button(store.t(.cal_skip)) {
                        dismiss()
                    }
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.dimText)
                }
                .frame(maxWidth: .infinity)

                HeightBar(
                    height: tracker.headHeight,
                    upThreshold: tracker.upThreshold,
                    downThreshold: tracker.downThreshold,
                    isDown: tracker.phase == .down,
                    seesHead: tracker.seesHead,
                    upLabel: store.t(.bar_up),
                    downLabel: store.t(.bar_down)
                )
                .padding(.vertical, 50)
            }
        }
        .interactiveDismissDisabled(true)
        .onDisappear { timer?.invalidate() }
    }

    private func startCountdown() {
        countdown = 3
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            Task { @MainActor in
                guard let c = countdown else { t.invalidate(); return }
                if c > 1 {
                    countdown = c - 1
                } else {
                    t.invalidate()
                    countdown = nil
                    capture()
                }
            }
        }
    }

    private func capture() {
        let value = tracker.headHeight
        if step == 0 {
            capturedTop = value
            step = 1
        } else {
            let top = capturedTop ?? 0.75
            let bottom = value
            // Bij te weinig verschil is de kalibratie onbruikbaar; val terug op standaard.
            if top - bottom > 0.05 {
                tracker.applyCalibration(top: top, bottom: bottom)
                onDone(top, bottom)
            }
            dismiss()
        }
    }
}
