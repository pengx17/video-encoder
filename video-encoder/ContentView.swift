//
//  ContentView.swift
//  video-encoder
//

import SwiftUI
import UniformTypeIdentifiers
import AVKit

struct ContentView: View {
    @StateObject private var viewModel = VideoEncoderViewModel()
    @State private var isDragging = false
    @State private var isHoveringDropZone = false
    
    var body: some View {
        ZStack {
            // Transparent background with glass effect
            Color.clear
                .ignoresSafeArea()
                .background(.ultraThinMaterial)
                .background(WindowAccessor())
            
            VStack(spacing: 0) {
                // Custom title bar area
                HStack {
                    // Traffic light buttons area - leave space for them
                    Color.clear
                        .frame(width: 70, height: 28)
                    
                    Spacer()
                }
                .frame(height: 28)
                .background(Color.clear)
                
                // Main content
                VStack(spacing: 24) {
                    if !viewModel.ffmpegAvailable {
                        ffmpegMissingView
                    } else {
                        // App Header
                        appHeader
                        
                        if viewModel.inputVideoURL == nil {
                            dropArea
                        } else {
                            videoLoadedContent
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 10)
                .padding(.bottom, 50)
                
                Spacer(minLength: 0)
                
                // Footer with glass effect
                if viewModel.ffmpegAvailable && !viewModel.ffmpegVersion.isEmpty {
                    VStack(spacing: 0) {
                        Divider()
                        ffmpegInfoFooter
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                    }
                    .background(.thinMaterial)
        .cornerRadius(12)
                }
            }
        }
        .frame(minWidth: 700, idealWidth: 700)
        .fixedSize(horizontal: false, vertical: true)
    }
    
    private var appHeader: some View {
        HStack {
            Image(systemName: "video.badge.waveform")
                .font(.system(size: 32))
                .foregroundStyle(Color.accentColor)
                .symbolRenderingMode(.hierarchical)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Video Encoder")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Text("Compress and convert your videos with ease")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(.thinMaterial)
        .cornerRadius(16)
    }
    
    private var videoLoadedContent: some View {
        VStack(spacing: 20) {
            // Mini drop zone with glass effect
            miniDropZone
            
            videoPreviewSection
            
            // Video info and encoding options
            videoInfoSection
            encodingOptionsSection
            
            actionButtons
            
            if viewModel.encodingState == .encoding {
                progressSection
            }
            
            if case .completed = viewModel.encodingState {
                completionSection
            }
            
            if case .failed(let error) = viewModel.encodingState {
                errorSection(error)
            }
        }
    }
    
    private var miniDropZone: some View {
        HStack {
            Image(systemName: "film.stack")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Text(viewModel.inputVideoURL?.lastPathComponent ?? "")
                .font(.system(size: 14, weight: .medium))
                .lineLimit(1)
                .truncationMode(.middle)
            
            Spacer()
            
            Button(action: { clearVideo() }) {
                Label("Change Video", systemImage: "arrow.triangle.2.circlepath")
                    .font(.system(size: 13))
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(16)
        .background(.thinMaterial)
        .cornerRadius(12)
    }
    
    private var ffmpegMissingView: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.orange)
                .symbolRenderingMode(.hierarchical)
            
            VStack(spacing: 8) {
                Text("FFmpeg Not Found")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                
                Text("FFmpeg is required to encode videos")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 16) {
                Text("Install FFmpeg via Homebrew:")
                    .font(.system(size: 14, weight: .semibold))
                
                HStack(spacing: 12) {
                    Text("brew install ffmpeg")
                        .font(.system(size: 14, design: .monospaced))
                        .padding(12)
                        .background(.thinMaterial)
                        .cornerRadius(8)
                    
                    Button(action: {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString("brew install ffmpeg", forType: .string)
                    }) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 14))
                    }
                    .buttonStyle(.bordered)
                }
                
                Link(destination: URL(string: "https://brew.sh")!) {
                    Label("Get Homebrew", systemImage: "arrow.up.forward.app")
                        .font(.system(size: 13))
                }
                .buttonStyle(.link)
            }
            .padding(24)
            .background(.thinMaterial)
        .cornerRadius(12)
            
            Button(action: { viewModel.findFFmpeg() }) {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: 500)
    }
    
    private var ffmpegInfoFooter: some View {
        HStack {
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(.green)
                .font(.system(size: 14))
            Text(viewModel.ffmpegVersion)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .lineLimit(1)
            Spacer()
            if let path = viewModel.ffmpegPath {
                Text(path)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(Color.secondary.opacity(0.7))
                    .lineLimit(1)
            }
        }
    }
    
