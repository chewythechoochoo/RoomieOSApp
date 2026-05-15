import SwiftUI

// MARK: - Theme
//
// Palette + reusable bits that match the marketing site:
// cream paper background, ink text, hand-drawn paper cards,
// sticker buttons. Colors that need to react to day/night use
// UIColor's dynamic provider so they flip automatically when
// AppAppearance toggles the color scheme.

private extension Color {
    static let paperBg = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0x1B / 255, green: 0x16 / 255, blue: 0x35 / 255, alpha: 1)
            : UIColor(red: 0xFB / 255, green: 0xF3 / 255, blue: 0xDE / 255, alpha: 1)
    })

    static let paperSurface = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0x32 / 255, green: 0x2B / 255, blue: 0x55 / 255, alpha: 1)
            : UIColor(red: 0xFF / 255, green: 0xFC / 255, blue: 0xF1 / 255, alpha: 1)
    })

    static let ink = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0xF4 / 255, green: 0xE9 / 255, blue: 0xC9 / 255, alpha: 1)
            : UIColor(red: 0x2A / 255, green: 0x24 / 255, blue: 0x40 / 255, alpha: 1)
    })

    static let pencil = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0xC9 / 255, green: 0xC2 / 255, blue: 0xE0 / 255, alpha: 1)
            : UIColor(red: 0x5B / 255, green: 0x55 / 255, blue: 0x70 / 255, alpha: 1)
    })

    // Sticker pastels — stay vibrant in both themes.
    static let butter = Color(red: 0xFF / 255, green: 0xE3 / 255, blue: 0x8A / 255)
    static let peach = Color(red: 0xFF / 255, green: 0xC9 / 255, blue: 0xA8 / 255)
    static let mint = Color(red: 0xC1 / 255, green: 0xE8 / 255, blue: 0xC8 / 255)
    static let lavender = Color(red: 0xDC / 255, green: 0xC8 / 255, blue: 0xF5 / 255)
    static let sky = Color(red: 0xBD / 255, green: 0xDE / 255, blue: 0xFF / 255)
    static let imessage = Color(red: 0x0A / 255, green: 0x84 / 255, blue: 0xFF / 255)
    static let imessageSoft = Color(red: 0xD6 / 255, green: 0xE9 / 255, blue: 0xFF / 255)
    static let coral = Color(red: 0xFF / 255, green: 0x9F / 255, blue: 0x8D / 255)
}

private struct PaperCardModifier: ViewModifier {
    var tint: Color
    var stroke: CGFloat
    var radius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(tint)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(Color.ink.opacity(0.85), lineWidth: stroke)
            )
            .shadow(color: Color.ink.opacity(0.08), radius: 12, x: 0, y: 8)
            .shadow(color: Color.ink.opacity(0.05), radius: 0, x: 0, y: 1)
    }
}

private extension View {
    func paperCard(tint: Color = .paperSurface, stroke: CGFloat = 1.5, radius: CGFloat = 22) -> some View {
        modifier(PaperCardModifier(tint: tint, stroke: stroke, radius: radius))
    }
}

private struct StickerButtonStyle: ButtonStyle {
    enum Variant { case primary, cream }
    var variant: Variant = .primary

    func makeBody(configuration: Configuration) -> some View {
        let bg: Color = variant == .primary ? .imessage : .paperSurface
        let fg: Color = variant == .primary ? .white : .ink
        let pressed = configuration.isPressed
        return configuration.label
            .font(.gaegu(size: 22))
            .foregroundStyle(fg)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(bg)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.ink.opacity(0.85), lineWidth: 2))
            .offset(y: pressed ? 2 : 0)
            .shadow(color: Color.ink.opacity(0.55), radius: 0, x: 0, y: pressed ? 1 : 4)
            .animation(.spring(response: 0.22, dampingFraction: 0.7), value: pressed)
    }
}

private struct SoftPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// Cream paper background with soft pastel washes, mirroring the radial
// gradients used on the website.
private struct PaperWashBackground: View {
    var body: some View {
        ZStack {
            Color.paperBg.ignoresSafeArea()
            GeometryReader { proxy in
                let w = proxy.size.width
                let h = proxy.size.height
                ZStack {
                    Circle().fill(Color.butter.opacity(0.32))
                        .frame(width: w * 0.7, height: w * 0.7)
                        .blur(radius: 80)
                        .position(x: w * 0.12, y: h * 0.15)
                    Circle().fill(Color.lavender.opacity(0.32))
                        .frame(width: w * 0.7, height: w * 0.7)
                        .blur(radius: 90)
                        .position(x: w * 0.92, y: h * 0.28)
                    Circle().fill(Color.mint.opacity(0.28))
                        .frame(width: w * 0.7, height: w * 0.7)
                        .blur(radius: 90)
                        .position(x: w * 0.72, y: h * 0.78)
                    Circle().fill(Color.peach.opacity(0.30))
                        .frame(width: w * 0.7, height: w * 0.7)
                        .blur(radius: 90)
                        .position(x: w * 0.18, y: h * 0.92)
                }
            }
            .ignoresSafeArea()
        }
    }
}

private struct ScribbleUnderline: View {
    var color: Color = .imessage

    var body: some View {
        GeometryReader { proxy in
            Path { path in
                let w = proxy.size.width
                let mid = proxy.size.height / 2
                path.move(to: CGPoint(x: 0, y: mid))
                path.addCurve(
                    to: CGPoint(x: w * 0.5, y: mid + 2),
                    control1: CGPoint(x: w * 0.18, y: mid - 5),
                    control2: CGPoint(x: w * 0.34, y: mid + 5)
                )
                path.addCurve(
                    to: CGPoint(x: w, y: mid),
                    control1: CGPoint(x: w * 0.68, y: mid - 4),
                    control2: CGPoint(x: w * 0.86, y: mid + 3)
                )
            }
            .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
        }
        .frame(height: 8)
    }
}

private extension Font {
    static func gaegu(size: CGFloat) -> Font {
        .custom("Gaegu-Regular", size: size)
    }
}

private enum AppAppearance {
    case light
    case dark

    var colorScheme: ColorScheme {
        switch self {
        case .light: .light
        case .dark: .dark
        }
    }

    var toggleTitle: String {
        switch self {
        case .light: "Night"
        case .dark: "Day"
        }
    }

    var toggleIcon: String {
        switch self {
        case .light: "moon.fill"
        case .dark: "sun.max.fill"
        }
    }
}

