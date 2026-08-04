import Foundation
import Combine
import AppKit


class DeviceStateMonitor: ObservableObject {


    @Published var isLocked = false

    @Published var isScreenOn = true

    @Published var isSleeping = false



    init() {

        setupNotifications()

    }



    deinit {

        DistributedNotificationCenter.default().removeObserver(self)

        NSWorkspace.shared.notificationCenter.removeObserver(self)

    }



    private func setupNotifications() {


        let distributed =
        DistributedNotificationCenter.default()



        distributed.addObserver(
            self,
            selector: #selector(screenLocked),
            name:
                NSNotification.Name(
                    "com.apple.screenIsLocked"
                ),
            object: nil
        )



        distributed.addObserver(
            self,
            selector: #selector(screenUnlocked),
            name:
                NSNotification.Name(
                    "com.apple.screenIsUnlocked"
                ),
            object: nil
        )
        
        let workspace =
        NSWorkspace.shared.notificationCenter



        workspace.addObserver(
            self,
            selector: #selector(
                didSleep
            ),
            name:
                NSWorkspace
                .willSleepNotification,
            object: nil
        )



        workspace.addObserver(
            self,
            selector: #selector(
                didWake
            ),
            name:
                NSWorkspace
                .didWakeNotification,
            object: nil
        )


    }



    @objc private func didSleep() {

        DispatchQueue.main.async {

            self.isSleeping = true

        }

    }

    @objc private func screenLocked() {

        DispatchQueue.main.async {

            self.isLocked = true

        }

    }



    @objc private func screenUnlocked() {

        DispatchQueue.main.async {

            self.isLocked = false

        }

    }
    
    
    

    @objc private func didWake() {

        DispatchQueue.main.async {

            self.isSleeping = false

        }

    }



    func canMonitor() -> Bool {

        return
            !isLocked &&
            !isSleeping &&
            isScreenOn

    }


}
