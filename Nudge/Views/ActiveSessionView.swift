import SwiftUI
import Combine

struct ActiveSessionView: View {

    @EnvironmentObject var session: SessionManager


    var body: some View {

        GeometryReader { geometry in

            ScrollView {

                VStack(spacing: 25) {


                    Text("Nudge")
                        .font(.largeTitle)
                        .bold()



                    HStack(
                        alignment: .top,
                        spacing: 25
                    ) {


                        // LEFT SIDE

                        VStack(
                            alignment: .leading,
                            spacing: 20
                        ) {


                            SectionHeader(
                                title: "Focus"
                            )


                            Text(
                                session.currentGoal?.title ?? ""
                            )
                            .font(.title3)
                            .lineLimit(3)



                            TimerView(
                                seconds: session.elapsedTime
                            )



                            if let next =
                                session.scheduler.nextCheck {


                                VStack(
                                    alignment: .leading,
                                    spacing: 5
                                ) {

                                    Text("Next Check")
                                        .font(.headline)


                                    Text(
                                        next.formatted(
                                            date: .omitted,
                                            time: .shortened
                                        )
                                    )
                                    .foregroundStyle(.secondary)

                                }

                            }

                        }
                        .frame(
                            width: 250,
                            alignment: .leading
                        )



                        Divider()
                            .frame(height: 220)



                        // RIGHT SIDE

                        VStack(
                            alignment: .leading,
                            spacing: 20
                        ) {


                            SectionHeader(
                                title: "System"
                            )


                            StatusBadge(
                                text: stateText,
                                color: .green
                            )


                            InfoRow(
                                title: "Current App",
                                value:
                                    session
                                        .contextManager
                                        .activityMonitor
                                        .currentApplication
                            )


                            InfoRow(
                                title: "Battery",
                                value: batteryText
                            )


                            InfoRow(
                                title: "Activity",
                                value: activityStatus
                            )
                            
                            InfoRow(
                                title: "Check Status",
                                value: checkStatusText
                            )
                            
                            InfoRow(
                                title: "Device",
                                value: deviceStateText
                            )

                        }
                        .frame(
                            width: 250,
                            alignment: .leading
                        )

                    }
                    .frame(
                        width: 550
                    )

                    Button("Test AI") {

                        Task {

                            guard let context =
                                session.contextManager.context
                            else {

                                print("❌ No context available")

                                return

                            }


                            print("✅ Context found:")
                            print(context)


                            do {

                                let result =
                                try await FocusAnalyzer()
                                    .analyze(
                                        context: context
                                    )


                                print("🤖 AI RESPONSE:")
                                print(result)

                            }
                            catch {

                                print("❌ AI ERROR:")
                                print(error)

                            }

                        }

                    }
                    
                    
                    Button("Capture Test Screenshot") {


                        Task {

                            await session
                                .contextManager
                                .screenCapture
                                .captureScreen()

                        }


                    }
                    .buttonStyle(.bordered)
                    
                    if let image =
                        session.contextManager
                            .screenCapture
                            .latestScreenshot {


                        Image(
                            nsImage: image
                        )
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: 400
                        )

                    }

                    Button("End Session") {

                        session.stop()

                    }
                    .buttonStyle(.borderedProminent)


                }
                .frame(
                    maxWidth: .infinity,
                    minHeight: geometry.size.height,
                    alignment: .center
                )
                .padding(30)

            }

        }

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



    private var batteryText: String {

        let battery =
            session.contextManager
                .batteryMonitor
                .batteryLevel


        return "\(Int(battery))%"

    }

    private var checkStatusText: String {

        session.contextManager
            .checkPermissionManager
            .lastReason
    }
    
    
    private var deviceStateText: String {

        let device =
            session.contextManager
                .deviceStateMonitor


        if device.isSleeping {

            return "Sleeping"

        }


        if device.isLocked {

            return "Locked"

        }


        return "Active"

    }

    private var activityStatus: String {

        let idle =
            session.contextManager
                .activityMonitor
                .idleTime


        if idle < 60 {

            return "Active"

        }
        else if idle < 300 {

            return "Away briefly"

        }
        else {

            return "Inactive"

        }

    }

}
