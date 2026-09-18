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
