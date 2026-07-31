import Foundation
import Combine
import IOKit.ps


class BatteryMonitor: ObservableObject {


    @Published var batteryLevel: Double = 100

    @Published var isCharging: Bool = false



    init() {

        update()

    }



    func update() {


        guard let info =
                IOPSCopyPowerSourcesInfo()?.takeRetainedValue()
        else {
            return
        }



        guard let sources =
                IOPSCopyPowerSourcesList(info)?
                .takeRetainedValue() as? [CFTypeRef]
        else {
            return
        }



        for source in sources {


            guard let description =
                    IOPSGetPowerSourceDescription(
                        info,
                        source
                    )?
                    .takeUnretainedValue()
                    as? [String: AnyObject]
            else {
                continue
            }



            if let capacity =
                description[
                    kIOPSCurrentCapacityKey
                ] as? Int {


                batteryLevel =
                Double(capacity)

            }



            if let charging =
                description[
                    kIOPSIsChargingKey
                ] as? Bool {


                isCharging = charging

            }

        }

    }

}
