import SwiftUI

struct MessageView: View {
    @ObservedObject var store: ScenarioStore
    
    private var messages: [Message] {
        store.messagesForOperator()
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
    
    private var hasAnomaly: Bool {
        message.isImpostor == true || message.hasEmoji
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let sender = sender {
                    Text(sender.displayName)
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundColor(hasAnomaly ?
                            Color(red: 1.0, green: 0.7, blue: 0.0) :
                            Color(red: 0.85, green: 0.82, blue: 0.75))
                } else {
                    Text(message.fromUserId)
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75))
                }
                Spacer()
                Text(message.sentAt)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75).opacity(0.5))
            }
            
            Text(message.body)
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75))
            
            if message.hasEmoji {
                HStack {
                    Text("⚠")
                        .font(.system(size: 10))
                    Text("Contains emoji")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(Color(red: 1.0, green: 0.7, blue: 0.0))
                }
            }
        }
        .padding()
        .panelStyle()
        .overlay(
            hasAnomaly ?
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color(red: 1.0, green: 0.7, blue: 0.0).opacity(0.3), lineWidth: 1) :
                nil
        )
    }
}
