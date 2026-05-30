import SwiftUI

// MARK: - Theme
//
// Palette + reusable bits that match the marketing site: cream paper
// background, ink text, hand-drawn paper cards, sticker buttons. Several
// "colorway" themes are available; each defines complementary day + night
// variants. The user picks one from Settings; the active selection lives in
// `CurrentTheme.name` and is read by the dynamic UIColor providers below.
// Forcing the view tree to re-render after the user changes themes is done
// at the app root with `.id(themeName)`.

enum ColorThemeName: String, CaseIterable, Identifiable {
    case classic
    case sunset
    case garden
    case twilight

    var id: String { rawValue }

    var title: String {
        switch self {
        case .classic: "Classic Cream"
        case .sunset: "Sunset Peach"
        case .garden: "Garden Mint"
        case .twilight: "Twilight Lavender"
        }
    }

    var subtitle: String {
        switch self {
        case .classic: "Cream paper, ink, iMessage blue"
        case .sunset: "Warm peach, plum night, coral accent"
        case .garden: "Mint paper, forest night, leaf accent"
        case .twilight: "Lavender paper, indigo night, lilac accent"
        }
    }

    fileprivate func paperBg(dark: Bool) -> UIColor {
        switch self {
        case .classic:  dark ? hex(0x1B1635) : hex(0xFBF3DE)
        case .sunset:   dark ? hex(0x2A1B2E) : hex(0xFFE3D0)
        case .garden:   dark ? hex(0x1A2924) : hex(0xE5F2DE)
        case .twilight: dark ? hex(0x20183A) : hex(0xE8DDF5)
        }
    }

    fileprivate func paperSurface(dark: Bool) -> UIColor {
        switch self {
        case .classic:  dark ? hex(0x322B55) : hex(0xFFFCF1)
        case .sunset:   dark ? hex(0x432942) : hex(0xFFF1E5)
        case .garden:   dark ? hex(0x2D4138) : hex(0xF4F9E8)
        case .twilight: dark ? hex(0x382A55) : hex(0xF4ECFA)
        }
    }

    fileprivate func ink(dark: Bool) -> UIColor {
        switch self {
        case .classic:  dark ? hex(0xF4E9C9) : hex(0x2A2440)
        case .sunset:   dark ? hex(0xF6E5DA) : hex(0x3A1F2C)
        case .garden:   dark ? hex(0xDCEDD7) : hex(0x1F3320)
        case .twilight: dark ? hex(0xE8DDF5) : hex(0x2D2247)
        }
    }

    fileprivate func pencil(dark: Bool) -> UIColor {
        switch self {
        case .classic:  dark ? hex(0xC9C2E0) : hex(0x5B5570)
        case .sunset:   dark ? hex(0xDCBFC8) : hex(0x6E4A56)
        case .garden:   dark ? hex(0xBCD5BC) : hex(0x4D6B4E)
        case .twilight: dark ? hex(0xC9BAE0) : hex(0x5C4D78)
        }
    }

    private func hex(_ value: UInt32) -> UIColor {
        UIColor(
            red: CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8) & 0xFF) / 255,
            blue: CGFloat(value & 0xFF) / 255,
            alpha: 1
        )
    }
}

// The currently-active theme. Mutated when the user picks a different theme
// in Settings; the app's root view also tags itself with `.id(themeName)` so
// SwiftUI tears down and rebuilds the view tree, causing the Color
// extensions below to re-evaluate against the new palette.
fileprivate enum CurrentTheme {
    static var name: ColorThemeName = .classic
}

private extension Color {
    static var paperBg: Color {
        Color(UIColor { trait in
            CurrentTheme.name.paperBg(dark: trait.userInterfaceStyle == .dark)
        })
    }

    static var paperSurface: Color {
        Color(UIColor { trait in
            CurrentTheme.name.paperSurface(dark: trait.userInterfaceStyle == .dark)
        })
    }

    static var ink: Color {
        Color(UIColor { trait in
            CurrentTheme.name.ink(dark: trait.userInterfaceStyle == .dark)
        })
    }

    static var pencil: Color {
        Color(UIColor { trait in
            CurrentTheme.name.pencil(dark: trait.userInterfaceStyle == .dark)
        })
    }

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

// MARK: - Animation helpers

// The house chip on the welcome screen — wiggles gently so the page feels alive.
private struct WelcomeHouseIcon: View {
    @State private var tilt: Double = -6

    var body: some View {
        Text("🏠")
            .font(.system(size: 34))
            .padding(10)
            .background(Color.butter)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.ink.opacity(0.85), lineWidth: 2))
            .rotationEffect(.degrees(tilt))
            .shadow(color: Color.ink.opacity(0.18), radius: 6, x: 0, y: 4)
            .onAppear {
                withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                    tilt = 6
                }
            }
    }
}

// A bouncy green check used on the onboarding success screen.
private struct SuccessCheckBadge: View {
    @State private var scale: CGFloat = 0.6
    @State private var rotation: Double = -18

    var body: some View {
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
        .scaleEffect(scale)
        .rotationEffect(.degrees(rotation))
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.55)) {
                scale = 1
                rotation = -6
            }
        }
    }
}

