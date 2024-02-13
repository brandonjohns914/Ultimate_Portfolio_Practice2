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
        .searchable(
            text: $dataController.filterText,
            tokens: $dataController.filterTokens,
            suggestedTokens: .constant(dataController.suggestedFilterTokens),
            prompt: "Select a Tag or write in the Issue Title"
        ) { tag in
            Text(tag.tagName)
        }
        .toolbar(content: ContentViewToolbar.init)
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
//
//#Preview {
//    ContentView()
//}
