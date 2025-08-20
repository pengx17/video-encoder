import SwiftUI
import AVKit
import AppKit

struct VideoPreviewView: View {
    let url: URL?
    @Binding var isPlaying: Bool
    @Binding var playbackTime: Double  // seconds
    @Binding var trimStart: Double
    @Binding var trimEnd: Double
    @Binding var isMuted: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if let url = url {
                PlayerViewRepresentable(url: url,
                                        isPlaying: $isPlaying,
                                        playbackTime: $playbackTime,
                                        trimStart: $trimStart,
                                        trimEnd: $trimEnd,
                                        isMuted: $isMuted)
                    .cornerRadius(16)
            } else {
                Color.clear
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct PlayerViewRepresentable: NSViewRepresentable {
    let url: URL
    @Binding var isPlaying: Bool
    @Binding var playbackTime: Double
    @Binding var trimStart: Double
    @Binding var trimEnd: Double
    @Binding var isMuted: Bool
    
    func makeCoordinator() -> Coordinator { Coordinator() }
    
    func makeNSView(context: Context) -> AVPlayerView {
        let view = AVPlayerView()
        view.controlsStyle = .none
        view.showsFullScreenToggleButton = false
        view.showsSharingServiceButton = false
        view.player = AVPlayer(url: url)
        view.player?.isMuted = isMuted
        addObserver(view: view, context: context)
        sync(view)
        return view
    }
    
    func updateNSView(_ nsView: AVPlayerView, context: Context) {
        if let currentItem = (nsView.player?.currentItem?.asset as? AVURLAsset)?.url, currentItem != url {
            // Replace player for new URL
            removeObserver(view: nsView, context: context)
            nsView.player = AVPlayer(url: url)
            addObserver(view: nsView, context: context)
        }
        nsView.player?.isMuted = isMuted
        clampPlaybackTime()
        sync(nsView)
    }
    
    static func dismantleNSView(_ nsView: AVPlayerView, coordinator: Coordinator) {
        if let observer = coordinator.timeObserver {
            nsView.player?.removeTimeObserver(observer)
            coordinator.timeObserver = nil
        }
        nsView.player?.pause()
    }
    
    private func clampPlaybackTime() {
        let start = min(trimStart, trimEnd)
        let end = max(trimStart, trimEnd)
        if playbackTime < start { playbackTime = start }
        if playbackTime > end { playbackTime = end }
    }
    
    private func sync(_ view: AVPlayerView) {
        guard let player = view.player else { return }
        // play/pause
        if isPlaying { player.play() } else { player.pause() }
        
        // Seek if drifted from desired time
        let current = CMTimeGetSeconds(player.currentTime())
        if abs(current - playbackTime) > 0.12 {
            let target = CMTime(seconds: playbackTime, preferredTimescale: 600)
            player.seek(to: target, toleranceBefore: .zero, toleranceAfter: .positiveInfinity)
        }
    }
    
    private func addObserver(view: AVPlayerView, context: Context) {
        guard let player = view.player else { return }
        let interval = CMTime(seconds: 0.05, preferredTimescale: 600)
        context.coordinator.timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            let t = CMTimeGetSeconds(time)
            // Clamp to trim range; auto-pause at end
            let start = min(trimStart, trimEnd)
            let end = max(trimStart, trimEnd)
            if t >= end {
                playbackTime = end
                isPlaying = false
                player.pause()
            } else if t < start {
                playbackTime = start
                player.seek(to: CMTime(seconds: start, preferredTimescale: 600))
            } else {
                playbackTime = t
            }
        }
    }
    
    private func removeObserver(view: AVPlayerView, context: Context) {
        if let obs = context.coordinator.timeObserver {
            view.player?.removeTimeObserver(obs)
            context.coordinator.timeObserver = nil
        }
    }
    
    class Coordinator {
        var timeObserver: Any?
    }
}


