import Foundation

@MainActor
class ScenarioStore: ObservableObject {
    @Published var scenario: ScenarioData?
    @Published var currentPhaseIndex: Int = 0
    @Published var completedFlags: Set<String> = []
    @Published var chromeRevision: String = "baseline"
    
    @Published var tickets: [Ticket] = []
    @Published var users: [User] = []
    @Published var authEvents: [AuthenticationEvent] = []
    @Published var departments: [Department] = []
    @Published var entitlements: [Entitlement] = []
    @Published var messages: [Message] = []
    @Published var documents: [Document] = []
    @Published var roles: [Role] = []
    @Published var groups: [UserGroup] = []
    @Published var policies: [Policy] = []
    
    @Published var selectedTicketId: String?
    @Published var selectedUserId: String?
    @Published var selectedDepartmentId: String?
    @Published var selectedPolicyId: String?
    @Published var selectedWindow: Window = .tickets
    
    var operatorName: String {
        scenario?.operator.displayName ?? "Daniel"
    }
    
    var currentPhase: ScenarioPhase? {
        guard let scenario = scenario,
              currentPhaseIndex < scenario.phases.count else { return nil }
        return scenario.phases[currentPhaseIndex]
    }
    
    var currentObjective: String {
        currentPhase?.objective ?? ""
    }
    
    func loadScenario(from bundle: Bundle? = nil) {
        let targetBundle = bundle ?? Bundle.main
        
        guard let url = targetBundle.url(forResource: "demo-vertical-slice", withExtension: "json") else {
            print("Failed to find demo-vertical-slice.json in bundle: \(targetBundle.bundleIdentifier ?? "unknown")")
            return
        }
        
        guard let data = try? Data(contentsOf: url) else {
            print("Failed to load data from \(url.path)")
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode(ScenarioData.self, from: data)
            scenario = decoded
            loadBaselineData()
            advanceToNextPhase()
        } catch {
            print("Failed to decode scenario JSON: \(error)")
            if let decodingError = error as? DecodingError {
                print("Decoding error details: \(decodingError)")
            }
        }
    }
    
    func loadScenario() {
        loadScenario(from: nil)
    }
    
    private func loadBaselineData() {
        guard let baseline = scenario?.sharedBaseline else { return }
        users.append(contentsOf: baseline.users)
        departments.append(contentsOf: baseline.departments)
        roles = baseline.roles
        groups = baseline.groups
        policies = baseline.policies
    }
    
    func advanceToNextPhase() {
        guard let scenario = scenario else { return }
        
        while currentPhaseIndex < scenario.phases.count {
            let phase = scenario.phases[currentPhaseIndex]
            
            if let deps = phase.dependsOn {
                let hasAllDeps = deps.allSatisfy { completedFlags.contains($0) }
                if !hasAllDeps {
                    currentPhaseIndex += 1
                    continue
                }
            }
            
            loadPhaseSeed(phase)
            break
        }
    }
    
    private func loadPhaseSeed(_ phase: ScenarioPhase) {
        guard let seed = phase.seed else { return }
        
        if let newUsers = seed.users {
            for user in newUsers {
                if let index = users.firstIndex(where: { $0.id == user.id }) {
                    users[index] = user
                } else {
                    users.append(user)
                }
            }
        }
        
        if let newTickets = seed.tickets {
            tickets.append(contentsOf: newTickets)
        }
        
        if let newAuthEvents = seed.authEvents {
            authEvents.append(contentsOf: newAuthEvents)
        }
        
        if let newDepartments = seed.departments {
            for dept in newDepartments {
                if let index = departments.firstIndex(where: { $0.id == dept.id }) {
                    departments[index] = dept
                } else {
                    departments.append(dept)
                }
            }
        }
        
        if let newEntitlements = seed.entitlements {
            for ent in newEntitlements {
                if let index = entitlements.firstIndex(where: { $0.id == ent.id }) {
                    entitlements[index] = ent
                } else {
                    entitlements.append(ent)
                }
            }
        }
        
        if let newMessages = seed.messages {
            messages.append(contentsOf: newMessages)
        }
        
        if let newDocuments = seed.documents {
            documents.append(contentsOf: newDocuments)
        }
    }
    
