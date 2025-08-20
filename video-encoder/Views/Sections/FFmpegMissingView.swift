import SwiftUI
import AppKit

struct FFmpegMissingView: View {
    let onRefresh: () -> Void
    
    var body: some View {
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
            
            Button(action: { onRefresh() }) {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: 500)
    }
}


