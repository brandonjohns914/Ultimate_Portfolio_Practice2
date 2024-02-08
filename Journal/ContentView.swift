//
//  ContentView.swift
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


struct ContentView: View {
    @EnvironmentObject var dataController: DataController
    
    
    var body: some View {
        List( selection: $dataController.selectedIssue) {
            /// Displays all the issues
            ForEach(dataController.issuesForSelectedFilter()) { issue in
                /// The selected issue is passed to IssueRow and changes the view
                IssueRow(issue: issue)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Issues")
        .searchable(text: $dataController.filterText, tokens: $dataController.filterTokens, suggestedTokens: .constant(dataController.suggestedFilterTokens), prompt: "Select a Tag or Type to find something else") { tag in
            Text(tag.tagName)
        }
        .toolbar {
            Menu {
                Button(dataController.filterEnabled ? "Turn Filter Off" : "Turn Filter On") {
                    dataController.filterEnabled.toggle()
                }

                Divider()

                Menu("Sort By") {
                    Picker("Sort By", selection: $dataController.sortType) {
                        Text("Date Created").tag(SortType.dateCreated)
                        Text("Date Modified").tag(SortType.dateModified)
                        Text("Title").tag(SortType.titleOrder)
                    }

                    Divider()
                    Picker("Sort Order", selection: $dataController.sortNewestFirst) {
                        Text("Newest to Oldest").tag(true)
                        Text("Oldest to Newest").tag(false)
                    }
  
                }
                
                    Picker("Status", selection: $dataController.filterStatus) {
                        Text("All").tag(Status.all)
                        Text("Open").tag(Status.open)
                        Text("Closed").tag(Status.closed)
                    }
                    .disabled(dataController.filterEnabled == false)
                    
                    
                    Picker("Priority", selection: $dataController.filterPriority) {
                        Text("All").tag(-1)
                        
                        Text("Low").tag(0)
                        Text("Medium").tag(1)
                        Text("High").tag(2)
                    }
                    .disabled(dataController.filterEnabled == false)
                    
              
                
            } label: {
                Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    .symbolVariant(dataController.filterEnabled ? .fill : .none)            }
            
        }
    }
    
    /// Deletes Issues
    func delete(_ offsets: IndexSet) {
        
        let issues = dataController.issuesForSelectedFilter()
        
        for offset in offsets {
            let item = issues[offset]
            /// Calls the dataController.Delete function to delete the Issue out of core memory
            dataController.delete(item)
        }
    }
    
}

#Preview {
    ContentView()
}
