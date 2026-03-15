import SwiftUI
import ServiceManagement

enum ScanState {
    case idle
    case scanning
    case found([URL])
    case notFound
}

struct MenuBarView: View {
    @State private var state: ScanState = .idle
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    var body: some View {
        VStack(spacing: 0) {
            scanSection
            Divider()
            settingsSection
        }
        .frame(width: 320)
    }

    @ViewBuilder
    private var scanSection: some View {
        switch state {
        case .idle:
            rowButton("Scan QR Code", icon: "qrcode.viewfinder") {
                Task { await scan() }
            }

        case .scanning:
            HStack(spacing: 8) {
                ProgressView().scaleEffect(0.7).frame(width: 16, height: 16)
                Text("Scanning…").foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)

        case .found(let urls):
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(Array(urls.enumerated()), id: \.offset) { i, url in
                            urlRow(url: url)
                            if i < urls.count - 1 { Divider() }
                        }
                    }
                }
                .frame(maxHeight: 180)
                Divider()
                rowButton("Scan Again", icon: "arrow.clockwise") {
                    Task { await scan() }
                }
            }

        case .notFound:
            HStack(spacing: 8) {
                Image(systemName: "xmark.circle")
                    .foregroundStyle(.secondary)
                    .frame(width: 16, height: 16)
                Text("No QR code found")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
        }
    }

    private func urlRow(url: URL) -> some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(url.host(percentEncoded: false) ?? url.absoluteString)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
                Text(url.absoluteString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            Spacer(minLength: 8)
            Button {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(url.absoluteString, forType: .string)
            } label: {
                Image(systemName: "doc.on.doc")
            }
            .buttonStyle(.borderless)
            .help("Copy URL")
            Button("Open") {
                NSWorkspace.shared.open(url)
            }
            .controlSize(.small)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var settingsSection: some View {
        Toggle("Launch at Login", isOn: $launchAtLogin)
            .toggleStyle(.checkbox)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .onChange(of: launchAtLogin) { enabled in
                do {
                    if enabled {
                        try SMAppService.mainApp.register()
                    } else {
                        try SMAppService.mainApp.unregister()
                    }
                } catch {
                    launchAtLogin = SMAppService.mainApp.status == .enabled
                }
            }

        Divider()

        Button {
            NSApplication.shared.terminate(nil)
        } label: {
            Text("Quit TinyQR")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .keyboardShortcut("q", modifiers: .command)
    }

    private func rowButton(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
