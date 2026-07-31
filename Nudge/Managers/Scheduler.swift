import Foundation
import Combine

class Scheduler: ObservableObject {

    @Published var currentInterval: TimeInterval = 300
    @Published var nextCheck: Date?

    func sessionStarted() {

        currentInterval = 300
        scheduleNext()

    }

    func process(result: FocusStatus) {

        switch result {

        case .onTask:

            currentInterval = min(
                currentInterval + 300,
                900
            )

        case .distracted:

            currentInterval = 300

        case .unknown:

            currentInterval = 300

        }

        scheduleNext()
    }

    private func scheduleNext() {

        nextCheck = Date().addingTimeInterval(
            currentInterval
        )

    }

}