struct ContentView: View {
    @State private var pages = SampleData.pages
    @State private var pageIDs = SampleData.pageIDs
    @State private var rootPageIDs = SampleData.rootPageIDs
    @State private var selectedPageID = SampleData.seed.selectedPageID
    @State private var householdName = SampleData.seed.householdName
    @State private var chores = SampleData.chores
    @State private var expenses = SampleData.expenses
    @State private var roommates = SampleData.roommates
    @State private var saveState: SaveState = .saved
    @State private var hasCompletedOnboarding = false
    @State private var isCreateThreadPresented = false
    @State private var toastMessage: String?
    @State private var appearance: AppAppearance = .light

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                workspaceShell
            } else {
                OnboardingFlowView(
                    appearance: $appearance,
                    onComplete: { seed in
                        applyWorkspace(seed)
                        hasCompletedOnboarding = true
                        showToast("Workspace ready")
                    }
                )
            }
        }
        .preferredColorScheme(appearance.colorScheme)
    }

    private var workspaceShell: some View {
        HybridWorkspaceShell(
            householdName: householdName,
            pages: $pages,
            rootPageIDs: rootPageIDs,
            selectedPageID: $selectedPageID,
            chores: $chores,
            expenses: $expenses,
            roommates: $roommates,
            saveState: $saveState,
            toastMessage: $toastMessage,
            onCreatePage: { isCreateThreadPresented = true },
            onRunCommand: runCommand,
            onToast: showToast
        )
        .tint(.blue)
        .sheet(isPresented: $isCreateThreadPresented) {
            ThingEditorSheet(
                mode: .create,
                initialTitle: "",
                initialIcon: "✨",
                initialKind: .document,
                onCancel: { isCreateThreadPresented = false },
                onSave: { title, icon, kind in
                    createThing(title: title, icon: icon, kind: kind)
                    isCreateThreadPresented = false
                }
            )
        }
    }

    private func createBlankPage() {
        createThing(title: "Untitled Thread", icon: "✨", kind: .document)
    }

    private func createThing(title: String, icon: String, kind: PageKind) {
        let cleanedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Untitled Thread"
            : title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedIcon = icon.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? kind.defaultEmoji
            : icon.trimmingCharacters(in: .whitespacesAndNewlines)
        let blocks: [EditorBlock]

        switch kind {
        case .document:
            blocks = [EditorBlock(id: UUID(), kind: .paragraph, text: "", checked: false)]
        case .rules:
            blocks = [EditorBlock(id: UUID(), kind: .heading1, text: cleanedTitle, checked: false)]
        case .chores, .expenses, .roommates:
            blocks = []
        }

        let page = WorkspacePage(
            id: UUID(),
            parentID: nil,
            title: cleanedTitle,
            icon: cleanedIcon,
            kind: kind,
            childIDs: [],
            blocks: blocks,
            isReadOnly: false
        )

        pages.append(page)
        rootPageIDs.append(page.id)
        selectedPageID = page.id
        showToast("\(cleanedTitle) added")
    }

    private func runCommand(_ action: CommandAction) {
        switch action {
        case .newPage:
            createBlankPage()
        case .newChore:
            selectedPageID = pageIDs.choresID
            chores.insert(
                ChoreRecord(id: UUID(), title: "New chore", assignee: "Unassigned", status: "Not started", dueDate: "No due date"),
                at: 0
            )
            showToast("Chore added")
        case .newExpense:
            selectedPageID = pageIDs.expensesID
            expenses.insert(
                ExpenseRecord(id: UUID(), title: "New expense", amount: 0, paidBy: "Alex Kim", status: "Unpaid", splitWith: "Everyone"),
                at: 0
            )
            showToast("Expense added")
        case .newRule:
            selectedPageID = pageIDs.rulesID
            if let rulesIndex = pages.firstIndex(where: { $0.id == pageIDs.rulesID }) {
                pages[rulesIndex].blocks.append(EditorBlock(id: UUID(), kind: .paragraph, text: "New house rule", checked: false))
            }
            showToast("Rule block added")
        case .toggleOffline:
            saveState = saveState == .offline ? .saved : .offline
        case .showConflict:
            saveState = saveState == .conflict ? .saved : .conflict
        case .makeReadOnly:
            if let index = pages.firstIndex(where: { $0.id == selectedPageID }) {
                pages[index].isReadOnly.toggle()
            }
        }
    }

    private func applyWorkspace(_ seed: WorkspaceSeed) {
        householdName = seed.householdName
        pageIDs = seed.pageIDs
        rootPageIDs = seed.rootPageIDs
        pages = seed.pages
        chores = seed.chores
        expenses = seed.expenses
        roommates = seed.roommates
        selectedPageID = seed.selectedPageID
        saveState = .saved
    }

    private func showToast(_ message: String) {
        withAnimation {
            toastMessage = message
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation {
                if toastMessage == message {
                    toastMessage = nil
                }
            }
        }
    }
}

private enum OnboardingStep {
    case welcome
    case intent
    case household
    case template
    case firstAction
    case success
}

private struct OnboardingFlowView: View {
    @Binding var appearance: AppAppearance
    let onComplete: (WorkspaceSeed) -> Void

    @State private var step: OnboardingStep = .welcome
    @State private var selectedIntent: OnboardingIntent = .apartment
    @State private var householdName = "Sixth College Apartment"
    @State private var selectedTemplate: StarterTemplate = .apartmentOS
    @State private var firstAction = FirstActionDraft()
    @State private var completedSeed: WorkspaceSeed?
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            PaperWashBackground()

