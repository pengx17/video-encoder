//
//  VideoEncoderViewModel.swift
//  video-encoder
//

import SwiftUI
import Foundation
import AVFoundation
import AppKit

@MainActor
class VideoEncoderViewModel: ObservableObject {
    @Published var inputVideoURL: URL?
    @Published var outputVideoURL: URL?
    @Published var encodingState: EncodingState = .idle
    @Published var encodingProgress: Double = 0.0
    @Published var inputFileSize: String = ""
    @Published var outputFileSize: String = ""
    @Published var estimatedOutputSize: String = ""
    @Published var videoResolution: String = ""
    @Published var videoFPS: Double = 0
    @Published var videoDuration: Double = 0
    @Published var ffmpegAvailable: Bool = false
    @Published var ffmpegVersion: String = "Checking..."
    @Published var ffmpegPath: String?
    @Published var estimatedTimeRemaining: String = ""
    
    // Encoding options
    @Published var selectedCodec: VideoCodec = .h264
    @Published var selectedPreset: VideoPreset = .medium
    @Published var selectedFPS: FPSOption = .keep
    @Published var selectedSpeed: PlaybackSpeed = .speed1
    @Published var targetBitrate: String = "2000"
    @Published var customFFmpegOptions: String = ""
    @Published var cropSettings = CropSettings()
    
    init() {
        findFFmpeg()
    }
    
    func findFFmpeg() {
        Task {
            await findFFmpegAsync()
        }
    }
    
    private func findFFmpegAsync() async {
        // Check if ffmpeg is available in common locations
        let possiblePaths = [
            "/opt/homebrew/bin/ffmpeg",
            "/usr/local/bin/ffmpeg",
            "/usr/bin/ffmpeg"
        ]
        
        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path) {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: path)
                process.arguments = ["-version"]
                process.standardOutput = Pipe()
                process.standardError = Pipe()
                
