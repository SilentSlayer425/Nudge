import SwiftUI

struct GoalEntryView: View {

    @EnvironmentObject var session: SessionManager

    @ObservedObject private var history = HistoryStore.shared

    @State private var goalText = ""


    var body: some View {

        ScrollView {

            VStack(spacing: 30) {


                VStack(spacing: 22) {

                    Text("Nudge")
                        .font(.largeTitle)
                        .bold()


                    TextField(
                        "What do you want to accomplish?",
                        text: $goalText
                    )
                    .textFieldStyle(.roundedBorder)



                    Button("Start Focus Session") {

                        session.start(goal: goalText)

                    }
                    .buttonStyle(.primary)
                    .disabled(goalText.isEmpty)

                }



                Divider()
                    .padding(.vertical)



                VStack(spacing: 12) {


                    Text("Your Stats")
                        .font(.headline)



                    HStack {


                        VStack {

                            Text("Today")
                                .font(.caption)
                                .foregroundStyle(.secondary)


                            Text("\(history.completedSessions)")
                                .font(.title2)


                            Text("Sessions")
                                .font(.caption)

                        }



                        Spacer()



                        VStack {

                            Text("Focus")
                                .font(.caption)
                                .foregroundStyle(.secondary)


                            Text(accuracyText)
                                .font(.title2)


                            Text("Accuracy")
                                .font(.caption)

                        }



                        Spacer()



                        VStack {

                            Text("Focused")
                                .font(.caption)
                                .foregroundStyle(.secondary)


                            Text(focusTimeText)
                                .font(.title2)


                            Text("Time")
                                .font(.caption)

                        }


                    }

                }

            }
            .frame(
                maxWidth: 500
            )
            .padding(40)

        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )

    }


    private var accuracyText: String {

        guard let accuracy = history.focusAccuracy else {

            return "--"

        }

        return "\(Int((accuracy * 100).rounded()))%"

    }


    private var focusTimeText: String {

        let totalMinutes = Int(history.totalFocusTime) / 60


        if totalMinutes < 60 {

            return "\(totalMinutes)m"

        }


        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60


        return "\(hours)h \(minutes)m"

    }

}
