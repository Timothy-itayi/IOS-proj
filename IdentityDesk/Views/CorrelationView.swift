import SwiftUI

struct CorrelationView: View {
    @ObservedObject var store: ScenarioStore
    
    private var correlations: [Correlation] {
        var results: [Correlation] = []
        
        if store.chromeRevision == "postMaintenance" {
            if let user = store.selectedUserId, let userData = store.user(withId: user) {
                results.append(Correlation(
                    id: "CORR-USER-DEPT",
                    ticketId: nil,
                    userId: user,
                    departmentId: userData.departmentId,
                    description: "User → Department link"
                ))
            }
            
            if let deptId = store.selectedDepartmentId {
                let deptUsers = store.users.filter { $0.departmentId == deptId }
                if let firstUser = deptUsers.first {
                    results.append(Correlation(
                        id: "CORR-DEPT-USER",
                        ticketId: nil,
                        userId: firstUser.id,
                        departmentId: deptId,
                        description: "Department → User link"
                    ))
                }
            }
            
            if let ticketId = store.selectedTicketId, let ticket = store.tickets.first(where: { $0.id == ticketId }) {
                results.append(Correlation(
                    id: "CORR-TICKET-USER",
                    ticketId: ticketId,
                    userId: ticket.requesterId,
                    departmentId: ticket.departmentId,
                    description: "Ticket → User → Department"
                ))
            }
        }
        
        return results
    }
    
    var body: some View {
        ScrollView {
            if store.chromeRevision == "postMaintenance" {
                if correlations.isEmpty {
                    Text("No correlations available")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75).opacity(0.5))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 40)
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Linked Records")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .panelStyle()
                        
                        ForEach(correlations) { correlation in
                            correlationRow(correlation)
                        }
                    }
                    .padding()
                }
            } else {
                Text("Feature not available")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75).opacity(0.5))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 40)
            }
        }
    }
    
    private func correlationRow(_ correlation: Correlation) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(correlation.description)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.7))
            
            if let ticketId = correlation.ticketId {
                HStack {
                    Text("Ticket")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.5))
                    Spacer()
                    Text(ticketId)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                }
            }
            
            if let userId = correlation.userId {
                HStack {
                    Text("User")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.5))
                    Spacer()
                    if let user = store.user(withId: userId) {
                        Button(action: {
                            store.selectedUserId = userId
                            store.selectedWindow = .user
                        }) {
                            Text(user.displayName)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.7))
                        }
                    } else {
                        Text(userId)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                    }
                }
            }
            
            if let deptId = correlation.departmentId {
                HStack {
                    Text("Department")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.5))
                    Spacer()
                    if let dept = store.department(withId: deptId) {
                        Button(action: {
                            store.selectedDepartmentId = deptId
                            store.selectedWindow = .dept
                        }) {
                            Text(dept.name)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.7))
                        }
                    } else {
                        Text(deptId)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                    }
                }
            }
        }
        .padding()
        .panelStyle()
    }
}
