import SwiftUI

struct TicketDetailView: View {
    @ObservedObject var store: ScenarioStore
    let ticket: Ticket
    @Binding var isPresented: Bool
    @State private var notes: String = ""
    
    private var availableActions: [String] {
        store.availableActions(for: ticket.id)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.15, green: 0.15, blue: 0.15)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ticketInfoSection
                        requesterSection
                        descriptionSection
                        notesSection
                        actionsSection
                    }
                    .padding()
                }
            }
            .navigationTitle(ticket.id)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        isPresented = false
                    }
                    .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75))
                }
            }
        }
    }
    
    private var ticketInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                FieldLabel(text: "STATUS")
                Spacer()
                Text(ticket.status)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
            }
            
            HStack {
                FieldLabel(text: "PRIORITY")
                Spacer()
                Text(ticket.priority)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(ticket.priority == "High" ?
                        Color(red: 1.0, green: 0.7, blue: 0.0) :
                        Color(red: 0.15, green: 0.15, blue: 0.15))
            }
            
            HStack {
                FieldLabel(text: "OPENED")
                Spacer()
                Text(ticket.openedAt)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
            }
        }
        .padding()
        .panelStyle()
    }
    
    private var requesterSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            FieldLabel(text: "REQUESTER")
            
            if let requester = store.user(withId: ticket.requesterId) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(requester.displayName)
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                    
                    Text("Status: \(requester.status)")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.6))
                    
                    Button(action: {
                        store.selectedUserId = requester.id
                        store.selectedWindow = .user
                        isPresented = false
                    }) {
                        Text("View User Profile →")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.7))
                    }
                }
            }
        }
        .padding()
        .panelStyle()
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            FieldLabel(text: "DESCRIPTION")
            Text(ticket.description)
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
        }
        .padding()
        .panelStyle()
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            FieldLabel(text: "NOTES")
            
            if #available(iOS 16.0, *) {
                TextEditor(text: $notes)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                    .frame(height: 80)
                    .scrollContentBackground(.hidden)
                    .background(Color(red: 0.95, green: 0.94, blue: 0.92))
                    .cornerRadius(4)
            } else {
                TextEditor(text: $notes)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                    .frame(height: 80)
                    .background(Color(red: 0.95, green: 0.94, blue: 0.92))
                    .cornerRadius(4)
            }
        }
        .padding()
        .panelStyle()
    }
    
    private var actionsSection: some View {
        VStack(spacing: 8) {
            if availableActions.contains("resetPassword") {
                ActionButton(title: "RESET PASSWORD", priority: ticket.priority) {
                    store.resetPassword(userId: ticket.requesterId)
                }
            }
            
            if availableActions.contains("unlockAccount") {
                ActionButton(title: "UNLOCK ACCOUNT", priority: ticket.priority, isAlert: true) {
                    store.unlockAccount(userId: ticket.requesterId)
                }
            }
            
            if availableActions.contains("assignEntitlement") {
                ActionButton(title: "ASSIGN ENTITLEMENT", priority: ticket.priority) {
                    if let ent = store.entitlements.first(where: { $0.userId == ticket.requesterId && $0.status == "REVOKED" }) {
                        store.assignEntitlement(entitlementId: ent.id)
                    }
                }
            }
            
            if availableActions.contains("close") {
                ActionButton(title: "CLOSE TICKET", priority: ticket.priority) {
                    store.closeTicket(ticket.id, notes: notes.isEmpty ? nil : notes)
                    isPresented = false
                }
            }
        }
    }
}

struct ActionButton: View {
    let title: String
    var priority: String = "Normal"
    var isAlert: Bool = false
    let action: () -> Void
    
    private var useAmber: Bool {
        priority == "High" || isAlert
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(useAmber ? Color(red: 0.1, green: 0.1, blue: 0.1) : Color(red: 0.15, green: 0.15, blue: 0.15))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(useAmber ? Color(red: 1.0, green: 0.7, blue: 0.0) : Color(red: 0.90, green: 0.88, blue: 0.84))
                .cornerRadius(4)
        }
    }
}