                do {
                    try process.run()
                    
                    // Don't block the main thread - check asynchronously
                    await withCheckedContinuation { continuation in
                        DispatchQueue.global(qos: .background).async {
                            process.waitUntilExit()
                            continuation.resume()
                        }
                    }
                    
                    if process.terminationStatus == 0 {
                        await MainActor.run {
                            self.ffmpegAvailable = true
                            self.ffmpegVersion = "FFmpeg (detected)"
                            self.ffmpegPath = path
                        }
                        return
                    }
                } catch {
                    continue
                }
            }
        }
        
        // No FFmpeg found
        await MainActor.run {
            self.ffmpegAvailable = false
            self.ffmpegVersion = "FFmpeg not found"
            self.ffmpegPath = nil
        }
    }
    
    func loadVideo(from url: URL) {
        inputVideoURL = url
        extractVideoInfo(from: url)
        calculateEstimatedSize()
    }
    
    private func extractVideoInfo(from url: URL) {
        let asset = AVAsset(url: url)
        
        // Get file size
        if let resourceValues = try? url.resourceValues(forKeys: [.fileSizeKey]),
           let fileSize = resourceValues.fileSize {
            inputFileSize = ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
        }
        
        // Get duration
        let duration = asset.duration
        if duration.isValid {
            videoDuration = CMTimeGetSeconds(duration)
        }
        
        // Get video track info
        if let videoTrack = asset.tracks(withMediaType: .video).first {
            let size = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
            videoResolution = "\(Int(abs(size.width)))x\(Int(abs(size.height)))"
            videoFPS = Double(videoTrack.nominalFrameRate)
        }
    }
    
    func calculateEstimatedSize() {
        guard videoDuration > 0, let bitrate = Int(targetBitrate) else {
            estimatedOutputSize = ""
            return
        }
        
        let estimatedBytes = (Double(bitrate) * 1000 * videoDuration) / 8
        estimatedOutputSize = ByteCountFormatter.string(fromByteCount: Int64(estimatedBytes), countStyle: .file)
    }
    
    func startEncoding() {
        guard let inputURL = inputVideoURL,
              let ffmpegPath = ffmpegPath else {
            encodingState = .failed("No input video or FFmpeg not found")
            return
        }
        
        encodingState = .encoding
        encodingProgress = 0.0
        
        Task {
            await performEncoding(inputURL: inputURL, ffmpegPath: ffmpegPath)
        }
    }
    
    private func performEncoding(inputURL: URL, ffmpegPath: String) async {
        // Generate output file path
        let inputFilename = inputURL.deletingPathExtension().lastPathComponent
        let outputFilename = "\(inputFilename)_encoded.mp4"
        let outputURL = inputURL.deletingLastPathComponent().appendingPathComponent(outputFilename)
        
        await MainActor.run {
            self.outputVideoURL = outputURL
        }
        
        // Build FFmpeg command
        var arguments = [
            "-i", inputURL.path,
            "-c:v", selectedCodec == .h264 ? "libx264" : selectedCodec == .h265 ? "libx265" : "libaom-av1",
            "-preset", selectedPreset.ffmpegValue,
            "-b:v", "\(targetBitrate)k"
        ]
        
        // Add FPS option if not keeping original
        if selectedFPS != .keep {
            let fps = selectedFPS == .fps24 ? "24" : selectedFPS == .fps30 ? "30" : "60"
            arguments.append(contentsOf: ["-r", fps])
        }
        
        // Add custom options if provided
        if !customFFmpegOptions.isEmpty {
            arguments.append(contentsOf: customFFmpegOptions.components(separatedBy: " "))
        }
        
        arguments.append(contentsOf: ["-y", outputURL.path]) // -y to overwrite
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: ffmpegPath)
        process.arguments = arguments
        
        let pipe = Pipe()
        process.standardError = pipe
        
        do {
            try process.run()
            
            // Monitor progress by parsing FFmpeg output
            let fileHandle = pipe.fileHandleForReading
            
            await withCheckedContinuation { continuation in
                DispatchQueue.global(qos: .background).async {
                    process.waitUntilExit()
                    continuation.resume()
                }
            }
            
            await MainActor.run {
                if process.terminationStatus == 0 {
                    // Get output file size
                    if let resourceValues = try? outputURL.resourceValues(forKeys: [.fileSizeKey]),
                       let fileSize = resourceValues.fileSize {
                        self.outputFileSize = ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
                    }
                    self.encodingState = .completed
                    self.encodingProgress = 1.0
                } else {
                    self.encodingState = .failed("Encoding failed with exit code \(process.terminationStatus)")
                }
            }
            
        } catch {
            await MainActor.run {
                self.encodingState = .failed("Failed to start encoding: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelEncoding() {
        encodingState = .idle
        encodingProgress = 0.0
        estimatedTimeRemaining = ""
    }
    
    func openOutputFolder() {
        guard let outputURL = outputVideoURL else {
            // Fallback to Downloads if no output file
            NSWorkspace.shared.open(FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!)
            return
        }
        
        // Check if the output file exists
        if FileManager.default.fileExists(atPath: outputURL.path) {
            // Select the file in Finder
            NSWorkspace.shared.activateFileViewerSelecting([outputURL])
        } else {
            // Open the containing folder if file doesn't exist
            NSWorkspace.shared.open(outputURL.deletingLastPathComponent())
        }
    }
}

enum EncodingState: Equatable {
    case idle
    case encoding
    case completed
    case failed(String)
}

enum VideoCodec: CaseIterable {
    case h264, h265, av1
    
    var displayName: String {
        switch self {
        case .h264: return "H.264"
        case .h265: return "H.265 (HEVC)"
        case .av1: return "AV1"
        }
    }
}

enum VideoPreset: CaseIterable {
    case ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow
    
    var displayName: String {
        switch self {
        case .ultrafast: return "Ultra Fast"
        case .superfast: return "Super Fast"
        case .veryfast: return "Very Fast"
        case .faster: return "Faster"
        case .fast: return "Fast"
        case .medium: return "Medium"
        case .slow: return "Slow"
        case .slower: return "Slower"
        case .veryslow: return "Very Slow"
        }
    }
    
    var ffmpegValue: String {
        switch self {
        case .ultrafast: return "ultrafast"
        case .superfast: return "superfast"
        case .veryfast: return "veryfast"
        case .faster: return "faster"
        case .fast: return "fast"
        case .medium: return "medium"
        case .slow: return "slow"
        case .slower: return "slower"
        case .veryslow: return "veryslow"
        }
    }
}

enum FPSOption: CaseIterable {
    case keep, fps24, fps30, fps60
    
    var displayName: String {
        switch self {
        case .keep: return "Keep Original"
        case .fps24: return "24 fps"
        case .fps30: return "30 fps"
        case .fps60: return "60 fps"
        }
    }
}

enum PlaybackSpeed: CaseIterable {
    case speed0_5, speed0_75, speed1, speed1_25, speed1_5, speed2
    
    var displayName: String {
        switch self {
        case .speed0_5: return "0.5x"
        case .speed0_75: return "0.75x"
        case .speed1: return "1x"
        case .speed1_25: return "1.25x"
        case .speed1_5: return "1.5x"
        case .speed2: return "2x"
        }
    }
}

struct CropSettings {
    var enabled: Bool = false
    var width: String = "1920"
    var height: String = "1080"
    var x: String = "0"
    var y: String = "0"
}
