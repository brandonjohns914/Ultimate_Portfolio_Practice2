//
//  DetailView.swift
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

/// Decides if there is an issue selected
/// If there is an Issue selected show IssueView
/// else show DetailView
struct DetailView: View {
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        VStack {
            /// send the selected Issue to IssueView
            if let issue = dataController.selectedIssue {
                IssueView(issue: issue)
            } else {
                NoIssueView()
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    DetailView()
}
