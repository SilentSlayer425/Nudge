import Foundation
import Combine


class ContextManager: ObservableObject {


    @Published var context:
    FocusContext?

    let screenCapture = ScreenCaptureService()

    let activityMonitor = ActivityMonitor()

    let deviceStateMonitor = DeviceStateMonitor()

    let batteryMonitor = BatteryMonitor()



    lazy var checkPermissionManager:
        CheckPermissionManager =
        CheckPermissionManager(
            contextManager: self
        )



    func update(goal: Goal?) {


        guard let goal else {

            return

        }



        context = FocusContext(

            goal: goal.title,

            currentApplication:
                activityMonitor.currentApplication,

            idleTime:
                activityMonitor.idleTime,

            batteryLevel:
                batteryMonitor.batteryLevel,

            isCharging:
                batteryMonitor.isCharging,

            timestamp:
                Date()

        )

    }

}
