//
//  To_Do_list_with_SwiftDataApp.swift
//  To Do list with SwiftData
//
//  Created by Harshit Agarwal on 20/12/23.
//

import SwiftUI
import SwiftData

@main
struct To_Do_list_with_SwiftDataApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            newLists.self,
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
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
