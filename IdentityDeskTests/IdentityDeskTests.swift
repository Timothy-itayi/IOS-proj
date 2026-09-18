import XCTest
@testable import IdentityDesk

@MainActor
final class PhaseATests: XCTestCase {
    
    var store: ScenarioStore!
    
    override func setUp() async throws {
        store = ScenarioStore()
        
        // For unit tests, load from test bundle where JSON resource is copied
        let testBundle = Bundle(for: type(of: self))
        store.loadScenario(from: testBundle)
        
        try await Task.sleep(nanoseconds: 100_000_000)
    }
    
    override func tearDown() {
        store = nil
    }
    
    func testScenarioLoads() {
        XCTAssertNotNil(store.scenario, "Scenario should load from demo-vertical-slice.json. Check console for DecodingError if nil.")
        XCTAssertEqual(store.operatorName, "Daniel", "Operator should be Daniel")
        
        // Verify phases loaded
        if let scenario = store.scenario {
            XCTAssertGreaterThan(scenario.phases.count, 0, "Scenario should have phases")
            XCTAssertGreaterThan(scenario.sharedBaseline.users.count, 0, "Baseline should have users")
        }
    }
    
    func testPhaseATicketExists() {
        let sarahTicket = store.tickets.first { $0.id == "INC-7001" }
        
        XCTAssertNotNil(sarahTicket, "Sarah's ticket INC-7001 should exist in Phase A")
        XCTAssertEqual(sarahTicket?.subject, "Password isn't working again.", "Ticket subject should match")
        XCTAssertEqual(sarahTicket?.requesterId, "U-SARAH", "Requester should be Sarah")
        XCTAssertEqual(sarahTicket?.priority, "Normal", "Priority should be Normal")
        XCTAssertEqual(sarahTicket?.status, "Open", "Status should be Open")
    }
    
    func testPhaseASarahUserExists() {
        let sarah = store.user(withId: "U-SARAH")
        
        XCTAssertNotNil(sarah, "Sarah Chen should exist in users")
        XCTAssertEqual(sarah?.displayName, "Sarah Chen", "Display name should be Sarah Chen")
        XCTAssertEqual(sarah?.status, "ACTIVE", "Sarah should start as ACTIVE")
        XCTAssertEqual(sarah?.roleId, "R-EMPLOYEE", "Sarah should have Employee role")
        XCTAssertEqual(sarah?.departmentId, "D-OPS", "Sarah should be in Operations dept")
    }
    
    func testPhaseACurrentObjective() {
        let objective = store.currentObjective
        
        XCTAssertEqual(objective, "Help Sarah reset her password", "Phase A objective should be about Sarah's password")
    }
    
    func testPhaseAAvailableActions() {
        let actions = store.availableActions(for: "INC-7001")
        
        XCTAssertTrue(actions.contains("resetPassword"), "resetPassword should be available for INC-7001")
        XCTAssertTrue(actions.contains("close"), "close should be available for INC-7001")
        XCTAssertEqual(actions.count, 2, "Only resetPassword and close should be available")
        XCTAssertFalse(actions.contains("unlockAccount"), "unlockAccount should NOT be available in Phase A")
    }
    
    func testResetPasswordUpdatesUserStatus() {
        var james = User(
            id: "U-TEST-LOCKED",
            displayName: "Test User",
            status: "LOCKED",
            roleId: "R-EMPLOYEE",
            managerId: nil,
            departmentId: "D-IT",
            groupIds: []
        )
        
        store.users.append(james)
        
        let initialUser = store.user(withId: "U-TEST-LOCKED")
        XCTAssertEqual(initialUser?.status, "LOCKED", "User should start as LOCKED")
        
        store.resetPassword(userId: "U-TEST-LOCKED")
        
        let updatedUser = store.user(withId: "U-TEST-LOCKED")
        XCTAssertEqual(updatedUser?.status, "ACTIVE", "User should be ACTIVE after password reset")
        XCTAssertNotEqual(initialUser?.status, updatedUser?.status, "Status should have changed from LOCKED to ACTIVE")
    }
    
    func testCloseTicketWithNotes() {
        let notes = "Password reset completed. User verified via email."
        
        store.closeTicket("INC-7001", notes: notes)
        
        // Closing INC-7001 completes Phase A and advances to Phase B (which seeds INC-7002)
        XCTAssertNil(store.tickets.first { $0.id == "INC-7001" }, "INC-7001 should be removed from queue")
        XCTAssertNotNil(store.tickets.first { $0.id == "INC-7002" }, "Phase B ticket INC-7002 should appear after phase advance")
        XCTAssertEqual(store.currentPhase?.id, "B_account_unlock", "Should advance to Phase B after closing Phase A ticket")
    }
    
