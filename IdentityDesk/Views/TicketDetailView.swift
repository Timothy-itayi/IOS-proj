import SwiftUI

struct TicketDetailView: View {
    @ObservedObject var store: ScenarioStore
    let ticket: Ticket
    @Binding var isPresented: Bool
    @State private var notes: String = ""
    @State private var showSuccessStatus: Bool = false
    @State private var successStatusMessage: String = ""
    @State private var notesHeight: CGFloat = 80
    @State private var isNotesFieldFocused: Bool = false
    
    private var availableActions: [String] {
        store.availableActions(for: ticket.id)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.15, green: 0.15, blue: 0.15)
                    .ignoresSafeArea()
                
                ScrollViewWithKeyboardDismissal(hideKeyboard: hideKeyboard) {
                    VStack(alignment: .leading, spacing: 16) {
                        ticketInfoSection
                        requesterSection
                        descriptionSection
                        notesSection
                        actionsSection
                    }
                    .padding()
                }
            }
            .navigationTitle(ticket.id)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        isPresented = false
                    }
                    .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75))
                }
            }
            .onAppear {
                store.markTicketViewed(ticket.id)
            }
        }
    }
    
    private var ticketInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                FieldLabel(text: "STATUS")
                Spacer()
                Text(ticket.status)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
            }
            
            HStack {
                FieldLabel(text: "PRIORITY")
                Spacer()
                Text(ticket.priority)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(ticket.priority == "High" ?
                        Color(red: 0.72, green: 0.29, blue: 0.23) :
                        Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.55))
            }
            
            HStack {
                FieldLabel(text: "OPENED")
                Spacer()
                Text(TimeFormatter.formatScenarioTime(ticket.openedAt))
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
            }
        }
        .padding()
        .panelStyle()
    }
    
    private var requesterSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            FieldLabel(text: "REQUESTER")
            
            if let requester = store.user(withId: ticket.requesterId) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(requester.displayName)
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                    
                    Text("Status: \(requester.status)")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.6))
                    
                    Button(action: {
                        store.selectedUserId = requester.id
                        store.selectedWindow = .user
                        isPresented = false
                    }) {
                        Text("View User Profile →")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.7))
                    }
                }
            }
        }
        .padding()
        .panelStyle()
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            FieldLabel(text: "DESCRIPTION")
            Text(ticket.description)
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
        }
        .padding()
        .panelStyle()
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            FieldLabel(text: "NOTES")
            
            ZStack(alignment: .topLeading) {
                if #available(iOS 16.0, *) {
                    TextEditor(text: $notes)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                        .frame(minHeight: notesHeight)
                        .scrollContentBackground(.hidden)
                        .background(Color(red: 0.95, green: 0.94, blue: 0.92))
                        .cornerRadius(4)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") {
                                    hideKeyboard()
                                }
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                            }
                        }
                        .onTapGesture {
                            isNotesFieldFocused = true
                            notesHeight = max(120, notesHeight)
                        }
                } else {
                    TextEditor(text: $notes)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                        .frame(minHeight: notesHeight)
                        .background(Color(red: 0.95, green: 0.94, blue: 0.92))
                        .cornerRadius(4)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") {
                                    hideKeyboard()
                                }
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                            }
                        }
                        .onTapGesture {
                            isNotesFieldFocused = true
                            notesHeight = max(120, notesHeight)
                        }
                }
                
                if notes.isEmpty {
                    Text("Case notes (saved on close)")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.35))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 8)
                        .allowsHitTesting(false)
                }
            }
        }
        .padding()
        .panelStyle()
    }
    
    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            FieldLabel(text: "ACTIONS")
            
            VStack(spacing: 8) {
                if availableActions.contains("resetPassword") {
                    ResolveButton(
                        title: "RESET PASSWORD",
                        successLabel: "PASSWORD RESET"
                    ) {
                        store.resetPassword(userId: ticket.requesterId)
                        showSuccessStatus(message: "Status updated · User ACTIVE")
                    }
                }
                
                if availableActions.contains("unlockAccount") {
                    ResolveButton(
                        title: "UNLOCK ACCOUNT",
                        successLabel: "ACCOUNT UNLOCKED"
                    ) {
                        store.unlockAccount(userId: ticket.requesterId)
                        showSuccessStatus(message: "Status updated · User ACTIVE")
                    }
                }
                
                if availableActions.contains("assignEntitlement") {
                    AssignButton(
                        ticket: ticket,
                        store: store,
                        onSuccess: {
                            showSuccessStatus(message: "Status updated · Entitlement ACTIVE")
                        }
                    )
                }
                
                if availableActions.contains("close") {
                    ActionButton(title: "CLOSE TICKET", isPrimary: false) {
                        store.closeTicket(ticket.id, notes: notes.isEmpty ? nil : notes)
                        isPresented = false
                    }
                }
            }
            
            if showSuccessStatus {
                HStack(spacing: 8) {
                    Text(successStatusMessage)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.8))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color(red: 0.48, green: 0.62, blue: 0.50).opacity(0.18))
                .cornerRadius(4)
            }
        }
        .padding()
        .panelStyle()
    }
    
    private func showSuccessStatus(message: String) {
        successStatusMessage = message
        withAnimation {
            showSuccessStatus = true
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        isNotesFieldFocused = false
        notesHeight = 80
    }
}

