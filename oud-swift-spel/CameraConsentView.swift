import AVFoundation
import SwiftUI

/// Uitleg vóórdat we de camera openen.
///
/// iOS vraagt zelf om toestemming, maar dat gebeurt één keer en zonder context.
/// Dit scherm vertelt eerst waarom we de camera nodig hebben en wat er met het
/// beeld gebeurt, en laat de systeemvraag daarna pas verschijnen. Het antwoord
/// hoort bij dit toestel: installeer je de app op een andere telefoon, dan
/// vraagt die opnieuw. Dat is met opzet — toestemming reist niet mee met je
/// account.
struct CameraConsentView: View {
    @EnvironmentObject var store: GameStore
    var onDone: (Bool) -> Void

    @State private var busy = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 46))
                    .foregroundStyle(Theme.gold)
                    .padding(.bottom, 18)

                Text(store.t(.cam_ask_title))
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Text(store.t(.cam_ask_text))
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(Theme.dimText)
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)
                    .padding(.horizontal, 8)

                Text(store.t(.cam_ask_device))
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(Theme.dimText.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.top, 14)

                Button {
                    vraagToestemming()
                } label: {
                    Text(store.t(.cam_allow))
                        .font(.system(size: 19, weight: .black, design: .rounded))
                        .tracking(2)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(
                            Capsule().fill(LinearGradient(colors: [Theme.gold, Theme.flame],
                                                          startPoint: .top, endPoint: .bottom))
                        )
                }
                .disabled(busy)
                .padding(.top, 26)

                Button(store.t(.cam_without)) { onDone(false) }
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.dimText)
                    .padding(.top, 14)
            }
            .padding(.horizontal, 30)
        }
    }

    private func vraagToestemming() {
        busy = true
        AVCaptureDevice.requestAccess(for: .video) { granted in
            Task { @MainActor in
                busy = false
                onDone(granted)
            }
        }
    }

    /// Of dit toestel al een antwoord heeft gegeven. Bewust niet in het profiel
    /// opgeslagen: toestemming hoort bij het toestel, niet bij je account.
    static var alreadyAnswered: Bool {
        AVCaptureDevice.authorizationStatus(for: .video) != .notDetermined
    }
}
