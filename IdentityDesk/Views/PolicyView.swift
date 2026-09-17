import SwiftUI

struct PolicyView: View {
    @ObservedObject var store: ScenarioStore
    @Binding var isPresented: Bool
    
    private var selectedPolicy: Policy? {
        guard let policyId = store.selectedPolicyId else { return nil }
        return store.policy(withId: policyId)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.15, green: 0.15, blue: 0.15)
                    .ignoresSafeArea()
                
                if let policy = selectedPolicy {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            policyHeader(policy: policy)
                            rulesSection(policy: policy)
                            appliesSection(policy: policy)
                            linkedDepartmentsSection(policy: policy)
                        }
                        .padding()
                    }
                } else {
                    Text("No policy selected")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75).opacity(0.5))
                }
            }
            .navigationTitle("Policy")
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
    
    private func policyHeader(policy: Policy) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(policy.name)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75))
            
            Text(policy.id)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75).opacity(0.7))
        }
        .padding()
        .panelStyle()
    }
    
    private func rulesSection(policy: Policy) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            FieldLabel(text: "RULES")
            
            if policy.rules.isEmpty {
                EmptyFieldText(value: nil)
            } else {
                ForEach(policy.rules, id: \.self) { rule in
                    Text("• \(rule)")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75))
                }
            }
        }
        .padding()
        .panelStyle()
    }
    
    private func appliesSection(policy: Policy) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            FieldLabel(text: "APPLIES TO")
            Text(policy.appliesTo)
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75))
        }
        .padding()
        .panelStyle()
    }
    
    private func linkedDepartmentsSection(policy: Policy) -> some View {
        let linkedDepts = store.departments.filter { $0.policyIds.contains(policy.id) }
        
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                FieldLabel(text: "LINKED DEPARTMENTS")
                Spacer()
                Text("\(linkedDepts.count) linked")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75).opacity(0.7))
            }
            
            if linkedDepts.isEmpty {
                EmptyFieldText(value: nil)
            } else {
                ForEach(linkedDepts) { dept in
                    Button(action: {
                        store.selectedDepartmentId = dept.id
                        store.selectedWindow = .dept
                    }) {
                        Text("• \(dept.name)")
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75))
                    }
                }
            }
        }
        .padding()
        .panelStyle()
    }
}