// Random colored sparkles fade up around the success badge.
private struct SparkleConfetti: View {
    @State private var appeared = false

    private let pieces: [SparklePiece] = (0..<10).map { _ in
        SparklePiece(
            color: [Color.butter, .peach, .mint, .lavender, .coral, .sky].randomElement()!,
            offset: CGSize(
                width: CGFloat.random(in: -40...260),
                height: CGFloat.random(in: -40...80)
            ),
            delay: Double.random(in: 0...0.4),
            scale: CGFloat.random(in: 0.7...1.4),
            rotation: Double.random(in: -30...30)
        )
    }

    var body: some View {
        ZStack {
            ForEach(pieces) { piece in
                Text("✨")
                    .font(.system(size: 18 * piece.scale))
                    .foregroundStyle(piece.color)
                    .offset(piece.offset)
                    .scaleEffect(appeared ? 1 : 0)
                    .rotationEffect(.degrees(appeared ? piece.rotation : 0))
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.7, dampingFraction: 0.65).delay(piece.delay), value: appeared)
            }
        }
        .frame(width: 0, height: 0)
        .allowsHitTesting(false)
        .onAppear { appeared = true }
    }

    private struct SparklePiece: Identifiable {
        let id = UUID()
        let color: Color
        let offset: CGSize
        let delay: Double
        let scale: CGFloat
        let rotation: Double
    }
}

// A view modifier that gently nudges a view in from below with a spring,
// staggered by its index. Used to make lists feel alive when they first
// appear.
private struct RevealOnAppearModifier: ViewModifier {
    let delay: Double
    @State private var visible = false

    func body(content: Content) -> some View {
        content
            .opacity(visible ? 1 : 0)
            .offset(y: visible ? 0 : 14)
            .animation(.spring(response: 0.55, dampingFraction: 0.78).delay(delay), value: visible)
            .onAppear { visible = true }
    }
}

private extension View {
    func revealOnAppear(delay: Double = 0) -> some View {
        modifier(RevealOnAppearModifier(delay: delay))
    }
}

private enum AppAppearance: String, CaseIterable, Identifiable {
    case light
    case dark
    case system

    var id: String { rawValue }

    // Nil means "follow the device". The onboarding toggle only flips between
    // .light and .dark; .system is reached from Settings.
    var colorScheme: ColorScheme? {
        switch self {
        case .light: .light
        case .dark: .dark
        case .system: nil
        }
    }

    var toggleTitle: String {
        switch self {
        case .light: "Night"
        case .dark: "Day"
        case .system: "Day"
        }
    }

    var toggleIcon: String {
        switch self {
        case .light: "moon.fill"
        case .dark: "sun.max.fill"
        case .system: "moon.fill"
        }
    }

    var settingsTitle: String {
        switch self {
        case .light: "Day"
        case .dark: "Night"
        case .system: "Match system"
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

    // Persisted user preferences. AppStorage keeps the choice across launches.
    @AppStorage("appearanceMode") private var appearanceRaw: String = AppAppearance.light.rawValue
    @AppStorage("colorTheme") private var themeRaw: String = ColorThemeName.classic.rawValue

    private var appearance: AppAppearance {
        get { AppAppearance(rawValue: appearanceRaw) ?? .light }
    }

    private var themeName: ColorThemeName {
        get { ColorThemeName(rawValue: themeRaw) ?? .classic }
    }

    private var appearanceBinding: Binding<AppAppearance> {
        Binding(
            get: { AppAppearance(rawValue: appearanceRaw) ?? .light },
            set: { appearanceRaw = $0.rawValue }
        )
    }

    private var themeBinding: Binding<ColorThemeName> {
        Binding(
            get: { ColorThemeName(rawValue: themeRaw) ?? .classic },
            set: {
                CurrentTheme.name = $0
                themeRaw = $0.rawValue
            }
        )
    }

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                workspaceShell
            } else {
                OnboardingFlowView(
                    appearance: appearanceBinding,
                    onComplete: { seed in
                        applyWorkspace(seed)
                        hasCompletedOnboarding = true
                        showToast("Workspace ready")
                    }
                )
            }
        }
        .preferredColorScheme(appearance.colorScheme)
        .onAppear {
            // Ensure CurrentTheme is in sync with persisted choice on launch.
            CurrentTheme.name = themeName
        }
        .id(themeRaw) // forces a re-render when the user picks a new theme
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
            appearance: appearanceBinding,
            themeName: themeBinding,
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
        case .trips:
            blocks = [
                EditorBlock(id: UUID(), kind: .heading1, text: cleanedTitle, checked: false),
                EditorBlock(id: UUID(), kind: .callout, text: "Drop trip ideas. Anyone can chime in.", checked: false)
            ]
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
                ExpenseRecord(id: UUID(), title: "New expense", amount: 0, paidBy: "Alex Kim", status: "Unpaid", splitWith: "Everyone", splits: []),
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
        withAnimation(.spring(response: 0.45, dampingFraction: 0.6)) {
            toastMessage = message
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeOut(duration: 0.25)) {
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
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    }
                    .frame(maxWidth: 720, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 28)
                    .frame(maxWidth: .infinity)
                    .animation(.spring(response: 0.45, dampingFraction: 0.82), value: step)
                }
            }
        }
        .foregroundStyle(Color.ink)
        .animation(.easeInOut(duration: 0.4), value: appearance)
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
                    WelcomeHouseIcon()
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
                ForEach(Array(OnboardingIntent.allCases.enumerated()), id: \.element.id) { index, intent in
                    SelectableCard(
                        title: intent.title,
                        subtitle: intent.subtitle,
                        icon: intent.icon,
                        badge: intent == .apartment ? "Recommended" : nil,
                        isSelected: selectedIntent == intent
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedIntent = intent
                            selectedTemplate = intent.defaultTemplate
                        }
                    }
                    .revealOnAppear(delay: Double(index) * 0.06)
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
                ForEach(Array(StarterTemplate.allCases.enumerated()), id: \.element.id) { index, template in
                    TemplateCard(
                        template: template,
                        isSelected: selectedTemplate == template,
                        onSelect: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTemplate = template
                            }
                        }
                    )
                    .revealOnAppear(delay: Double(index) * 0.07)
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
            ZStack(alignment: .topLeading) {
                HStack(spacing: 14) {
                    SuccessCheckBadge()
                    VStack(alignment: .leading, spacing: 6) {
                        Text("welcome home!")
                            .font(.gaegu(size: 34))
                        Text("your little place is ready 🏠")
                            .font(.gaegu(size: 19))
                            .foregroundStyle(Color.pencil)
                    }
                }
                SparkleConfetti()
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

    var accent: Color {
        switch self {
        case .inbox: .sky
        case .expenses: .mint
        }
    }
}

