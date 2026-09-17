import SwiftUI

struct AccessView: View {
    @ObservedObject var store: ScenarioStore
    @State private var selectedFilter: AccessFilter = .all
    
    private var selectedUser: User? {
        guard let userId = store.selectedUserId else { return nil }
        return store.user(withId: userId)
    }
    
    private var entitlements: [Entitlement] {
        guard let userId = selectedUser?.id else { return [] }
        return store.entitlements(for: userId, filter: selectedFilter)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if selectedUser != nil {
                filterChips
            }
            
            ScrollView {
                if let user = selectedUser {
                    VStack(spacing: 12) {
                        userHeader(user: user)
                        
                        if entitlements.isEmpty {
                            Text("No entitlements")
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75).opacity(0.5))
                                .padding(.top, 20)
                        } else {
                            ForEach(entitlements) { entitlement in
                                EntitlementRow(entitlement: entitlement, store: store)
                            }
                        }
                    }
                    .padding()
                } else {
                    Text("No user selected")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75).opacity(0.5))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 40)
                }
            }
        }
    }
    
    private var filterChips: some View {
        HStack(spacing: 8) {
            ForEach(AccessFilter.allCases, id: \.self) { filter in
                Button(action: {
                    selectedFilter = filter
                }) {
                    Text(filter.rawValue)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(selectedFilter == filter ?
                            Color(red: 0.1, green: 0.1, blue: 0.1) :
                            Color(red: 0.85, green: 0.82, blue: 0.75))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selectedFilter == filter ?
                            Color(red: 1.0, green: 0.7, blue: 0.0) :
                            Color(red: 0.2, green: 0.2, blue: 0.2))
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color(red: 0.15, green: 0.15, blue: 0.15))
    }
    
    private func userHeader(user: User) -> some View {
        HStack {
            Text("Access for \(user.displayName)")
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75))
            Spacer()
        }
        .padding()
        .panelStyle()
    }
}

struct EntitlementRow: View {
    let entitlement: Entitlement
    @ObservedObject var store: ScenarioStore
    
    private var statusColor: Color {
        switch entitlement.status {
        case "ACTIVE":
            return Color(red: 0.15, green: 0.15, blue: 0.15)
        case "REVOKED":
            return Color(red: 1.0, green: 0.3, blue: 0.0)
        default:
            return Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.5)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entitlement.name)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                Spacer()
                Text(entitlement.status)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(statusColor)
            }
            
            HStack {
                Text("Access Source")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.5))
                Spacer()
                HStack(spacing: 4) {
                    Text(entitlement.sourceType)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                    
                    Text("|")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.5))
                    
                    EmptyFieldText(value: entitlement.sourceLabel)
                        .font(.system(size: 12, design: .monospaced))
                }
            }
            
            if let policyId = entitlement.policyId, let policy = store.policy(withId: policyId) {
                Button(action: {
                    store.selectedPolicyId = policyId
                }) {
                    HStack {
                        Text("Policy: \(policy.name)")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.7))
                        Spacer()
                        Text("→")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.7))
                    }
                }
            } else {
                HStack {
                    Text("Policy")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.5))
                    Spacer()
                    EmptyFieldText(value: nil)
                        .font(.system(size: 12, design: .monospaced))
                }
            }
        }
        .padding()
        .panelStyle()
    }
}
