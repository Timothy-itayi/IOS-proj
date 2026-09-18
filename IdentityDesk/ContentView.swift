import SwiftUI

struct ContentView: View {
    @StateObject private var store = ScenarioStore()
    @State private var showResetConfirmation = false
    @State private var showDemoCompleteSheet = false
    
    var body: some View {
        ZStack {
            Color(red: 0.15, green: 0.15, blue: 0.15)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                objectiveBar
                windowSwitcher
                contentArea
            }
        }
        .onAppear {
            if !store.restoreProgress() {
                store.loadScenario()
            }
        }
        .onChange(of: store.showDemoComplete) { newValue in
            if newValue {
                showDemoCompleteSheet = true
            }
        }
        .sheet(isPresented: $showResetConfirmation) {
            ResetConfirmationView(
                isPresented: $showResetConfirmation,
                onConfirm: {
                    store.resetProgress()
                }
            )
        }
        .sheet(isPresented: $showDemoCompleteSheet) {
            DemoCompleteView(
                isPresented: $showDemoCompleteSheet,
                store: store
            )
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("IDENTITY DESK · Operator \(store.operatorName)")
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75))
            
            if store.chromeRevision == "postMaintenance" {
                Text("v2.1")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75).opacity(0.4))
                    .padding(.leading, 4)
            }
            
            Spacer()
            
            Button(action: {
                showResetConfirmation = true
            }) {
                Text("RESET")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75).opacity(0.7))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(red: 0.2, green: 0.2, blue: 0.2))
                    .cornerRadius(3)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal)
        .frame(height: 44)
        .background(Color(red: 0.1, green: 0.1, blue: 0.1))
    }
    
    private var objectiveBar: some View {
        Group {
            if !store.currentObjective.isEmpty {
                HStack {
                    Text("OBJECTIVE")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75).opacity(0.6))
                    Text(store.currentObjective)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75))
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(red: 0.12, green: 0.12, blue: 0.12))
            }
        }
    }
    
    private var availableWindows: [Window] {
        Window.allCases.filter { window in
            if window == .correlation {
                return store.chromeRevision == "postMaintenance"
            }
            return true
        }
    }
    
    private var windowSwitcher: some View {
        HStack(spacing: 0) {
            ForEach(availableWindows, id: \.self) { window in
                Button(action: {
                    store.selectedWindow = window
                }) {
                    Text(window.rawValue)
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundColor(store.selectedWindow == window ?
                            Color(red: 1.0, green: 0.7, blue: 0.0) :
                            Color(red: 0.85, green: 0.82, blue: 0.75).opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(store.selectedWindow == window ?
                            Color(red: 0.2, green: 0.2, blue: 0.2) :
                            Color(red: 0.12, green: 0.12, blue: 0.12))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(Color(red: 0.1, green: 0.1, blue: 0.1))
    }
    
    private var contentArea: some View {
        Group {
            switch store.selectedWindow {
            case .tickets:
                TicketQueueView(store: store)
            case .user:
                UserProfileView(store: store)
            case .dept:
                DepartmentView(store: store)
            case .access:
                AccessView(store: store)
            case .correlation:
                CorrelationView(store: store)
            case .msg:
                MessageView(store: store)
            }
        }
    }
}

struct EmptyFieldText: View {
    let value: String?
    
    var body: some View {
        Text(value ?? "—")
            .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
    }
}

struct FieldLabel: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold, design: .monospaced))
            .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.5))
    }
}

struct PanelBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color(red: 0.90, green: 0.88, blue: 0.84))
            .cornerRadius(4)
    }
}

extension View {
    func panelStyle() -> some View {
        modifier(PanelBackground())
    }
}

struct ResetConfirmationView: View {
    @Binding var isPresented: Bool
    let onConfirm: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Reset progress?")
                    .font(.system(size: 17, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                
                Text("This clears save data and restarts the demo.")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.7))
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(red: 0.15, green: 0.15, blue: 0.15), lineWidth: 1)
                        )
                }
                
                Button(action: {
                    isPresented = false
                    onConfirm()
                }) {
                    Text("Reset")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(red: 0.15, green: 0.15, blue: 0.15))
                        .cornerRadius(4)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color(red: 0.90, green: 0.88, blue: 0.84))
    }
}

struct DemoCompleteView: View {
    @Binding var isPresented: Bool
    @ObservedObject var store: ScenarioStore
    @State private var showResetConfirmation = false
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                Text("SESSION COMPLETE")
                    .font(.system(size: 17, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                
                Text("Operator log closed. Identity Desk vertical slice finished.")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.7))
                
                Text("Tip build · A→G")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.55))
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                Button(action: {
                    showResetConfirmation = true
                }) {
                    Text("RESET DEMO")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color(red: 0.90, green: 0.88, blue: 0.84))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(red: 0.15, green: 0.15, blue: 0.15), lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    isPresented = false
                    store.showDemoComplete = false
                    store.selectedWindow = .tickets
                }) {
                    Text("DONE")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(red: 0.96, green: 0.94, blue: 0.90))
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color(red: 0.15, green: 0.15, blue: 0.15))
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color(red: 0.90, green: 0.88, blue: 0.84))
        .sheet(isPresented: $showResetConfirmation) {
            ResetConfirmationView(
                isPresented: $showResetConfirmation,
                onConfirm: {
                    store.resetProgress()
                    isPresented = false
                }
            )
        }
    }
}