            VStack(spacing: 0) {
                OnboardingTopBar(
                    stepLabel: stepLabel,
                    canGoBack: step != .welcome,
                    appearance: appearance,
                    onBack: goBack,
                    onToggleAppearance: toggleAppearance
                )

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Group {
                            switch step {
                            case .welcome:
                                welcomeScreen
                            case .intent:
                                intentScreen
                            case .household:
                                householdScreen
                            case .template:
                                templateScreen
                            case .firstAction:
                                firstActionScreen
                            case .success:
                                successScreen
                            }
                        }
                        .id(step)
                    }
                    .frame(maxWidth: 720, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 28)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .foregroundStyle(Color.ink)
    }

    private var stepLabel: String {
        switch step {
        case .welcome: "Welcome"
        case .intent, .household: "Setup 1 of 3"
        case .template: "Setup 2 of 3"
        case .firstAction: "Setup 3 of 3"
        case .success: "Workspace ready"
        }
    }

    private var welcomeScreen: some View {
        VStack(alignment: .leading, spacing: 26) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Text("🏠")
                        .font(.system(size: 34))
                        .padding(10)
                        .background(Color.butter)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.ink.opacity(0.85), lineWidth: 2))
                        .rotationEffect(.degrees(-6))
                        .shadow(color: Color.ink.opacity(0.18), radius: 6, x: 0, y: 4)
                    Text("a second home from home")
                        .font(.gaegu(size: 18))
                        .italic()
                        .foregroundStyle(Color.pencil)
                }

                Text("RoomieOS")
                    .font(.gaegu(size: 56))
                ZStack(alignment: .bottom) {
                    Text("a calmer way to run a shared apartment.")
                        .font(.gaegu(size: 22))
                        .foregroundStyle(Color.pencil)
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                PreviewPill(icon: "🧹", title: "Chores", detail: "who's doing what, today")
                PreviewPill(icon: "💸", title: "Expenses", detail: "who paid, who owes")
                PreviewPill(icon: "📜", title: "House rules", detail: "what everyone agreed to")
            }
            .padding(18)
            .paperCard()

            Button("Let's get started") {
                step = .intent
            }
            .buttonStyle(StickerButtonStyle())
        }
    }

    private var intentScreen: some View {
        VStack(alignment: .leading, spacing: 22) {
            OnboardingHeader(
                title: "what do you want to organize first?",
                subtitle: "we'll set up a simple little workspace. you can change everything later."
            )

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 260), spacing: 14)], spacing: 14) {
                ForEach(OnboardingIntent.allCases) { intent in
                    SelectableCard(
                        title: intent.title,
                        subtitle: intent.subtitle,
                        icon: intent.icon,
                        badge: intent == .apartment ? "Recommended" : nil,
                        isSelected: selectedIntent == intent
                    ) {
                        selectedIntent = intent
                        selectedTemplate = intent.defaultTemplate
                    }
                }
            }

            OnboardingActions(
                primaryTitle: "Continue",
                secondaryTitle: "Use default setup",
                errorMessage: nil,
                onPrimary: {
                    selectedTemplate = selectedIntent.defaultTemplate
                    step = .household
                },
                onSecondary: {
                    selectedIntent = .apartment
                    selectedTemplate = .apartmentOS
                    step = .household
                }
            )
        }
    }

    private var householdScreen: some View {
        VStack(alignment: .leading, spacing: 22) {
            OnboardingHeader(
                title: "name your little place",
                subtitle: "something your roommates will recognize. you can change it any time."
            )

            VStack(alignment: .leading, spacing: 10) {
                Text("household name")
                    .font(.gaegu(size: 17))
                    .foregroundStyle(Color.pencil)
                TextField("Sixth College Apartment", text: $householdName)
                    .font(.gaegu(size: 22))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .paperCard(radius: 16)
                    .onSubmit(validateHouseholdAndContinue)
                HStack(spacing: 8) {
                    ForEach(["My Apartment", "Dorm Room", "Shared House"], id: \.self) { suggestion in
                        Button {
                            householdName = suggestion
                        } label: {
                            Text(suggestion)
                                .font(.gaegu(size: 16))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.butter.opacity(0.55))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color.ink.opacity(0.6), lineWidth: 1.5))
                                .foregroundStyle(Color.ink)
                        }
                        .buttonStyle(SoftPressStyle())
                    }
                }
            }

            OnboardingActions(
                primaryTitle: "Create workspace",
                secondaryTitle: "Use My Apartment",
                errorMessage: errorMessage,
                onPrimary: validateHouseholdAndContinue,
                onSecondary: {
                    householdName = "My Apartment"
                    errorMessage = nil
                    step = .template
                }
            )
        }
    }

    private var templateScreen: some View {
        VStack(alignment: .leading, spacing: 22) {
            OnboardingHeader(
                title: "pick a starter room",
                subtitle: "templates are fully editable. nothing is locked, mess with it!"
            )

            VStack(spacing: 12) {
                ForEach(StarterTemplate.allCases) { template in
                    TemplateCard(
                        template: template,
                        isSelected: selectedTemplate == template,
                        onSelect: { selectedTemplate = template }
                    )
                }
            }

            OnboardingActions(
                primaryTitle: "Use this template",
                secondaryTitle: "Start with the recommended setup",
                errorMessage: nil,
                onPrimary: { step = .firstAction },
                onSecondary: {
                    selectedTemplate = selectedIntent.defaultTemplate
                    step = .firstAction
                }
            )
        }
    }

    private var firstActionScreen: some View {
        VStack(alignment: .leading, spacing: 22) {
            OnboardingHeader(title: firstActionTitle, subtitle: firstActionSubtitle)

            VStack(alignment: .leading, spacing: 12) {
                Text(selectedIntent == .expenses ? "expense title" : "title")
                    .font(.gaegu(size: 17))
                    .foregroundStyle(Color.pencil)
                TextField(firstActionPlaceholder, text: $firstAction.title)
                    .font(.gaegu(size: 22))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .paperCard(radius: 16)
                    .onSubmit(validateFirstActionAndContinue)

                if selectedIntent == .expenses {
                    Text("amount")
                        .font(.gaegu(size: 17))
                        .foregroundStyle(Color.pencil)
                    TextField("60.00", value: $firstAction.amount, format: .number.precision(.fractionLength(2)))
                        .font(.gaegu(size: 22))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .paperCard(radius: 16)
                        .keyboardType(.decimalPad)
                }
            }

            OnboardingActions(
                primaryTitle: firstActionButtonTitle,
                secondaryTitle: nil,
                errorMessage: errorMessage,
                onPrimary: validateFirstActionAndContinue,
                onSecondary: nil
            )
        }
    }

    private var successScreen: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.mint)
                        .frame(width: 80, height: 80)
                        .overlay(Circle().stroke(Color.ink.opacity(0.85), lineWidth: 2))
                        .shadow(color: Color.ink.opacity(0.18), radius: 8, x: 0, y: 5)
                    Image(systemName: "checkmark")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundStyle(Color.ink)
                }
                .rotationEffect(.degrees(-6))

                VStack(alignment: .leading, spacing: 6) {
                    Text("welcome home!")
                        .font(.gaegu(size: 34))
                    Text("your little place is ready 🏠")
                        .font(.gaegu(size: 19))
                        .foregroundStyle(Color.pencil)
                }
            }

            Text("pages for chores, expenses, house rules, and roommates are set up. you can decorate, rename, or rearrange any of it later.")
                .font(.gaegu(size: 20))
                .foregroundStyle(Color.pencil)
                .padding(.top, 2)

            if !firstAction.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                HStack(spacing: 10) {
                    Text(selectedIntent.icon).font(.system(size: 22))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("added").font(.gaegu(size: 15)).foregroundStyle(Color.pencil)
                        Text(firstAction.title).font(.gaegu(size: 20))
                    }
                    Spacer()
                }
                .padding(14)
                .paperCard(tint: Color.butter.opacity(0.55))
            }

            Button("Open workspace") {
                onComplete(completedSeed ?? WorkspaceFactory.make(householdName: householdName, intent: selectedIntent, template: selectedTemplate))
            }
            .buttonStyle(StickerButtonStyle())
        }
    }

    private var firstActionTitle: String {
        switch selectedIntent {
        case .apartment: "Add the first shared responsibility"
        case .chores: "Add your first chore"
        case .expenses: "Add your first shared expense"
        case .rules: "Add one house rule"
        }
    }

    private var firstActionSubtitle: String {
        switch selectedIntent {
        case .apartment: "Start with one thing roommates usually forget."
        case .chores: "You can assign it later."
        case .expenses: "Use any recent bill or supply run."
        case .rules: "Start with the rule that prevents the most confusion."
        }
    }

    private var firstActionPlaceholder: String {
        switch selectedIntent {
        case .apartment: "Take out trash"
        case .chores: "Clean bathroom"
        case .expenses: "Internet bill"
        case .rules: "Quiet hours are 11 PM to 8 AM"
        }
    }

    private var firstActionButtonTitle: String {
        switch selectedIntent {
        case .apartment, .chores: "Add chore"
        case .expenses: "Add expense"
        case .rules: "Add rule"
        }
    }

    private func validateHouseholdAndContinue() {
        let trimmedName = householdName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            errorMessage = "Add a household name to continue."
            return
        }
        if trimmedName.count > 48 {
            errorMessage = "Keep the name under 48 characters."
            return
        }

        householdName = trimmedName
        errorMessage = nil
        step = .template
    }

    private func validateFirstActionAndContinue() {
        let trimmedTitle = firstAction.title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedTitle.isEmpty {
            errorMessage = "Add a title to continue."
            return
        }
        if selectedIntent == .expenses && firstAction.amount <= 0 {
            errorMessage = "Enter a valid amount."
            return
        }

        firstAction.title = trimmedTitle
        completedSeed = WorkspaceFactory.make(
            householdName: householdName,
            intent: selectedIntent,
            template: selectedTemplate,
            firstAction: firstAction
        )
        errorMessage = nil
        step = .success
    }

    private func goBack() {
        errorMessage = nil
        switch step {
        case .welcome:
            break
        case .intent:
            step = .welcome
        case .household:
            step = .intent
        case .template:
            step = .household
        case .firstAction:
            step = .template
        case .success:
            step = .firstAction
        }
    }

    private func toggleAppearance() {
        appearance = appearance == .light ? .dark : .light
    }
}

private struct OnboardingTopBar: View {
    let stepLabel: String
    let canGoBack: Bool
    let appearance: AppAppearance
    let onBack: () -> Void
    let onToggleAppearance: () -> Void

    var body: some View {
        HStack {
            if canGoBack {
                Button {
                    onBack()
                } label: {
                    Label("Back", systemImage: "chevron.left")
                        .font(.gaegu(size: 18))
                        .foregroundStyle(Color.ink)
                }
                .buttonStyle(SoftPressStyle())
            } else {
                Button(action: onToggleAppearance) {
                    Label(appearance.toggleTitle, systemImage: appearance.toggleIcon)
                        .font(.gaegu(size: 18))
                        .foregroundStyle(Color.ink)
                }
                .buttonStyle(SoftPressStyle())
                .accessibilityLabel("Switch to \(appearance.toggleTitle.lowercased()) mode")
            }

            Spacer()
        }
        .overlay {
            Text(stepLabel)
                .font(.gaegu(size: 15))
                .foregroundStyle(Color.pencil)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(Color.paperBg.opacity(0.72))
        .overlay(
            Rectangle()
                .fill(Color.ink.opacity(0.12))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

private struct OnboardingHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.gaegu(size: 38))
                .foregroundStyle(Color.ink)
            Text(subtitle)
                .font(.gaegu(size: 20))
                .foregroundStyle(Color.pencil)
        }
    }
}

private struct OnboardingActions: View {
    let primaryTitle: String
    let secondaryTitle: String?
    let errorMessage: String?
    let onPrimary: () -> Void
    let onSecondary: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let errorMessage {
                HStack(spacing: 8) {
                    Text("⚠️")
                    Text(errorMessage)
                        .font(.gaegu(size: 17))
                }
                .foregroundStyle(Color.coral)
            }

            HStack(spacing: 14) {
                Button(primaryTitle, action: onPrimary)
                    .buttonStyle(StickerButtonStyle())

                if let secondaryTitle, let onSecondary {
                    Button(secondaryTitle, action: onSecondary)
                        .buttonStyle(StickerButtonStyle(variant: .cream))
                }
            }
        }
    }
}