    func testPhaseACompletionAdvancesPhase() {
        let initialPhase = store.currentPhaseIndex
        XCTAssertEqual(store.currentPhase?.id, "A_sarah_password_reset", "Should start on Phase A")
        
        store.closeTicket("INC-7001", notes: "Resolved")
        
        XCTAssertGreaterThan(store.currentPhaseIndex, initialPhase, "Phase index should advance after completing Phase A")
        XCTAssertTrue(store.completedFlags.contains("learned_password_reset"), "Should have learned_password_reset flag")
    }
    
    func testPhaseACompletionLoadsPhaseB() {
        store.closeTicket("INC-7001", notes: "Resolved")
        
        XCTAssertEqual(store.currentPhase?.id, "B_account_unlock", "Should advance to Phase B after completing A")
        
        let jamesTicket = store.tickets.first { $0.id == "INC-7002" }
        XCTAssertNotNil(jamesTicket, "James's ticket should load after Phase A completes")
    }
    
    func testTicketNotesCanBeSet() {
        let ticket = store.tickets.first { $0.id == "INC-7001" }
        XCTAssertNotNil(ticket, "INC-7001 should exist")
        
        var updatedTicket = ticket!
        updatedTicket.notes = "Identity verified via manager call"
        
        XCTAssertEqual(updatedTicket.notes, "Identity verified via manager call", "Notes should be settable")
    }
    
    func testDepartmentForSarah() {
        let ops = store.department(withId: "D-OPS")
        
        XCTAssertNotNil(ops, "Operations department should exist")
        XCTAssertEqual(ops?.name, "Operations", "Department name should be Operations")
        XCTAssertTrue(ops?.memberIds.contains("U-SARAH") ?? false, "Sarah should be a member of Operations")
    }
    
    func testRoleForSarah() {
        let sarah = store.user(withId: "U-SARAH")
        let role = store.role(withId: sarah?.roleId)
        
        XCTAssertNotNil(role, "Sarah's role should exist")
        XCTAssertEqual(role?.name, "Employee", "Role name should be Employee")
    }
    
    func testManagerForSarah() {
        let sarah = store.user(withId: "U-SARAH")
        let manager = store.user(withId: sarah?.managerId ?? "")
        
        XCTAssertNotNil(manager, "Sarah's manager should exist")
        XCTAssertEqual(manager?.id, "U-MARTIN", "Manager should be Martin")
        XCTAssertEqual(manager?.displayName, "Martin Hale", "Manager name should be Martin Hale")
    }
    
    func testPhaseAOnlyOneTicketInitially() {
        let phaseATickets = store.tickets.filter { ticket in
            store.availableActions(for: ticket.id).contains("resetPassword")
        }
        
        XCTAssertEqual(phaseATickets.count, 1, "Only one ticket should have resetPassword action in Phase A")
        XCTAssertEqual(phaseATickets.first?.id, "INC-7001", "That ticket should be INC-7001")
    }
    
    func testEmptyFieldRenderingForMissingManager() {
        let userWithNoManager = User(
            id: "U-NO-MGR",
            displayName: "Orphan User",
            status: "ACTIVE",
            roleId: "R-EMPLOYEE",
            managerId: nil,
            departmentId: "D-IT",
            groupIds: []
        )
        
        store.users.append(userWithNoManager)
        
        let manager = store.user(withId: userWithNoManager.managerId ?? "")
        XCTAssertNil(manager, "Manager should be nil when managerId is nil")
        
        let displayValue = manager?.displayName ?? nil
        XCTAssertNil(displayValue, "Display value should be nil, which EmptyFieldText renders as em-dash")
    }
    
    func testEmptyFieldRenderingForMissingRole() {
        let userWithNoRole = User(
            id: "U-NO-ROLE",
            displayName: "Roleless User",
            status: "ACTIVE",
            roleId: nil,
            managerId: nil,
            departmentId: "D-IT",
            groupIds: []
        )
        
        store.users.append(userWithNoRole)
        
        let role = store.role(withId: userWithNoRole.roleId)
        XCTAssertNil(role, "Role should be nil when roleId is nil")
        
        let displayValue = role?.name ?? nil
        XCTAssertNil(displayValue, "Display value should be nil, which EmptyFieldText renders as em-dash")
    }
    
