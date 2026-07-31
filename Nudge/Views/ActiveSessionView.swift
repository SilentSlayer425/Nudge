import SwiftUI

struct ActiveSessionView: View {

    @EnvironmentObject var session: SessionManager


    var body: some View {

        VStack(spacing: 20) {

            Text("Current Goal")
                .font(.headline)

            Text(session.currentGoal?.title ?? "")
                .font(.title2)


            TimerView(seconds: session.elapsedTime)


            if let next = session.scheduler.nextCheck {

                VStack {

                    Text("Next Check")

                    Text(
                        next.formatted(
                            date: .omitted,
                            time: .shortened
                        )
                    )

                }

            }


            StatusBadge(
                text: "Active",
                color: .green
            )


            Divider()


            Button("End Session") {

                session.stop()

            }


            Divider()


            Text("Current App")
                .font(.headline)


            Text(
                session.activityMonitor.currentApplication
            )
            .foregroundStyle(.secondary)



            Divider()


            Text("Activity")
                .font(.headline)


            Text(activityStatus)
                .foregroundStyle(.secondary)

        }
        .padding(40)

    }



    private var activityStatus: String {

        let idle = session.activityMonitor.idleTime


        if idle < 60 {

            return "Active"

        } else if idle < 300 {

            return "Away briefly"

        } else {

            return "Inactive"

        }

    }

}
