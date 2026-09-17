import SwiftUI

struct DepartmentView: View {
    @ObservedObject var store: ScenarioStore
    
    private var selectedDepartment: Department? {
        guard let deptId = store.selectedDepartmentId else { return nil }
        return store.department(withId: deptId)
    }
    
    var body: some View {
        ScrollView {
            if let dept = selectedDepartment {
                VStack(alignment: .leading, spacing: 16) {
                    departmentHeader(dept: dept)
                    departmentFields(dept: dept)
                }
                .padding()
            } else {
                Text("No department selected")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75).opacity(0.5))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 40)
            }
        }
    }
    
    private func departmentHeader(dept: Department) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(dept.name)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
            
            Text(dept.id)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.6))
        }
        .padding()
        .panelStyle()
    }
    
    private func departmentFields(dept: Department) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Head")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.5))
                Spacer()
                EmptyFieldText(value: store.user(withId: dept.headId ?? "")?.displayName)
                    .font(.system(size: 13, design: .monospaced))
            }
            
            HStack {
                Text("Manager")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.5))
                Spacer()
                EmptyFieldText(value: store.user(withId: dept.managerId ?? "")?.displayName)
                    .font(.system(size: 13, design: .monospaced))
            }
            
            HStack {
                Text("Cost Centre")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.5))
                Spacer()
                EmptyFieldText(value: dept.costCentre)
                    .font(.system(size: 13, design: .monospaced))
            }
            
            HStack {
                Text("Members")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.5))
                Spacer()
                if dept.memberIds.isEmpty {
                    EmptyFieldText(value: nil)
                        .font(.system(size: 13, design: .monospaced))
                } else {
                    Text("\(dept.memberIds.count)")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Policies")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.5))
                
                if dept.policyIds.isEmpty {
                    EmptyFieldText(value: nil)
                        .font(.system(size: 13, design: .monospaced))
                } else {
                    ForEach(dept.policyIds, id: \.self) { policyId in
                        if let policy = store.policy(withId: policyId) {
                            Button(action: {
                                store.selectedPolicyId = policyId
                            }) {
                                HStack {
                                    Text("• \(policy.name)")
                                        .font(.system(size: 13, design: .monospaced))
                                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.7))
                                    Spacer()
                                }
                            }
                        } else {
                            Text("• \(policyId)")
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
}
