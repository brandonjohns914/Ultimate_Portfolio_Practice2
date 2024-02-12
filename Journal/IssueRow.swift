//
//  IssueRow.swift
//  Journal
//
//  Created by Brandon Johns on 2/5/24.
//

import SwiftUI

struct IssueRow: View {
    ///Watching for changes coming in usually from iCloud
    @EnvironmentObject var dataController: DataController
    
    /// Local Changes to the issue right now
    /// Must be passed explicitly
    @ObservedObject var issue: Issue
    
    
    var body: some View {
        
        NavigationLink(value: issue) {
            HStack {
                /// Every row has the Image attached to
                /// issue.priority must be high to view the image
                /// its attached too all items because if its not on the low level priority it will cause row to shift
                Image(systemName: "exclamationmark.circle")
                    .imageScale(.large)
                    .opacity(issue.priority == 2 ? 1 : 0)
                
                VStack(alignment: .leading) {
                    Text(issue.issueTitle)
                        .font(.headline)
                        .lineLimit(1)

                    Text(issue.issueTagsList)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()
                ///CreationDate of the Issue and displays Closed if the issue is closed.
                VStack(alignment: .trailing) {
                    Text(issue.issueCreationDate.formatted(date: .abbreviated, time: .omitted))
                        .accessibilityLabel(issue.issueCreationDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)

                    if issue.completed {
                        Text("CLOSED")
                            .font(.body.smallCaps())
                    }
                }
                .foregroundStyle(.secondary)
            }
        }
        .accessibilityHint(issue.priority == 2 ? "High priority" : "")
    }
}

#Preview {
    IssueRow(issue: .example)
}
