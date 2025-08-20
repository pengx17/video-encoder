import SwiftUI

struct OptionRow<Content: View>: View {
    let label: String
    let icon: String
    let content: () -> Content
    
    var body: some View {
        HStack(spacing: 12) {
            Label(label, systemImage: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary.opacity(0.9))
                .frame(width: 150, alignment: .leading)
            
            Spacer()
            
            content()
                .frame(maxWidth: 180, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }
}


