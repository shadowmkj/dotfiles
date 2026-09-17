import Foundation
import AppKit

class AirDropDelegate: NSObject, NSSharingServiceDelegate {
    func sharingService(_ sharingService: NSSharingService, didShareItems items: [Any]) {
        NSApp.terminate(nil)
    }
    func sharingService(_ sharingService: NSSharingService, didFailToShareItems items: [Any], error: Error) {
        NSApp.terminate(nil)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    let delegate = AirDropDelegate()

    func applicationDidFinishLaunching(_ notification: Notification) {
        let args = CommandLine.arguments
        guard args.count > 1 else {
            print("Usage: airdrop <file-path>")
            NSApp.terminate(nil)
            return
        }

        let filePath = (args[1] as NSString).expandingTildeInPath
        let url = URL(fileURLWithPath: filePath)

        guard FileManager.default.fileExists(atPath: url.path) else {
            print("Error: File not found at '\(url.path)'")
            NSApp.terminate(nil)
            return
        }

        guard let service = NSSharingService(named: .sendViaAirDrop) else {
            print("Error: AirDrop service unavailable.")
            NSApp.terminate(nil)
            return
        }

        service.delegate = delegate

        if service.canPerform(withItems: [url]) {
            service.perform(withItems: [url])
        } else {
            print("Error: AirDrop cannot share this file.")
            NSApp.terminate(nil)
        }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
