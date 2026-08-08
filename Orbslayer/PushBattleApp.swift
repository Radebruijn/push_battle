import SwiftUI
import AVFoundation

/// Push Battle voor de App Store.
///
/// Het spel zelf is de webversie: één zelfstandig bestand dat meereist in de
/// app en dus zonder internet opent. Deze app zet daar een echte iOS-jas
/// omheen — volledig scherm, geen adresbalk, de camera via de gewone
/// toestemmingsvraag van iOS, en het geluid door het mediakanaal zodat het
/// schuifje aan de zijkant het niet stilzet.
@main
struct PushBattleApp: App {
  init() {
    // Zonder dit valt zelfgemaakt geluid op iOS in de bak 'omgevingsgeluid'
    // en hoor je niets zodra het schuifje op stil staat.
    let sessie = AVAudioSession.sharedInstance()
    try? sessie.setCategory(.playback, mode: .default, options: [.mixWithOthers])
    try? sessie.setActive(true)
  }

  var body: some Scene {
    WindowGroup {
      SpelScherm()
        .ignoresSafeArea()
        .background(Color.black)
        .preferredColorScheme(.dark)
        .statusBarHidden(true)
    }
  }
}
