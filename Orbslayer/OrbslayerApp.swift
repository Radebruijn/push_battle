import SwiftUI

@main
struct OrbslayerApp: App {
    @StateObject private var store = GameStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}
