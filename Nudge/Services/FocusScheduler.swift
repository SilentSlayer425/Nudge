import Foundation
import Combine


class FocusScheduler: ObservableObject {


    @Published var nextCheck: Date?



    private var timer: Timer?



    var interval: TimeInterval = 300
    // default 5 minutes



    func start() {

        scheduleNext(
            seconds: 300
        )

    }



    func scheduleNext(
        seconds: TimeInterval
    ) {

        interval = seconds

        nextCheck =
            Date()
            .addingTimeInterval(seconds)

    }



    func focused() {

        if interval < 900 {

            scheduleNext(
                seconds: interval + 300
            )

        }
        else {

            scheduleNext(
                seconds: 900
            )

        }

    }



    func distracted() {

        scheduleNext(
            seconds: 300
        )

    }



    func stop() {

        nextCheck = nil

    }


}
