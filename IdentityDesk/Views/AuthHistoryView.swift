import SwiftUI

struct AuthHistoryView: View {
    @ObservedObject var store: ScenarioStore
    let userId: String
    
    private var events: [AuthenticationEvent] {
        store.authHistory(for: userId)
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.15, green: 0.15, blue: 0.15)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 12) {
                    if events.isEmpty {
                        Text("No authentication events")
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75).opacity(0.5))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.top, 40)
                    } else {
                        ForEach(events) { event in
                            AuthEventRow(event: event)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Auth History")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AuthEventRow: View {
    let event: AuthenticationEvent
    
    private var resultColor: Color {
        switch event.result {
        case "success":
            return Color(red: 0.85, green: 0.82, blue: 0.75)
        case "fail":
            return Color(red: 1.0, green: 0.7, blue: 0.0)
        case "lockout":
            return Color(red: 1.0, green: 0.3, blue: 0.0)
        default:
            return Color(red: 0.85, green: 0.82, blue: 0.75)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(event.timestamp)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75).opacity(0.7))
                Spacer()
                Text(event.result.uppercased())
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(resultColor)
            }
            
            Text(event.reason)
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(Color(red: 0.85, green: 0.82, blue: 0.75))
        }
        .padding()
        .panelStyle()
    }
}
