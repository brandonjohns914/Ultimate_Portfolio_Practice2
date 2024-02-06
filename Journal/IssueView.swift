//
//  IssueView.swift
//  Journal
//
//  Created by Brandon Johns on 2/5/24.
//

import SwiftUI

struct IssueView: View {
    @ObservedObject var issue: Issue
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    TextField("Title", text: $issue.issueTitle, prompt: Text("Enter the issue title here"))
                        .font(.title)
                    
                    Text("**Modified:** \(issue.issueModificationDate.formatted(date: .long, time: .shortened))")
                        .foregroundStyle(.secondary)
                }
                
                Picker("Priority", selection: $issue.priority) {
                    Text("Low")
                    Text("Medium")
                    Text("High")
                }
            }
        }
    }
}

#Preview {
    IssueView(issue: .example)
}
