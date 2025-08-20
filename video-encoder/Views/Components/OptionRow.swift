import SwiftUI

struct OptionRow<Content: View>: View {
    let label: String
    let icon: String
    let content: () -> Content

    private let labelWidth: CGFloat = 170
    private let iconWidth: CGFloat = 18

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .frame(width: iconWidth, alignment: .leading)

                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            .frame(width: labelWidth, alignment: .leading)

            Spacer(minLength: 12)

            content()
                .frame(maxWidth: 260, alignment: .trailing)
        }
        .padding(.vertical, 6)
    }
}


