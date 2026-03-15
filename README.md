# TinyQR

A minimal macOS menu bar app that detects QR codes from your clipboard or screen.

## Usage

Click the `⊡` icon in the menu bar, then hit **Scan QR Code**.

- **Clipboard first** — if you have a QR code image copied, it scans that instantly
- **Screen fallback** — if the clipboard has no image, it captures your screen and scans for any visible QR code (requires Screen Recording permission on first run)

Found URLs appear with **Copy** and **Open** buttons. Auto-dismisses after 2 seconds if nothing is found.

## Requirements

- macOS 13.0+
- Screen Recording permission (for screen fallback — optional)

## Building

Open `TinyQR.xcodeproj` in Xcode and press **⌘R**.

## Installation

Download `TinyQR.zip` from [Releases](../../releases), unzip, and drag to `/Applications`.

> **First launch:** right-click the app → **Open** to bypass Gatekeeper, or run:
>
> ```bash
> xattr -cr /Applications/TinyQR.app
> ```

## Settings

| Setting         | Description                                |
| --------------- | ------------------------------------------ |
| Launch at Login | Start TinyQR automatically when you log in |
| Quit TinyQR     | ⌘Q                                         |
