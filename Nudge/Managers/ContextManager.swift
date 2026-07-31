import Foundation
import Combine


class ContextManager: ObservableObject {


    @Published var context:
    FocusContext?


    let activityMonitor = ActivityMonitor()

    let batteryMonitor = BatteryMonitor()

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
