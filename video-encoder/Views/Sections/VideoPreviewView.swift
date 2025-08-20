import SwiftUI
import AVKit
import AppKit

struct VideoPreviewView: View {
    let url: URL?
    
    var body: some View {
        Group {
            if let url = url {
                ZStack {
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
}


