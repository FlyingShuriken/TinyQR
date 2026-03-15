import SwiftUI

@main
struct TinyQRApp: App {
    var body: some Scene {
        MenuBarExtra("TinyQR", systemImage: "qrcode.viewfinder") {
            MenuBarView()
        }
        .menuBarExtraStyle(.window)
    }
}
