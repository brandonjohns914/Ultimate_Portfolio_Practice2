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
    
    /// Filters Issues so if there is a Tag use if not find issues and sort
    var issues: [Issue] {
        /// Filter is the selected filter if not defaults to .all
        let filter = dataController.selectedFilter ?? .all
        
        var allIssues: [Issue]

        ///Tag attached to filter then filter by Tag first
        if let tag = filter.tag {
            ///Add the Tag issues to the array
            allIssues = tag.issues?.allObjects as? [Issue] ?? []
            
        } else {
            
            /// No Tags then fetch all issues if no issues then an empty array
            let request = Issue.fetchRequest()
            
            ///Requesting Issues based on the modificationDate based on the filter that is currently active
            request.predicate = NSPredicate(
                format: "modificationDate > %@",
                filter.minModificationDate as NSDate
            )
            allIssues = (try? dataController.container.viewContext.fetch(request)) ?? []
        }

        return allIssues.sorted()
    }
    
    
    var body: some View {
        List {
            /// Displays all the issues
            ForEach(issues) { issue in
                /// The selected issue is passed to IssueRow and changes the view 
                IssueRow(issue: issue)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Issues")
    }
    /// Deletes Issues
    func delete(_ offsets: IndexSet) {
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