    func testEmptyFieldRenderingForMissingDepartmentFields() {
        let brokenDept = Department(
            id: "D-BROKEN",
            name: "Broken Department",
            headId: nil,
            managerId: nil,
            costCentre: nil,
            memberIds: [],
            policyIds: []
        )
        
        store.departments.append(brokenDept)
        
        let dept = store.department(withId: "D-BROKEN")
        XCTAssertNotNil(dept, "Department should exist")
        XCTAssertNil(dept?.headId, "Head should be nil")
        XCTAssertNil(dept?.managerId, "Manager should be nil")
        XCTAssertNil(dept?.costCentre, "Cost centre should be nil")
        
        let head = store.user(withId: dept?.headId ?? "")
        XCTAssertNil(head, "Head user lookup should return nil")
        
        let manager = store.user(withId: dept?.managerId ?? "")
        XCTAssertNil(manager, "Manager user lookup should return nil")
    }
    
    func testEmptyFieldRenderingForNonExistentUser() {
        let user = store.user(withId: "U-DOES-NOT-EXIST")
        XCTAssertNil(user, "Non-existent user should return nil")
        
        let displayValue = user?.displayName ?? nil
        XCTAssertNil(displayValue, "Display value should be nil, which EmptyFieldText renders as em-dash")
    }
    
    func testEmptyFieldRenderingForNonExistentDepartment() {
        let dept = store.department(withId: "D-DOES-NOT-EXIST")
        XCTAssertNil(dept, "Non-existent department should return nil")
    }
    
    func testTimeFormatterNow() {
        XCTAssertEqual(TimeFormatter.formatScenarioTime("T+0m"), "now", "T+0m should format as 'now'")
    }
    
    func testTimeFormatterMinutes() {
        XCTAssertEqual(TimeFormatter.formatScenarioTime("T+5m"), "5m ago", "T+5m should format as '5m ago'")
        XCTAssertEqual(TimeFormatter.formatScenarioTime("T+45m"), "45m ago", "T+45m should format as '45m ago'")
    }
    
    func testTimeFormatterHours() {
        XCTAssertEqual(TimeFormatter.formatScenarioTime("T+60m"), "1h ago", "T+60m should format as '1h ago'")
        XCTAssertEqual(TimeFormatter.formatScenarioTime("T+120m"), "2h ago", "T+120m should format as '2h ago'")
    }
    
    func testTimeFormatterHoursAndMinutes() {
        XCTAssertEqual(TimeFormatter.formatScenarioTime("T+65m"), "1h 5m ago", "T+65m should format as '1h 5m ago'")
        XCTAssertEqual(TimeFormatter.formatScenarioTime("T+95m"), "1h 35m ago", "T+95m should format as '1h 35m ago'")
    }
    
    func testTimeFormatterPassthrough() {
        XCTAssertEqual(TimeFormatter.formatScenarioTime("invalid"), "invalid", "Invalid format should pass through unchanged")
        XCTAssertEqual(TimeFormatter.formatScenarioTime("2024-01-01"), "2024-01-01", "ISO date should pass through unchanged")
    }
    
    func testSaveAndRestoreProgress() {
        store.currentPhaseIndex = 2
        store.completedFlags.insert("test_flag")
        store.chromeRevision = "postMaintenance"
        
        store.saveProgress()
        
        let newStore = ScenarioStore()
        newStore.scenario = store.scenario
        newStore.roles = store.roles
        newStore.groups = store.groups
        newStore.policies = store.policies
        
        let restored = newStore.restoreProgress()
        
        XCTAssertTrue(restored, "Progress should be restored successfully")
        XCTAssertEqual(newStore.currentPhaseIndex, 2, "Phase index should be restored")
        XCTAssertTrue(newStore.completedFlags.contains("test_flag"), "Completed flags should be restored")
        XCTAssertEqual(newStore.chromeRevision, "postMaintenance", "Chrome revision should be restored")
    }
    
    func testResetProgressClearsState() {
        store.currentPhaseIndex = 3
        store.completedFlags.insert("some_flag")
        store.chromeRevision = "postMaintenance"
        store.saveProgress()
        
        store.resetProgress()
        
        XCTAssertEqual(store.currentPhaseIndex, 0, "Phase index should reset to 0")
        XCTAssertTrue(store.completedFlags.isEmpty, "Completed flags should be cleared")
        XCTAssertEqual(store.chromeRevision, "baseline", "Chrome revision should reset to baseline")
        
        let newStore = ScenarioStore()
        let restored = newStore.restoreProgress()
        XCTAssertFalse(restored, "Should not restore progress after reset")
    }
    
