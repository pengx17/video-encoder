import SwiftUI

struct OptionRow<Content: View>: View {
    let label: String
    let icon: String
    let content: () -> Content
    
    var body: some View {
        HStack {
            Label(label, systemImage: icon)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .frame(width: 140, alignment: .leading)
            
            Spacer()
            
            content()
        }
        .padding(.vertical, 4)
    }
}


