import Foundation
import AppKit
import Combine
import CoreGraphics


class ActivityMonitor: ObservableObject {

    @Published var currentApplication = "Unknown"

    @Published var idleTime: TimeInterval = 0

    @Published var lastUpdated = Date()


    private var timer: Timer?



    init() {

        startMonitoring()

    }



    func startMonitoring() {

        timer?.invalidate()


        timer = Timer.scheduledTimer(
            withTimeInterval: 5,
            repeats: true
        ) { _ in

            DispatchQueue.main.async {

                self.update()

            }

        }

    }



    func update() {


        // Current App

        if let app = NSWorkspace.shared.frontmostApplication {

            currentApplication =
            app.localizedName ?? "Unknown"

        }



        // Idle Time

        idleTime = getIdleTime()



        lastUpdated = Date()

    }





    private func getIdleTime() -> TimeInterval {


        let event = CGEventSource.secondsSinceLastEventType(
            .combinedSessionState,
            eventType: .mouseMoved
        )


        return event

    }

}