// Sticker-styled bottom tab bar. Pairs with `.tabViewStyle(.page)` above so
// swiping horizontally and tapping a tab both update the same selection.
private struct StickerTabBar: View {
    @Binding var selection: HybridTab
    @Namespace private var pillNamespace

    var body: some View {
        HStack(spacing: 4) {
            ForEach(HybridTab.allCases) { tab in
                let isSelected = selection == tab
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selection = tab
                    }
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 19, weight: .semibold))
                            .scaleEffect(isSelected ? 1.05 : 1)
                        Text(tab.title)
                            .font(.gaegu(size: 14))
                    }
                    .foregroundStyle(isSelected ? Color.ink : Color.pencil)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        Group {
                            if isSelected {
                                Capsule()
                                    .fill(tab.accent.opacity(0.55))
                                    .overlay(Capsule().stroke(Color.ink.opacity(0.55), lineWidth: 1.5))
                                    .matchedGeometryEffect(id: "pill", in: pillNamespace)
                            }
                        }
                    )
                }
                .buttonStyle(SoftPressStyle())
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.paperSurface)
        .overlay(
            Rectangle().fill(Color.ink.opacity(0.12)).frame(height: 1),
            alignment: .top
        )
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
        case .document, .roommates, .trips:
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
    @Binding var appearance: AppAppearance
    @Binding var themeName: ColorThemeName
    let onCreatePage: () -> Void
    let onRunCommand: (CommandAction) -> Void
    let onToast: (String) -> Void
    @State private var selectedTab: HybridTab = .inbox
    @State private var isSettingsPresented = false

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                TabView(selection: $selectedTab) {
                    NavigationStack {
                        HybridInboxView(
                            householdName: householdName,
                            pages: pages,
                            rootPageIDs: rootPageIDs,
                            chores: chores,
                            expenses: expenses,
                            onCreatePage: onCreatePage,
                            onOpenSettings: { isSettingsPresented = true }
                        )
                        .navigationDestination(for: UUID.self) { pageID in
                            destination(for: pageID)
                        }
                    }
                    .tag(HybridTab.inbox)

                    NavigationStack {
                        ExpenseAnalyticsView(
                            expenses: $expenses,
                            roommates: roommates,
                            onToast: onToast
                        )
                    }
                    .tag(HybridTab.expenses)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .tint(Color.imessage)
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedTab)

                StickerTabBar(selection: $selectedTab)
            }

            VStack(spacing: 10) {
                if let toastMessage {
                    ToastView(message: toastMessage)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.5).combined(with: .opacity).combined(with: .move(edge: .bottom)),
                            removal: .opacity
                        ))
                }
            }
            .padding(.bottom, 92)
            .animation(.spring(response: 0.45, dampingFraction: 0.6), value: toastMessage)
        }
        .foregroundStyle(Color.ink)
        .sheet(isPresented: $isSettingsPresented) {
            SettingsSheet(
                roommates: $roommates,
                appearance: $appearance,
                themeName: $themeName,
                onToast: onToast
            )
        }
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
    let onOpenSettings: () -> Void

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
                        ForEach(Array(orderedPages.enumerated()), id: \.element.id) { index, page in
                            NavigationLink(value: page.id) {
                                ThreadRow(
                                    title: page.title,
                                    preview: preview(for: page),
                                    icon: page.icon,
                                    badges: badges(for: page)
                                )
                            }
                            .buttonStyle(SoftPressStyle())
                            .revealOnAppear(delay: Double(index) * 0.06)
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
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onOpenSettings) {
                    Image(systemName: "gearshape.fill")
                        .font(.title3)
                        .foregroundStyle(Color.ink)
                }
                .accessibilityLabel("Settings")
            }

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
        .toolbarBackground(Color.paperBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
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
        case .document, .rules, .trips:
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
        case .trips: ["Travel"]
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
    @Binding var expenses: [ExpenseRecord]
    let roommates: [Roommate]
    let onToast: (String) -> Void
    @State private var selectedRange: ExpenseAnalyticsRange = .week
    @State private var selectedPointIndex: Int?
    @State private var isAddExpensePresented = false
    @State private var expandedRoommateID: UUID?

    private var paidTotal: Double {
        expenses.flatMap(\.splits).filter(\.isPaid).map(\.amount).reduce(0, +)
    }

    private var unpaidTotal: Double {
        expenses.flatMap(\.splits).filter { !$0.isPaid }.map(\.amount).reduce(0, +)
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
                    whoOwesWhomSection
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
                Button {
                    isAddExpensePresented = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.imessage)
                }
                .accessibilityLabel("Add expense")
            }
        }
        .navigationTitle("Expenses")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.paperBg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $isAddExpensePresented) {
            AddExpenseSheet(
                roommates: roommates,
                onCancel: { isAddExpensePresented = false },
                onSave: { record in
                    expenses.insert(record, at: 0)
                    isAddExpensePresented = false
                    onToast("\(record.title) added")
                }
            )
        }
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

    // The "Who owes whom" section. For each roommate, sums up unpaid splits
    // across every expense they paid for. Tap a card to expand and see each
    // individual split, with a Paid/Unpaid toggle so users can settle up.
    private var whoOwesWhomSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("who owes whom")
                .font(.gaegu(size: 22))
                .foregroundStyle(Color.ink)

            VStack(spacing: 10) {
                ForEach(Array(roommates.enumerated()), id: \.element.id) { index, roommate in
                    RoommateOwesCard(
                        roommate: roommate,
                        tint: Self.memberTints[index % Self.memberTints.count],
                        expenses: $expenses,
                        isExpanded: expandedRoommateID == roommate.id,
                        onToggleExpanded: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                                expandedRoommateID = (expandedRoommateID == roommate.id) ? nil : roommate.id
                            }
                        },
                        onTogglePaid: { expenseID, splitID in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                togglePaid(expenseID: expenseID, splitID: splitID)
                            }
                        }
                    )
                }
            }
        }
    }

    private static let memberTints: [Color] = [.mint, .peach, .lavender, .sky]

    private func togglePaid(expenseID: UUID, splitID: UUID) {
        guard let expenseIndex = expenses.firstIndex(where: { $0.id == expenseID }) else { return }
        guard let splitIndex = expenses[expenseIndex].splits.firstIndex(where: { $0.id == splitID }) else { return }
        expenses[expenseIndex].splits[splitIndex].isPaid.toggle()
        // Keep `status` synced for the legacy field.
        if expenses[expenseIndex].splits.allSatisfy(\.isPaid) {
            expenses[expenseIndex].status = "Paid"
        } else if expenses[expenseIndex].splits.contains(where: \.isPaid) {
            expenses[expenseIndex].status = "Partially paid"
        } else {
            expenses[expenseIndex].status = "Unpaid"
        }
        onToast(expenses[expenseIndex].splits[splitIndex].isPaid ? "Marked paid" : "Marked unpaid")
    }

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

