import SwiftUI

struct TicketQueueView: View {
    @ObservedObject var store: ScenarioStore
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if store.tickets.isEmpty {
                    Text("No open tickets")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75).opacity(0.5))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 40)
                } else {
                    ForEach(store.tickets) { ticket in
                        TicketRowView(ticket: ticket, store: store)
                    }
                }
            }
            .padding()
        }
    }
}

struct TicketRowView: View {
    let ticket: Ticket
    @ObservedObject var store: ScenarioStore
    @State private var showingDetail = false
    
    var priorityColor: Color {
        ticket.priority == "High" ?
            Color(red: 1.0, green: 0.7, blue: 0.0) :
            Color(red: 0.85, green: 0.82, blue: 0.75)
    }
    
    var body: some View {
        Button(action: {
            store.selectedTicketId = ticket.id
            showingDetail = true
        }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(ticket.id)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75).opacity(0.7))
                    
                    Text(ticket.priority.uppercased())
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(priorityColor)
                    
                    Spacer()
                    
                    Text(ticket.openedAt)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75).opacity(0.5))
                }
                
                Text(ticket.subject)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let requester = store.user(withId: ticket.requesterId) {
                    Text("Requester: \(requester.displayName)")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75).opacity(0.7))
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .panelStyle()
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            TicketDetailView(store: store, ticket: ticket, isPresented: $showingDetail)
        }
    }
}
