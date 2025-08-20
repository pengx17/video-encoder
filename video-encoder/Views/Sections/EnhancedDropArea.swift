import SwiftUI
import UniformTypeIdentifiers

struct EnhancedDropArea: View {
    @Binding var isDragging: Bool
    @Binding var isHoveringDropZone: Bool
    let onSelectFile: () -> Void
    let onDropProviders: ([NSItemProvider]) -> Bool
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.accentColor.opacity(0.03),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                isDragging ?
                                LinearGradient(
                                    colors: [Color.accentColor.opacity(0.8), Color.accentColor.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [Color.secondary.opacity(0.3), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                style: StrokeStyle(lineWidth: isDragging ? 3 : 2)
                            )
                    )
                    .shadow(color: .black.opacity(0.05), radius: 20, y: 10)
                    .animation(.easeInOut(duration: 0.3), value: isDragging)
                    .scaleEffect(isHoveringDropZone ? 1.02 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isHoveringDropZone)
                
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(.regularMaterial)
                            .frame(width: 120, height: 120)
                            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [.white.opacity(0.3), .clear],
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
                            .animation(.easeInOut(duration: 0.3), value: isDragging)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Drop your video here")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("or click to browse")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: { onSelectFile() }) {
                        Label("Choose Video", systemImage: "folder")
                            .frame(width: 160)
                    }
                    .buttonStyle(GlassProminentButtonStyle())
                    .controlSize(.large)
                    
                    Text("Supports MP4, MOV, AVI, MKV and more")
                        .font(.system(size: 12))
                        .foregroundColor(Color.secondary.opacity(0.7))
                }
                .padding(40)
            }
            .onDrop(of: [.movie, .quickTimeMovie, .mpeg4Movie], isTargeted: $isDragging) { providers in
                onDropProviders(providers)
            }
            .onHover { hovering in
                isHoveringDropZone = hovering
            }
        }
    }
}


