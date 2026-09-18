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
                Text(TimeFormatter.formatScenarioTime(message.sentAt))
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
        .background(Color(red: 0.90, green: 0.88, blue: 0.84))
        .cornerRadius(4)
    }
}

struct ChipWrapView: View {
    let chips: [ReplyChip]
    @ObservedObject var store: ScenarioStore
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100, maximum: 300), spacing: 8)], spacing: 8) {
            ForEach(chips) { chip in
                ChipButton(chip: chip, store: store)
            }
        }
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
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color(red: 0.15, green: 0.15, blue: 0.15), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
