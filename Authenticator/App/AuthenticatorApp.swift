import SwiftUI

@main
struct AuthenticatorApp: App {
    @StateObject private var totpService = TOTPService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(totpService)
                .environmentObject(totpService.getTOTPGenerator())
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}