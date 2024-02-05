//
//  SidebarView.swift
//  Journal
//
//  Created by Brandon Johns on 2/4/24.
// Sidebar View: Primary view
//      Left most showing filters
//      default view when the app is loaded 
// Content View:  middle view showing issues
// Detail View: Showing one specific issue
//      Right most 
//      appears first in landscape mode

import SwiftUI

struct SidebarView: View {
    
    ///Creates the dataController
    @EnvironmentObject var dataController: DataController
    
    ///Two filtering view options
    let smartFilters: [Filter] = [.all, .recent]
    
    ///FetcheRequest loads all theTags from CoreData based on tag.name
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var tags: FetchedResults<Tag>

    /// Converts all Tags into Filter objects in an array.
    var tagFilters: [Filter] {
        tags.map { tag in
            Filter(id: tag.id ?? UUID(), name: tag.name ?? "No Name", icon: "tag", tag: tag)
        }
    }
    
    var body: some View {
        
        List(selection: $dataController.selectedFilter) {
            /// Listing out the Filters for the User decide .all or .recent
            Section("Smart Filters") {
                /// Sorts by tagFilters and the filter selected navigatates to a new view
                ForEach(smartFilters) { filter in
                    /// Takes the User to the filter picked
                    NavigationLink(value: filter) {
                        Label(filter.name, systemImage: filter.icon )
                    }
                }
            }
            ///Listing out Tags and filters changes the view based on if a tag was selected or not.
            Section("Tags") {
                ForEach(tagFilters) { filter in
                    NavigationLink(value: filter){
                        Label(filter.name, systemImage: filter.icon)
                    }
                }
            }
        }
        .toolbar {
            Button {
                dataController.deleteAll()
                dataController.createSampleData()
            } label : {
                Label("ADD SAMPLES", systemImage: "flame")
            }
        }
    }
}

#Preview {
    SidebarView()
        .environmentObject(DataController.preview)
}
