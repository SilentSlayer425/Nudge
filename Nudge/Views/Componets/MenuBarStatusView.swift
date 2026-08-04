import SwiftUI
import Combine

struct MenuBarStatusView: View {

    @EnvironmentObject var session: SessionManager

    @State private var goalText = ""


    var body: some View {

        VStack(alignment: .leading, spacing: 12) {

            Text("Nudge")
                .font(.headline)


            Divider()


            if let goal = session.currentGoal {

                Label("Current Goal", systemImage: "target")

                Text(goal.title)
                    .font(.callout)

            } else {

                Text("No active goal")
                    .foregroundStyle(.secondary)

            }


            Divider()


            Label("Status", systemImage: "circle.fill")

            Text(stateText)


            if session.isRunning {

                Divider()


                Label("Session", systemImage: "clock")


                Text(
                    timeString(
                        session.elapsedTime
                    )
                )


                if let next = session.scheduler.nextCheck {

                    Label(
                        "Next Check",
                        systemImage: "timer"
                    )


                    Text(
                        next.formatted(
                            date: .omitted,
                            time: .shortened
                        )
                    )

                }


                Divider()


                Button("End Session") {

                    session.stop()

                }
                .buttonStyle(.destructive)

            } else {

                Divider()


                TextField(
                    "What do you want to accomplish?",
                    text: $goalText
                )
                .textFieldStyle(.roundedBorder)


                Button("Start Focus Session") {

                    session.start(goal: goalText)

                    goalText = ""

                }
                .buttonStyle(.primary)
                .disabled(goalText.isEmpty)

            }


            Divider()


            Button("Open Nudge") {

                NSApp.activate(
                    ignoringOtherApps: true
                )

            }


            Button("Settings") {

                // Placeholder — settings UI isn't built yet.

            }
            .disabled(true)


            Button("Quit") {

                NSApplication.shared.terminate(nil)

            }

        }
        .padding()
        .frame(width: 260)

    }


    private var stateText: String {

        switch session.appState {

        case .focused:
            return "Focused"

        case .idle:
            return "Idle"

        case .checking:
            return "Checking"

        case .distracted:
            return "Distracted"

        case .standby:
            return "Standby"

        }

    }



    func timeString(
        _ seconds: TimeInterval
    ) -> String {

        let total = Int(seconds)

        let minutes = total / 60
        let seconds = total % 60

        return String(
            format: "%02d:%02d",
            minutes,
            seconds
        )

    }

}