// MARK: - Who owes whom

private struct RoommateOwesCard: View {
    let roommate: Roommate
    let tint: Color
    @Binding var expenses: [ExpenseRecord]
    let isExpanded: Bool
    let onToggleExpanded: () -> Void
    let onTogglePaid: (UUID, UUID) -> Void

    // All (expense, split) pairs where someone else owes this roommate.
    private var owedItems: [(expense: ExpenseRecord, split: ExpenseSplit)] {
        expenses
            .filter { $0.paidBy == roommate.name }
            .flatMap { expense in
                expense.splits.map { (expense: expense, split: $0) }
            }
    }

    private var outstandingTotal: Double {
        owedItems.filter { !$0.split.isPaid }.map(\.split.amount).reduce(0, +)
    }

    private var paidTotal: Double {
        owedItems.filter { $0.split.isPaid }.map(\.split.amount).reduce(0, +)
    }

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onToggleExpanded) {
                HStack(spacing: 12) {
                    Text(initials(for: roommate.name))
                        .font(.gaegu(size: 17))
                        .frame(width: 40, height: 40)
                        .background(tint.opacity(0.85))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.ink.opacity(0.55), lineWidth: 1.5))
                        .foregroundStyle(Color.ink)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(roommate.name)
                            .font(.gaegu(size: 20))
                            .foregroundStyle(Color.ink)
                        Text(subtitle)
                            .font(.gaegu(size: 14))
                            .foregroundStyle(Color.pencil)
                    }

                    Spacer()

                    Text(outstandingTotal.formatted(.currency(code: "USD")))
                        .font(.gaegu(size: 19))
                        .foregroundStyle(outstandingTotal > 0 ? Color.ink : Color.pencil)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.pencil)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(14)
            }
            .buttonStyle(SoftPressStyle())

            if isExpanded {
                Divider()
                    .overlay(Color.ink.opacity(0.18))
                    .padding(.horizontal, 14)

                VStack(spacing: 8) {
                    if owedItems.isEmpty {
                        Text("nobody owes \(firstName) anything yet.")
                            .font(.gaegu(size: 16))
                            .foregroundStyle(Color.pencil)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(owedItems.indices, id: \.self) { i in
                            let pair = owedItems[i]
                            OwedSplitRow(
                                expenseTitle: pair.expense.title,
                                debtor: pair.split.roommateName,
                                amount: pair.split.amount,
                                isPaid: pair.split.isPaid,
                                onTogglePaid: {
                                    onTogglePaid(pair.expense.id, pair.split.id)
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity
                ))
            }
        }
        .paperCard()
    }

    private var subtitle: String {
        if owedItems.isEmpty {
            return "nothing fronted yet"
        }
        let unpaidCount = owedItems.filter { !$0.split.isPaid }.count
        if unpaidCount == 0 {
            return "all settled · paid \(paidTotal.formatted(.currency(code: "USD")))"
        }
        return "\(unpaidCount) unpaid · \(owedItems.count) total"
    }

    private var firstName: String {
        roommate.name.split(separator: " ").first.map(String.init) ?? roommate.name
    }

    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ")
        let first = parts.first.map { String($0.prefix(1)) } ?? ""
        let second = parts.dropFirst().first.map { String($0.prefix(1)) } ?? ""
        return (first + second).uppercased()
    }
}