struct ScrollViewWithKeyboardDismissal<Content: View>: View {
    let hideKeyboard: () -> Void
    let content: () -> Content
    
    var body: some View {
        if #available(iOS 16.0, *) {
            ScrollView {
                content()
            }
            .scrollDismissesKeyboard(.interactively)
        } else {
            ScrollView {
                content()
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
}

struct ActionButton: View {
    let title: String
    var isPrimary: Bool = true
    var isDisabled: Bool = false
    let action: () -> Void
    
    @State private var isPressed: Bool = false
    @State private var showSuccess: Bool = false
    @State private var successLabel: String = ""
    
    var body: some View {
        Button(action: {
            if !isDisabled && !showSuccess {
                action()
            }
        }) {
            HStack(spacing: 4) {
                if showSuccess {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                }
                Text(showSuccess ? successLabel : title)
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
            }
            .foregroundColor(buttonTextColor)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(buttonBackgroundColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(buttonStrokeColor, lineWidth: isPrimary || isDisabled ? 0 : 1)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isDisabled && !showSuccess && !isPressed {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    if isPressed {
                        isPressed = false
                    }
                }
        )
        .disabled(isDisabled || showSuccess)
    }
    
    private var buttonTextColor: Color {
        if showSuccess {
            return Color(red: 0.96, green: 0.94, blue: 0.90)
        }
        if isDisabled {
            return Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.30)
        }
        if isPrimary {
            return Color(red: 0.96, green: 0.94, blue: 0.90)
        }
        return Color(red: 0.15, green: 0.15, blue: 0.15)
    }
    
    private var buttonBackgroundColor: Color {
        if showSuccess {
            return Color(red: 0.48, green: 0.62, blue: 0.50)
        }
        if isDisabled {
            return Color(red: 0.90, green: 0.88, blue: 0.84)
        }
        if isPrimary {
            let baseColor = Color(red: 0.15, green: 0.15, blue: 0.15)
            return isPressed ? baseColor.opacity(0.88) : baseColor
        }
        let baseColor = Color(red: 0.90, green: 0.88, blue: 0.84)
        return isPressed ? baseColor.opacity(0.88) : baseColor
    }
    
    private var buttonStrokeColor: Color {
        if isDisabled {
            return Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.30)
        }
        return Color(red: 0.15, green: 0.15, blue: 0.15)
    }
    
    func triggerSuccess(label: String) {
        successLabel = label
        withAnimation {
            showSuccess = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation {
                showSuccess = true
            }
        }
    }
}

struct ResolveButton: View {
    let title: String
    let successLabel: String
    let action: () -> Void
    
    @State private var isPressed: Bool = false
    @State private var showSuccess: Bool = false
    
    var body: some View {
        Button(action: {
            if !showSuccess {
                action()
                withAnimation {
                    showSuccess = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                }
            }
        }) {
            HStack(spacing: 4) {
                if showSuccess {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                }
                Text(showSuccess ? successLabel : title)
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
            }
            .foregroundColor(showSuccess ? Color(red: 0.96, green: 0.94, blue: 0.90) : Color(red: 0.96, green: 0.94, blue: 0.90))
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(showSuccess ? Color(red: 0.48, green: 0.62, blue: 0.50) : (isPressed ? Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.88) : Color(red: 0.15, green: 0.15, blue: 0.15)))
            .cornerRadius(8)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !showSuccess && !isPressed {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    if isPressed {
                        isPressed = false
                    }
                }
        )
        .disabled(showSuccess)
    }
}

struct AssignButton: View {
    let ticket: Ticket
    @ObservedObject var store: ScenarioStore
    let onSuccess: () -> Void
    
    @State private var isPressed: Bool = false
    @State private var showSuccess: Bool = false
    @State private var showNothingToAssign: Bool = false
    
    var body: some View {
        Button(action: {
            if !showSuccess && !showNothingToAssign {
                if let ent = store.entitlements.first(where: { $0.userId == ticket.requesterId && $0.status == "REVOKED" }) {
                    store.assignEntitlement(entitlementId: ent.id)
                    withAnimation {
                        showSuccess = true
                    }
                    onSuccess()
                } else {
                    withAnimation {
                        showNothingToAssign = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        withAnimation {
                            showNothingToAssign = false
                        }
                    }
                }
            }
        }) {
            HStack(spacing: 4) {
                if showSuccess {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                }
                Text(showSuccess ? "ENTITLEMENT ASSIGNED" : (showNothingToAssign ? "NOTHING TO ASSIGN" : "ASSIGN ENTITLEMENT"))
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
            }
            .foregroundColor(showSuccess ? Color(red: 0.96, green: 0.94, blue: 0.90) : Color(red: 0.96, green: 0.94, blue: 0.90))
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(showSuccess ? Color(red: 0.48, green: 0.62, blue: 0.50) : (isPressed ? Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.88) : Color(red: 0.15, green: 0.15, blue: 0.15)))
            .cornerRadius(8)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !showSuccess && !showNothingToAssign && !isPressed {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    if isPressed {
                        isPressed = false
                    }
                }
        )
        .disabled(showSuccess)
    }
}
