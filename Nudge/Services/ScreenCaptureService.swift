import Foundation
import ScreenCaptureKit
import AppKit
import Combine


class ScreenCaptureService: ObservableObject {


    @Published var latestScreenshot:
        NSImage?



    func captureScreen() async {


        do {


            let content =
                try await
                SCShareableContent
                    .current



            guard let display =
                    content.displays.first

            else {

                return

            }



            let filter =
                SCContentFilter(
                    display: display,
                    excludingWindows: []
                )



            let configuration =
                SCStreamConfiguration()



            configuration.width =
                display.width



            configuration.height =
                display.height



            configuration.pixelFormat =
                kCVPixelFormatType_32BGRA



            let image =
                try await
                SCScreenshotManager
                    .captureImage(
                        contentFilter: filter,
                        configuration: configuration
                    )



            let nsImage =
                NSImage(
                    cgImage: image,
                    size: NSSize(
                        width: image.width,
                        height: image.height
                    )
                )



            DispatchQueue.main.async {

                self.latestScreenshot = nsImage

            }


        }
        catch {

            print(
                "Screenshot error:",
                error
            )

        }

    }

}
