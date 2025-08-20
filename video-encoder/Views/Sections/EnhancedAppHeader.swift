import SwiftUI

struct EnhancedAppHeader: View {
    let isReady: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Draggable area for window movement
            Color.clear
                .frame(width: 70, height: 1)
            
            // App icon
            Image(systemName: "video.badge.waveform")
                .font(.system(size: 18))
                .foregroundStyle(Color.accentColor)
                .symbolRenderingMode(.hierarchical)
            
            // App title
            Text("Video Encoder")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
            
            Text("Compress and convert your videos with ease")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Status indicator
            HStack(spacing: 6) {
                Circle()
                    .fill(isReady ? .green : .red)
                    .frame(width: 6, height: 6)
                    .shadow(color: isReady ? .green.opacity(0.5) : .red.opacity(0.5), radius: 2)
                
                Text(isReady ? "Ready" : "Setup Required")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .frame(height: 28)
    }
}


