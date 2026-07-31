import SwiftUI


struct MenuBarView: View {
    
    @EnvironmentObject var session: SessionManager
    
    @Environment(\.openWindow) private var openWindow
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            Text("Nudge")
                .font(.headline)
            
            
            if let goal = session.currentGoal {
                
                Text("Current Goal:")
                    .font(.caption)
                
                Text(goal.title)
                
            } else {
                
                Text("No active goal")
                
            }
            
            
            Divider()
            
            
            Button("Open Nudge") {
                openWindow(id: "main")
            }
            
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
        .frame(width: 220)
    }
}