private struct SelectableCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let badge: String?
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(icon)
                        .font(.system(size: 28))
                        .padding(8)
                        .background(Color.butter.opacity(0.55))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.ink.opacity(0.6), lineWidth: 1.5))
                        .rotationEffect(.degrees(-4))
                    Spacer()
                    if let badge {
                        Text(badge)
                            .font(.gaegu(size: 14))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.mint)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.ink.opacity(0.6), lineWidth: 1.5))
                            .foregroundStyle(Color.ink)
                    }
                }
                Text(title)
                    .font(.gaegu(size: 24))
                    .foregroundStyle(Color.ink)
                Text(subtitle)
                    .font(.gaegu(size: 17))
                    .foregroundStyle(Color.pencil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.paperSurface)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? Color.imessage : Color.ink.opacity(0.6), lineWidth: isSelected ? 3 : 1.5)
            )
            .shadow(color: Color.ink.opacity(isSelected ? 0.18 : 0.08), radius: isSelected ? 14 : 10, x: 0, y: isSelected ? 8 : 6)
        }
        .buttonStyle(SoftPressStyle())
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct TemplateCard: View {
    let template: StarterTemplate
    let isSelected: Bool
    let onSelect: () -> Void

    private var accent: Color {
        switch template {
        case .apartmentOS: .sky
        case .choreReset: .mint
        case .billsAndSupplies: .butter
        }
    }

    var body: some View {
        Button(action: onSelect) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "square.grid.2x2")
                    .font(.title2)
                    .foregroundStyle(Color.ink)
                    .frame(width: 42, height: 42)
                    .background(accent.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.ink.opacity(0.6), lineWidth: 1.5))
                    .rotationEffect(.degrees(-4))

                VStack(alignment: .leading, spacing: 8) {
                    Text(template.title)
                        .font(.gaegu(size: 24))
                        .foregroundStyle(Color.ink)
                    Text(template.subtitle)
                        .font(.gaegu(size: 17))
                        .foregroundStyle(Color.pencil)
                        .fixedSize(horizontal: false, vertical: true)
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(template.previewRows, id: \.self) { row in
                            Label(row, systemImage: "checkmark")
                                .font(.gaegu(size: 15))
                                .foregroundStyle(Color.pencil)
                        }
                    }
                    .padding(.top, 4)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.imessage : Color.pencil.opacity(0.5))
            }
            .padding(16)
            .background(Color.paperSurface)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? Color.imessage : Color.ink.opacity(0.6), lineWidth: isSelected ? 3 : 1.5)
            )
            .shadow(color: Color.ink.opacity(isSelected ? 0.18 : 0.08), radius: isSelected ? 14 : 10, x: 0, y: isSelected ? 8 : 6)
        }
        .buttonStyle(SoftPressStyle())
    }
}

private struct PreviewPill: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 24))
                .frame(width: 36, height: 36)
                .background(Color.mint.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.ink.opacity(0.5), lineWidth: 1.5))
                .rotationEffect(.degrees(-3))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.gaegu(size: 22))
                    .foregroundStyle(Color.ink)
                Text(detail)
                    .font(.gaegu(size: 17))
                    .foregroundStyle(Color.pencil)
            }
            Spacer()
        }
    }
}

private enum HybridTab: Int, CaseIterable, Identifiable {
    case inbox
    case expenses

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .inbox: "Inbox"
        case .expenses: "Expenses"
        }
    }

    var icon: String {
        switch self {
        case .inbox: "bubble.left.and.bubble.right"
        case .expenses: "chart.line.uptrend.xyaxis"
        }
    }
}

private enum ComposerMode: String, CaseIterable, Identifiable {
    case message = "Message"
    case chore = "Chore"
    case expense = "Expense"
    case rule = "Rule"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .message: "bubble.left"
        case .chore: "checklist"
        case .expense: "dollarsign.circle"
        case .rule: "doc.text"
        }
    }

    var placeholder: String {
        switch self {
        case .message: "Message this thread"
        case .chore: "Add a chore"
        case .expense: "Add an expense"
        case .rule: "Add a house rule"
        }
    }
}

private extension PageKind {
    var composerModes: [ComposerMode] {
        switch self {
        case .document, .roommates:
            [.message]
        case .chores:
            [.chore]
        case .expenses:
            [.expense]
        case .rules:
            [.rule]
        }
    }
}

private struct HybridWorkspaceShell: View {
    let householdName: String
    @Binding var pages: [WorkspacePage]
    let rootPageIDs: [UUID]
    @Binding var selectedPageID: UUID
    @Binding var chores: [ChoreRecord]
    @Binding var expenses: [ExpenseRecord]
    @Binding var roommates: [Roommate]
    @Binding var saveState: SaveState
    @Binding var toastMessage: String?
    let onCreatePage: () -> Void
    let onRunCommand: (CommandAction) -> Void
    let onToast: (String) -> Void
    @State private var selectedTab: HybridTab = .inbox

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                NavigationStack {
                    HybridInboxView(
                        householdName: householdName,
                        pages: pages,
                        rootPageIDs: rootPageIDs,
                        chores: chores,
                        expenses: expenses,
                        onCreatePage: onCreatePage
                    )
                    .navigationDestination(for: UUID.self) { pageID in
                        destination(for: pageID)
                    }
                }
                .tabItem {
                    Label(HybridTab.inbox.title, systemImage: HybridTab.inbox.icon)
                }
                .tag(HybridTab.inbox)

                NavigationStack {
                    ExpenseAnalyticsView(
                        expenses: expenses,
                        roommates: roommates,
                        onAddExpense: {
                            onRunCommand(.newExpense)
                        }
                    )
                }
                .tabItem {
                    Label(HybridTab.expenses.title, systemImage: HybridTab.expenses.icon)
                }
                .tag(HybridTab.expenses)
            }
            .tint(Color.imessage)
            .ignoresSafeArea(.keyboard, edges: .bottom)

            VStack(spacing: 10) {
                if let toastMessage {
                    ToastView(message: toastMessage)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(.bottom, 82)
        }
        .foregroundStyle(Color.ink)
    }

    @ViewBuilder
    private func destination(for pageID: UUID) -> some View {
        if let pageBinding = bindingForPage(pageID) {
            HybridThreadView(
                householdName: householdName,
                page: pageBinding,
                pages: pages,
                chores: $chores,
                expenses: $expenses,
                roommates: $roommates,
                saveState: $saveState,
                onToast: onToast
            )
        } else {
            ContentUnavailableView("Thread not found", systemImage: "bubble.left")
        }
    }

    private func bindingForPage(_ pageID: UUID) -> Binding<WorkspacePage>? {
        guard let index = pages.firstIndex(where: { $0.id == pageID }) else { return nil }
        return $pages[index]
    }
}

private struct HybridInboxView: View {
    let householdName: String
    let pages: [WorkspacePage]
    let rootPageIDs: [UUID]
    let chores: [ChoreRecord]
    let expenses: [ExpenseRecord]
    let onCreatePage: () -> Void

    private var orderedPages: [WorkspacePage] {
        rootPageIDs.compactMap { id in pages.first { $0.id == id } }
    }

    private var unpaidCount: Int {
        expenses.filter { $0.status != "Paid" }.count
    }

    private var openChoreCount: Int {
        chores.filter { $0.status != "Done" }.count
    }

    var body: some View {
        ZStack {
            PaperWashBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    inboxHeader
                    Text("Threads")
                        .font(.gaegu(size: 22))
                        .foregroundStyle(Color.pencil)
                        .padding(.horizontal, 2)

                    VStack(spacing: 12) {
                        ForEach(orderedPages) { page in
                            NavigationLink(value: page.id) {
                                ThreadRow(
                                    title: page.title,
                                    preview: preview(for: page),
                                    icon: page.icon,
                                    badges: badges(for: page)
                                )
                            }
                            .buttonStyle(SoftPressStyle())
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 100)
            }
        }
        .scrollContentBackground(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onCreatePage) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.imessage)
                }
                .accessibilityLabel("Add thread")
            }
        }
        .navigationTitle("Inbox")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var inboxHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(householdName)
                .font(.gaegu(size: 34))
                .foregroundStyle(Color.ink)
            HStack(spacing: 10) {
                ThreadChip(title: "\(openChoreCount) open chores", systemImage: "checklist", tint: .mint)
                ThreadChip(title: "\(unpaidCount) unpaid", systemImage: "dollarsign.circle", tint: .butter)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .paperCard()
    }

    private func preview(for page: WorkspacePage) -> String {
        switch page.kind {
        case .document, .rules:
            page.blocks.first(where: { !$0.text.isEmpty })?.text ?? "Start a note"
        case .chores:
            "\(openChoreCount) chores need attention"
        case .expenses:
            "\(unpaidCount) expenses are not fully paid"
        case .roommates:
            "Roommates, roles, and contact details"
        }
    }

    private func badges(for page: WorkspacePage) -> [String] {
        switch page.kind {
        case .chores: ["Tasks"]
        case .expenses: ["Money"]
        case .rules: ["Rules"]
        case .roommates: ["People"]
        case .document: ["Page"]
        }
    }
}