private struct OwedSplitRow: View {
    let expenseTitle: String
    let debtor: String
    let amount: Double
    let isPaid: Bool
    let onTogglePaid: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isPaid ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(isPaid ? Color.imessage : Color.pencil)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(debtor) owes \(amount.formatted(.currency(code: "USD")))")
                    .font(.gaegu(size: 17))
                    .foregroundStyle(Color.ink)
                    .strikethrough(isPaid)
                Text("for \(expenseTitle)")
                    .font(.gaegu(size: 14))
                    .foregroundStyle(Color.pencil)
            }

            Spacer()

            Button(action: onTogglePaid) {
                Text(isPaid ? "Paid off" : "Mark paid")
                    .font(.gaegu(size: 14))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(isPaid ? Color.mint.opacity(0.7) : Color.paperSurface)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.ink.opacity(0.55), lineWidth: 1.5))
                    .foregroundStyle(Color.ink)
            }
            .buttonStyle(SoftPressStyle())
        }
        .padding(10)
        .background(Color.paperSurface.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
            .stroke(Color.ink.opacity(0.35), lineWidth: 1))
    }
}

// MARK: - Add Expense Sheet

private struct AddExpenseSheet: View {
    let roommates: [Roommate]
    let onCancel: () -> Void
    let onSave: (ExpenseRecord) -> Void

    @State private var title = ""
    @State private var amount: Double = 0
    @State private var paidByID: UUID
    @State private var splits: [DraftSplit]
    @State private var errorMessage: String?

    fileprivate struct DraftSplit: Identifiable, Equatable {
        let id: UUID
        let roommateID: UUID
        var roommateName: String
        var amount: Double
        var isIncluded: Bool
    }

    init(roommates: [Roommate], onCancel: @escaping () -> Void, onSave: @escaping (ExpenseRecord) -> Void) {
        self.roommates = roommates
        self.onCancel = onCancel
        self.onSave = onSave
        let firstID = roommates.first?.id ?? UUID()
        _paidByID = State(initialValue: firstID)
        // Default: every roommate except the payer is included with 0 owed.
        _splits = State(initialValue: roommates.filter { $0.id != firstID }.map {
            DraftSplit(id: UUID(), roommateID: $0.id, roommateName: $0.name, amount: 0, isIncluded: true)
        })
    }

