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
    
    /// These state values are temporary
    @State private var tagToRename: Tag?
    @State private var renamingTag = false
    @State private var tagName = ""
    
    
    @State private var showingAwards = false
    
    
    /// Converts all Tags into Filter objects in an array.
    var tagFilters: [Filter] {
        tags.map { tag in
            Filter(id: tag.tagID, name: tag.tagName, icon: "tag", tag: tag)
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
                        ///Displays the tags and the number of active issues
                        Label(filter.name, systemImage: filter.icon)
                            .badge(filter.tag?.tagActiveIssues.count ?? 0)
                            .contextMenu {
                                Button {
                                    rename(filter)
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }
                            }
                    }
                } /// Swipe to delete
                .onDelete(perform: delete)
            }
        }
        .toolbar {
            Button(action: dataController.newTag) {
                Label("Add tag", systemImage: "plus")
            }
            
            Button {
                showingAwards.toggle()
            } label: {
                Label("Show awards", systemImage: "rosette")
            }

            //Only seen in debug wont be shown on the app store
    #if DEBUG
            Button {
                dataController.deleteAll()
                dataController.createSampleData()
            } label: {
                Label("ADD SAMPLES", systemImage: "flame")
            }
    #endif

        }
        .alert("Rename tag", isPresented: $renamingTag) {
            Button("OK", action: completeRename)
            Button("Cancel", role: .cancel) { }
            TextField("New name", text: $tagName)
        }
        .sheet(isPresented: $showingAwards, content: AwardsView.init)

    }
    /// Deletes Tags and the Issues associated with that Tag
    func delete(_ offsets: IndexSet) {
        for offset in offsets {
            let item = tags[offset]
            /// Calls the dataController.Delete function to delete the Tag out of core memory
            dataController.delete(item)
        }
    }
    
    /// Renaming the Tag
    /// filter is the Tag currently selected
    func rename(_ filter: Filter) {
        tagToRename = filter.tag
        tagName = filter.name
        renamingTag = true
    }
    
    /// Accepts the users rename
    func completeRename() {
        tagToRename?.name = tagName
        dataController.save()
    }
    
}

#Preview {
    SidebarView()
        .environmentObject(DataController.preview)
}
