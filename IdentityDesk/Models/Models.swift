import Foundation

struct Ticket: Codable, Identifiable, Equatable {
    let id: String
    let subject: String
    let requesterId: String
    let departmentId: String
    let priority: String
    let status: String
    let openedAt: String
    let description: String
    var notes: String?
}

struct User: Codable, Identifiable, Equatable {
    let id: String
    let displayName: String
    var status: String
    let roleId: String?
    let managerId: String?
    let departmentId: String
    let groupIds: [String]
}

struct AuthenticationEvent: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    let timestamp: String
    let result: String
    let reason: String
}

struct Department: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    var headId: String?
    var managerId: String?
    var costCentre: String?
    var memberIds: [String]
    var policyIds: [String]
}

struct Role: Codable, Identifiable, Equatable {
    let id: String
    let name: String
}

struct UserGroup: Codable, Identifiable, Equatable {
    let id: String
    let name: String
}

struct Entitlement: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let sourceType: String
    let sourceLabel: String?
    let sourceId: String?
    let policyId: String?
    var status: String
    let userId: String
}

struct Policy: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let rules: [String]
    let appliesTo: String
}

struct Message: Codable, Identifiable, Equatable {
    let id: String
    let fromUserId: String
    let toUserId: String
    let body: String
    let sentAt: String
    let hasEmoji: Bool
    let isImpostor: Bool?
    let triggersFlag: String?
    
    enum CodingKeys: String, CodingKey {
        case id, fromUserId, toUserId, body, sentAt, hasEmoji, isImpostor, triggersFlag
    }
    
    init(id: String, fromUserId: String, toUserId: String, body: String, sentAt: String, hasEmoji: Bool, isImpostor: Bool? = nil, triggersFlag: String? = nil) {
        self.id = id
        self.fromUserId = fromUserId
        self.toUserId = toUserId
        self.body = body
        self.sentAt = sentAt
        self.hasEmoji = hasEmoji
        self.isImpostor = isImpostor
        self.triggersFlag = triggersFlag
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        fromUserId = try container.decode(String.self, forKey: .fromUserId)
        toUserId = try container.decode(String.self, forKey: .toUserId)
        body = try container.decode(String.self, forKey: .body)
        sentAt = try container.decode(String.self, forKey: .sentAt)
        hasEmoji = try container.decodeIfPresent(Bool.self, forKey: .hasEmoji) ?? false
        isImpostor = try container.decodeIfPresent(Bool.self, forKey: .isImpostor)
        triggersFlag = try container.decodeIfPresent(String.self, forKey: .triggersFlag)
    }
}

struct Document: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let body: String
    let tags: [String]
    let createdAt: String
}

struct ReplyChip: Codable, Identifiable, Equatable {
    let id: String
    let text: String
    let setId: String
    let triggersFlag: String?
    let triggersResponse: String?
    let isRisky: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, text, setId, triggersFlag, triggersResponse, isRisky
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        setId = try container.decode(String.self, forKey: .setId)
        triggersFlag = try container.decodeIfPresent(String.self, forKey: .triggersFlag)
        triggersResponse = try container.decodeIfPresent(String.self, forKey: .triggersResponse)
        isRisky = try container.decodeIfPresent(Bool.self, forKey: .isRisky)
    }
}

struct ObjectiveTransition: Codable, Equatable {
    let flag: String
    let newObjective: String
}

struct Correlation: Identifiable, Equatable {
    let id: String
    let ticketId: String?
    let userId: String?
    let departmentId: String?
    let description: String
}

struct ScenarioPhase: Codable {
    let id: String
    let objective: String
    let teaches: [String]
    let dependsOn: [String]?
    let seed: PhaseSeed?
    let availableActions: [String: [String]]
    let completion: PhaseCompletion
    let objectiveTransitions: [ObjectiveTransition]?
    
    enum CodingKeys: String, CodingKey {
        case id, objective, teaches, dependsOn, seed, availableActions, completion, objectiveTransitions
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        objective = try container.decode(String.self, forKey: .objective)
        teaches = try container.decodeIfPresent([String].self, forKey: .teaches) ?? []
        dependsOn = try container.decodeIfPresent([String].self, forKey: .dependsOn)
        seed = try container.decodeIfPresent(PhaseSeed.self, forKey: .seed)
        availableActions = try container.decodeIfPresent([String: [String]].self, forKey: .availableActions) ?? [:]
        completion = try container.decode(PhaseCompletion.self, forKey: .completion)
        objectiveTransitions = try container.decodeIfPresent([ObjectiveTransition].self, forKey: .objectiveTransitions)
    }
}

struct PhaseSeed: Codable {
    let users: [User]?
    let tickets: [Ticket]?
    let authEvents: [AuthenticationEvent]?
    let departments: [Department]?
    let entitlements: [Entitlement]?
    let messages: [Message]?
    let documents: [Document]?
    let replyChips: [ReplyChip]?
}

struct PhaseCompletion: Codable {
    let ticketClosed: String?
    let userStatus: [String: String]?
    let entitlementStatus: [String: String]?
    let flags: [String]
    let demoEnd: Bool?
    
    enum CodingKeys: String, CodingKey {
        case ticketClosed, userStatus, entitlementStatus, flags, demoEnd
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ticketClosed = try container.decodeIfPresent(String.self, forKey: .ticketClosed)
        userStatus = try container.decodeIfPresent([String: String].self, forKey: .userStatus)
        entitlementStatus = try container.decodeIfPresent([String: String].self, forKey: .entitlementStatus)
        flags = try container.decodeIfPresent([String].self, forKey: .flags) ?? []
        demoEnd = try container.decodeIfPresent(Bool.self, forKey: .demoEnd)
    }
}

struct ScenarioData: Codable {
    let id: String
    let title: String
    let `operator`: OperatorInfo
    let phases: [ScenarioPhase]
    let sharedBaseline: SharedBaseline
}

struct OperatorInfo: Codable {
    let id: String
    let displayName: String
}

struct SharedBaseline: Codable {
    let users: [User]
    let departments: [Department]
    let roles: [Role]
    let groups: [UserGroup]
    let policies: [Policy]
}

enum Window: String, CaseIterable {
    case tickets = "Tickets"
    case user = "User"
    case dept = "Dept"
    case access = "Access"
    case correlation = "Correlation"
    case msg = "Msg"
}

enum AccessFilter: String, CaseIterable {
    case all = "All"
    case role = "Role"
    case group = "Group"
    case inherited = "Inherited"
}
