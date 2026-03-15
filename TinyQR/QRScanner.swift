import Vision
import AppKit
import CoreGraphics

enum QRScanner {
    static func scan() async -> ScanState {
        // Stage 1: clipboard image
        if let img = clipboardCGImage() {
            let urls = detectQR(in: img)
            if !urls.isEmpty { return .found(urls) }
        }

        // Stage 2: full-screen screenshot
        guard CGPreflightScreenCaptureAccess() else {
            CGRequestScreenCaptureAccess()   // shows system permission dialog
            return .notFound
        }
        if let img = CGDisplayCreateImage(CGMainDisplayID()) {
            let urls = detectQR(in: img)
            if !urls.isEmpty { return .found(urls) }
        }

        return .notFound
    }

    private static func clipboardCGImage() -> CGImage? {
        let pb = NSPasteboard.general
        guard let data = pb.data(forType: .tiff) ?? pb.data(forType: .png) else { return nil }
        return NSImage(data: data)?.cgImage(forProposedRect: nil, context: nil, hints: nil)
    }

    private static func detectQR(in cgImage: CGImage) -> [URL] {
        var found: [URL] = []
        let request = VNDetectBarcodesRequest()
        request.symbologies = [.qr]
        let handler = VNImageRequestHandler(cgImage: cgImage)
        try? handler.perform([request])
        found = (request.results ?? [])
            .compactMap { $0.payloadStringValue }
            .compactMap { URL(string: $0) }
        return found
    }
}
