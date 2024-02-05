//
//  JournalApp.swift
//  Journal
//
//  Created by Brandon Johns on 2/4/24.
//

import SwiftUI

@main
struct JournalApp: App {
    /// Creates the dataController class which stays alive during the whole runtime of the app
    @StateObject var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
        }
    }
}

/*
 managedObjectContext: Connects Core Data to SwiftUI tells by telling SwiftUI where to find the data
 
 
 */
