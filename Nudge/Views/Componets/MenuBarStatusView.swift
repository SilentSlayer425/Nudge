import SwiftUI


struct MenuBarStatusView: View {

    @EnvironmentObject var session: SessionManager


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

            Text(
                session.isRunning
                ? "Focused"
                : "Idle"
            )


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

            }


            Divider()


            Button("Open Nudge") {

                NSApp.activate(
                    ignoringOtherApps: true
                )

            }


            Button("Settings") {

                // later

            }


            Button("Quit") {

                NSApplication.shared.terminate(nil)

            }

        }
        .padding()
        .frame(width: 260)

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
