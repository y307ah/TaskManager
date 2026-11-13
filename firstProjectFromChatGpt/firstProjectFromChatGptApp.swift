//
//  firstProjectFromChatGptApp.swift
//  firstProjectFromChatGpt
//
//  Created by Ярослав on 23.09.2026.
//

import SwiftUI
import SwiftData

@main
struct firstProjectFromChatGptApp: App {
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
            ContentViewPreviewWrapper()
        }
        .modelContainer(sharedModelContainer)
    }
}
