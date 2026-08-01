import SwiftUI


struct MenuBarView: View {

    @EnvironmentObject var session: SessionManager


    var body: some View {

        VStack(alignment: .leading, spacing: 12) {


            MenuBarStatusView()


            Divider()


            Label(
                "Battery",
                systemImage: "battery.100"
            )


            Text(batteryText)
                .foregroundStyle(.secondary)



            Label(
                "Activity",
                systemImage: "keyboard"
            )


            Text(activityText)
                .foregroundStyle(.secondary)

        }
        .padding()

    }



    private var batteryText: String {

        let battery =
        session.contextManager
            .batteryMonitor
            .batteryLevel


        return "\(Int(battery))%"

    }



    private var activityText: String {

        let idle =
        session.contextManager
            .activityMonitor
            .idleTime


        if idle < 60 {

            return "Active"

        }
        else if idle < 300 {

            return "Away"

        }
        else {

            return "Inactive"

        }

    }

}
