import Foundation

enum PageKind: String, CaseIterable {
    case document
    case chores
    case expenses
    case rules
    case roommates
}

enum BlockKind: String, CaseIterable, Identifiable {
    case paragraph
    case heading1
    case heading2
    case checklist
    case callout
    case divider
    case database

    var id: String { rawValue }

    var title: String {
        switch self {
        case .paragraph: "Text"
        case .heading1: "Heading 1"
        case .heading2: "Heading 2"
        case .checklist: "To-do"
        case .callout: "Callout"
        case .divider: "Divider"
        case .database: "Table"
        }
    }

    var icon: String {
        switch self {
        case .paragraph: "text.alignleft"
        case .heading1: "h.square"
        case .heading2: "h.square.on.square"
        case .checklist: "checklist"
        case .callout: "lightbulb"
        case .divider: "minus"
        case .database: "tablecells"
        }
    }
}

enum SaveState {
    case saved
    case saving
    case offline
    case conflict

    var title: String {
        switch self {
        case .saved: "Saved"
        case .saving: "Saving..."
        case .offline: "Offline - changes are local"
        case .conflict: "Conflict - newer version available"
        }
    }

    var systemImage: String {
        switch self {
        case .saved: "checkmark.circle"
        case .saving: "arrow.triangle.2.circlepath"
        case .offline: "wifi.slash"
        case .conflict: "exclamationmark.triangle"
        }
    }
}

enum CommandAction: String, Identifiable, CaseIterable {
    case newPage
    case newChore
    case newExpense
    case newRule
    case toggleOffline
    case showConflict
    case makeReadOnly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .newPage: "New page"
        case .newChore: "New chore"
        case .newExpense: "New expense"
        case .newRule: "New house rule"
        case .toggleOffline: "Toggle offline state"
        case .showConflict: "Show conflict banner"
        case .makeReadOnly: "Toggle read-only"
        }
    }

    var subtitle: String {
        switch self {
        case .newPage: "Create a blank household thread"
        case .newChore: "Add a row to the chores table"
        case .newExpense: "Add a row to the expenses table"
        case .newRule: "Add a new rule block"
        case .toggleOffline: "Preview local-only changes"
        case .showConflict: "Preview sync conflict UI"
        case .makeReadOnly: "Preview permission state"
        }
    }

    var icon: String {
        switch self {
        case .newPage: "doc.badge.plus"
        case .newChore: "checklist"
        case .newExpense: "dollarsign.circle"
        case .newRule: "doc.text"
        case .toggleOffline: "wifi.slash"
        case .showConflict: "exclamationmark.triangle"
        case .makeReadOnly: "lock"
        }
    }
}

enum OnboardingIntent: String, CaseIterable, Identifiable {
    case apartment
    case chores
    case expenses
    case rules

    var id: String { rawValue }

    var title: String {
        switch self {
        case .apartment: "Run my apartment"
        case .chores: "Track chores only"
        case .expenses: "Split expenses"
        case .rules: "Write house rules"
        }
    }

    var subtitle: String {
        switch self {
        case .apartment: "Chores, bills, roommates, and rules in one place."
        case .chores: "Start with a shared task table."
        case .expenses: "Track who paid and who still owes."
        case .rules: "Make agreements clear without awkward texts."
        }
    }

    var icon: String {
        switch self {
        case .apartment: "🏠"
        case .chores: "🧹"
        case .expenses: "💸"
        case .rules: "📜"
        }
    }

    var defaultTemplate: StarterTemplate {
        switch self {
        case .apartment: .apartmentOS
        case .chores: .choreReset
        case .expenses: .billsAndSupplies
        case .rules: .apartmentOS
        }
    }
}

enum StarterTemplate: String, CaseIterable, Identifiable {
    case apartmentOS
    case choreReset
    case billsAndSupplies

    var id: String { rawValue }

    var title: String {
        switch self {
        case .apartmentOS: "Apartment OS"
        case .choreReset: "Chore Reset"
        case .billsAndSupplies: "Bills & Supplies"
        }
    }

