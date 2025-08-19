# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a SwiftUI-based macOS application for video encoding. The project uses Swift with SwiftUI for the UI framework and SwiftData for persistence.

## Development Commands

### Building the Project
```bash
# Build using Xcode command line tools
xcodebuild -project video-encoder.xcodeproj -scheme video-encoder -configuration Debug build

# Build for release
xcodebuild -project video-encoder.xcodeproj -scheme video-encoder -configuration Release build
```

### Running Tests
```bash
# Run unit tests
xcodebuild test -project video-encoder.xcodeproj -scheme video-encoder -destination 'platform=macOS'

# Run UI tests
xcodebuild test -project video-encoder.xcodeproj -scheme video-encoderUITests -destination 'platform=macOS'

# Run a specific test
xcodebuild test -project video-encoder.xcodeproj -scheme video-encoder -destination 'platform=macOS' -only-testing:video-encoderTests/video_encoderTests/example
```

### Cleaning the Build
```bash
xcodebuild clean -project video-encoder.xcodeproj -scheme video-encoder
```

## Architecture

### Core Components

- **video_encoderApp.swift**: Main app entry point that sets up the SwiftUI app with SwiftData model container
- **ContentView.swift**: Primary UI view with navigation split view pattern for managing items
- **Item.swift**: SwiftData model representing items with timestamps

### Key Technologies

- **SwiftUI**: Modern declarative UI framework for building the interface
- **SwiftData**: Apple's persistence framework for data storage
- **Testing Framework**: Uses Swift Testing (`@Test`) for unit tests and XCTest for UI tests

### Project Structure

The app follows standard Xcode project organization:
- Main app code in `video-encoder/` directory
- Unit tests using Swift Testing framework in `video-encoderTests/`
- UI tests using XCTest framework in `video-encoderUITests/`
- Assets and app configuration in `Assets.xcassets` and entitlements file

### Data Flow

The app uses SwiftData with a `ModelContainer` that manages `Item` objects. The container is injected into the SwiftUI environment and accessed via `@Environment(\.modelContext)` and `@Query` property wrappers for reactive data updates.