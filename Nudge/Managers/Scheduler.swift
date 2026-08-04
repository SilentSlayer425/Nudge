import Foundation
import Combine


class Scheduler: ObservableObject {

    @Published var nextCheck: Date?

    private var timer: Timer?

    var onCheck: (() -> Void)?

    private var interval: TimeInterval = 300

    private var minInterval: TimeInterval = 300

    private var maxInterval: TimeInterval = 900


    /// Bounds come from `SettingsManager` at the call site (Scheduler itself
    /// isn't main-actor isolated, so it doesn't reach into that singleton
    /// directly).
    func start(minSeconds: TimeInterval, maxSeconds: TimeInterval) {

        minInterval = minSeconds
        maxInterval = maxSeconds

        scheduleNext(seconds: minInterval)

        timer?.invalidate()

        timer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { [weak self] _ in

            guard let self else { return }

            if let next = self.nextCheck,
               Date() >= next {

                self.onCheck?()

                self.scheduleNext(
                    seconds: self.interval
                )
            }
        }
    }



    func scheduleNext(seconds: TimeInterval) {

        interval = seconds

        nextCheck =
            Date()
            .addingTimeInterval(seconds)

    }



    func focused() {

        scheduleNext(
            seconds: min(interval + minInterval, maxInterval)
        )

    }



    func distracted() {

        scheduleNext(
            seconds: minInterval
        )

    }



    func stop() {

        timer?.invalidate()
        timer = nil

        nextCheck = nil
    }

}
