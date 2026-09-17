import XCTest
@testable import IdentityDesk

@MainActor
final class PhaseATests: XCTestCase {
    
    var store: ScenarioStore!
    
    override func setUp() async throws {
        store = ScenarioStore()
        store.loadScenario()
        
        try await Task.sleep(nanoseconds: 100_000_000)
    }
    
    override func tearDown() {
        store = nil
    }
    
    func testScenarioLoads() {
        XCTAssertNotNil(store.scenario, "Scenario should load from demo-vertical-slice.json")
        XCTAssertEqual(store.operatorName, "Daniel", "Operator should be Daniel")
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
        let sarah = store.user(withId: "U-SARAH")
        XCTAssertNotNil(sarah, "Sarah should exist before reset")
        
        let initialStatus = sarah?.status
        
        store.resetPassword(userId: "U-SARAH")
        
        let updatedSarah = store.user(withId: "U-SARAH")
        XCTAssertEqual(updatedSarah?.status, "ACTIVE", "Sarah should remain ACTIVE after password reset")
        XCTAssertEqual(initialStatus, "ACTIVE", "Sarah was already ACTIVE (password reset doesn't change status in Phase A)")
    }
    
    func testCloseTicketWithNotes() {
        let initialTicketCount = store.tickets.count
        let notes = "Password reset completed. User verified via email."
        
        store.closeTicket("INC-7001", notes: notes)
        
        XCTAssertEqual(store.tickets.count, initialTicketCount - 1, "Ticket count should decrease by 1")
        XCTAssertNil(store.tickets.first { $0.id == "INC-7001" }, "INC-7001 should be removed from queue")
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
}
