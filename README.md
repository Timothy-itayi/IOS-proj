# Identity Desk

**Playable iOS SwiftUI shell for the Sector 7 demo vertical slice**

Identity Desk is a workplace identity and access management simulator with an alien clinical aesthetic. You play as Daniel, an IT technician working through increasingly strange support tickets.

## Requirements

- **Xcode 15.0+**
- **iOS 15.0+** (iPhone 11 or later)
- **macOS** for development

## Getting Started

### 1. Open the Project

```bash
# Open the Xcode project
open IdentityDesk.xcodeproj
```

Or in Xcode: **File → Open** and select `IdentityDesk.xcodeproj`

### 2. Select a Target Device

In Xcode's toolbar, select a simulator:
- Choose any **iPhone 11 or later** simulator
- Recommended: iPhone 14 Pro or iPhone 15

### 3. Build and Run

- Press **⌘R** or click the Play button in Xcode's toolbar
- The app will build and launch in the iOS Simulator

### 4. Play Through the Demo

The app loads scenario data from `IdentityDesk/Resources/demo-vertical-slice.json` and presents phases A–G:

**Phase A: Sarah's Password Reset**
- Open ticket INC-7001 from the Tickets window
- View Sarah's user profile (tap "View User Profile")
- Reset her password
- Close the ticket

**Phase B: Account Unlock**
- Handle ticket INC-7002 for James Okonkwo
- View his Auth History to see lockout events
- Unlock his account
- Close the ticket

**Phase C: R&D Governance**
- Process ticket INC-7003 about R&D department leadership change
- Navigate to Dept window to review department structure
- Notice baseline governance requirements (Head, Manager, Cost Centre)
- Close the ticket

**Phase D: Design Access**
- Resolve ticket INC-7004 for Maya Brooks
- Switch to Access window to view her entitlements
- Note the Access Source field (Role | Group | Inherited)
- Restore the revoked Design Shared Drive entitlement
- Close the ticket

**Phase F: Sector 7 Anomaly** (Phase E is maintenance stub)
- Ticket INC-7314 appears with broken baseline fields
- Department view shows "—" for Head, Manager, Cost Centre
- Entitlement shows Inherited with no parent source (→ "—")
- Actions are disabled (investigation only)

**Phase G: Fake Martin** (stub with message display)
- Martin's messages appear in Msg window
- Early messages follow normal patterns
- Later message contains emoji (anomaly tell)

## Architecture

### Data Flow
- **ScenarioStore**: `@ObservableObject` that loads `demo-vertical-slice.json` and manages game state
- **Phase progression**: Driven by completion flags, not hard-coded puzzle logic
- **Action gating**: Only actions listed in `availableActions` for the active ticket are enabled

### Key Files

```
IdentityDesk/
├── IdentityDeskApp.swift          # App entry point
├── ContentView.swift              # Chrome: header + window switcher + content area
├── Models/
│   └── Models.swift               # Codable data structures (Ticket, User, etc.)
├── Stores/
│   └── ScenarioStore.swift        # Game state manager, JSON loader
├── Views/
│   ├── TicketQueueView.swift     # Ticket list (window 1)
│   ├── TicketDetailView.swift    # Ticket detail + gated actions
│   ├── UserProfileView.swift     # User profile (window 2)
│   ├── AuthHistoryView.swift     # Auth event timeline
│   ├── DepartmentView.swift      # Department record (window 3)
│   ├── AccessView.swift          # Entitlements + filter chips (window 4)
│   ├── MessageView.swift         # Martin's messages (window 5)
│   └── PolicyView.swift          # Policy viewer (modal)
└── Resources/
    └── demo-vertical-slice.json   # Scenario seed data
```

## Visual Design

### Color Palette (Alien Clinical)
- **Background**: Charcoal void `rgb(38, 38, 38)`
- **Panels**: Bone `rgb(51, 51, 51)`
- **Text**: Off-white `rgb(217, 209, 191)`
- **Accent/Selection**: Amber `rgb(255, 179, 0)` — **ONLY** for selection, High priority, alerts

### Chrome Rules
- **Header**: `IDENTITY DESK · Operator {displayName}`
- **Window Switcher**: Exclusive tabs (Tickets | User | Dept | Access | Msg)
- **Empty fields**: Always render as em dash "—" (never hide required rows)
- **Department screen**: Always shows 5 rows (Head, Manager, Cost Centre, Members, Policies)
- **Entitlement rows**: Must show Access Source: Role | Group | Inherited

## Implementation Status

### ✅ Milestone 1: Phases A–D Playable
- [x] SwiftUI iOS project builds
- [x] Scenario JSON drives tickets/users/depts/entitlements/events
- [x] Wire-note field rules honored (em dash for missing values)
- [x] Player can complete phases A–D
- [x] Sector 7 broken fields render as "—"
- [x] Window switcher navigation
- [x] Action gating from scenario config

### 🚧 Stubs / Future Work
- [ ] **Phase E**: Maintenance UI refresh (currently just flag progression)
- [ ] **Phase G**: Interactive Fake Martin interrogation (messages display only)
- [ ] Timestamp formatting (currently shows "T+Xm" raw values)
- [ ] Enhanced animations/transitions
- [ ] Persistence (game state resets on app restart)

## Scenario Engine

The app does **not** hard-code puzzle logic. Instead:

1. **Load**: `ScenarioStore.loadScenario()` reads `demo-vertical-slice.json`
2. **Seed**: Each phase's `seed` object populates users, tickets, departments, etc.
3. **Gate**: Only actions in `phase.availableActions[ticketId]` are enabled
4. **Complete**: When `phase.completion` conditions are met, flags are added and the next phase loads
5. **Progress**: Phases with `dependsOn` wait for required flags before loading

To modify the scenario:
- Edit `IdentityDesk/Resources/demo-vertical-slice.json`
- Rebuild the app (Xcode automatically bundles the updated JSON)
- No code changes required for most puzzle adjustments

## Troubleshooting

### Simulator won't launch
- Ensure you've selected an iPhone 11+ simulator target
- Try **Product → Clean Build Folder** (⇧⌘K) then rebuild

### JSON not loading
- Check Xcode console for "Failed to load scenario"
- Verify `demo-vertical-slice.json` is in `IdentityDesk/Resources/`
- Ensure the file is included in the target (select file → File Inspector → Target Membership)

### Layout issues
- The app is designed for portrait orientation on iPhone
- iPad layout is supported but not optimized

## License

Sector 7 demo scaffold — engineering reference build
