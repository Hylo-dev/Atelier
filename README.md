# Atelier

A native Apple wardrobe management app built with SwiftUI and SwiftData. Atelier lets you catalog your entire clothing collection, build outfits from your inventory, scan garment care labels with on-device CoreML, and even generate 3D models of your garments through photogrammetry — all running fully offline on iPhone, iPad, and Mac.

## What It Does

- **Wardrobe Inventory** — Add, edit, filter, and browse your garments with full metadata (category, brand, color, season, material, purchase date, and more). Images are stored locally via a dedicated `ImageStorage` layer.
- **Outfit Builder** — Compose outfits by picking garments from your inventory. Filter by season, tag them, and keep track of what goes well together.
- **Care Label Scanner** — Point your camera at a laundry care symbol. A bundled CoreML model classifies it on-device, no network needed.
- **3D Garment Capture** — Capture photos from your iPhone and send them over Multipeer Connectivity to a Mac, which runs a full `PhotogrammetrySession` (RealityKit Object Capture) to generate a `.usdz` 3D model of the garment.

## Tech Stack

| Layer | What's used |
|---|---|
| **UI** | SwiftUI (iOS/macOS 26+), adaptive `TabView` + `NavigationSplitView` layout |
| **Persistence** | SwiftData (`ModelContainer` with `Garment`, `Outfit`, `LaundrySession` schemas) |
| **ML** | CoreML — custom-trained image classifier |
| **3D Pipeline** | RealityKit `PhotogrammetrySession` (macOS), Multipeer Connectivity for iOS-to-Mac photo transfer |
| **Observation** | Swift `@Observable` macro throughout |
| **Architecture** | Feature-based modules, domain layer with models/enums/filters/managers, reusable UI components |

## Architecture Overview

The app follows a **feature-based architecture** with a clean separation between domain logic and presentation:

- **Domain layer** holds all SwiftData models, enums, filter configurations, and manager classes. It has zero UI imports and is fully testable in isolation.
- **Feature modules** are self-contained vertical slices (Inventory, OutfitBuilder, Scanner, Care), each owning their views and feature-specific logic.
- **Core** contains cross-cutting infrastructure — right now that's the 3D capture pipeline (photogrammetry + Multipeer Connectivity).
- **Components** are generic, reusable UI pieces shared across features.

State management uses Swift's native `@Observable` macro (Observation framework), with `@State`, `@Bindable`, and `@Environment` — no third-party reactive frameworks.

## Platform-Specific Behavior

The codebase compiles for both iOS and macOS using `#if os(iOS)` / `#if os(macOS)` conditional compilation:

| Feature | iOS | macOS |
|---|---|---|
| Camera capture | AVCaptureSession, photo capture to disk | N/A |
| Multipeer role | Advertiser (waits for Mac to connect) | Browser (scans for iPhones) |
| Photogrammetry | Sends photos to Mac | Runs `PhotogrammetrySession`, outputs `.usdz` |
| Layout | `TabView` bottom tabs | `NavigationSplitView` sidebar |

The `HomeView` detects `horizontalSizeClass` and switches between a compact tab layout and a regular sidebar layout automatically, so on iPad in split-screen it degrades gracefully.

## 3D Capture Pipeline

This is the most technically interesting piece. Here's the flow:

1. **iPhone** — The user takes 10-20+ photos of a garment using `CameraView`. Each photo is compressed to JPEG (0.7 quality) and saved to the documents directory.
2. **Transfer** — `MultipeerManager` establishes an encrypted peer-to-peer connection (Multipeer Connectivity, service type `"atelier"`). The iPhone sends all photos as resources, then fires an `"END_BATCH"` data message.
3. **Mac** — `CaptureManager` receives each file, moves it to `Atelier_Scans/Input/`. When `"END_BATCH"` arrives, `readyToProcess` flips to `true`.
4. **Reconstruction** — On the Mac, `startReconstruction()` initializes a RealityKit `PhotogrammetrySession` with `.full` detail, streams progress updates, and outputs a timestamped `.usdz` file to `Atelier_Models/`.

The whole pipeline requires zero cloud services. Everything stays on your local network.

## Requirements

- **Xcode 26+**
- **iOS 26+** / **macOS 14+**
- **Swift 6+** 
- A physical iPhone is required for camera features and Multipeer Connectivity (Simulator won't cut it for the 3D pipeline)

## Getting Started

```bash
git clone https://github.com/Hylo-dev/Atelier.git
```

Open `Atelier.xcodeproj` in Xcode, select your target (iOS or macOS), and hit Run. SwiftData handles the local database automatically on first launch — no migrations, no setup scripts.

For the 3D capture flow, run the macOS target on your Mac and the iOS target on your iPhone. They'll discover each other over Multipeer Connectivity automatically.

## License

[Mozilla Public License 2.0](LICENSE)
