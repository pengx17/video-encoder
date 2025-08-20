//
//  ContentView.swift
//  video-encoder
//

import AVKit
import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @ObservedObject var viewModel: VideoEncoderViewModel
    @State private var isDragging = false
    @State private var isHoveringDropZone = false

    var body: some View {
        mainContentView
    }

    private var mainContentView: some View {
        VStack(spacing: 0) {

            // Main content area
            VStack(spacing: 24) {
                if !viewModel.ffmpegAvailable {
                    ffmpegMissingView.padding(.bottom, 24)
                } else {
                    if viewModel.inputVideoURL == nil {
                        enhancedDropArea.padding(.top, 24)
                    } else {
                        videoLoadedContent
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)

            // Floating footer with enhanced glass effect
            if viewModel.ffmpegAvailable && !viewModel.ffmpegVersion.isEmpty {
                floatingFooter
            }
        }
        .frame(
            minWidth: viewModel.inputVideoURL != nil ? 1100 : 700,
            idealWidth: viewModel.inputVideoURL != nil ? 1100 : 700,
            maxWidth: viewModel.inputVideoURL != nil ? 1600 : 700,
        )
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Enhanced Glass Components

    private var enhancedDropArea: some View {
        VStack(spacing: 24) {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.accentColor.opacity(0.05),
                                        Color.clear,
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                isDragging
                                    ? LinearGradient(
                                        colors: [
                                            Color.accentColor.opacity(0.8),
                                            Color.accentColor.opacity(0.4),
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    : LinearGradient(
                                        colors: [
                                            Color.secondary.opacity(0.5),
                                            Color.clear,
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                style: StrokeStyle(
                                    lineWidth: isDragging ? 3 : 2
                                )
                            )
                    )
                    .shadow(color: .black.opacity(0.05), radius: 20, y: 10)
                    .animation(.easeInOut(duration: 0.3), value: isDragging)
                    .scaleEffect(isHoveringDropZone ? 1.02 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.2),
                        value: isHoveringDropZone
                    )

                VStack(spacing: 24) {
                    // Enhanced floating glass icon
                    ZStack {
                        Circle()
                            .fill(Color(NSColor.controlBackgroundColor).opacity(0.9))
                            .frame(width: 120, height: 120)
                            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                .white.opacity(0.3), .clear,
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )

                        Image(systemName: "arrow.down.doc.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(Color.accentColor)
                            .symbolRenderingMode(.hierarchical)
                            .scaleEffect(isDragging ? 1.1 : 1.0)
                            .animation(
                                .easeInOut(duration: 0.3),
                                value: isDragging
                            )
                    }

                    VStack(spacing: 8) {
                        Text("Drop your video here")
                            .font(
                                .system(
                                    size: 22,
                                    weight: .semibold,
                                    design: .rounded
                                )
                            )
                            .foregroundColor(.primary)

                        Text("or click to browse")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }

                    Button(action: { selectFile() }) {
                        Label("Choose Video", systemImage: "folder")
                            .frame(width: 160)
                    }
                    .buttonStyle(GlassProminentButtonStyle())
                    .controlSize(.large)

                    Text("Supports MP4, MOV, AVI, MKV and more")
                        .font(.system(size: 12))
                        .foregroundColor(Color.secondary.opacity(0.7))
                }
                .padding(50)
            }
            .frame(height: 320)
            .onDrop(
                of: [.movie, .quickTimeMovie, .mpeg4Movie],
                isTargeted: $isDragging
            ) { providers in
                handleDrop(providers: providers)
            }
            .onHover { hovering in
                isHoveringDropZone = hovering
            }
        }
    }

    private var floatingFooter: some View {
        VStack(spacing: 0) {
            Divider()
                .background(.secondary.opacity(0.3))

            ZStack {
                if viewModel.encodingState == .encoding {
                    GeometryReader { proxy in
                        Rectangle()
                            .fill(Color.accentColor.opacity(0.15))
                            .frame(width: max(0, proxy.size.width * viewModel.encodingProgress), height: proxy.size.height)
                            .animation(.easeInOut(duration: 0.2), value: viewModel.encodingProgress)
                            .edgesIgnoringSafeArea(.all)
                    }
                    .allowsHitTesting(false)
                }

                HStack(spacing: 12) {
                    if viewModel.encodingState == .encoding {
                        Image(systemName: "gearshape.2.fill")
                            .foregroundColor(.accentColor)
                            .font(.system(size: 14))
                            .rotationEffect(.degrees(viewModel.encodingProgress * 360))
                            .animation(
                                .linear(duration: 1).repeatForever(autoreverses: false),
                                value: viewModel.encodingState == .encoding
                            )

                        Text("Encoding in progress...")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.primary)

                        Spacer()

                        Text("\(Int(viewModel.encodingProgress * 100))%")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.accentColor)

                        Button("Cancel") {
                            viewModel.cancelEncoding()
                        }
                        .buttonStyle(GlassButtonStyle())
                        .controlSize(.small)
                    } else {
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
                                .truncationMode(.middle)
                        }

                        Spacer()

                        if viewModel.inputVideoURL != nil {
                            HStack(spacing: 8) {
                                Button(action: { viewModel.startEncoding() }) {
                                    Label("Start Encoding", systemImage: "play.fill")
                                }
                                .buttonStyle(GlassProminentButtonStyle())
                                .controlSize(.small)
                                .disabled(viewModel.encodingState == .encoding)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        .overlay(
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.1), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 1),
            alignment: .top
        )
    }

    private var videoLoadedContent: some View {
        HStack(alignment: .top, spacing: 20) {
            // Left column: mini drop zone + video preview + video info
            VStack(spacing: 16) {
                miniDropZone
                VideoPreviewView(url: viewModel.inputVideoURL, isPlaying: $viewModel.isPlaying, playbackTime: $viewModel.playbackTime, trimStart: $viewModel.trimStart, trimEnd: $viewModel.trimEnd, isMuted: $viewModel.isMuted)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                // Trim controls
                if viewModel.videoDuration > 0 {
                    VStack(spacing: 8) {
                        HStack(spacing: 16) {
                            Button(action: { viewModel.isPlaying.toggle() }) {
                                Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Text(formatDuration(viewModel.playbackTime))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white)
                            
                            EnhancedRangeSlider(duration: viewModel.videoDuration,
                                                lower: $viewModel.trimStart,
                                                upper: $viewModel.trimEnd,
                                                playhead: $viewModel.playbackTime)
                                .frame(height: 24)
                                .padding(.horizontal, 8)
                                .frame(maxWidth: .infinity)
                            
                            Text(formatDuration(viewModel.videoDuration))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white)
                            
                            Button(action: { viewModel.isMuted.toggle() }) {
                                Image(systemName: viewModel.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        
                        HStack {
                            Text(formatDuration(viewModel.trimStart))
                                .font(.system(size: 11)).foregroundColor(.secondary)
                            Spacer()
                            Text(formatDuration(viewModel.trimEnd))
                                .font(.system(size: 11)).foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 4)
                }
                // videoInfoSection merged into miniDropZone
            }
            .frame(minWidth: 400, maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            // Right column: settings
            VStack(spacing: 12) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        encodingOptionsSection

                        if case .completed = viewModel.encodingState {
                            completionSection
                        }

                        if case .failed(let error) = viewModel.encodingState {
                            errorSection(error)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                }
            }
            .frame(width: 480, alignment: .top)
        }
    }

    private var miniDropZone: some View {
        VStack(spacing: 12) {
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
                    Label(
                        "Change Video",
                        systemImage: "arrow.triangle.2.circlepath"
                    )
                    .font(.system(size: 13))
                }
                .buttonStyle(GlassButtonStyle())
                .controlSize(.small)
            }
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
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
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)

                    Button(action: {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(
                            "brew install ffmpeg",
                            forType: .string
                        )
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
            .background(Color(NSColor.controlBackgroundColor))
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
                            .shadow(
                                color: .black.opacity(0.2),
                                radius: 10,
                                y: 5
                            )
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
            let cgImage = try imageGenerator.copyCGImage(
                at: time,
                actualTime: nil
            )
            return NSImage(
                cgImage: cgImage,
                size: NSSize(width: cgImage.width, height: cgImage.height)
            )
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
                                isDragging
                                    ? Color.accentColor
                                    : Color.secondary.opacity(0.3),
                                style: StrokeStyle(
                                    lineWidth: 2
                                )
                            )
                    )
                    .animation(.easeInOut(duration: 0.2), value: isDragging)
                    .scaleEffect(isHoveringDropZone ? 1.02 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.2),
                        value: isHoveringDropZone
                    )

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
                            .font(
                                .system(
                                    size: 22,
                                    weight: .semibold,
                                    design: .rounded
                                )
                            )
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
            .onDrop(
                of: [.movie, .quickTimeMovie, .mpeg4Movie],
                isTargeted: $isDragging
            ) { providers in
                handleDrop(providers: providers)
            }
            .onHover { hovering in
                isHoveringDropZone = hovering
            }
        }
    }

    private var videoInfoSection: some View {
        VStack(spacing: 12) {
            HStack {
                Label("Video Information", systemImage: "info.circle.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }

            HStack(spacing: 12) {
                InfoPill(
                    icon: "doc",
                    label: "Size",
                    value: viewModel.inputFileSize
                )

                if viewModel.videoDuration > 0 {
                    InfoPill(
                        icon: "clock",
                        label: "Duration",
                        value: formatDuration(viewModel.videoDuration)
                    )
                }

                if !viewModel.videoResolution.isEmpty {
                    InfoPill(
                        icon: "aspectratio",
                        label: "Resolution",
                        value: viewModel.videoResolution
                    )
                }

                if viewModel.videoFPS > 0 {
                    InfoPill(
                        icon: "speedometer",
                        label: "FPS",
                        value: "\(Int(viewModel.videoFPS))"
                    )
                }

                Spacer()
            }
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }

    private var encodingOptionsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Label("Encoding Settings", systemImage: "slider.horizontal.3")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
                if !viewModel.estimatedOutputSize.isEmpty {
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 13))
                        Text(viewModel.estimatedOutputSize)
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.accentColor)
                    .cornerRadius(16)
                }
            }

            VStack(spacing: 14) {
                OptionRow(label: "Codec", icon: "cpu") {
                    Picker("", selection: $viewModel.selectedCodec) {
                        ForEach(VideoCodec.allCases, id: \.self) { codec in
                            Text(codec.displayName).tag(codec)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                OptionRow(label: "Quality Preset", icon: "dial.high") {
                    Picker("", selection: $viewModel.selectedPreset) {
                        ForEach(VideoPreset.allCases, id: \.self) { preset in
                            Text(preset.displayName).tag(preset)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                OptionRow(label: "Frame Rate", icon: "timer") {
                    Picker("", selection: $viewModel.selectedFPS) {
                        ForEach(FPSOption.allCases, id: \.self) { fps in
                            Text(fps.displayName).tag(fps)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                OptionRow(
                    label: "Playback Speed",
                    icon: "gauge.with.dots.needle.67percent"
                ) {
                    Picker("", selection: $viewModel.selectedSpeed) {
                        ForEach(PlaybackSpeed.allCases, id: \.self) { speed in
                            Text(speed.displayName).tag(speed)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: viewModel.selectedSpeed) {
                        viewModel.calculateEstimatedSize()
                    }
                }

                OptionRow(
                    label: "Bitrate (kbps)",
                    icon: "gauge.with.dots.needle.bottom.50percent"
                ) {
                    TextField("2000", text: $viewModel.targetBitrate)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: viewModel.targetBitrate) {
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
                                TextField(
                                    "1920",
                                    text: $viewModel.cropSettings.width
                                )
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Height")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                TextField(
                                    "1080",
                                    text: $viewModel.cropSettings.height
                                )
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("X Position")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                TextField("0", text: $viewModel.cropSettings.x)
                                    .textFieldStyle(
                                        RoundedBorderTextFieldStyle()
                                    )
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Y Position")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                TextField("0", text: $viewModel.cropSettings.y)
                                    .textFieldStyle(
                                        RoundedBorderTextFieldStyle()
                                    )
                            }
                        }

                        Text(
                            "Tip: Use width and height to set crop size, X and Y to set position"
                        )
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
                    TextField(
                        "e.g., -crf 23",
                        text: $viewModel.customFFmpegOptions
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }

    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button(action: { clearVideo() }) {
                Label("Clear", systemImage: "xmark.circle")
                    .frame(width: 120)
            }
            .buttonStyle(GlassButtonStyle())
            .controlSize(.large)

            Spacer()

            Button(action: { viewModel.startEncoding() }) {
                Label("Start Encoding", systemImage: "play.fill")
                    .frame(width: 180)
            }
            .buttonStyle(GlassProminentButtonStyle())
            .controlSize(.large)
            .disabled(viewModel.encodingState == .encoding)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .contentShape(Rectangle())
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
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
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

            if !viewModel.lastFFmpegLog.isEmpty {
                DisclosureGroup {
                    ScrollView {
                        Text(viewModel.lastFFmpegLog)
                            .font(.system(size: 12, design: .monospaced))
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)
                    }
                    .frame(maxHeight: 220)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)

                    HStack {
                        Spacer()
                        Button {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(viewModel.lastFFmpegLog, forType: .string)
                        } label: {
                            Label("Copy Log", systemImage: "doc.on.doc")
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                } label: {
                    Text("Details").font(.system(size: 13, weight: .medium))
                }
            }

            Button(action: { viewModel.encodingState = .idle }) {
                Label("Try Again", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(16)
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }

        provider.loadItem(
            forTypeIdentifier: UTType.movie.identifier,
            options: nil
        ) { item, error in
            if let url = item as? URL {
                DispatchQueue.main.async {
                    viewModel.loadVideo(from: url)
                }
            } else if let data = item as? Data {
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString + ".mov")
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
        panel.allowedContentTypes = [
            .movie, .quickTimeMovie, .mpeg4Movie, .avi,
        ]
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

// Enhanced slider with gradient progress and playhead
fileprivate struct EnhancedRangeSlider: View {
    let duration: Double
    @Binding var lower: Double
    @Binding var upper: Double
    @Binding var playhead: Double
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let range = max(duration, 0.0001)
            let l = max(0, min(lower, duration))
            let u = max(l, min(upper, duration))
            let p = max(0, min(playhead, duration))
            let lx = CGFloat(l / range) * width
            let ux = CGFloat(u / range) * width
            let px = CGFloat(p / range) * width
            
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.15)).frame(height: height / 5)
                // Selected range base
                Rectangle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: ux - lx, height: height / 5)
                    .offset(x: lx)
                // Progress gradient inside selected range
                if px > lx {
                    Rectangle()
                        .fill(LinearGradient(colors: [.purple, .blue, .mint], startPoint: .leading, endPoint: .trailing))
                        .frame(width: min(px, ux) - lx, height: height / 5)
                        .offset(x: lx)
                }
                // Lower knob
                knob.position(x: lx, y: height / 2)
                    .gesture(DragGesture().onChanged { value in
                        let x = max(0, min(width, value.location.x))
                        let v = Double(x / width) * range
                        lower = min(v, upper)
                    })
                // Upper knob
                knob.position(x: ux, y: height / 2)
                    .gesture(DragGesture().onChanged { value in
                        let x = max(0, min(width, value.location.x))
                        let v = Double(x / width) * range
                        upper = max(v, lower)
                    })
                // Playhead
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 2, height: height)
                    .position(x: px, y: height / 2)
                    .gesture(DragGesture().onChanged { value in
                        let x = max(0, min(width, value.location.x))
                        let v = Double(x / width) * range
                        playhead = min(max(v, lower), upper)
                    })
            }
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let x = max(0, min(width, value.location.x))
                            let v = Double(x / width) * range
                            playhead = min(max(v, l), u)
                        }
                        .onEnded { value in
                            let x = max(0, min(width, value.location.x))
                            let v = Double(x / width) * range
                            playhead = min(max(v, l), u)
                        }
            )
        }
    }
    
    private var knob: some View {
        Capsule()
            .fill(Color.white)
            .overlay(Capsule().stroke(Color.black.opacity(0.2), lineWidth: 1))
            .frame(width: 6, height: 18)
            .shadow(radius: 1, y: 0.5)
            .accessibilityHidden(true)
    }
}
