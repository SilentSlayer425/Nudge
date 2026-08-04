import Foundation
import Combine
import IOKit.ps


class BatteryMonitor: ObservableObject {


    @Published var batteryLevel: Double = 100

    @Published var isCharging: Bool = false


    private var timer: Timer?

    private var runLoopSource: CFRunLoopSource?



    init() {

        update()

    }



    deinit {

        timer?.invalidate()


        if let runLoopSource {

            CFRunLoopRemoveSource(
                CFRunLoopGetCurrent(),
                runLoopSource,
                .defaultMode
            )

        }

    }



    func startMonitoring() {

        stopMonitoring()

        update()


        timer = Timer.scheduledTimer(
            withTimeInterval: 30,
            repeats: true
        ) { [weak self] _ in

            DispatchQueue.main.async {

                self?.update()

            }

        }


        // Must be passed by value. Passing `&context` would hand IOKit a
        // pointer to this stack slot, which dies when the function returns.
        let context = UnsafeMutableRawPointer(
            Unmanaged.passUnretained(self).toOpaque()
        )


        guard let sourceRef = IOPSNotificationCreateRunLoopSource(
            { pointer in

                guard let pointer else {

                    return

                }


                let monitor =
                    Unmanaged<BatteryMonitor>
                        .fromOpaque(pointer)
                        .takeUnretainedValue()


                DispatchQueue.main.async {

                    monitor.update()

                }

            },
            context
        )
        else {

            return

        }


        let source = sourceRef.takeRetainedValue()

        runLoopSource = source

        CFRunLoopAddSource(
            CFRunLoopGetCurrent(),
            source,
            .defaultMode
        )

    }



    func stopMonitoring() {

        timer?.invalidate()

        timer = nil


        if let runLoopSource {

            CFRunLoopRemoveSource(
                CFRunLoopGetCurrent(),
                runLoopSource,
                .defaultMode
            )

            self.runLoopSource = nil

        }

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
