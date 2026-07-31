import SwiftUI


@main
struct NudgeApp: App {
    
    @StateObject private var session = SessionManager()
    
    var body: some Scene {
        
        WindowGroup(id: "main") {
            ContentView()
                .environmentObject(session)
        }
        
        
        MenuBarExtra("Nudge", systemImage: "brain.head.profile") {
            MenuBarView()
                .environmentObject(session)
        }
    }
}
