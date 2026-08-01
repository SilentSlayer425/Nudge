import Foundation
import Combine


class CheckPermissionManager: ObservableObject {


    @Published var lastReason: String = "Ready"


    let contextManager: ContextManager



    init(contextManager: ContextManager) {

        self.contextManager = contextManager

        refresh()

    }



    func refresh() {

        _ = canRunCheck()

    }



    func canRunCheck() -> Bool {


        let device =
            contextManager
                .deviceStateMonitor



        let battery =
            contextManager
                .batteryMonitor



        if device.isSleeping {

            lastReason = "Mac is sleeping"

            return false

        }



        if device.isLocked {

            lastReason = "Screen is locked"

            return false

        }



        if battery.batteryLevel < 15 {

            lastReason = "Battery too low"

            return false

        }



        lastReason = "Allowed"

        return true

    }

}