    var subtitle: String {
        switch self {
        case .apartmentOS: "Dashboard, chores, expenses, rules, and roommates."
        case .choreReset: "A simple setup for keeping shared spaces clean."
        case .billsAndSupplies: "Track shared bills, groceries, and household supplies."
        }
    }

    var previewRows: [String] {
        switch self {
        case .apartmentOS: ["Home dashboard", "Chores table", "Expenses table", "House rules"]
        case .choreReset: ["Weekly reset note", "Bathroom/kitchen/trash chores", "Shared spaces page"]
        case .billsAndSupplies: ["Expenses table", "Supply list", "Reimbursement checklist"]
        }
    }
}

struct WorkspacePageIDs {
    let homeID: UUID
    let choresID: UUID
    let expensesID: UUID
    let rulesID: UUID
    let roommatesID: UUID
    let notesID: UUID
    let guestPolicyID: UUID
}

struct WorkspaceSeed {
    let householdName: String
    let pageIDs: WorkspacePageIDs
    let rootPageIDs: [UUID]
    let pages: [WorkspacePage]
    let chores: [ChoreRecord]
    let expenses: [ExpenseRecord]
    let roommates: [Roommate]
    let selectedPageID: UUID
}

struct FirstActionDraft {
    var title: String = ""
    var amount: Double = 0
}

struct WorkspacePage: Identifiable, Equatable {
    let id: UUID
    var parentID: UUID?
    var title: String
    var icon: String
    var kind: PageKind
    var childIDs: [UUID]
    var blocks: [EditorBlock]
    var isReadOnly: Bool
}

struct EditorBlock: Identifiable, Equatable {
    let id: UUID
    var kind: BlockKind
    var text: String
    var checked: Bool
}

struct ChoreRecord: Identifiable, Equatable {
    let id: UUID
    var title: String
    var assignee: String
    var status: String
    var dueDate: String
}

struct ExpenseRecord: Identifiable, Equatable {
    let id: UUID
    var title: String
    var amount: Double
    var paidBy: String
    var status: String
    var splitWith: String
}

struct Roommate: Identifiable, Equatable {
    let id: UUID
    var name: String
    var email: String
    var role: String
}

