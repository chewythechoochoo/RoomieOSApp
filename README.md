# RoomieOS

Native SwiftUI/Xcode-only frontend prototype for RoomieOS. This version is an iOS-first Notion x iMessage hybrid with local sample data only.

## Implemented

- First-launch onboarding with welcome, intent chooser, household naming, template picker, first action, and success state.
- Day/night appearance toggle on the first onboarding screen.
- Starter workspace generation for Apartment OS, Chore Reset, and Bills & Supplies.
- Inbox tab with household activity, open chore count, unpaid expense count, swipe actions, and thread rows.
- Swipeable bottom navigation for Inbox and Expenses.
- Expenses analytics tab with a scrub-friendly spending graph, week/month/year ranges, comparison cards, member spending, and recent expenses.
- Thread/Page view with chat-style message bubbles, structured block bubbles, inline chore cards, inline expense cards, and roommate bubbles.
- Message-style composer with mode switching for messages, chores, expenses, and rules.
- Blue iOS/iMessage-style accent system, insert sheet, slash-style suggestions, local toasts, save prompt, and UI-only offline/conflict/read-only states.

No backend, npm, Expo, Docker, or third-party packages are included.

## Run

1. Open `RoomieOS.xcodeproj` in Xcode.
2. Select an iPhone simulator.
3. Press Run.

If the Simulator fails with `launchd failed to respond`, that is a local CoreSimulator/Xcode service issue rather than a RoomieOS code issue. Quit Xcode and Simulator, restart the Mac if needed, then reopen the project and run again.
