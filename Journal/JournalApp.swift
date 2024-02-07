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
    
    /// Watch for if the app is moved out of active state
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                // first view 
                SidebarView()
            } content: {
                ContentView()
            } detail: {
                DetailView()
            }
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
                .onChange(of: scenePhase) { _ , phase in
                    if phase != .active {
                        dataController.save()
                    }
                }

        }
    }
}

/*
 managedObjectContext: Connects Core Data to SwiftUI tells by telling SwiftUI where to find the data
 
 
 */