private enum ExpenseAnalyticsRange: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case year = "Year"

    var id: String { rawValue }

    var pointCount: Int {
        switch self {
        case .week: 7
        case .month: 30
        case .year: 12
        }
    }

    var baseMultiplier: Double {
        switch self {
        case .week: 1
        case .month: 3.6
        case .year: 12.4
        }
    }
}

private struct ExpenseTrendPoint: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
}

private struct ExpenseAnalyticsView: View {
    let expenses: [ExpenseRecord]
    let roommates: [Roommate]
    let onAddExpense: () -> Void
    @State private var selectedRange: ExpenseAnalyticsRange = .week
    @State private var selectedPointIndex: Int?

    private var paidTotal: Double {
        expenses.filter { $0.status == "Paid" }.map(\.amount).reduce(0, +)
    }

    private var unpaidTotal: Double {
        expenses.filter { $0.status != "Paid" }.map(\.amount).reduce(0, +)
    }

    private var points: [ExpenseTrendPoint] {
        let total = max(expenses.map(\.amount).reduce(0, +), 1) * selectedRange.baseMultiplier
        let labels = labels(for: selectedRange)
        return labels.enumerated().map { index, label in
            let progress = Double(index + 1) / Double(labels.count)
            let wave = sin(Double(index) * 0.72) * 0.035
            return ExpenseTrendPoint(label: label, value: total * min(max(progress + wave, 0.04), 1))
        }
    }

    private var displayedValue: Double {
        guard let selectedPointIndex, points.indices.contains(selectedPointIndex) else {
            return max(expenses.map(\.amount).reduce(0, +), 1) * selectedRange.baseMultiplier
        }
        return points[selectedPointIndex].value
    }

    var body: some View {
        ZStack {
            PaperWashBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    graphCard
                    memberBreakdown
                    recentExpenses
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 100)
            }
        }
        .scrollContentBackground(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onAddExpense) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.imessage)
                }
                .accessibilityLabel("Add expense")
            }
        }
        .navigationTitle("Expenses")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(displayedValue.formatted(.currency(code: "USD")))
                        .font(.gaegu(size: 46))
                        .foregroundStyle(Color.ink)
                        .minimumScaleFactor(0.75)
                    Text("this \(selectedRange.rawValue.lowercased())")
                        .font(.gaegu(size: 18))
                        .foregroundStyle(Color.pencil)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Label(paidTotal.formatted(.currency(code: "USD")), systemImage: "checkmark.circle.fill")
                        .foregroundStyle(Color.imessage)
                    Label(unpaidTotal.formatted(.currency(code: "USD")), systemImage: "clock")
                        .foregroundStyle(Color.pencil)
                }
                .font(.gaegu(size: 15))
            }

            Text("a crayon line of where the money went. scrub the graph to peek at any week.")
                .font(.gaegu(size: 17))
                .foregroundStyle(Color.pencil)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .paperCard()
    }

    private var graphCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("Range", selection: $selectedRange) {
                ForEach(ExpenseAnalyticsRange.allCases) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedRange) {
                selectedPointIndex = nil
            }

            ExpenseLineGraph(points: points, selectedIndex: $selectedPointIndex)
                .frame(height: 230)

            HStack(spacing: 6) {
                Image(systemName: "hand.draw")
                Text("drag to scrub")
            }
            .font(.gaegu(size: 15))
            .foregroundStyle(Color.pencil)
        }
        .padding(16)
        .paperCard()
    }

    private var memberBreakdown: some View {
        let maxAmount = max(roommates.map { roommate in
            expenses.filter { $0.paidBy == roommate.name }.map(\.amount).reduce(0, +)
        }.max() ?? 1, 1)

        return VStack(alignment: .leading, spacing: 12) {
            Text("by roommate")
                .font(.gaegu(size: 22))
                .foregroundStyle(Color.ink)

            VStack(spacing: 10) {
                ForEach(Array(roommates.enumerated()), id: \.element.id) { index, roommate in
                    let amount = expenses.filter { $0.paidBy == roommate.name }.map(\.amount).reduce(0, +)
                    MemberSpendRow(
                        name: roommate.name,
                        amount: amount,
                        maxAmount: maxAmount,
                        tint: Self.memberTints[index % Self.memberTints.count]
                    )
                }
            }
        }
        .padding(16)
        .paperCard()
    }

    private static let memberTints: [Color] = [.mint, .peach, .lavender, .sky]

    private var recentExpenses: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("recent")
                .font(.gaegu(size: 22))
                .foregroundStyle(Color.ink)

            VStack(spacing: 10) {
                ForEach(expenses.prefix(4)) { expense in
                    HStack(spacing: 12) {
                        Image(systemName: "creditcard.fill")
                            .foregroundStyle(Color.ink)
                            .frame(width: 36, height: 36)
                            .background(Color.butter.opacity(0.7))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color.ink.opacity(0.5), lineWidth: 1.5))
                            .rotationEffect(.degrees(-4))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(expense.title)
                                .font(.gaegu(size: 19))
                                .foregroundStyle(Color.ink)
                            Text("\(expense.paidBy) · \(expense.status)")
                                .font(.gaegu(size: 14))
                                .foregroundStyle(Color.pencil)
                        }

                        Spacer()

                        Text(expense.amount.formatted(.currency(code: "USD")))
                            .font(.gaegu(size: 19))
                            .foregroundStyle(Color.ink)
                    }
                    .padding(14)
                    .paperCard()
                }
            }
        }
    }

    private func labels(for range: ExpenseAnalyticsRange) -> [String] {
        switch range {
        case .week:
            ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        case .month:
            (1...30).map { "Day \($0)" }
        case .year:
            ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        }
    }
}

private struct ExpenseLineGraph: View {
    let points: [ExpenseTrendPoint]
    @Binding var selectedIndex: Int?

