//
//  HwatgimApp.swift
//  Hwatgim
//

import SwiftUI
import SwiftData

@main
struct HwatgimApp: App {
    @State private var selectedTab: Int = 0

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(selectedTab: $selectedTab)
                .preferredColorScheme(.dark)
                .onOpenURL { url in
                    if url.scheme == "hwatgim" && url.host == "breathing" {
                        selectedTab = 0
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
