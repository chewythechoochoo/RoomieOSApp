import SwiftUI
import CoreText

@main
struct RoomieOSApp: App {
    init() {
        AppFontRegistrar.register("Gaegu-Regular", extension: "ttf")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

private enum AppFontRegistrar {
    static func register(_ name: String, extension fileExtension: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: fileExtension) else { return }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }
}
