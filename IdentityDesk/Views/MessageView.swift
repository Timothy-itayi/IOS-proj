import SwiftUI

struct MessageView: View {
    @ObservedObject var store: ScenarioStore
    
    private var messages: [Message] {
        store.messagesForOperator()
    }
    
    private var availableChips: [ReplyChip] {
        store.availableReplyChips()
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if messages.isEmpty {
                    Text("No messages")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75).opacity(0.5))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 40)
                } else {
                    ForEach(messages) { message in
                        MessageRow(message: message, store: store)
                    }
                    
                    if !availableChips.isEmpty {
                        ReplyChipStrip(chips: availableChips, store: store)
                            .padding(.top, 8)
                    }
                }
            }
            .padding()
        }
    }
}

struct MessageRow: View {
    let message: Message
    @ObservedObject var store: ScenarioStore
    
    private var sender: User? {
        store.user(withId: message.fromUserId)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let sender = sender {
                    Text(sender.displayName)
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                } else {
                    Text(message.fromUserId)
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                }
                Spacer()
                Text(message.sentAt)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.5))
            }
            
            Text(message.body)
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
        }
        .padding()
        .panelStyle()
    }
}

struct ReplyChipStrip: View {
    let chips: [ReplyChip]
    @ObservedObject var store: ScenarioStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("REPLY")
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.5))
            
            FlowLayout(spacing: 8) {
                ForEach(chips) { chip in
                    Button(action: {
                        store.selectReplyChip(chip)
                    }) {
                        Text(chip.text)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(red: 0.90, green: 0.88, blue: 0.84))
                            .cornerRadius(3)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .background(Color(red: 0.90, green: 0.88, blue: 0.84).opacity(0.3))
        .cornerRadius(4)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            var maxX: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
                maxX = max(maxX, currentX - spacing)
            }
            
            size = CGSize(width: maxX, height: currentY + lineHeight)
        }
    }
}