    var body: some View {
        GeometryReader { proxy in
            let chartPoints = makeChartPoints(size: proxy.size)

            ZStack {
                ForEach(0..<4, id: \.self) { lineIndex in
                    Path { path in
                        let y = proxy.size.height * CGFloat(lineIndex) / 3
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: proxy.size.width, y: y))
                    }
                    .stroke(Color.ink.opacity(0.12), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                }

                areaPath(points: chartPoints, height: proxy.size.height)
                    .fill(
                        LinearGradient(
                            colors: [Color.imessage.opacity(0.28), Color.imessage.opacity(0.02)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                linePath(points: chartPoints)
                    .stroke(Color.imessage, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                if let selectedIndex, chartPoints.indices.contains(selectedIndex) {
                    let point = chartPoints[selectedIndex]

                    Rectangle()
                        .fill(Color.ink.opacity(0.35))
                        .frame(width: 1, height: proxy.size.height)
                        .position(x: point.x, y: proxy.size.height / 2)

                    Circle()
                        .fill(Color.paperSurface)
                        .frame(width: 18, height: 18)
                        .overlay(Circle().stroke(Color.ink, lineWidth: 2))
                        .position(point)
                }

                VStack {
                    Spacer()
                    HStack {
                        Text(points.first?.label ?? "")
                        Spacer()
                        Text(points[safe: points.count / 2]?.label ?? "")
                        Spacer()
                        Text(points.last?.label ?? "")
                    }
                    .font(.gaegu(size: 13))
                    .foregroundStyle(Color.pencil)
                    .padding(.top, 8)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        selectedIndex = nearestIndex(for: value.location.x, width: proxy.size.width)
                    }
            )
        }
        .accessibilityLabel("Expense performance graph")
        .accessibilityHint("Drag horizontally to inspect spending over time.")
    }

    private func makeChartPoints(size: CGSize) -> [CGPoint] {
        guard points.count > 1 else { return [] }
        let values = points.map(\.value)
        let minValue = values.min() ?? 0
        let maxValue = values.max() ?? 1
        let range = max(maxValue - minValue, 1)
        let verticalPadding: CGFloat = 22
        let drawableHeight = max(size.height - verticalPadding * 2, 1)

        return points.enumerated().map { index, point in
            let x = size.width * CGFloat(index) / CGFloat(points.count - 1)
            let normalized = (point.value - minValue) / range
            let y = size.height - verticalPadding - CGFloat(normalized) * drawableHeight
            return CGPoint(x: x, y: y)
        }
    }

    private func linePath(points: [CGPoint]) -> Path {
        Path { path in
            guard let first = points.first else { return }
            path.move(to: first)
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
        }
    }

    private func areaPath(points: [CGPoint], height: CGFloat) -> Path {
        Path { path in
            guard let first = points.first, let last = points.last else { return }
            path.move(to: CGPoint(x: first.x, y: height))
            path.addLine(to: first)
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
            path.addLine(to: CGPoint(x: last.x, y: height))
            path.closeSubpath()
        }
    }

    private func nearestIndex(for x: CGFloat, width: CGFloat) -> Int {
        guard points.count > 1 else { return 0 }
        let clampedX = min(max(x, 0), width)
        let progress = clampedX / max(width, 1)
        return min(max(Int(round(progress * CGFloat(points.count - 1))), 0), points.count - 1)
    }
}

private struct MemberSpendRow: View {
    let name: String
    let amount: Double
    let maxAmount: Double
    var tint: Color = .mint

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(name)
                    .font(.gaegu(size: 18))
                    .foregroundStyle(Color.ink)
                Spacer()
                Text(amount.formatted(.currency(code: "USD")))
                    .font(.gaegu(size: 18))
                    .foregroundStyle(Color.ink)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.paperSurface)
                        .overlay(Capsule().stroke(Color.ink.opacity(0.5), lineWidth: 1.5))
                    Capsule()
                        .fill(tint)
                        .overlay(Capsule().stroke(Color.ink.opacity(0.5), lineWidth: 1.5))
                        .frame(width: max(proxy.size.width * CGFloat(amount / maxAmount), 14))
                }
            }
            .frame(height: 12)
        }
    }
}

private struct HybridThreadView: View {
    let householdName: String
    @Binding var page: WorkspacePage
    let pages: [WorkspacePage]
    @Binding var chores: [ChoreRecord]
    @Binding var expenses: [ExpenseRecord]
    @Binding var roommates: [Roommate]
    @Binding var saveState: SaveState
    let onToast: (String) -> Void
    @State private var composerText = ""
    @State private var composerMode: ComposerMode = .message
    @State private var isInsertMenuPresented = false
    @State private var isEditThreadPresented = false

    private var allowedComposerModes: [ComposerMode] {
        page.kind.composerModes
    }

    private var fallbackComposerMode: ComposerMode {
        allowedComposerModes.first ?? .message
    }

    private var resolvedComposerMode: ComposerMode {
        allowedComposerModes.contains(composerMode) ? composerMode : fallbackComposerMode
    }

    private var composerModeBinding: Binding<ComposerMode> {
        Binding(
            get: { resolvedComposerMode },
            set: { newMode in
                composerMode = allowedComposerModes.contains(newMode) ? newMode : fallbackComposerMode
            }
        )
    }

    var body: some View {
        ZStack {
            PaperWashBackground()

            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ThreadPageHeader(householdName: householdName, page: page)
                        SystemTimelineNote(text: "\(saveState.title) - \(roommates.count) roommates")

                        ForEach(timelineBlocks) { block in
                            BlockBubble(block: block, isReadOnly: page.isReadOnly)
                        }

                        if page.kind == .chores {
                            ForEach($chores) { $chore in
                                InlineChoreBubble(chore: $chore, isReadOnly: page.isReadOnly)
                            }
                        }

                        if page.kind == .expenses {
                            ForEach($expenses) { $expense in
                                InlineExpenseBubble(expense: $expense, isReadOnly: page.isReadOnly)
                            }
                        }

                        if page.kind == .roommates {
                            ForEach(roommates) { roommate in
                                MessageBubble(
                                    text: "\(roommate.email)\n\(roommate.role)",
                                    author: roommate.name,
                                    alignment: .incoming,
                                    systemImage: "person.crop.circle"
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 16)
                }

                ComposerBar(
                    text: $composerText,
                    mode: composerModeBinding,
                    allowedModes: allowedComposerModes,
                    isReadOnly: page.isReadOnly,
                    onInsert: { isInsertMenuPresented = true },
                    onSend: sendComposer
                )
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isEditThreadPresented = true
                } label: {
                    Image(systemName: "pencil")
                }
                .disabled(page.isReadOnly)
                .accessibilityLabel("Edit thread")
            }

            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(saveState == .offline ? "Mark saved" : "Preview offline") {
                        saveState = saveState == .offline ? .saved : .offline
                    }
                    Button(saveState == .conflict ? "Clear conflict" : "Preview conflict") {
                        saveState = saveState == .conflict ? .saved : .conflict
                    }
                    Button(page.isReadOnly ? "Unlock thread" : "Make read-only") {
                        page.isReadOnly.toggle()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $isInsertMenuPresented) {
            InsertMenuSheet(mode: composerModeBinding, modes: allowedComposerModes)
                .presentationDetents([.height(320)])
        }
        .sheet(isPresented: $isEditThreadPresented) {
            ThingEditorSheet(
                mode: .edit,
                initialTitle: page.title,
                initialIcon: page.icon,
                initialKind: page.kind,
                onCancel: { isEditThreadPresented = false },
                onSave: { title, icon, _ in
                    page.title = title
                    page.icon = icon
                    isEditThreadPresented = false
                    onToast("Thread updated")
                }
            )
        }
    }

    private var timelineBlocks: [EditorBlock] {
        switch page.kind {
        case .document, .rules:
            page.blocks
        case .chores:
            [EditorBlock(id: UUID(), kind: .callout, text: "Chores are shared tasks. Tap a row to edit details or mark it done.", checked: false)]
        case .expenses:
            [EditorBlock(id: UUID(), kind: .callout, text: "Expenses are tracked as compact records. Use status to show what is paid.", checked: false)]
        case .roommates:
            [EditorBlock(id: UUID(), kind: .heading2, text: "Roommates", checked: false)]
        }
    }

    private func sendComposer() {
        let trimmed = composerText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let inferredMode = inferMode(from: trimmed)
        let mode = inferredMode.flatMap { allowedComposerModes.contains($0) ? $0 : nil } ?? resolvedComposerMode
        let cleanedText = cleanedComposerText(trimmed, mode: mode)

        switch mode {
        case .message:
            page.blocks.append(EditorBlock(id: UUID(), kind: .paragraph, text: cleanedText, checked: false))
            onToast("Message added")
        case .chore:
            chores.insert(ChoreRecord(id: UUID(), title: cleanedText, assignee: "Unassigned", status: "Not started", dueDate: "No due date"), at: 0)
            onToast("Chore added")
        case .expense:
            expenses.insert(ExpenseRecord(id: UUID(), title: cleanedText, amount: inferredAmount(from: cleanedText), paidBy: roommates.first?.name ?? "Unassigned", status: "Unpaid", splitWith: "Everyone"), at: 0)
            onToast("Expense added")
        case .rule:
            page.blocks.append(EditorBlock(id: UUID(), kind: .paragraph, text: cleanedText, checked: false))
            onToast("Rule added")
        }

        composerText = ""
        composerMode = fallbackComposerMode
    }

    private func inferMode(from text: String) -> ComposerMode? {
        if text.hasPrefix("/chore") { return .chore }
        if text.hasPrefix("/expense") { return .expense }
        if text.hasPrefix("/rule") { return .rule }
        if text.hasPrefix("$") { return .expense }
        return nil
    }

