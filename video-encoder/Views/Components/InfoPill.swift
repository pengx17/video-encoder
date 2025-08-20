import SwiftUI

struct InfoPill: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 10))
                    .foregroundColor(Color.secondary.opacity(0.7))
                Text(value)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(NSColor.controlBackgroundColor), in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
        )
    }
}


