import SwiftUI

struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        GlassButtonStyleBody(configuration: configuration)
    }
    
    private struct GlassButtonStyleBody: View {
        let configuration: Configuration
        @State private var isHovered = false
        
        var body: some View {
            configuration.label
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.3), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                )
                .scaleEffect(configuration.isPressed ? 0.98 : (isHovered ? 1.02 : 1.0))
                .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
                .animation(.easeInOut(duration: 0.15), value: isHovered)
                .onHover { hovering in
                    isHovered = hovering
                }
        }
    }
}

struct GlassProminentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        GlassProminentButtonStyleBody(configuration: configuration)
    }
    
    private struct GlassProminentButtonStyleBody: View {
        let configuration: Configuration
        @State private var isHovered = false
        
        var body: some View {
            configuration.label
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.accentColor.opacity(0.9),
                                        Color.accentColor
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.regularMaterial)
                            .opacity(0.2)
                    }
                )
                .foregroundColor(.white)
                .shadow(color: Color.accentColor.opacity(0.4), radius: 8, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.4), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                )
                .scaleEffect(configuration.isPressed ? 0.98 : (isHovered ? 1.02 : 1.0))
                .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
                .animation(.easeInOut(duration: 0.15), value: isHovered)
                .onHover { hovering in
                    isHovered = hovering
                }
        }
    }
}