    private var paidByName: String {
        roommates.first(where: { $0.id == paidByID })?.name ?? roommates.first?.name ?? "Unassigned"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PaperWashBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Add an expense")
                            .font(.gaegu(size: 30))
                            .foregroundStyle(Color.ink)
                        Text("Pick who paid, then how much each housemate owes.")
                            .font(.gaegu(size: 17))
                            .foregroundStyle(Color.pencil)

                        labeled("what was it for") {
                            TextField("Internet bill", text: $title)
                                .font(.gaegu(size: 22))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .paperCard(radius: 16)
                                .textInputAutocapitalization(.sentences)
                        }

                        labeled("total amount ($)") {
                            TextField("60.00", value: $amount, format: .number.precision(.fractionLength(2)))
                                .font(.gaegu(size: 22))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .paperCard(radius: 16)
                                .keyboardType(.decimalPad)
                                .onChange(of: amount) { _, _ in
                                    redistribute()
                                }
                        }

                        labeled("paid by") {
                            VStack(spacing: 8) {
                                ForEach(roommates) { roommate in
                                    PayerRow(
                                        name: roommate.name,
                                        isSelected: paidByID == roommate.id,
                                        onSelect: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                                paidByID = roommate.id
                                                rebuildSplits()
                                            }
                                        }
                                    )
                                }
                            }
                        }

                        labeled("who owes what") {
                            VStack(spacing: 8) {
                                if splits.isEmpty {
                                    Text("Need at least one more roommate to split with.")
                                        .font(.gaegu(size: 16))
                                        .foregroundStyle(Color.pencil)
                                } else {
                                    ForEach($splits) { $split in
                                        SplitInputRow(split: $split, paidByName: paidByName)
                                    }

                                    HStack {
                                        Button("Split evenly") {
                                            splitEvenly()
                                        }
                                        .font(.gaegu(size: 16))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.butter.opacity(0.6))
                                        .clipShape(Capsule())
                                        .overlay(Capsule().stroke(Color.ink.opacity(0.55), lineWidth: 1.5))
                                        .foregroundStyle(Color.ink)
                                        Spacer()
                                        Text("assigned: \(assignedTotal.formatted(.currency(code: "USD")))")
                                            .font(.gaegu(size: 15))
                                            .foregroundStyle(Color.pencil)
                                    }
                                    .padding(.top, 4)
                                }
                            }
                        }

                        if let errorMessage {
                            HStack(spacing: 6) {
                                Text("⚠️")
                                Text(errorMessage)
                                    .font(.gaegu(size: 17))
                            }
                            .foregroundStyle(Color.coral)
                        }

                        HStack(spacing: 14) {
                            Button("Add", action: validateAndSave)
                                .buttonStyle(StickerButtonStyle())
                            Button("Cancel", action: onCancel)
                                .buttonStyle(StickerButtonStyle(variant: .cream))
                        }
                    }
                    .padding(18)
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("New expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.paperBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
            }
        }
    }

    private var assignedTotal: Double {
        splits.filter(\.isIncluded).map(\.amount).reduce(0, +)
    }

    private func labeled<Content: View>(_ label: String, @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.gaegu(size: 16))
                .foregroundStyle(Color.pencil)
            content()
        }
    }

    private func rebuildSplits() {
        splits = roommates.filter { $0.id != paidByID }.map {
            DraftSplit(id: UUID(), roommateID: $0.id, roommateName: $0.name, amount: 0, isIncluded: true)
        }
        redistribute()
    }

    // When the total amount changes, split evenly among the included splitees
    // unless the user has typed custom amounts (we detect this by checking if
    // all included rows are currently 0 — if so, we're still in default mode).
    private func redistribute() {
        let allZero = splits.filter(\.isIncluded).allSatisfy { $0.amount == 0 }
        if allZero {
            splitEvenly()
        }
    }

    private func splitEvenly() {
        let active = splits.filter(\.isIncluded)
        guard !active.isEmpty else { return }
        let perPerson = (amount / Double(active.count) * 100).rounded() / 100
        for index in splits.indices where splits[index].isIncluded {
            splits[index].amount = perPerson
        }
    }

    private func validateAndSave() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            errorMessage = "Give it a quick name."
            return
        }
        if amount <= 0 {
            errorMessage = "Enter a real amount."
            return
        }
        let activeSplits = splits.filter(\.isIncluded)
        if activeSplits.isEmpty {
            errorMessage = "Pick at least one roommate to split with."
            return
        }
        let total = activeSplits.map(\.amount).reduce(0, +)
        if abs(total - amount) > 0.01 {
            errorMessage = "Splits add up to \(total.formatted(.currency(code: "USD"))). Should match the total."
            return
        }
        let record = ExpenseRecord(
            id: UUID(),
            title: trimmed,
            amount: amount,
            paidBy: paidByName,
            status: "Unpaid",
            splitWith: "Custom",
            splits: activeSplits.map {
                ExpenseSplit(id: UUID(), roommateName: $0.roommateName, amount: $0.amount, isPaid: false)
            }
        )
        onSave(record)
    }
}

private struct PayerRow: View {
    let name: String
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.imessage : Color.pencil.opacity(0.6))
                Text(name)
                    .font(.gaegu(size: 19))
                    .foregroundStyle(Color.ink)
                Spacer()
            }
            .padding(12)
            .background(Color.paperSurface)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? Color.imessage : Color.ink.opacity(0.55), lineWidth: isSelected ? 2 : 1.5)
            )
        }
        .buttonStyle(SoftPressStyle())
    }
}

private struct SplitInputRow: View {
    @Binding var split: AddExpenseSheet.DraftSplit
    let paidByName: String

