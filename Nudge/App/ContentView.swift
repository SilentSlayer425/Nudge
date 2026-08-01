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
        .frame(
            minWidth: 650,
            minHeight: 450
        )
    }

}

#Preview {

    ContentView()
        .environmentObject(
            SessionManager()
        )

}