    private func cleanedComposerText(_ text: String, mode: ComposerMode) -> String {
        let commands = ["/chore", "/expense", "/rule", "/message"]
        var cleaned = text
        for command in commands where cleaned.hasPrefix(command) {
            cleaned = String(cleaned.dropFirst(command.count)).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return cleaned.isEmpty ? mode.placeholder : cleaned
    }

    private func inferredAmount(from text: String) -> Double {
        let number = text
            .split(separator: " ")
            .first { $0.contains("$") || Double($0) != nil }?
            .replacingOccurrences(of: "$", with: "")
        return Double(number ?? "") ?? 0
    }
}

private struct ThreadPageHeader: View {
    let householdName: String
    let page: WorkspacePage

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            EmojiBadge(icon: page.icon, size: 28, frame: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text(page.title)
                    .font(.gaegu(size: 34))
                    .foregroundStyle(Color.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                HStack(spacing: 6) {
                    Text(householdName)
                    Text("·")
                    Text(page.kind.rawValue.capitalized)
                    if page.isReadOnly {
                        Label("read-only", systemImage: "lock")
                    }
                }
                .font(.gaegu(size: 15))
                .foregroundStyle(Color.pencil)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .paperCard()
        .padding(.bottom, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct EmojiBadge: View {
    let icon: String
    let size: CGFloat
    let frame: CGFloat

    private var displayedIcon: String {
        icon.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "📄" : icon
    }

    var body: some View {
        Text(displayedIcon)
            .font(.system(size: size))
            .frame(width: frame, height: frame)
            .background(Color.butter.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.ink.opacity(0.6), lineWidth: 1.5))
            .rotationEffect(.degrees(-4))
            .shadow(color: Color.ink.opacity(0.18), radius: 6, x: 0, y: 4)
    }
}

private enum BubbleAlignment {
    case incoming
    case outgoing
}

private struct MessageBubble: View {
    let text: String
    let author: String?
    let alignment: BubbleAlignment
    let systemImage: String?

    var body: some View {
        HStack(alignment: .bottom) {
            if alignment == .outgoing { Spacer(minLength: 42) }

            VStack(alignment: alignment == .outgoing ? .trailing : .leading, spacing: 4) {
                if let author {
                    Text(author)
                        .font(.gaegu(size: 14))
                        .foregroundStyle(Color.pencil)
                }
                HStack(alignment: .top, spacing: 8) {
                    if let systemImage {
                        Image(systemName: systemImage)
                            .foregroundStyle(alignment == .outgoing ? Color.white : Color.imessage)
                    }
                    Text(text)
                        .font(.gaegu(size: 20))
                        .foregroundStyle(alignment == .outgoing ? Color.white : Color.ink)
                        .multilineTextAlignment(alignment == .outgoing ? .trailing : .leading)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(alignment == .outgoing ? Color.imessage : Color.paperSurface)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.ink.opacity(0.85), lineWidth: 1.5)
                )
                .shadow(color: Color.ink.opacity(0.08), radius: 6, x: 0, y: 3)
            }
            .frame(maxWidth: 560, alignment: alignment == .outgoing ? .trailing : .leading)

            if alignment == .incoming { Spacer(minLength: 42) }
        }
    }
}

private struct BlockBubble: View {
    let block: EditorBlock
    let isReadOnly: Bool

    var body: some View {
        switch block.kind {
        case .paragraph:
            MessageBubble(text: block.text, author: "RoomieOS", alignment: .incoming, systemImage: nil)
        case .heading1:
            MessageBubble(text: block.text, author: nil, alignment: .incoming, systemImage: "textformat.size")
        case .heading2:
            MessageBubble(text: block.text, author: nil, alignment: .incoming, systemImage: "textformat")
        case .checklist:
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: block.checked ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(block.checked ? Color.imessage : Color.pencil)
                    Text(block.text)
                        .font(.gaegu(size: 20))
                        .foregroundStyle(Color.ink)
                        .strikethrough(block.checked)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.mint.opacity(0.55))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.ink.opacity(0.85), lineWidth: 1.5))
                .shadow(color: Color.ink.opacity(0.08), radius: 6, x: 0, y: 3)
                Spacer(minLength: 42)
            }
        case .callout:
            HStack {
                HStack(alignment: .top, spacing: 10) {
                    Text("💡").font(.system(size: 22))
                    Text(block.text)
                        .font(.gaegu(size: 20))
                        .foregroundStyle(Color.ink)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.butter.opacity(0.65))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.ink.opacity(0.85), lineWidth: 1.5))
                .shadow(color: Color.ink.opacity(0.08), radius: 6, x: 0, y: 3)
                Spacer(minLength: 42)
            }
        case .divider:
            HStack(spacing: 8) {
                Spacer()
                ForEach(0..<5, id: \.self) { _ in
                    Circle().fill(Color.pencil.opacity(0.4)).frame(width: 5, height: 5)
                }
                Spacer()
            }
            .padding(.vertical, 8)
        case .database:
            MessageBubble(text: block.text, author: "Table", alignment: .incoming, systemImage: "tablecells")
        }
    }
}

private struct InlineChoreBubble: View {
    @Binding var chore: ChoreRecord
    let isReadOnly: Bool

    var body: some View {
        InlineRecordBubble(
            icon: "checklist",
            title: chore.title,
            subtitle: "\(chore.assignee) - \(chore.dueDate)",
            status: chore.status,
            trailing: nil,
            isComplete: chore.status == "Done",
            primaryActionTitle: chore.status == "Done" ? "Reopen" : "Done",
            isReadOnly: isReadOnly,
            onPrimaryAction: {
                chore.status = chore.status == "Done" ? "Not started" : "Done"
            }
        )
    }
}

private struct InlineExpenseBubble: View {
    @Binding var expense: ExpenseRecord
    let isReadOnly: Bool

    var body: some View {
        InlineRecordBubble(
            icon: "dollarsign.circle",
            title: expense.title,
            subtitle: "Paid by \(expense.paidBy) - \(expense.splitWith)",
            status: expense.status,
            trailing: expense.amount.formatted(.currency(code: "USD")),
            isComplete: expense.status == "Paid",
            primaryActionTitle: expense.status == "Paid" ? "Unpaid" : "Paid",
            isReadOnly: isReadOnly,
            onPrimaryAction: {
                expense.status = expense.status == "Paid" ? "Unpaid" : "Paid"
            }
        )
    }
}

private struct InlineRecordBubble: View {
    let icon: String
    let title: String
    let subtitle: String
    let status: String
    let trailing: String?
    let isComplete: Bool
    let primaryActionTitle: String
    let isReadOnly: Bool
    let onPrimaryAction: () -> Void

    private var accent: Color {
        // chore/expense get different sticker colors
        icon.contains("dollar") ? Color.butter.opacity(0.55) : Color.mint.opacity(0.55)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(Color.ink)
                        .frame(width: 36, height: 36)
                        .background(Color.paperSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.ink.opacity(0.6), lineWidth: 1.5))
                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.gaegu(size: 21))
                            .foregroundStyle(Color.ink)
                        Text(subtitle)
                            .font(.gaegu(size: 15))
                            .foregroundStyle(Color.pencil)
                    }
                    Spacer()
                    if let trailing {
                        Text(trailing)
                            .font(.gaegu(size: 20))
                            .foregroundStyle(Color.ink)
                    }
                }

                HStack(spacing: 8) {
                    Label(status, systemImage: isComplete ? "checkmark.circle.fill" : "circle")
                        .font(.gaegu(size: 14))
                        .foregroundStyle(isComplete ? Color.imessage : Color.pencil)
                    Spacer()
                    Button(primaryActionTitle, action: onPrimaryAction)
                        .font(.gaegu(size: 15))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(Color.paperSurface)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.ink.opacity(0.6), lineWidth: 1.5))
                        .foregroundStyle(Color.ink)
                        .disabled(isReadOnly)
                        .opacity(isReadOnly ? 0.5 : 1)
                }
            }
            .padding(14)
            .background(accent)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.ink.opacity(0.85), lineWidth: 1.5))
            .shadow(color: Color.ink.opacity(0.08), radius: 6, x: 0, y: 3)
            Spacer(minLength: 28)
        }
    }
}