    var body: some View {
        HStack(spacing: 10) {
            Button {
                split.isIncluded.toggle()
            } label: {
                Image(systemName: split.isIncluded ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundStyle(split.isIncluded ? Color.imessage : Color.pencil.opacity(0.6))
            }
            .buttonStyle(SoftPressStyle())

            Text(split.roommateName)
                .font(.gaegu(size: 18))
                .foregroundStyle(split.isIncluded ? Color.ink : Color.pencil)
                .strikethrough(!split.isIncluded)

            Spacer()

            TextField("0.00", value: $split.amount, format: .number.precision(.fractionLength(2)))
                .font(.gaegu(size: 18))
                .multilineTextAlignment(.trailing)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .frame(width: 90)
                .background(Color.paperSurface)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.ink.opacity(0.55), lineWidth: 1.5))
                .keyboardType(.decimalPad)
                .disabled(!split.isIncluded)
        }
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
        case .document, .rules, .trips:
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
            expenses.insert(ExpenseRecord(id: UUID(), title: cleanedText, amount: inferredAmount(from: cleanedText), paidBy: roommates.first?.name ?? "Unassigned", status: "Unpaid", splitWith: "Everyone", splits: []), at: 0)
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
                withAnimation(.spring(response: 0.35, dampingFraction: 0.55)) {
                    chore.status = chore.status == "Done" ? "Not started" : "Done"
                }
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
                withAnimation(.spring(response: 0.35, dampingFraction: 0.55)) {
                    expense.status = expense.status == "Paid" ? "Unpaid" : "Paid"
                }
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
            .scaleEffect(isComplete ? 0.97 : 1)
            .animation(.spring(response: 0.35, dampingFraction: 0.55), value: isComplete)
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
                    .transition(.move(edge: .bottom).combined(with: .opacity))
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
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: text.hasPrefix("/"))
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: mode)
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

    // The toast sits on top of a hardcoded butter sticker, so the text and
    // border should stay dark regardless of the user's appearance choice —
    // otherwise dark-mode `Color.ink` becomes cream and turns light-on-light.
    private let toastInk = Color(red: 0x2A / 255, green: 0x24 / 255, blue: 0x40 / 255)

    var body: some View {
        HStack(spacing: 8) {
            Text("✨").font(.system(size: 16))
            Text(message)
                .font(.gaegu(size: 18))
                .foregroundStyle(toastInk)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.butter)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(toastInk.opacity(0.85), lineWidth: 1.5))
        .shadow(color: toastInk.opacity(0.25), radius: 0, x: 0, y: 4)
        .shadow(color: toastInk.opacity(0.15), radius: 12, x: 0, y: 8)
        .rotationEffect(.degrees(-2))
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Settings

private struct SettingsSheet: View {
    @Binding var roommates: [Roommate]
    @Binding var appearance: AppAppearance
    @Binding var themeName: ColorThemeName
    let onToast: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var isAddRoommatePresented = false

    var body: some View {
        NavigationStack {
            ZStack {
                PaperWashBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        roommatesSection
                        appearanceSection
                        themeSection
                    }
                    .padding(18)
                    .padding(.bottom, 32)
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.paperBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .font(.gaegu(size: 18))
                        .foregroundStyle(Color.imessage)
                }
            }
            .sheet(isPresented: $isAddRoommatePresented) {
                AddRoommateSheet(
                    onCancel: { isAddRoommatePresented = false },
                    onSave: { name, phone in
                        roommates.append(Roommate(
                            id: UUID(),
                            name: name,
                            email: "",
                            phoneNumber: phone,
                            role: "Roommate"
                        ))
                        isAddRoommatePresented = false
                        onToast("\(name) added")
                    }
                )
                .preferredColorScheme(appearance.colorScheme)
            }
        }
        // Force the sheet's view tree to re-evaluate when the user changes the
        // appearance from inside Settings. Without this, sheet content keeps
        // the trait collection it was presented with and the paper background
        // doesn't flip until the sheet is reopened.
        .preferredColorScheme(appearance.colorScheme)
        .id("\(appearance.rawValue)-\(themeName.rawValue)")
    }

    private var roommatesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(icon: "👥", title: "Roommates", subtitle: "Add the people sharing your place.")

            VStack(spacing: 10) {
                ForEach(roommates) { roommate in
                    RoommateRow(roommate: roommate) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            roommates.removeAll { $0.id == roommate.id }
                        }
                        onToast("\(roommate.name) removed")
                    }
                }
            }

            Button {
                isAddRoommatePresented = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("Add roommate")
                }
                .foregroundStyle(Color.white)
            }
            .buttonStyle(StickerButtonStyle())
        }
    }

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(icon: "🌗", title: "Appearance", subtitle: "Pick how the app should look.")

            VStack(spacing: 8) {
                ForEach(AppAppearance.allCases) { option in
                    AppearanceOptionRow(
                        option: option,
                        isSelected: appearance == option,
                        onSelect: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                appearance = option
                            }
                        }
                    )
                }
            }
        }
    }

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(icon: "🎨", title: "Colorway", subtitle: "Day + night versions designed to complement each other.")

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                ForEach(ColorThemeName.allCases) { theme in
                    ThemeSwatchCard(
                        theme: theme,
                        isSelected: themeName == theme,
                        onSelect: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                themeName = theme
                            }
                            onToast("\(theme.title) applied")
                        }
                    )
                }
            }
        }
    }

    private func sectionHeader(icon: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(icon)
                .font(.system(size: 22))
                .frame(width: 32, height: 32)
                .background(Color.butter.opacity(0.55))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.ink.opacity(0.5), lineWidth: 1.5))
                .rotationEffect(.degrees(-4))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.gaegu(size: 24))
                    .foregroundStyle(Color.ink)
                Text(subtitle)
                    .font(.gaegu(size: 15))
                    .foregroundStyle(Color.pencil)
            }
            Spacer()
        }
    }
}

