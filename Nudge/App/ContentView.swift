import SwiftUI

struct ContentView: View {

    @EnvironmentObject var session: SessionManager

    var body: some View {

        Group {

            if session.isRunning {

                ActiveSessionView()

            } else {

                GoalEntryView()

            }

        }
        .frame(width: 500,
               height: 420)

    }

}

#Preview {

    ContentView()
        .environmentObject(
            SessionManager()
        )

}
