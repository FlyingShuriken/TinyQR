import SwiftUI

enum ScanState {
    case idle
    case scanning
    case found([URL])
    case notFound
}

struct MenuBarView: View {
    @State private var state: ScanState = .idle

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            switch state {
            case .idle:
                Button("Scan QR Code") { Task { await scan() } }
                    .padding()

            case .scanning:
                HStack(spacing: 8) {
                    ProgressView().scaleEffect(0.7)
                    Text("Scanning...").foregroundStyle(.secondary)
                }
                .padding()

            case .found(let urls):
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(Array(urls.enumerated()), id: \.offset) { _, url in
                            HStack {
                                Text(url.absoluteString)
                                    .lineLimit(1).truncationMode(.middle)
                                    .font(.system(size: 12))
                                Spacer()
                                Button("Open") { NSWorkspace.shared.open(url) }
                                    .controlSize(.small)
                            }
                            .padding(.horizontal, 12).padding(.vertical, 8)
                            Divider()
                        }
                    }
                }
                .frame(maxHeight: 200)
                Button("Scan Again") { Task { await scan() } }
                    .padding()

            case .notFound:
                Text("No QR code found")
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
        .frame(width: 320)
    }

    private func scan() async {
        state = .scanning
        state = await QRScanner.scan()
        if case .notFound = state {
            try? await Task.sleep(for: .seconds(2))
            state = .idle
        }
    }
}
