import Foundation
import ScreenCaptureKit
import AppKit
import Combine


enum ScreenCaptureError: Error {

    case permissionDenied

    case noDisplayAvailable

    case captureFailed

    case encodingFailed

}


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



    /// Captures the primary display, downscales it to `maxWidth`, and
    /// returns it as compressed JPEG data — suitable for handing off to a
    /// vision model. Nothing consumes this yet; it exists so a future
    /// setting can wire it up without touching this service again.
    func captureJPEG(
        maxWidth: Int,
        quality: CGFloat
    ) async throws -> Data {


        guard CGPreflightScreenCaptureAccess() else {

            throw ScreenCaptureError.permissionDenied

        }


        let content: SCShareableContent


        do {

            content =
                try await
                SCShareableContent
                    .current

        }
        catch {

            throw ScreenCaptureError.permissionDenied

        }


        guard let display =
                content.displays.first

        else {

            throw ScreenCaptureError.noDisplayAvailable

        }


        let filter =
            SCContentFilter(
                display: display,
                excludingWindows: []
            )


        let configuration =
            SCStreamConfiguration()


        let targetWidth = min(maxWidth, display.width)

        let scale =
            CGFloat(targetWidth) / CGFloat(display.width)

        let targetHeight =
            max(1, Int(CGFloat(display.height) * scale))


        configuration.width = targetWidth

        configuration.height = targetHeight

        configuration.pixelFormat =
            kCVPixelFormatType_32BGRA


        let image: CGImage


        do {

            image =
                try await
                SCScreenshotManager
                    .captureImage(
                        contentFilter: filter,
                        configuration: configuration
                    )

        }
        catch {

            throw ScreenCaptureError.captureFailed

        }


        let nsImage =
            NSImage(
                cgImage: image,
                size: NSSize(
                    width: image.width,
                    height: image.height
                )
            )


        guard let tiffData = nsImage.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let jpegData = bitmap.representation(
                using: .jpeg,
                properties: [.compressionFactor: quality]
              )

        else {

            throw ScreenCaptureError.encodingFailed

        }


        await MainActor.run {

            self.latestScreenshot = nsImage

        }


        return jpegData

    }

}