private struct ComposerBar: View {
    @Binding var text: String
    @Binding var mode: ComposerMode
    let allowedModes: [ComposerMode]
    let isReadOnly: Bool
    let onInsert: () -> Void
    let onSend: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if text.hasPrefix("/") {
                SlashSuggestionStrip(mode: $mode, modes: allowedModes)
            }

            HStack(alignment: .bottom, spacing: 10) {
                Button(action: onInsert) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.ink)
                        .frame(width: 36, height: 36)
                        .background(Color.paperSurface)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.ink.opacity(0.85), lineWidth: 1.5))
                }
                .buttonStyle(SoftPressStyle())
                .disabled(isReadOnly)

                TextField(mode.placeholder, text: $text, axis: .vertical)
                    .font(.gaegu(size: 20))
                    .foregroundStyle(Color.ink)
                    .lineLimit(1...4)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(Color.paperSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.ink.opacity(0.85), lineWidth: 1.5))
                    .disabled(isReadOnly)

                let canSend = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                Button(action: onSend) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(canSend ? Color.white : Color.pencil)
                        .frame(width: 36, height: 36)
                        .background(canSend ? Color.imessage : Color.paperSurface)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.ink.opacity(0.85), lineWidth: 1.5))
                }
                .buttonStyle(SoftPressStyle())
                .disabled(isReadOnly || !canSend)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.paperBg.opacity(0.85))
        .overlay(
            Rectangle().fill(Color.ink.opacity(0.12)).frame(height: 1),
            alignment: .top
        )
    }
}

private struct SlashSuggestionStrip: View {
    @Binding var mode: ComposerMode
    let modes: [ComposerMode]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(modes) { candidate in
                    let selected = mode == candidate
                    Button {
                        mode = candidate
                    } label: {
                        Label(candidate.rawValue, systemImage: candidate.icon)
                            .font(.gaegu(size: 16))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selected ? Color.imessage : Color.paperSurface)
                            .foregroundStyle(selected ? Color.white : Color.ink)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.ink.opacity(0.6), lineWidth: 1.5))
                    }
                    .buttonStyle(SoftPressStyle())
                }
            }
        }
    }
}

private struct InsertMenuSheet: View {
    @Binding var mode: ComposerMode
    let modes: [ComposerMode]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                PaperWashBackground()
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(modes) { candidate in
                            Button {
                                mode = candidate
                                dismiss()
                            } label: {
                                CommandRow(icon: candidate.icon, title: candidate.rawValue, subtitle: candidate.placeholder)
                            }
                            .buttonStyle(SoftPressStyle())
                        }
                    }
                    .padding(18)
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Insert")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct SystemTimelineNote: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.gaegu(size: 14))
            .foregroundStyle(Color.pencil)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.paperSurface.opacity(0.5))
            .clipShape(Capsule())
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
    }
}

private struct ThreadRow: View {
    let title: String
    let preview: String
    let icon: String
    let badges: [String]

    var body: some View {
        HStack(spacing: 14) {
            EmojiBadge(icon: icon, size: 22, frame: 44)

            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline) {
                    Text(title)
                        .font(.gaegu(size: 22))
                        .foregroundStyle(Color.ink)
                    Spacer()
                    Text("Now")
                        .font(.gaegu(size: 13))
                        .foregroundStyle(Color.pencil)
                }
                Text(preview)
                    .font(.gaegu(size: 17))
                    .foregroundStyle(Color.pencil)
                    .lineLimit(2)
                if !badges.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(badges, id: \.self) { badge in
                            Text(badge)
                                .font(.gaegu(size: 13))
                                .padding(.horizontal, 9)
                                .padding(.vertical, 3)
                                .background(Color.lavender.opacity(0.7))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color.ink.opacity(0.5), lineWidth: 1))
                                .foregroundStyle(Color.ink)
                        }
                    }
                }
            }
        }
        .padding(14)
        .paperCard()
        .contentShape(Rectangle())
    }
}

private struct ThreadChip: View {
    let title: String
    let systemImage: String
    var tint: Color = .butter

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.gaegu(size: 15))
            .foregroundStyle(Color.ink)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(tint.opacity(0.8))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.ink.opacity(0.6), lineWidth: 1.5))
    }
}

private struct CommandRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 40, height: 40)
                .background(Color.mint.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.ink.opacity(0.5), lineWidth: 1.5))
                .rotationEffect(.degrees(-3))
                .foregroundStyle(Color.ink)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.gaegu(size: 22))
                    .foregroundStyle(Color.ink)
                Text(subtitle)
                    .font(.gaegu(size: 16))
                    .foregroundStyle(Color.pencil)
            }
            Spacer()
        }
        .padding(14)
        .paperCard()
    }
}

private enum ThingEditorMode: Equatable {
    case create
    case edit

    var title: String {
        switch self {
        case .create: "Add Thread"
        case .edit: "Edit Thread"
        }
    }

    var saveTitle: String {
        switch self {
        case .create: "Add"
        case .edit: "Save"
        }
    }
}

private struct ThingEditorSheet: View {
    let mode: ThingEditorMode
    let onCancel: () -> Void
    let onSave: (String, String, PageKind) -> Void

    @State private var draftTitle: String
    @State private var draftIcon: String
    @State private var draftKind: PageKind

    init(
        mode: ThingEditorMode,
        initialTitle: String,
        initialIcon: String,
        initialKind: PageKind,
        onCancel: @escaping () -> Void,
        onSave: @escaping (String, String, PageKind) -> Void
    ) {
        self.mode = mode
        self.onCancel = onCancel
        self.onSave = onSave
        _draftTitle = State(initialValue: initialTitle)
        _draftIcon = State(initialValue: initialIcon)
        _draftKind = State(initialValue: initialKind)
    }

    private var isSaveDisabled: Bool {
        draftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        draftIcon.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PaperWashBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("name")
                                .font(.gaegu(size: 16))
                                .foregroundStyle(Color.pencil)
                            TextField("Untitled thread", text: $draftTitle)
                                .font(.gaegu(size: 22))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .paperCard(radius: 16)

                            Text("emoji")
                                .font(.gaegu(size: 16))
                                .foregroundStyle(Color.pencil)
                            TextField("🏠", text: $draftIcon)
                                .font(.system(size: 26))
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .paperCard(radius: 16)
                        }

                        if mode == .create {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("kind")
                                    .font(.gaegu(size: 16))
                                    .foregroundStyle(Color.pencil)
                                Picker("Type", selection: $draftKind) {
                                    ForEach(PageKind.allCases, id: \.self) { kind in
                                        Text(kind.displayTitle).tag(kind)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .onChange(of: draftKind) {
                                    if draftIcon.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        draftIcon = draftKind.defaultEmoji
                                    }
                                }
                            }
                        }
                    }
                    .padding(18)
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                        .foregroundStyle(Color.ink)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(mode.saveTitle) {
                        let title = draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                        let icon = draftIcon.trimmingCharacters(in: .whitespacesAndNewlines)
                        onSave(title, icon, draftKind)
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.imessage)
                    .disabled(isSaveDisabled)
                }
            }
        }
    }
}

private struct ToastView: View {
    let message: String

    var body: some View {
        HStack(spacing: 8) {
            Text("✨").font(.system(size: 16))
            Text(message)
                .font(.gaegu(size: 18))
                .foregroundStyle(Color.ink)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.butter)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.ink.opacity(0.85), lineWidth: 1.5))
        .shadow(color: Color.ink.opacity(0.25), radius: 0, x: 0, y: 4)
        .shadow(color: Color.ink.opacity(0.15), radius: 12, x: 0, y: 8)
        .rotationEffect(.degrees(-2))
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

private extension PageKind {
    var displayTitle: String {
        switch self {
        case .document: "Home / Note"
        case .chores: "Chores"
        case .expenses: "Expenses"
        case .rules: "House Rules"
        case .roommates: "Roommates"
        }
    }

    var defaultEmoji: String {
        switch self {
        case .document: "🏠"
        case .chores: "🧹"
        case .expenses: "💸"
        case .rules: "📜"
        case .roommates: "👥"
        }
    }
}
