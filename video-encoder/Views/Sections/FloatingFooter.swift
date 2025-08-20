import SwiftUI

struct FloatingFooter: View {
    let version: String
    let path: String?
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(.secondary.opacity(0.3))
            
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 14))
                Text(version)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                Spacer()
                if let path = path {
                    Text(path)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color.secondary.opacity(0.7))
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 16)
        }
        .background(.regularMaterial)
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
}


