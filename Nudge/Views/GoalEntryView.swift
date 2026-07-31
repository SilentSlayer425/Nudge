import SwiftUI

struct GoalEntryView: View {

    @EnvironmentObject var session: SessionManager

    @State private var goalText = ""

    var body: some View {

        VStack(spacing: 20) {

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
            .disabled(goalText.isEmpty)

        }
        .padding(40)

        Divider()
            .padding(.vertical)


        VStack(spacing: 8) {

            Text("Your Stats")
                .font(.headline)


            HStack {

                VStack {
                    Text("Today")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("0")
                        .font(.title2)

                    Text("Sessions")
                        .font(.caption)
                }


                Spacer()


                VStack {
                    Text("Focus")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("--")

                    Text("Accuracy")
                        .font(.caption)
                }


                Spacer()


                VStack {
                    Text("Focused")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("--")

                    Text("Time")
                        .font(.caption)
                }

            }

        }
    }

}