enum WorkspaceFactory {
    static func make(
        householdName rawName: String,
        intent: OnboardingIntent = .apartment,
        template: StarterTemplate = .apartmentOS,
        firstAction: FirstActionDraft? = nil
    ) -> WorkspaceSeed {
        let householdName = rawName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "My Apartment"
            : rawName.trimmingCharacters(in: .whitespacesAndNewlines)

        let ids = WorkspacePageIDs(
            homeID: UUID(),
            choresID: UUID(),
            expensesID: UUID(),
            rulesID: UUID(),
            roommatesID: UUID(),
            notesID: UUID(),
            guestPolicyID: UUID()
        )

        let roommates = [
            Roommate(id: UUID(), name: "Alex Kim", email: "alex@example.edu", role: "Owner"),
            Roommate(id: UUID(), name: "Maya Patel", email: "maya@example.edu", role: "Roommate"),
            Roommate(id: UUID(), name: "Jordan Lee", email: "jordan@example.edu", role: "Roommate"),
            Roommate(id: UUID(), name: "Priya Shah", email: "priya@example.edu", role: "Roommate")
        ]

        var chores = starterChores(for: template)
        var expenses = starterExpenses(for: template)
        var ruleBlocks = starterRuleBlocks(for: template)

        if let firstAction {
            let title = firstAction.title.trimmingCharacters(in: .whitespacesAndNewlines)
            if !title.isEmpty {
                switch intent {
                case .apartment, .chores:
                    chores.insert(ChoreRecord(id: UUID(), title: title, assignee: "Unassigned", status: "Not started", dueDate: "No due date"), at: 0)
                case .expenses:
                    expenses.insert(
                        ExpenseRecord(id: UUID(), title: title, amount: max(firstAction.amount, 0), paidBy: "Alex Kim", status: "Unpaid", splitWith: "Everyone"),
                        at: 0
                    )
                case .rules:
                    ruleBlocks.append(EditorBlock(id: UUID(), kind: .paragraph, text: title, checked: false))
                }
            }
        }

        let pages = [
            WorkspacePage(
                id: ids.homeID,
                parentID: nil,
                title: "Home",
                icon: "🏠",
                kind: .document,
                childIDs: [],
                blocks: homeBlocks(householdName: householdName, intent: intent, template: template),
                isReadOnly: false
            ),
            WorkspacePage(
                id: ids.choresID,
                parentID: nil,
                title: "Chores",
                icon: "🧹",
                kind: .chores,
                childIDs: [],
                blocks: [],
                isReadOnly: false
            ),
            WorkspacePage(
                id: ids.expensesID,
                parentID: nil,
                title: "Expenses",
                icon: "💸",
                kind: .expenses,
                childIDs: [],
                blocks: [],
                isReadOnly: false
            ),
            WorkspacePage(
                id: ids.rulesID,
                parentID: nil,
                title: "House Rules",
                icon: "📜",
                kind: .rules,
                childIDs: [ids.guestPolicyID],
                blocks: ruleBlocks,
                isReadOnly: false
            ),
            WorkspacePage(
                id: ids.guestPolicyID,
                parentID: ids.rulesID,
                title: template == .choreReset ? "Weekly Reset" : "Guest Policy",
                icon: template == .choreReset ? "🗓️" : "👋",
                kind: .document,
                childIDs: [],
                blocks: guestOrResetBlocks(for: template),
                isReadOnly: false
            ),
            WorkspacePage(
                id: ids.roommatesID,
                parentID: nil,
                title: "Roommates",
                icon: "👥",
                kind: .roommates,
                childIDs: [],
                blocks: [],
                isReadOnly: false
            )
        ]

        return WorkspaceSeed(
            householdName: householdName,
            pageIDs: ids,
            rootPageIDs: [ids.homeID, ids.choresID, ids.expensesID, ids.rulesID, ids.roommatesID],
            pages: pages,
            chores: chores,
            expenses: expenses,
            roommates: roommates,
            selectedPageID: ids.homeID
        )
    }

    private static func homeBlocks(householdName: String, intent: OnboardingIntent, template: StarterTemplate) -> [EditorBlock] {
        [
            EditorBlock(id: UUID(), kind: .heading1, text: householdName, checked: false),
            EditorBlock(id: UUID(), kind: .callout, text: "Your workspace is ready. Start with one shared responsibility, then let the dashboard keep the system visible.", checked: false),
            EditorBlock(id: UUID(), kind: .heading2, text: "Start here", checked: false),
            EditorBlock(id: UUID(), kind: .checklist, text: "Add one chore, expense, or rule", checked: intent != .apartment),
            EditorBlock(id: UUID(), kind: .checklist, text: "Review the \(template.title) starter pages", checked: false),
            EditorBlock(id: UUID(), kind: .checklist, text: "Invite roommates after the setup feels right", checked: false)
        ]
    }

    private static func starterChores(for template: StarterTemplate) -> [ChoreRecord] {
        switch template {
        case .apartmentOS:
            [
                ChoreRecord(id: UUID(), title: "Take out trash", assignee: "Maya Patel", status: "Not started", dueDate: "May 6"),
                ChoreRecord(id: UUID(), title: "Clean bathroom", assignee: "Jordan Lee", status: "In progress", dueDate: "May 8"),
                ChoreRecord(id: UUID(), title: "Buy paper towels", assignee: "Priya Shah", status: "Done", dueDate: "May 5")
            ]
        case .choreReset:
            [
                ChoreRecord(id: UUID(), title: "Reset kitchen counters", assignee: "Alex Kim", status: "Not started", dueDate: "Sunday"),
                ChoreRecord(id: UUID(), title: "Clean bathroom sink", assignee: "Maya Patel", status: "Not started", dueDate: "Sunday"),
                ChoreRecord(id: UUID(), title: "Take out trash and recycling", assignee: "Jordan Lee", status: "In progress", dueDate: "Friday")
            ]
        case .billsAndSupplies:
            [
                ChoreRecord(id: UUID(), title: "Check shared supplies", assignee: "Priya Shah", status: "Not started", dueDate: "Saturday")
            ]
        }
    }

