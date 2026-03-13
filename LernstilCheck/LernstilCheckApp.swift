import SwiftUI

@main
struct LernstilCheckApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                IntroView()
            }
            .environmentObject(appState)
        }
    }
}
