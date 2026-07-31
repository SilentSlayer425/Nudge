import SwiftUI


struct ContentView: View {
    
    @StateObject private var session = SessionManager()
    @State private var goalText = ""
    
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Nudge")
                .font(.largeTitle)
                .bold()
            
            
            if let goal = session.currentGoal, session.isRunning {
                
                Text("Current Goal:")
                    .font(.headline)
                
                Text(goal.title)
                    .font(.title3)
                
                
                Text(timeString(session.elapsedTime))
                    .font(.system(size: 40))
                
                
                VStack(spacing: 15) {
                    
                    Button("End Goal") {
                        session.stop()
                    }
                    
                    
                    Button("Start New Goal") {
                        session.stop()
                    }
                }
                
            } else {
                
                TextField(
                    "What do you want to accomplish?",
                    text: $goalText
                )
                .textFieldStyle(.roundedBorder)
                
                
                Button("Start Focus Session") {
                    session.start(goal: goalText)
                }
                .disabled(goalText.isEmpty)
            }
            
        }
        .padding(40)
        .frame(width: 450, height: 350)
    }
    
    
    func timeString(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
}


#Preview {
    ContentView()
}