    func user(withId id: String) -> User? {
        users.first(where: { $0.id == id })
    }
    
    func department(withId id: String) -> Department? {
        departments.first(where: { $0.id == id })
    }
    
    func role(withId id: String?) -> Role? {
        guard let id = id else { return nil }
        return roles.first(where: { $0.id == id })
    }
    
    func group(withId id: String) -> UserGroup? {
        groups.first(where: { $0.id == id })
    }
    
    func policy(withId id: String?) -> Policy? {
        guard let id = id else { return nil }
        return policies.first(where: { $0.id == id })
    }
    
    func availableActions(for ticketId: String) -> [String] {
        currentPhase?.availableActions[ticketId] ?? []
    }
    
    func resetPassword(userId: String) {
        if let index = users.firstIndex(where: { $0.id == userId }) {
            users[index].status = "ACTIVE"
        }
    }
    
    func unlockAccount(userId: String) {
        if let index = users.firstIndex(where: { $0.id == userId }) {
            users[index].status = "ACTIVE"
        }
    }
    
    func assignEntitlement(entitlementId: String) {
        if let index = entitlements.firstIndex(where: { $0.id == entitlementId }) {
            entitlements[index].status = "ACTIVE"
        }
    }
    
    func closeTicket(_ ticketId: String, notes: String? = nil) {
        if let index = tickets.firstIndex(where: { $0.id == ticketId }) {
            var updatedTicket = tickets[index]
            updatedTicket.notes = notes
            tickets[index] = updatedTicket
            tickets.remove(at: index)
            
            checkPhaseCompletion(ticketId: ticketId)
        }
    }
    
    private func checkPhaseCompletion(ticketId: String) {
        guard let phase = currentPhase else { return }
        let completion = phase.completion
        
        var completed = false
        
        if completion.ticketClosed == ticketId {
            completed = true
        }
        
        if let userStatuses = completion.userStatus {
            for (userId, expectedStatus) in userStatuses {
                if let user = user(withId: userId), user.status == expectedStatus {
                    completed = true
                } else {
                    completed = false
                    break
                }
            }
        }
        
        if let entStatuses = completion.entitlementStatus {
            for (entId, expectedStatus) in entStatuses {
                if let ent = entitlements.first(where: { $0.id == entId }), ent.status == expectedStatus {
                    completed = true
                } else {
                    completed = false
                    break
                }
            }
        }
        
        if completed {
            completedFlags.formUnion(completion.flags)
            if completion.flags.contains("post_maintenance") {
                chromeRevision = "postMaintenance"
            }
            currentPhaseIndex += 1
            advanceToNextPhase()
        }
    }
    
    func entitlements(for userId: String, filter: AccessFilter = .all) -> [Entitlement] {
        let userEnts = entitlements.filter { $0.userId == userId }
        
        switch filter {
        case .all:
            return userEnts
        case .role:
            return userEnts.filter { $0.sourceType == "Role" }
        case .group:
            return userEnts.filter { $0.sourceType == "Group" }
        case .inherited:
            return userEnts.filter { $0.sourceType == "Inherited" }
        }
    }
    
    func authHistory(for userId: String) -> [AuthenticationEvent] {
        authEvents.filter { $0.userId == userId }.sorted { $0.timestamp > $1.timestamp }
    }
    
    func messagesForOperator() -> [Message] {
        guard let operatorId = scenario?.operator.id else { return [] }
        return messages.filter { $0.toUserId == operatorId || $0.fromUserId == operatorId }.sorted { $0.sentAt < $1.sentAt }
    }
}