    private var videoPreviewSection: some View {
        Group {
            if let url = viewModel.inputVideoURL {
                ZStack {
                    // Background
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black)
                        .frame(height: 220)
                    
                    if let thumbnail = generateThumbnail(for: url) {
                        Image(nsImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 220)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "video.slash")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            Text("Preview unavailable")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Play button overlay with glass effect
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(radius: 10)
                }
            }
        }
    }
    
    private func generateThumbnail(for url: URL) -> NSImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 1, preferredTimescale: 60)
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
        } catch {
            print("Failed to generate thumbnail: \(error)")
            return nil
        }
    }
    
    private var dropArea: some View {
        VStack(spacing: 24) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isDragging ? Color.accentColor : Color.secondary.opacity(0.3),
                                style: StrokeStyle(lineWidth: 2, dash: isDragging ? [] : [12, 8])
                            )
                    )
                    .animation(.easeInOut(duration: 0.2), value: isDragging)
                    .scaleEffect(isHoveringDropZone ? 1.02 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isHoveringDropZone)
                
                VStack(spacing: 20) {
                    // Icon with glass badge
                    ZStack {
                        Circle()
                            .fill(.thinMaterial)
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "arrow.down.doc.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(Color.accentColor)
                            .symbolRenderingMode(.hierarchical)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Drop your video here")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("or click to browse")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: { selectFile() }) {
                        Label("Choose Video", systemImage: "folder")
                            .frame(width: 140)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    Text("Supports MP4, MOV, AVI, MKV and more")
                        .font(.system(size: 12))
                        .foregroundColor(Color.secondary.opacity(0.7))
                }
                .padding(40)
            }
            .frame(height: 280)
            .onDrop(of: [.movie, .quickTimeMovie, .mpeg4Movie], isTargeted: $isDragging) { providers in
                handleDrop(providers: providers)
            }
            .onHover { hovering in
                isHoveringDropZone = hovering
            }
        }
    }
    
    private var videoInfoSection: some View {
        VStack(spacing: 16) {
            HStack {
                Label("Video Information", systemImage: "info.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            HStack(spacing: 24) {
                InfoPill(icon: "doc", label: "Size", value: viewModel.inputFileSize)
                
                if viewModel.videoDuration > 0 {
                    InfoPill(icon: "clock", label: "Duration", value: formatDuration(viewModel.videoDuration))
                }
                
                if !viewModel.videoResolution.isEmpty {
                    InfoPill(icon: "aspectratio", label: "Resolution", value: viewModel.videoResolution)
                }
                
                if viewModel.videoFPS > 0 {
                    InfoPill(icon: "speedometer", label: "FPS", value: "\(Int(viewModel.videoFPS))")
                }
            }
        }
        .padding(20)
        .background(.thinMaterial)
        .cornerRadius(16)
    }
    
    private var encodingOptionsSection: some View {
        VStack(spacing: 20) {
            HStack {
                Label("Encoding Settings", systemImage: "slider.horizontal.3")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                if !viewModel.estimatedOutputSize.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 14))
                        Text(viewModel.estimatedOutputSize)
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.accentColor)
                    .cornerRadius(20)
                }
            }
            
            VStack(spacing: 16) {
                OptionRow(label: "Codec", icon: "cpu") {
                    Picker("", selection: $viewModel.selectedCodec) {
                        ForEach(VideoCodec.allCases, id: \.self) { codec in
                            Text(codec.displayName).tag(codec)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 200)
                }
                
                OptionRow(label: "Quality Preset", icon: "dial.high") {
                    Picker("", selection: $viewModel.selectedPreset) {
                        ForEach(VideoPreset.allCases, id: \.self) { preset in
                            Text(preset.displayName).tag(preset)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 200)
                }
                
                OptionRow(label: "Frame Rate", icon: "timer") {
                    Picker("", selection: $viewModel.selectedFPS) {
                        ForEach(FPSOption.allCases, id: \.self) { fps in
                            Text(fps.displayName).tag(fps)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 200)
                }
                
                OptionRow(label: "Playback Speed", icon: "gauge.with.dots.needle.67percent") {
                    Picker("", selection: $viewModel.selectedSpeed) {
                        ForEach(PlaybackSpeed.allCases, id: \.self) { speed in
                            Text(speed.displayName).tag(speed)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 200)
                }
                
                OptionRow(label: "Bitrate (kbps)", icon: "gauge.with.dots.needle.bottom.50percent") {
                    TextField("2000", text: $viewModel.targetBitrate)
                        .frame(width: 200)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: viewModel.targetBitrate) { _ in
                            viewModel.calculateEstimatedSize()
                        }
                }
                
                // Crop settings with glass effect
                DisclosureGroup(isExpanded: $viewModel.cropSettings.enabled) {
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Width")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                TextField("1920", text: $viewModel.cropSettings.width)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Height")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                TextField("1080", text: $viewModel.cropSettings.height)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("X Position")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                TextField("0", text: $viewModel.cropSettings.x)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Y Position")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                TextField("0", text: $viewModel.cropSettings.y)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                        }
                        
                        Text("Tip: Use width and height to set crop size, X and Y to set position")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.top, 8)
                } label: {
                    HStack {
                        Image(systemName: "crop")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        Text("Crop Video")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        Spacer()
                        Toggle("", isOn: $viewModel.cropSettings.enabled)
                            .labelsHidden()
                            .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                            .scaleEffect(0.8)
                    }
                    .padding(.vertical, 4)
                }
                
                OptionRow(label: "Advanced", icon: "terminal") {
                    TextField("e.g., -crf 23", text: $viewModel.customFFmpegOptions)
                        .frame(width: 200)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
        }
        .padding(20)
        .background(.thinMaterial)
        .cornerRadius(16)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: { clearVideo() }) {
                Label("Clear", systemImage: "xmark.circle")
                    .frame(width: 100)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            
            Spacer()
            
            Button(action: { viewModel.startEncoding() }) {
                Label("Start Encoding", systemImage: "play.fill")
                    .frame(width: 160)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(viewModel.encodingState == .encoding)
        }
    }
    
    private var progressSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "gearshape.2.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.accentColor)
                    .rotationEffect(.degrees(viewModel.encodingProgress * 360))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: viewModel.encodingState == .encoding)
                
                Text("Encoding in progress...")
                    .font(.system(size: 16, weight: .medium))
                
                Spacer()
                
                Text("\(Int(viewModel.encodingProgress * 100))%")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.accentColor)
            }
            
            ProgressView(value: viewModel.encodingProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
                .scaleEffect(y: 2)
            
            HStack {
                Text(viewModel.estimatedTimeRemaining)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Cancel") {
                    viewModel.cancelEncoding()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding(20)
        .background(.thinMaterial)
        .cornerRadius(16)
        .cornerRadius(16)
    }
    
    private var completionSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Encoding Complete!")
                        .font(.system(size: 18, weight: .semibold))
                    if !viewModel.outputFileSize.isEmpty {
                        Text("Output size: \(viewModel.outputFileSize)")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                Button(action: { viewModel.openOutputFolder() }) {
                    Label("Show in Finder", systemImage: "folder")
                        .frame(width: 140)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button(action: { clearVideo() }) {
                    Label("Encode Another", systemImage: "arrow.clockwise")
                        .frame(width: 140)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
        .padding(20)
        .background(.thinMaterial)
        .cornerRadius(16)
        .cornerRadius(16)
    }
    
    private func errorSection(_ error: String) -> some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.red)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Encoding Failed")
                        .font(.system(size: 18, weight: .semibold))
                    Text(error)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            
            Button(action: { viewModel.encodingState = .idle }) {
                Label("Try Again", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        .padding(20)
        .background(.thinMaterial)
        .cornerRadius(16)
        .cornerRadius(16)
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        
        provider.loadItem(forTypeIdentifier: UTType.movie.identifier, options: nil) { item, error in
            if let url = item as? URL {
                DispatchQueue.main.async {
                    viewModel.loadVideo(from: url)
                }
            } else if let data = item as? Data {
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
                do {
                    try data.write(to: tempURL)
                    DispatchQueue.main.async {
                        viewModel.loadVideo(from: tempURL)
                    }
                } catch {
                    print("Failed to save dropped file: \(error)")
                }
            }
        }
        
        return true
    }
    
    private func selectFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.movie, .quickTimeMovie, .mpeg4Movie, .avi]
        panel.allowsMultipleSelection = false
        
        if panel.runModal() == .OK, let url = panel.url {
            viewModel.loadVideo(from: url)
        }
    }
    
    private func clearVideo() {
        viewModel.inputVideoURL = nil
        viewModel.outputVideoURL = nil
        viewModel.encodingState = .idle
        viewModel.encodingProgress = 0.0
        viewModel.inputFileSize = ""
        viewModel.outputFileSize = ""
        viewModel.estimatedOutputSize = ""
        viewModel.videoResolution = ""
        viewModel.videoFPS = 0
        viewModel.selectedSpeed = .speed1
        viewModel.cropSettings = CropSettings()
    }
    
    private func formatDuration(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
}

// Window accessor to enable drag-to-move functionality
struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                window.isMovableByWindowBackground = true
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
                window.styleMask.insert(.fullSizeContentView)
                // Make window transparent with glass effect
                window.backgroundColor = NSColor.clear
                window.isOpaque = false
                window.hasShadow = true
            }
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            if let window = nsView.window {
                window.isMovableByWindowBackground = true
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
                window.styleMask.insert(.fullSizeContentView)
                // Make window transparent with glass effect
                window.backgroundColor = NSColor.clear
                window.isOpaque = false
                window.hasShadow = true
            }
        }
    }
}

// Helper Views
struct InfoPill: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(Color.secondary.opacity(0.7))
                Text(value)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .cornerRadius(8)
    }
}

struct OptionRow<Content: View>: View {
    let label: String
    let icon: String
    let content: () -> Content
    
    var body: some View {
        HStack {
            Label(label, systemImage: icon)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .frame(width: 140, alignment: .leading)
            
            Spacer()
            
            content()
        }
        .padding(.vertical, 4)
    }
}