private struct RoommateRow: View {
    let roommate: Roommate
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(initials(for: roommate.name))
                .font(.gaegu(size: 18))
                .frame(width: 40, height: 40)
                .background(Color.mint.opacity(0.6))
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.ink.opacity(0.5), lineWidth: 1.5))
                .foregroundStyle(Color.ink)

            VStack(alignment: .leading, spacing: 2) {
                Text(roommate.name)
                    .font(.gaegu(size: 20))
                    .foregroundStyle(Color.ink)
                Text(roommate.phoneNumber.isEmpty ? "No phone yet" : roommate.phoneNumber)
                    .font(.gaegu(size: 15))
                    .foregroundStyle(Color.pencil)
            }

            Spacer()

            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.coral)
            }
            .buttonStyle(SoftPressStyle())
            .accessibilityLabel("Remove \(roommate.name)")
        }
        .padding(12)
        .paperCard()
    }

    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ")
        let first = parts.first.map { String($0.prefix(1)) } ?? ""
        let second = parts.dropFirst().first.map { String($0.prefix(1)) } ?? ""
        return (first + second).uppercased()
    }
}

private struct AppearanceOptionRow: View {
    let option: AppAppearance
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .frame(width: 30)
                    .foregroundStyle(Color.ink)
                Text(option.settingsTitle)
                    .font(.gaegu(size: 20))
                    .foregroundStyle(Color.ink)
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.imessage : Color.pencil.opacity(0.4))
            }
            .padding(14)
            .background(Color.paperSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color.imessage : Color.ink.opacity(0.6), lineWidth: isSelected ? 2.5 : 1.5)
            )
        }
        .buttonStyle(SoftPressStyle())
    }

    private var icon: String {
        switch option {
        case .light: "sun.max.fill"
        case .dark: "moon.fill"
        case .system: "circle.lefthalf.filled"
        }
    }
}

private struct ThemeSwatchCard: View {
    let theme: ColorThemeName
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    swatch(dark: false)
                    swatch(dark: true)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.imessage)
                    }
                }
                Text(theme.title)
                    .font(.gaegu(size: 19))
                    .foregroundStyle(Color.ink)
                Text(theme.subtitle)
                    .font(.gaegu(size: 14))
                    .foregroundStyle(Color.pencil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color.paperSurface)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? Color.imessage : Color.ink.opacity(0.6), lineWidth: isSelected ? 2.5 : 1.5)
            )
            .shadow(color: Color.ink.opacity(isSelected ? 0.18 : 0.08), radius: isSelected ? 12 : 8, x: 0, y: isSelected ? 8 : 4)
        }
        .buttonStyle(SoftPressStyle())
    }

    @ViewBuilder
    private func swatch(dark: Bool) -> some View {
        let bg = Color(theme.paperBg(dark: dark))
        let surface = Color(theme.paperSurface(dark: dark))
        let ink = Color(theme.ink(dark: dark))
        ZStack {
            Circle()
                .fill(bg)
                .overlay(Circle().stroke(Color.ink.opacity(0.6), lineWidth: 1.5))
            Circle()
                .fill(surface)
                .frame(width: 16, height: 16)
                .overlay(Circle().stroke(ink, lineWidth: 1))
        }
        .frame(width: 32, height: 32)
    }
}

private struct AddRoommateSheet: View {
    let onCancel: () -> Void
    let onSave: (String, String) -> Void

    @State private var name = ""
    @State private var phone = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                PaperWashBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Add a roommate")
                            .font(.gaegu(size: 30))
                            .foregroundStyle(Color.ink)
                        Text("Their info stays on this device for now. Backend coming later.")
                            .font(.gaegu(size: 17))
                            .foregroundStyle(Color.pencil)

                        labeled("name") {
                            TextField("Alex Kim", text: $name)
                                .font(.gaegu(size: 22))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .paperCard(radius: 16)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.words)
                        }

                        labeled("phone number") {
                            TextField("(555) 010-2201", text: $phone)
                                .font(.gaegu(size: 22))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .paperCard(radius: 16)
                                .keyboardType(.phonePad)
                        }

                        if let errorMessage {
                            HStack(spacing: 6) {
                                Text("⚠️")
                                Text(errorMessage)
                                    .font(.gaegu(size: 17))
                            }
                            .foregroundStyle(Color.coral)
                        }

                        HStack(spacing: 14) {
                            Button("Add", action: validateAndSave)
                                .buttonStyle(StickerButtonStyle())
                            Button("Cancel", action: onCancel)
                                .buttonStyle(StickerButtonStyle(variant: .cream))
                        }
                    }
                    .padding(18)
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("New roommate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
            }
        }
    }

    private func labeled<Content: View>(_ label: String, @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.gaegu(size: 16))
                .foregroundStyle(Color.pencil)
            content()
        }
    }

    private func validateAndSave() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            errorMessage = "Pop a name in first."
            return
        }
        if trimmedPhone.isEmpty {
            errorMessage = "Add a phone number too."
            return
        }
        onSave(trimmedName, trimmedPhone)
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
        case .trips: "Trips"
        }
    }

    var defaultEmoji: String {
        switch self {
        case .document: "🏠"
        case .chores: "🧹"
        case .expenses: "💸"
        case .rules: "📜"
        case .roommates: "👥"
        case .trips: "✈️"
        }
    }
}