    private static func starterExpenses(for template: StarterTemplate) -> [ExpenseRecord] {
        switch template {
        case .apartmentOS:
            [
                ExpenseRecord(id: UUID(), title: "Internet bill", amount: 60, paidBy: "Alex Kim", status: "Partially paid", splitWith: "Everyone"),
                ExpenseRecord(id: UUID(), title: "Toilet paper", amount: 18, paidBy: "Maya Patel", status: "Unpaid", splitWith: "Everyone"),
                ExpenseRecord(id: UUID(), title: "Cleaning supplies", amount: 25, paidBy: "Jordan Lee", status: "Paid", splitWith: "Everyone")
            ]
        case .choreReset:
            [
                ExpenseRecord(id: UUID(), title: "Cleaning supplies", amount: 25, paidBy: "Jordan Lee", status: "Unpaid", splitWith: "Everyone")
            ]
        case .billsAndSupplies:
            [
                ExpenseRecord(id: UUID(), title: "Internet bill", amount: 60, paidBy: "Alex Kim", status: "Partially paid", splitWith: "Everyone"),
                ExpenseRecord(id: UUID(), title: "Paper towels", amount: 16, paidBy: "Priya Shah", status: "Unpaid", splitWith: "Everyone"),
                ExpenseRecord(id: UUID(), title: "Electricity bill", amount: 95, paidBy: "Maya Patel", status: "Unpaid", splitWith: "Everyone")
            ]
        }
    }

    private static func starterRuleBlocks(for template: StarterTemplate) -> [EditorBlock] {
        switch template {
        case .apartmentOS, .billsAndSupplies:
            [
                EditorBlock(id: UUID(), kind: .heading1, text: "House Rules", checked: false),
                EditorBlock(id: UUID(), kind: .paragraph, text: "Quiet hours are 11 PM to 8 AM on weeknights.", checked: false),
                EditorBlock(id: UUID(), kind: .paragraph, text: "Give the group a heads-up before overnight guests stay over.", checked: false)
            ]
        case .choreReset:
            [
                EditorBlock(id: UUID(), kind: .heading1, text: "Chore Agreements", checked: false),
                EditorBlock(id: UUID(), kind: .paragraph, text: "If you cannot do your assigned chore, swap with someone before the due date.", checked: false)
            ]
        }
    }

    private static func guestOrResetBlocks(for template: StarterTemplate) -> [EditorBlock] {
        switch template {
        case .choreReset:
            [
                EditorBlock(id: UUID(), kind: .heading1, text: "Weekly Reset", checked: false),
                EditorBlock(id: UUID(), kind: .checklist, text: "Clear old food from fridge", checked: false),
                EditorBlock(id: UUID(), kind: .checklist, text: "Wipe kitchen counters", checked: false),
                EditorBlock(id: UUID(), kind: .checklist, text: "Restock toilet paper", checked: false)
            ]
        case .apartmentOS, .billsAndSupplies:
            [
                EditorBlock(id: UUID(), kind: .heading1, text: "Guest Policy", checked: false),
                EditorBlock(id: UUID(), kind: .paragraph, text: "Overnight guests are okay with a same-day note in the group chat.", checked: false),
                EditorBlock(id: UUID(), kind: .checklist, text: "Ask before guests use shared groceries", checked: false)
            ]
        }
    }
}

enum SampleData {
    static let seed = WorkspaceFactory.make(householdName: "Sixth College Apartment")
    static let pageIDs = seed.pageIDs
    static let rootPageIDs = seed.rootPageIDs
    static let pages = seed.pages
    static let chores = seed.chores
    static let expenses = seed.expenses
    static let roommates = seed.roommates
}