    func testSector7EmptyFieldsPhaseF() {
        // Phase F depends on "post_maintenance" flag from Phase E completion
        store.completedFlags.insert("post_maintenance")
        store.currentPhaseIndex = 5
        store.advanceToNextPhase()
        
        let sector7User = store.user(withId: "X-USER-417")
        XCTAssertNotNil(sector7User, "Sector 7 user should exist in Phase F")
        XCTAssertNil(sector7User?.roleId, "Sector 7 user should have nil roleId")
        XCTAssertNil(sector7User?.managerId, "Sector 7 user should have nil managerId")
        
        let sector7Dept = store.department(withId: "D-SECTOR7")
        XCTAssertNotNil(sector7Dept, "Sector 7 department should exist")
        XCTAssertNil(sector7Dept?.headId, "Sector 7 dept should have nil headId")
        XCTAssertNil(sector7Dept?.managerId, "Sector 7 dept should have nil managerId")
        XCTAssertNil(sector7Dept?.costCentre, "Sector 7 dept should have nil costCentre")
        
        let role = store.role(withId: sector7User?.roleId)
        XCTAssertNil(role, "Sector 7 role lookup should return nil")
        
        let manager = store.user(withId: sector7User?.managerId ?? "")
        XCTAssertNil(manager, "Sector 7 manager lookup should return nil")
        
        let head = store.user(withId: sector7Dept?.headId ?? "")
        XCTAssertNil(head, "Sector 7 dept head lookup should return nil")
    }
    
    func testEntitlementEmptyFieldRenderingInheritedNoParent() {
        // Phase F depends on "post_maintenance" flag from Phase E completion
        store.completedFlags.insert("post_maintenance")
        store.currentPhaseIndex = 5
        store.advanceToNextPhase()
        
        let sector7Ent = store.entitlements.first { $0.id == "E-S7-ORPHAN" }
        XCTAssertNotNil(sector7Ent, "Sector 7 entitlement should exist")
        XCTAssertEqual(sector7Ent?.sourceType, "Inherited", "Source type should be Inherited")
        XCTAssertNil(sector7Ent?.sourceLabel, "Source label should be nil for orphaned inherited entitlement")
        XCTAssertNil(sector7Ent?.sourceId, "Source ID should be nil")
        XCTAssertNil(sector7Ent?.policyId, "Policy ID should be nil")
        
        let sourceDisplayValue = sector7Ent?.sourceLabel ?? nil
        XCTAssertNil(sourceDisplayValue, "Source label nil should render as em-dash")
        
        let policy = store.policy(withId: sector7Ent?.policyId)
        XCTAssertNil(policy, "Policy lookup should return nil")
    }
    
    func testResetProgressClearsDataAndRestartsDemo() {
        // Advance to Phase B first
        store.closeTicket("INC-7001", notes: "Resolved")
        
        XCTAssertEqual(store.currentPhase?.id, "B_account_unlock", "Should be on Phase B")
        XCTAssertTrue(store.completedFlags.contains("learned_password_reset"), "Should have completion flag")
        XCTAssertGreaterThan(store.currentPhaseIndex, 0, "Phase index should be > 0")
        
        // Now reset
        store.resetProgress()
        
        // Verify state reset
        XCTAssertEqual(store.currentPhaseIndex, 0, "Phase index should reset to 0")
        XCTAssertEqual(store.completedFlags.count, 0, "Completed flags should be cleared")
        XCTAssertEqual(store.chromeRevision, "baseline", "Chrome revision should reset to baseline")
        XCTAssertEqual(store.selectedWindow, .tickets, "Selected window should reset to tickets")
        
        // Verify data reloaded
        XCTAssertEqual(store.currentPhase?.id, "A_sarah_password_reset", "Should be back on Phase A")
        XCTAssertNotNil(store.tickets.first { $0.id == "INC-7001" }, "Phase A ticket should exist again")
        XCTAssertNil(store.tickets.first { $0.id == "INC-7002" }, "Phase B ticket should not exist")
    }

    func testMessagesForOperatorIncludesOutboundReplies() {
        guard let operatorId = store.scenario?.operator.id else {
            XCTFail("Operator ID should exist")
            return
        }
        
        let outboundMessage = Message(
            id: "M-TEST-OUTBOUND",
            fromUserId: operatorId,
            toUserId: "U-MARTIN",
            body: "Test reply to Martin",
            sentAt: "T+115m",
            hasEmoji: false,
            isImpostor: nil
        )
        
        store.messages.append(outboundMessage)
        
        let operatorMessages = store.messagesForOperator()
        let containsOutbound = operatorMessages.contains { $0.id == "M-TEST-OUTBOUND" }
        
        XCTAssertTrue(containsOutbound, "Operator's outbound messages should appear in messagesForOperator()")
        
        let outboundCount = operatorMessages.filter { $0.fromUserId == operatorId }.count
        XCTAssertGreaterThan(outboundCount, 0, "Should include at least the test outbound message")
 
    }
}
