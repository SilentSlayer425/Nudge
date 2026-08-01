import SwiftUI

struct GoalEntryView: View {

    @EnvironmentObject var session: SessionManager

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
                                .font(.title2)


                            Text("Accuracy")
                                .font(.caption)

                        }



                        Spacer()



                        VStack {

                            Text("Focused")
                                .font(.caption)
                                .foregroundStyle(.secondary)


                            Text("--")
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

}
