import Foundation

struct TimeFormatter {
    static func formatScenarioTime(_ timestamp: String) -> String {
        guard timestamp.hasPrefix("T+") && timestamp.hasSuffix("m") else {
            return timestamp
        }
        
        let minutesString = timestamp.dropFirst(2).dropLast(1)
        guard let minutes = Int(minutesString) else {
            return timestamp
        }
        
        if minutes == 0 {
            return "now"
        } else if minutes < 60 {
            return "\(minutes)m ago"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return "\(hours)h ago"
            } else {
                return "\(hours)h \(remainingMinutes)m ago"
            }
        }
    }
}
