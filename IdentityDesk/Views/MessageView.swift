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
            
            ChipWrapView(chips: chips, store: store)
        }
        .padding()
        .background(Color(red: 0.90, green: 0.88, blue: 0.84).opacity(0.3))
        .cornerRadius(4)
    }
}

struct ChipWrapView: View {
    let chips: [ReplyChip]
    @ObservedObject var store: ScenarioStore
    
    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(height: calculateHeight())
    }
    
    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width: CGFloat = 0
        var height: CGFloat = 0
        var lastHeight: CGFloat = 0
        
        return ZStack(alignment: .topLeading) {
            ForEach(Array(chips.enumerated()), id: \.element.id) { index, chip in
                ChipButton(chip: chip, store: store)
                    .padding(.trailing, 8)
                    .padding(.bottom, 8)
                    .alignmentGuide(.leading, computeValue: { dimension in
                        if abs(width - dimension.width) > geometry.size.width {
                            width = 0
                            height -= lastHeight
                        }
                        lastHeight = dimension.height
                        let result = width
                        if chips.indices.contains(index + 1) {
                            width -= dimension.width + 8
                        } else {
                            width = 0
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { dimension in
                        let result = height
                        if chips.indices.contains(index + 1) {
                            lastHeight = dimension.height
                        } else {
                            height = 0
                        }
                        return result
                    })
            }
        }
    }
    
    private func calculateHeight() -> CGFloat {
        var height: CGFloat = 44
        let chipCount = chips.count
        if chipCount > 0 {
            let estimatedRows = max(1, chipCount / 2)
            height = CGFloat(estimatedRows) * 44
        }
        return height
    }
}

struct ChipButton: View {
    let chip: ReplyChip
    @ObservedObject var store: ScenarioStore
    
    var body: some View {
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
