import SwiftUI

struct UserProfileView: View {
    @ObservedObject var store: ScenarioStore
    @State private var showingAuthHistory = false
    
    private var selectedUser: User? {
        guard let userId = store.selectedUserId else { return nil }
        return store.user(withId: userId)
    }
    
    var body: some View {
        ScrollView {
            if let user = selectedUser {
                VStack(alignment: .leading, spacing: 16) {
                    userInfoSection(user: user)
                    organizationSection(user: user)
                    authHistoryButton(user: user)
                }
                .padding()
                .sheet(isPresented: $showingAuthHistory) {
                    if let user = selectedUser {
                        NavigationView {
                            AuthHistoryView(store: store, userId: user.id)
                        }
                    }
                }
            } else {
                Text("No user selected")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75).opacity(0.5))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 40)
            }
        }
    }
    
    private func userInfoSection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(user.displayName)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
            
            HStack {
                FieldLabel(text: "ID")
                Spacer()
                Text(user.id)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
            }
            
            HStack {
                FieldLabel(text: "STATUS")
                Spacer()
                Text(user.status)
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(user.status == "ACTIVE" ?
                        Color(red: 0.15, green: 0.15, blue: 0.15) :
                        Color(red: 1.0, green: 0.7, blue: 0.0))
            }
        }
        .padding()
        .panelStyle()
    }
    
    private func organizationSection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            FieldLabel(text: "ORGANIZATION")
            
            HStack {
                Text("Role")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.5))
                Spacer()
                EmptyFieldText(value: store.role(withId: user.roleId)?.name)
                    .font(.system(size: 13, design: .monospaced))
            }
            
            HStack {
                Text("Manager")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.5))
                Spacer()
                EmptyFieldText(value: store.user(withId: user.managerId ?? "")?.displayName)
                    .font(.system(size: 13, design: .monospaced))
            }
            
            HStack {
                Text("Department")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.5))
                Spacer()
                if let dept = store.department(withId: user.departmentId) {
                    Button(action: {
                        store.selectedDepartmentId = dept.id
                        store.selectedWindow = .dept
                    }) {
                        Text(dept.name)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.7))
                    }
                } else {
                    EmptyFieldText(value: nil)
                        .font(.system(size: 13, design: .monospaced))
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Groups")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.5))
                
                if user.groupIds.isEmpty {
                    EmptyFieldText(value: nil)
                        .font(.system(size: 13, design: .monospaced))
                } else {
                    ForEach(user.groupIds, id: \.self) { groupId in
                        if let group = store.group(withId: groupId) {
                            Text("• \(group.name)")
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                        }
                    }
                }
            }
        }
        .padding()
        .panelStyle()
    }
    
    private func authHistoryButton(user: User) -> some View {
        Button(action: {
            showingAuthHistory = true
        }) {
            HStack {
                Text("View Authentication History")
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                Spacer()
                Text("→")
            }
            .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.7))
            .padding()
            .panelStyle()
        }
    }
}
