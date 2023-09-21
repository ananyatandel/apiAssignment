//
//  apiAssignmentApp.swift
//  apiAssignment
//
//  Created by Ananya Tandel on 9/21/23.
//

import SwiftUI

@main
struct apiAssignmentApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            JokesView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
